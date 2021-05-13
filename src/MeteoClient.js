.pragma library

//
var baseURL= 'http://webservice.meteofrance.com';
var token = '__Wj7dVSTjV9YGu1guveLyDq0g7S7TfTjaHBTPTpO0kj8__';
var UNSENT = 0; // initial state
var OPENED = 1; // open called
var HEADERS_RECEIVED = 2; // response headers received
var LOADING = 3; // response is loading (a data packet is received)
var DONE = 4; // request complete

function request(url, callback) {
    var xhr = new XMLHttpRequest();
    xhr.responseType = 'json';

    xhr.onreadystatechange = (function(myxhr) {
        return function() {
            if (xhr.readyState === LOADING) {
                // loading
            }
            if (xhr.readyState === DONE) {
                // request finished
                callback(myxhr.response);
            }

        }
    })(xhr);
    //console.debug('query: '+url);
    xhr.open('GET', baseURL+url+'&token='+token, true);
    xhr.send();
}

function pad(str){
    if(str.length === 1){
        return '0'+str;
    }
    return str;
}

function formatDate(timestamp){
    var date = new Date(timestamp * 1000);
    return [pad(String(date.getDate())),
            pad(String(date.getMonth()+1)),
            String(date.getFullYear()).substr(2, 2)].join("/");
}

function formatDatetime(timestamp){
    var date = new Date(timestamp * 1000);
    return  [pad(String(date.getHours())),
             pad(String(date.getMinutes()))].join(":");
}

function formatDateHourtime(timestamp){
    var date = new Date(timestamp * 1000);
    return  [pad(String(date.getDate())),
             pad(String(date.getMonth()+1)),
             String(date.getFullYear()).substr(2, 2)].join("/") + " " +
            [pad(String(date.getHours())),
             pad(String(date.getMinutes()))].join(":");
}

function Forecast(forecast){
    this.position = forecast.position;
    this.updated_on = forecast.updated_on;
    this.daily_forecast = forecast.daily_forecast;
    this.forecast = forecast.forecast;
    this.probability_forecast = forecast.probability_forecast;
}

Forecast.prototype.getDay = function(today){
    var tmp = this.forecast[today ? 0 : 24];
    return {
        Date: formatDateHourtime(tmp.dt), //timestamp
        Temperature: tmp.T.value,
        Humidity: tmp.humidity,
        Desc: tmp.weather.desc,
        Wind: 3 * Math.round(Math.pow(tmp.wind.speed, (3/2)))
    };
};

// Eliminer les accents
String.prototype.sansAccent = function(){
    var accent = [
        /[\300-\306]/g, /[\340-\346]/g, // A, a
        /[\310-\313]/g, /[\350-\353]/g, // E, e
        /[\314-\317]/g, /[\354-\357]/g, // I, i
        /[\322-\330]/g, /[\362-\370]/g, // O, o
        /[\331-\334]/g, /[\371-\374]/g, // U, u
        /[\321]/g, /[\361]/g, // N, n
        /[\307]/g, /[\347]/g, // C, c
    ];
    var noaccent = ['A','a','E','e','I','i','O','o','U','u','N','n','C','c'];

    var str = this;
    for(var i = 0; i < accent.length; i++){
        str = str.replace(accent[i], noaccent[i]);
    }

    return str;
}

// Obtenir la date sur 15 jours
Forecast.prototype.getXDaysData = function(start, end){
    var dates = []
    var tmp;
    for (var i=start; i<end; i++) {
        tmp = this.daily_forecast[i];
        if(tmp)
            dates.push({
                           SunRise: formatDatetime(tmp.sun.rise), //timestamp
                           SunSet: formatDatetime(tmp.sun.set), //timestamp
                           Date: formatDate(tmp.dt), //timestamp
                           TemperatureMax: tmp.T.max,
                           TemperatureMin: tmp.T.min,
                           HumidityMin: tmp.humidity.min,
                           HumidityMax: tmp.humidity.max,
                           Desc: tmp.weather12H.desc
                       })
    }
    return dates;
};

// Obtenir les 6 prochaines heures d'informations pour aujourd'hui ou demain
Forecast.prototype.getXHours = function(start, end){
    var dates = []
    var tmp;
    for (var i=start; i<end; i++) {
        tmp = this.forecast[i];
        if(tmp)
            dates.push({
                           Date: formatDatetime(tmp.dt),
                           Temperature: tmp.T.value,
                           Humidity: tmp.humidity,
                           Desc: tmp.weather.desc,
                           Wind: 3 * Math.round(Math.pow(tmp.wind.speed, (3/2)))
                       })
    }
    return dates;
};

var fetched = {
    getPosition: function(res){

        var xhr = new XMLHttpRequest();
        xhr.responseType = 'json';

        xhr.onreadystatechange = (function(myxhr) {
            return function() {
                if (xhr.readyState === LOADING) {
                    // loading
                }
                if (xhr.readyState === DONE) {
                    // request finished
                    res(myxhr.response);
                }

            }
        })(xhr);
        xhr.open('GET', 'https://ipv4.geojs.io/v1/ip/geo.json', true);
        xhr.send();

    },
    getPlaces: function(query, res) {
        request('/places?q='+encodeURIComponent(query), res);
    },

    getCity: function(query, res){
        api.getPlaces(query, function(cities){
            if (cities === null || cities.length <= 0)
                return res(null);
            var city = cities[0];
            if (city.postCode === null)
                return res(null);
            city.prettyName = city.name+' ('+city.postCode+')'
            res(city);
        })

    },

    getForecast: function(lat, lon, res) {
        request('/forecast?lat='+lat+'&lon='+lon, function(o){
            res(new Forecast(o));
        })
    }

};

var api = fetched;
