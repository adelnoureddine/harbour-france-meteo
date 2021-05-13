import QtQuick 2.0
import QtQml 2.0

import Sailfish.Silica 1.0
import "qrc:/MeteoClient.js" as MeteoClient

Page {
    id: mainPage

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height + Theme.paddingLarge

        Column {
            id: column
            width: parent.width
            // Accès à "propos"
            PullDownMenu{

                MenuItem {
                    text: "A propos"
                    onClicked: pageStack.animatorPush(propos, {}, PageStackAction.Animated)
                }
            }
            // Activer/Désactiver la géolocalisation
            TextSwitch {

                SectionHeader {
                    text: "Météo"
                }

                id: geolocation
                text: "Activer la géolocalisation"
                anchors.left: parent.left
                checked: true
                Component.onCompleted: {
                    if (menu.currentIndex === 1) {
                        today.visible = false;
                        tomorrow.visible = true;
                        days.visible = false;
                    } else if (menu.currentIndex === 0){
                        today.visible = true;
                        tomorrow.visible = false;
                        days.visible = false;
                    } else if (menu.currentIndex === 2){
                        today.visible = false;
                        tomorrow.visible = false;
                        days.visible = true;
                    }
                    geolocation.text = "Désactiver la géolocalisation"
                    //console.log('getPosition')
                    MeteoClient.api.getPosition(function(geoapi){
                        mainPage.updateCity(geoapi.latitude, geoapi.longitude);
                    });
                }
                onCheckedChanged: {busy = true; textBusyTimer.start()}
                onClicked: function geoloc() {
                    //console.log('clicked')

                    if(checked) {
                        if (menu.currentIndex === 1) {
                            today.visible = false;
                            tomorrow.visible = true;
                            days.visible = false;
                        } else if (menu.currentIndex === 0){
                            today.visible = true;
                            tomorrow.visible = false;
                            days.visible = false;
                        } else if (menu.currentIndex === 2){
                            today.visible = false;
                            tomorrow.visible = false;
                            days.visible = true;
                        }
                        geolocation.text = "Désactiver la géolocalisation"
                        //console.log('getPosition')
                        MeteoClient.api.getPosition(function(geoapi){
                            mainPage.updateCity(geoapi.latitude, geoapi.longitude);
                        });

                    } else {
                        geolocation.text = "Activer la géolocalisation"
                        today.visible = false;
                        tomorrow.visible = false;
                        days.visible = false;
                        menu.enabled = false;
                    }
                }
                Timer {
                    id: textBusyTimer
                    interval: 2000
                    onTriggered: parent.busy = false

                }
            }
            // La barre de recherche
            Row {
                width: parent.width
                TextField {
                    id: query
                    width: parent.width
                    placeholderText: "Saisir le nom de la ville"
                    font.pixelSize: Theme.fontSizeExtraLarge
                    labelVisible: false
                    EnterKey.onClicked: focus = false
                    onClicked: query.text = ""
                }
            }
            // Bouton de recherche
            Row {
                anchors.horizontalCenter: parent.horizontalCenter

                Button {
                    text: "Rechercher"

                    onClicked: function update() {

                        if (menu.currentIndex === 1) {
                            today.visible = false;
                            tomorrow.visible = true;
                            days.visible = false;
                        } else if (menu.currentIndex === 0){
                            today.visible = true;
                            tomorrow.visible = false;
                            days.visible = false;
                        } else if (menu.currentIndex === 2){
                            today.visible = false;
                            tomorrow.visible = false;
                            days.visible = true;
                        }
                        today_city.text = ''
                        // Les informations de demain
                        tomorrow_city.text= ''
                        // Les informations
                        MeteoClient.api.getCity(query.text, function(city){
                            mainPage.updateCity(city && city.lat, city && city.lon);
                        });

                    }
                }
            }
            // Accèder aux informations d'aujourd'hui/demain/15 jours
            ComboBox {
                id: menu
                label: "Informations"
                enabled: false
                currentIndex: 0
                menu: ContextMenu {
                    MenuItem { text: "Aujourd'hui"; font.pixelSize: Theme.fontSizeLarge }
                    MenuItem { text: "Demain"; font.pixelSize: Theme.fontSizeLarge }
                    MenuItem { text: "15 jours"; font.pixelSize: Theme.fontSizeLarge }
                }
                onCurrentIndexChanged: function options(){
                    if (currentIndex === 1) {
                        today.visible = false;
                        tomorrow.visible = true;
                        days.visible = false;
                    } else if (currentIndex === 0){
                        today.visible = true;
                        tomorrow.visible = false;
                        days.visible = false;
                    } else if (currentIndex === 2){
                        today.visible = false;
                        tomorrow.visible = false;
                        days.visible = true;
                    }
                }
            }

            // Les informations d'aujourd'hui
            Column {

                id: today
                width: parent.width
                spacing: Theme.paddingLarge
                visible: false
                // Afficher la ville
                Label {
                    id: today_city
                    text: ""
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.family: Theme.fontFamilyHeading
                    font.bold: true
                    font.pixelSize: Theme.fontSizeLarge
                }
                // Afficher la date de mise à jour
                Label {
                    id: today_date
                    text: ""
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.family: Theme.fontFamilyHeading
                    font.bold: true
                    font.pixelSize: Theme.fontSizeLarge
                }

                Row {

                    spacing: Theme.paddingLarge

                    anchors.horizontalCenter: parent.horizontalCenter
                    // Logo + Description
                    Column {

                        anchors.verticalCenter: parent.verticalCenter
                        spacing: Theme.paddingLarge

                        Icon {
                            id: today_logo
                            source: "image://theme/icon-l-dismiss"
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        Label {
                            id: today_desc
                            text: ""
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.family: Theme.fontFamilyHeading
                            font.bold: true
                            font.pixelSize: Theme.fontSizeLarge
                        }

                    }
                    // Température + Humidité + Vent
                    Column {

                        id : info_column
                        anchors.verticalCenter: parent.verticalCenter

                        Label {
                            text: "Température  "
                            font.family: Theme.fontFamilyHeading
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.pixelSize: Theme.fontSizeLarge
                            font.bold: true
                        }

                        Label {
                            id: today_temperature
                            text: ""
                            font.family: Theme.fontFamilyHeading
                            font.italic: true
                            font.bold: true
                            font.pixelSize: Theme.fontSizeLarge
                        }

                        Label {
                            text: "Humidité  "
                            font.family: Theme.fontFamilyHeading
                            font.bold: true
                            font.pixelSize: Theme.fontSizeLarge
                        }

                        Label {
                            id: today_humidity
                            text: ""
                            font.family: Theme.fontFamilyHeading
                            font.italic: true
                            font.bold: true
                            font.pixelSize: Theme.fontSizeLarge
                        }

                        Label {
                            text: "Vent  "
                            font.family: Theme.fontFamilyHeading
                            font.bold: true
                            font.pixelSize: Theme.fontSizeLarge
                        }

                        Label {
                            id: today_wind
                            text: ""
                            font.family: Theme.fontFamilyHeading
                            font.italic: true
                            font.bold: true
                            font.pixelSize: Theme.fontSizeLarge
                        }
                    }
                }

                Row {

                    spacing: Theme.paddingSmall

                    anchors.horizontalCenter: parent.horizontalCenter
                    // Afficher par colonne les informations sur 6 heures
                    Column {

                        spacing: Theme.paddingLarge

                        Label{
                            id: today_date_hour0
                            text: "18h00"
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.bold: true
                            font.pixelSize: Theme.fontSizeExtraSmall
                        }

                        Icon {
                            id: today_icon_hour0
                            source: "image://theme/icon-l-dismiss"
                            anchors.horizontalCenter: parent.horizontalCenter
                            sourceSize.width: Theme.iconSizeMedium
                            sourceSize.height: Theme.iconSizeMedium

                        }

                        Label{
                            id: today_temp_hour0
                            text: "20°C"
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.bold: true
                            font.pixelSize: Theme.fontSizeExtraSmall                        }

                        Label{
                            id: today_wind_hour0
                            text: "20 km/h"
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.bold: true
                            font.pixelSize: Theme.fontSizeExtraSmall
                        }
                    }

                    Column {

                        spacing: Theme.paddingLarge

                        Label{
                            id: today_date_hour1
                            text: "18h00"
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.bold: true
                            font.pixelSize: Theme.fontSizeExtraSmall
                        }

                        Icon {
                            id: today_icon_hour1
                            source: "image://theme/icon-l-dismiss"
                            anchors.horizontalCenter: parent.horizontalCenter
                            sourceSize.width: Theme.iconSizeMedium
                            sourceSize.height: Theme.iconSizeMedium

                        }

                        Label{
                            id: today_temp_hour1
                            text: "20°C"
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.bold: true
                            font.pixelSize: Theme.fontSizeExtraSmall
                        }

                        Label{
                            id: today_wind_hour1
                            text: "20 km/h"
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.bold: true
                            font.pixelSize: Theme.fontSizeExtraSmall
                        }
                    }

                    Column {

                        spacing: Theme.paddingLarge

                        Label{
                            id: today_date_hour2
                            text: "18h00"
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.bold: true
                            font.pixelSize: Theme.fontSizeExtraSmall
                        }

                        Icon {
                            id: today_icon_hour2
                            source: "image://theme/icon-l-dismiss"
                            anchors.horizontalCenter: parent.horizontalCenter
                            sourceSize.width: Theme.iconSizeMedium
                            sourceSize.height: Theme.iconSizeMedium

                        }

                        Label{
                            id: today_temp_hour2
                            text: "20°C"
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.bold: true
                            font.pixelSize: Theme.fontSizeExtraSmall
                        }

                        Label{
                            id: today_wind_hour2
                            text: "20 km/h"
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.bold: true
                            font.pixelSize: Theme.fontSizeExtraSmall
                        }
                    }

                    Column {

                        spacing: Theme.paddingLarge

                        Label{
                            id: today_date_hour3
                            text: "18h00"
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.bold: true
                            font.pixelSize: Theme.fontSizeExtraSmall
                        }

                        Icon {
                            id: today_icon_hour3
                            source: "image://theme/icon-l-dismiss"
                            anchors.horizontalCenter: parent.horizontalCenter
                            sourceSize.width: Theme.iconSizeMedium
                            sourceSize.height: Theme.iconSizeMedium

                        }

                        Label{
                            id: today_temp_hour3
                            text: "20°C"
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.bold: true
                            font.pixelSize: Theme.fontSizeExtraSmall
                        }

                        Label{
                            id: today_wind_hour3
                            text: "20 km/h"
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.bold: true
                            font.pixelSize: Theme.fontSizeExtraSmall
                        }
                    }

                    Column {

                        spacing: Theme.paddingLarge

                        Label{
                            id: today_date_hour4
                            text: "18h00"
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.bold: true
                            font.pixelSize: Theme.fontSizeExtraSmall
                        }

                        Icon {
                            id: today_icon_hour4
                            source: "image://theme/icon-l-dismiss"
                            anchors.horizontalCenter: parent.horizontalCenter
                            sourceSize.width: Theme.iconSizeMedium
                            sourceSize.height: Theme.iconSizeMedium

                        }

                        Label{
                            id: today_temp_hour4
                            text: "20°C"
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.bold: true
                            font.pixelSize: Theme.fontSizeExtraSmall
                        }

                        Label{
                            id: today_wind_hour4
                            text: "20 km/h"
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.bold: true
                            font.pixelSize: Theme.fontSizeExtraSmall
                        }
                    }

                    Column {

                        spacing: Theme.paddingLarge

                        Label{
                            id: today_date_hour5
                            text: "18h00"
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.bold: true
                            font.pixelSize: Theme.fontSizeExtraSmall
                        }

                        Icon {
                            id: today_icon_hour5
                            source: "image://theme/icon-l-dismiss"
                            anchors.horizontalCenter: parent.horizontalCenter
                            sourceSize.width: Theme.iconSizeMedium
                            sourceSize.height: Theme.iconSizeMedium

                        }

                        Label{
                            id: today_temp_hour5
                            text: "20°C"
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.bold: true
                            font.pixelSize: Theme.fontSizeExtraSmall
                        }

                        Label{
                            id: today_wind_hour5
                            text: "20 km/h"
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.bold: true
                            font.pixelSize: Theme.fontSizeExtraSmall
                        }
                    }
                }
            }
            // Les informations du lendemain
            Column {

                id: tomorrow
                width: parent.width
                spacing: Theme.paddingLarge
                visible: false
                // Afficher la ville
                Label {
                    id: tomorrow_city
                    text: ""
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.family: Theme.fontFamilyHeading
                    font.bold: true
                    font.pixelSize: Theme.fontSizeLarge
                }
                // Afficher la date 24h après celle d'aujourd'hui
                Label {
                    id: tomorrow_date
                    text: ""
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.family: Theme.fontFamilyHeading
                    font.bold: true
                    font.pixelSize: Theme.fontSizeLarge
                }

                Row {

                    spacing: Theme.paddingLarge

                    anchors.horizontalCenter: parent.horizontalCenter
                    // Logo + Description
                    Column {

                        anchors.verticalCenter: parent.verticalCenter
                        spacing: Theme.paddingLarge

                        Icon {
                            id: tomorrow_logo
                            source: "image://theme/icon-l-dismiss"
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        Label {
                            id: tomorrow_desc
                            text: ""
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.family: Theme.fontFamilyHeading
                            font.bold: true
                            font.pixelSize: Theme.fontSizeLarge
                        }

                    }
                    // Température + Humidité + Vent
                    Column {

                        anchors.verticalCenter: parent.verticalCenter

                        Label {
                            text: "Température  "
                            font.family: Theme.fontFamilyHeading
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.bold: true
                            font.pixelSize: Theme.fontSizeLarge
                        }

                        Label {
                            id: tomorrow_temperature
                            text: ""
                            font.family: Theme.fontFamilyHeading
                            font.italic: true
                            font.bold: true
                            font.pixelSize: Theme.fontSizeLarge
                        }

                        Label {
                            text: "Humidité  "
                            font.family: Theme.fontFamilyHeading
                            font.bold: true
                            font.pixelSize: Theme.fontSizeLarge
                        }

                        Label {
                            id: tomorrow_humidity
                            text: ""
                            font.family: Theme.fontFamilyHeading
                            font.italic: true
                            font.bold: true
                            font.pixelSize: Theme.fontSizeLarge
                        }

                        Label {
                            text: "Vent  "
                            font.family: Theme.fontFamilyHeading
                            font.bold: true
                            font.pixelSize: Theme.fontSizeLarge
                        }

                        Label {
                            id: tomorrow_wind
                            text: ""
                            font.family: Theme.fontFamilyHeading
                            font.italic: true
                            font.bold: true
                            font.pixelSize: Theme.fontSizeLarge
                        }
                    }
                }

                Row {

                    spacing: Theme.paddingSmall

                    anchors.horizontalCenter: parent.horizontalCenter
                    // Afficher par colonne les informations sur les 6 prochaines heures du lendemain
                    Column {

                        spacing: Theme.paddingLarge

                        Label{
                            id: tomorrow_date_hour0
                            text: "18h00"
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.bold: true
                            font.pixelSize: Theme.fontSizeExtraSmall
                        }

                        Icon {
                            id: tomorrow_icon_hour0
                            source: "image://theme/icon-l-dismiss"
                            anchors.horizontalCenter: parent.horizontalCenter
                            sourceSize.width: Theme.iconSizeMedium
                            sourceSize.height: Theme.iconSizeMedium

                        }

                        Label{
                            id: tomorrow_temp_hour0
                            text: "20°C"
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.bold: true
                            font.pixelSize: Theme.fontSizeExtraSmall
                        }

                        Label{
                            id: tomorrow_wind_hour0
                            text: "20 km/h"
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.bold: true
                            font.pixelSize: Theme.fontSizeExtraSmall
                        }
                    }

                    Column {

                        spacing: Theme.paddingLarge

                        Label{
                            id: tomorrow_date_hour1
                            text: "18h00"
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.bold: true
                            font.pixelSize: Theme.fontSizeExtraSmall
                        }

                        Icon {
                            id: tomorrow_icon_hour1
                            source: "image://theme/icon-l-dismiss"
                            anchors.horizontalCenter: parent.horizontalCenter
                            sourceSize.width: Theme.iconSizeMedium
                            sourceSize.height: Theme.iconSizeMedium

                        }

                        Label{
                            id: tomorrow_temp_hour1
                            text: "20°C"
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.bold: true
                            font.pixelSize: Theme.fontSizeExtraSmall
                        }

                        Label{
                            id: tomorrow_wind_hour1
                            text: "20 km/h"
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.bold: true
                            font.pixelSize: Theme.fontSizeExtraSmall
                        }
                    }

                    Column {

                        spacing: Theme.paddingLarge

                        Label{
                            id: tomorrow_date_hour2
                            text: "18h00"
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.bold: true
                            font.pixelSize: Theme.fontSizeExtraSmall
                        }

                        Icon {
                            id: tomorrow_icon_hour2
                            source: "image://theme/icon-l-dismiss"
                            anchors.horizontalCenter: parent.horizontalCenter
                            sourceSize.width: Theme.iconSizeMedium
                            sourceSize.height: Theme.iconSizeMedium

                        }

                        Label{
                            id: tomorrow_temp_hour2
                            text: "20°C"
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.bold: true
                            font.pixelSize: Theme.fontSizeExtraSmall
                        }

                        Label{
                            id: tomorrow_wind_hour2
                            text: "20 km/h"
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.bold: true
                            font.pixelSize: Theme.fontSizeExtraSmall
                        }
                    }

                    Column {

                        spacing: Theme.paddingLarge

                        Label{
                            id: tomorrow_date_hour3
                            text: "18h00"
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.bold: true
                            font.pixelSize: Theme.fontSizeExtraSmall
                        }

                        Icon {
                            id: tomorrow_icon_hour3
                            source: "image://theme/icon-l-dismiss"
                            anchors.horizontalCenter: parent.horizontalCenter
                            sourceSize.width: Theme.iconSizeMedium
                            sourceSize.height: Theme.iconSizeMedium

                        }

                        Label{
                            id: tomorrow_temp_hour3
                            text: "20°C"
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.bold: true
                            font.pixelSize: Theme.fontSizeExtraSmall
                        }

                        Label{
                            id: tomorrow_wind_hour3
                            text: "20 km/h"
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.bold: true
                            font.pixelSize: Theme.fontSizeExtraSmall
                        }
                    }

                    Column {

                        spacing: Theme.paddingLarge

                        Label{
                            id: tomorrow_date_hour4
                            text: "18h00"
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.bold: true
                            font.pixelSize: Theme.fontSizeExtraSmall
                        }

                        Icon {
                            id: tomorrow_icon_hour4
                            source: "image://theme/icon-l-dismiss"
                            anchors.horizontalCenter: parent.horizontalCenter
                            sourceSize.width: Theme.iconSizeMedium
                            sourceSize.height: Theme.iconSizeMedium

                        }

                        Label{
                            id: tomorrow_temp_hour4
                            text: "20°C"
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.bold: true
                            font.pixelSize: Theme.fontSizeExtraSmall
                        }

                        Label{
                            id: tomorrow_wind_hour4
                            text: "20 km/h"
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.bold: true
                            font.pixelSize: Theme.fontSizeExtraSmall
                        }
                    }

                    Column {

                        spacing: Theme.paddingLarge

                        Label{
                            id: tomorrow_date_hour5
                            text: "18h00"
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.bold: true
                            font.pixelSize: Theme.fontSizeExtraSmall
                        }

                        Icon {
                            id: tomorrow_icon_hour5
                            source: "image://theme/icon-l-dismiss"
                            anchors.horizontalCenter: parent.horizontalCenter
                            sourceSize.width: Theme.iconSizeMedium
                            sourceSize.height: Theme.iconSizeMedium

                        }

                        Label{
                            id: tomorrow_temp_hour5
                            text: "20°C"
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.bold: true
                            font.pixelSize: Theme.fontSizeExtraSmall
                        }

                        Label{
                            id: tomorrow_wind_hour5
                            text: "20 km/h"
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.bold: true
                            font.pixelSize: Theme.fontSizeExtraSmall
                        }
                    }
                }                }
            // Les informations sur 15 jours
            Column {
                id: days
                visible: false
                spacing: Theme.paddingLarge
                width: parent.width
                // Afficher la ville
                Label {
                    id: day_city
                    text: ""
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.family: Theme.fontFamilyHeading
                    font.bold: true
                    font.pixelSize: Theme.fontSizeLarge
                }
                // On dispose de 5 rangées de 3 colonnes chacune
                Row {

                    spacing: Theme.paddingLarge
                    anchors.horizontalCenter: parent.horizontalCenter
                    // Chaque colonne est attribué aux informations du jour correspondant
                    Column{

                        anchors.verticalCenter: parent.verticalCenter

                        Label {
                            id: day_date1
                            text: "Jour 1"
                            font.family: Theme.fontFamilyHeading
                            font.pixelSize: Theme.fontSizeExtraSmall
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.bold: true
                        }

                        Icon {
                            id: day_logo1
                            source: "image://theme/icon-l-dismiss"
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        Label {
                            id: day_desc1
                            text: "Ensoleille"
                            font.family: Theme.fontFamilyHeading
                            font.pixelSize: Theme.fontSizeExtraSmall
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.bold: true
                        }

                        Label {
                            id: day_temperature1
                            text: 12 + "°C - "+ 15 + "°C"
                            font.family: Theme.fontFamilyHeading
                            font.pixelSize: Theme.fontSizeExtraSmall
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.bold: true
                        }

                        Label {
                            id: day_humidity1
                            text: 12 + "% - " + 15 + "%"
                            font.family: Theme.fontFamilyHeading
                            font.pixelSize: Theme.fontSizeExtraSmall
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.bold: true
                        }


                    }

                    Column{

                        anchors.verticalCenter: parent.verticalCenter

                        Label {
                            id: day_date2
                            text: "Jour 2"
                            font.family: Theme.fontFamilyHeading
                            font.pixelSize: Theme.fontSizeExtraSmall
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.bold: true
                        }

                        Icon {
                            id: day_logo2
                            source: "image://theme/icon-l-dismiss"
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        Label {
                            id: day_desc2
                            text: "Ensoleille"
                            font.family: Theme.fontFamilyHeading
                            font.pixelSize: Theme.fontSizeExtraSmall
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.bold: true
                        }

                        Label {
                            id: day_temperature2
                            text: 12 + "°C - "+ 15 + "°C"
                            font.family: Theme.fontFamilyHeading
                            font.pixelSize: Theme.fontSizeExtraSmall
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.bold: true
                        }

                        Label {
                            id: day_humidity2
                            text: 12 + "% - " + 15 + "%"
                            font.family: Theme.fontFamilyHeading
                            font.pixelSize: Theme.fontSizeExtraSmall
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.bold: true
                        }


                    }

                    Column{

                        anchors.verticalCenter: parent.verticalCenter

                        Label {
                            id: day_date3
                            text: "Jour 3"
                            font.family: Theme.fontFamilyHeading
                            font.pixelSize: Theme.fontSizeExtraSmall
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.bold: true
                        }

                        Icon {
                            id: day_logo3
                            source: "image://theme/icon-l-dismiss"
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        Label {
                            id: day_desc3
                            text: "Ensoleille"
                            font.family: Theme.fontFamilyHeading
                            font.pixelSize: Theme.fontSizeExtraSmall
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.bold: true
                        }

                        Label {
                            id: day_temperature3
                            text: 12 + "°C - "+ 15 + "°C"
                            font.family: Theme.fontFamilyHeading
                            font.pixelSize: Theme.fontSizeExtraSmall
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.bold: true
                        }

                        Label {
                            id: day_humidity3
                            text: 12 + "% - " + 15 + "%"
                            font.family: Theme.fontFamilyHeading
                            font.pixelSize: Theme.fontSizeExtraSmall
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.bold: true
                        }


                    }
                }

                Row {

                    spacing: Theme.paddingLarge
                    anchors.horizontalCenter: parent.horizontalCenter

                    Column{

                        anchors.verticalCenter: parent.verticalCenter

                        Label {
                            id: day_date4
                            text: "Jour 4"
                            font.family: Theme.fontFamilyHeading
                            font.pixelSize: Theme.fontSizeExtraSmall
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.bold: true
                        }

                        Icon {
                            id: day_logo4
                            source: "image://theme/icon-l-dismiss"
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        Label {
                            id: day_desc4
                            text: "Ensoleille"
                            font.family: Theme.fontFamilyHeading
                            font.pixelSize: Theme.fontSizeExtraSmall
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.bold: true
                        }

                        Label {
                            id: day_temperature4
                            text: 12 + "°C - "+ 15 + "°C"
                            font.family: Theme.fontFamilyHeading
                            font.pixelSize: Theme.fontSizeExtraSmall
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.bold: true
                        }

                        Label {
                            id: day_humidity4
                            text: 12 + "% - " + 15 + "%"
                            font.family: Theme.fontFamilyHeading
                            font.pixelSize: Theme.fontSizeExtraSmall
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.bold: true
                        }


                    }

                    Column{

                        anchors.verticalCenter: parent.verticalCenter

                        Label {
                            id: day_date5
                            text: "Jour 5"
                            font.family: Theme.fontFamilyHeading
                            font.pixelSize: Theme.fontSizeExtraSmall
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.bold: true
                        }

                        Icon {
                            id: day_logo5
                            source: "image://theme/icon-l-dismiss"
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        Label {
                            id: day_desc5
                            text: "Ensoleille"
                            font.family: Theme.fontFamilyHeading
                            font.pixelSize: Theme.fontSizeExtraSmall
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.bold: true
                        }

                        Label {
                            id: day_temperature5
                            text: 12 + "°C - "+ 15 + "°C"
                            font.family: Theme.fontFamilyHeading
                            font.pixelSize: Theme.fontSizeExtraSmall
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.bold: true
                        }

                        Label {
                            id: day_humidity5
                            text: 12 + "% - " + 15 + "%"
                            font.family: Theme.fontFamilyHeading
                            font.pixelSize: Theme.fontSizeExtraSmall
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.bold: true
                        }


                    }

                    Column{

                        anchors.verticalCenter: parent.verticalCenter

                        Label {
                            id: day_date6
                            text: "Jour 6"
                            font.family: Theme.fontFamilyHeading
                            font.pixelSize: Theme.fontSizeExtraSmall
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.bold: true
                        }

                        Icon {
                            id: day_logo6
                            source: "image://theme/icon-l-dismiss"
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        Label {
                            id: day_desc6
                            text: "Ensoleille"
                            font.family: Theme.fontFamilyHeading
                            font.pixelSize: Theme.fontSizeExtraSmall
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.bold: true
                        }

                        Label {
                            id: day_temperature6
                            text: 12 + "°C - "+ 15 + "°C"
                            font.family: Theme.fontFamilyHeading
                            font.pixelSize: Theme.fontSizeExtraSmall
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.bold: true
                        }

                        Label {
                            id: day_humidity6
                            text: 12 + "% - " + 15 + "%"
                            font.family: Theme.fontFamilyHeading
                            font.pixelSize: Theme.fontSizeExtraSmall
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.bold: true
                        }


                    }
                }

                Row {

                    spacing: Theme.paddingLarge
                    anchors.horizontalCenter: parent.horizontalCenter

                    Column{

                        anchors.verticalCenter: parent.verticalCenter

                        Label {
                            id: day_date7
                            text: "Jour 7"
                            font.family: Theme.fontFamilyHeading
                            font.pixelSize: Theme.fontSizeExtraSmall
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.bold: true
                        }

                        Icon {
                            id: day_logo7
                            source: "image://theme/icon-l-dismiss"
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        Label {
                            id: day_desc7
                            text: "Ensoleille"
                            font.family: Theme.fontFamilyHeading
                            font.pixelSize: Theme.fontSizeExtraSmall
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.bold: true
                        }

                        Label {
                            id: day_temperature7
                            text: 12 + "°C - "+ 15 + "°C"
                            font.family: Theme.fontFamilyHeading
                            font.pixelSize: Theme.fontSizeExtraSmall
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.bold: true
                        }

                        Label {
                            id: day_humidity7
                            text: 12 + "% - " + 15 + "%"
                            font.family: Theme.fontFamilyHeading
                            font.pixelSize: Theme.fontSizeExtraSmall
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.bold: true
                        }


                    }

                    Column{

                        anchors.verticalCenter: parent.verticalCenter

                        Label {
                            id: day_date8
                            text: "Jour 8"
                            font.family: Theme.fontFamilyHeading
                            font.pixelSize: Theme.fontSizeExtraSmall
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.bold: true
                        }

                        Icon {
                            id: day_logo8
                            source: "image://theme/icon-l-dismiss"
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        Label {
                            id: day_desc8
                            text: "Ensoleille"
                            font.family: Theme.fontFamilyHeading
                            font.pixelSize: Theme.fontSizeExtraSmall
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.bold: true
                        }

                        Label {
                            id: day_temperature8
                            text: 12 + "°C - "+ 15 + "°C"
                            font.family: Theme.fontFamilyHeading
                            font.pixelSize: Theme.fontSizeExtraSmall
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.bold: true
                        }

                        Label {
                            id: day_humidity8
                            text: 12 + "% - " + 15 + "%"
                            font.family: Theme.fontFamilyHeading
                            font.pixelSize: Theme.fontSizeExtraSmall
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.bold: true
                        }


                    }

                    Column{

                        anchors.verticalCenter: parent.verticalCenter

                        Label {
                            id: day_date9
                            text: "Jour 9"
                            font.family: Theme.fontFamilyHeading
                            font.pixelSize: Theme.fontSizeExtraSmall
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.bold: true
                        }

                        Icon {
                            id: day_logo9
                            source: "image://theme/icon-l-dismiss"
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        Label {
                            id: day_desc9
                            text: "Ensoleille"
                            font.family: Theme.fontFamilyHeading
                            font.pixelSize: Theme.fontSizeExtraSmall
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.bold: true
                        }

                        Label {
                            id: day_temperature9
                            text: 12 + "°C - "+ 15 + "°C"
                            font.family: Theme.fontFamilyHeading
                            font.pixelSize: Theme.fontSizeExtraSmall
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.bold: true
                        }

                        Label {
                            id: day_humidity9
                            text: 12 + "% - " + 15 + "%"
                            font.family: Theme.fontFamilyHeading
                            font.pixelSize: Theme.fontSizeExtraSmall
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.bold: true
                        }


                    }
                }

                Row {

                    spacing: Theme.paddingLarge
                    anchors.horizontalCenter: parent.horizontalCenter

                    Column{

                        anchors.verticalCenter: parent.verticalCenter

                        Label {
                            id: day_date10
                            text: "Jour 10"
                            font.family: Theme.fontFamilyHeading
                            font.pixelSize: Theme.fontSizeExtraSmall
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.bold: true
                        }

                        Icon {
                            id: day_logo10
                            source: "image://theme/icon-l-dismiss"
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        Label {
                            id: day_desc10
                            text: "Ensoleille"
                            font.family: Theme.fontFamilyHeading
                            font.pixelSize: Theme.fontSizeExtraSmall
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.bold: true
                        }

                        Label {
                            id: day_temperature10
                            text: 12 + "°C - "+ 15 + "°C"
                            font.family: Theme.fontFamilyHeading
                            font.pixelSize: Theme.fontSizeExtraSmall
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.bold: true
                        }

                        Label {
                            id: day_humidity10
                            text: 12 + "% - " + 15 + "%"
                            font.family: Theme.fontFamilyHeading
                            font.pixelSize: Theme.fontSizeExtraSmall
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.bold: true
                        }


                    }

                    Column{

                        anchors.verticalCenter: parent.verticalCenter

                        Label {
                            id: day_date11
                            text: "Jour 11"
                            font.family: Theme.fontFamilyHeading
                            font.pixelSize: Theme.fontSizeExtraSmall
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.bold: true
                        }

                        Icon {
                            id: day_logo11
                            source: "image://theme/icon-l-dismiss"
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        Label {
                            id: day_desc11
                            text: "Ensoleille"
                            font.family: Theme.fontFamilyHeading
                            font.pixelSize: Theme.fontSizeExtraSmall
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.bold: true
                        }

                        Label {
                            id: day_temperature11
                            text: 12 + "°C - "+ 15 + "°C"
                            font.family: Theme.fontFamilyHeading
                            font.pixelSize: Theme.fontSizeExtraSmall
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.bold: true
                        }

                        Label {
                            id: day_humidity11
                            text: 12 + "% - " + 15 + "%"
                            font.family: Theme.fontFamilyHeading
                            font.pixelSize: Theme.fontSizeExtraSmall
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.bold: true
                        }


                    }

                    Column{

                        anchors.verticalCenter: parent.verticalCenter

                        Label {
                            id: day_date12
                            text: "Jour 12"
                            font.family: Theme.fontFamilyHeading
                            font.pixelSize: Theme.fontSizeExtraSmall
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.bold: true
                        }

                        Icon {
                            id: day_logo12
                            source: "image://theme/icon-l-dismiss"
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        Label {
                            id: day_desc12
                            text: "Ensoleille"
                            font.family: Theme.fontFamilyHeading
                            font.pixelSize: Theme.fontSizeExtraSmall
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.bold: true
                        }

                        Label {
                            id: day_temperature12
                            text: 12 + "°C - "+ 15 + "°C"
                            font.family: Theme.fontFamilyHeading
                            font.pixelSize: Theme.fontSizeExtraSmall
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.bold: true
                        }

                        Label {
                            id: day_humidity12
                            text: 12 + "% - " + 15 + "%"
                            font.family: Theme.fontFamilyHeading
                            font.pixelSize: Theme.fontSizeExtraSmall
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.bold: true
                        }


                    }
                }

                Row {

                    spacing: Theme.paddingLarge
                    anchors.horizontalCenter: parent.horizontalCenter

                    Column{

                        anchors.verticalCenter: parent.verticalCenter

                        Label {
                            id: day_date13
                            text: "Jour 13"
                            font.family: Theme.fontFamilyHeading
                            font.pixelSize: Theme.fontSizeExtraSmall
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.bold: true
                        }

                        Icon {
                            id: day_logo13
                            source: "image://theme/icon-l-dismiss"
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        Label {
                            id: day_desc13
                            text: "Ensoleille"
                            font.family: Theme.fontFamilyHeading
                            font.pixelSize: Theme.fontSizeExtraSmall
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.bold: true
                        }

                        Label {
                            id: day_temperature13
                            text: 12 + "°C - "+ 15 + "°C"
                            font.family: Theme.fontFamilyHeading
                            font.pixelSize: Theme.fontSizeExtraSmall
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.bold: true
                        }

                        Label {
                            id: day_humidity13
                            text: 12 + "% - " + 15 + "%"
                            font.family: Theme.fontFamilyHeading
                            font.pixelSize: Theme.fontSizeExtraSmall
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.bold: true
                        }


                    }

                    Column{

                        anchors.verticalCenter: parent.verticalCenter

                        Label {
                            id: day_date14
                            text: "Jour 14"
                            font.family: Theme.fontFamilyHeading
                            font.pixelSize: Theme.fontSizeExtraSmall
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.bold: true
                        }

                        Icon {
                            id: day_logo14
                            source: "image://theme/icon-l-dismiss"
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        Label {
                            id: day_desc14
                            text: "Ensoleille"
                            font.family: Theme.fontFamilyHeading
                            font.pixelSize: Theme.fontSizeExtraSmall
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.bold: true
                        }

                        Label {
                            id: day_temperature14
                            text: 12 + "°C - "+ 15 + "°C"
                            font.family: Theme.fontFamilyHeading
                            font.pixelSize: Theme.fontSizeExtraSmall
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.bold: true
                        }

                        Label {
                            id: day_humidity14
                            text: 12 + "% - " + 15 + "%"
                            font.family: Theme.fontFamilyHeading
                            font.pixelSize: Theme.fontSizeExtraSmall
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.bold: true
                        }


                    }

                    Column{

                        anchors.verticalCenter: parent.verticalCenter

                        Label {
                            id: day_date15
                            text: "Jour 15"
                            font.family: Theme.fontFamilyHeading
                            font.pixelSize: Theme.fontSizeExtraSmall
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.bold: true
                        }

                        Icon {
                            id: day_logo15
                            source: "image://theme/icon-l-dismiss"
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        Label {
                            id: day_desc15
                            text: "Ensoleille"
                            font.family: Theme.fontFamilyHeading
                            font.pixelSize: Theme.fontSizeExtraSmall
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.bold: true
                        }

                        Label {
                            id: day_temperature15
                            text: 12 + "°C - "+ 15 + "°C"
                            font.family: Theme.fontFamilyHeading
                            font.pixelSize: Theme.fontSizeExtraSmall
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.bold: true
                        }

                        Label {
                            id: day_humidity15
                            text: 12 + "% - " + 15 + "%"
                            font.family: Theme.fontFamilyHeading
                            font.pixelSize: Theme.fontSizeExtraSmall
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.bold: true
                        }


                    }
                }

            }
        }

    }

    // Cette fonction est appelé à chaque recherche et à chaque activation du mode géolocalisation
    function updateCity(lat, lon){
        //console.log('update city ' +lat+' '+lon)
        if(lat === null || lat === false
                ||  lon === null || lon === false){
            today.visible = false;
            tomorrow.visible = false;
            days.visible = false;
            menu.enabled = false;
        }else{
            MeteoClient.api.getForecast(lat, lon, function(forecast){
                query.text = forecast.position.name
                today_city.text = forecast.position.name
                cover_city.text = today_city.text //Pour la cover
                day_city.text = forecast.position.name
                tomorrow_city.text= forecast.position.name
                var vtoday = forecast.getDay(true)
                // Les informations d'aujourd'hui
                var vtomorrow = forecast.getDay(false)
                today_desc.text = vtoday.Desc
                cover_desc.text = today_desc.text //Pour la cover
                today_date.text = vtoday.Date
                today_temperature.text = vtoday.Temperature + qsTr(" °C ")
                cover_temperature.text = today_temperature.text //Pour la cover
                today_humidity.text = vtoday.Humidity + " % "
                today_wind.text = vtoday.Wind + "km/h "
                // Obtenir les informations sur heures aujourd'hui
                var data6hours_today = forecast.getXHours(0,6);
                var today_tmp
                for (var x=0; x<data6hours_today.length; x++) {
                    today_tmp = data6hours_today[x]
                    if(today_tmp) {
                        eval("today_date_hour" + x).text = data6hours_today[x].Date
                        eval("today_temp_hour" + x).text = data6hours_today[x].Temperature + "°C"
                        eval("today_wind_hour" + x).text = data6hours_today[x].Wind + " km/h"
                        // Afficher les logos correspondant sur les 6 prochaines heures
                        switch(mainPage.replaceSpecialChars(data6hours_today[x].Desc.toUpperCase())) {

                        case mainPage.replaceSpecialChars("Nuit claire".toUpperCase()) :
                            eval("today_icon_hour"+(x)).source = 'image://theme/icon-l-weather-n000-dark'
                            break
                        case mainPage.replaceSpecialChars("Tres nuageux".toUpperCase()) :
                            eval("today_icon_hour"+(x)).source = 'image://theme/icon-l-weather-d400-dark'
                            break;
                        case mainPage.replaceSpecialChars("Couvert".toUpperCase()) :
                            eval("today_icon_hour"+(x)).source = 'image://theme/icon-l-weather-d200-dark'
                            break;
                        case mainPage.replaceSpecialChars("Brume".toUpperCase()) :
                            eval("today_icon_hour"+(x)).source = 'image://theme/icon-l-weather-d500-dark'
                            break;
                        case mainPage.replaceSpecialChars("Brume ou bancs de brouillard".toUpperCase()) :
                            eval("today_icon_hour"+(x)).source = 'image://theme/icon-l-weather-d500-dark'
                            break;
                        case mainPage.replaceSpecialChars("Brouillard".toUpperCase()) :
                            eval("today_icon_hour"+(x)).source = 'image://theme/icon-l-weather-d600-dark'
                            break;
                        case mainPage.replaceSpecialChars("Brouillard givrant".toUpperCase()) :
                            eval("today_icon_hour"+(x)).source = 'image://theme/icon-l-weather-d600-dark'
                            break;
                        case mainPage.replaceSpecialChars("Risque de grele".toUpperCase()) :
                            eval("today_icon_hour"+(x)).source = 'image://theme/icon-l-weather-d432-dark'
                            break;
                        case mainPage.replaceSpecialChars("Orages".toUpperCase()) :
                            eval("today_icon_hour"+(x)).source = 'image://theme/icon-l-weather-n440-dark'
                            break;
                        case mainPage.replaceSpecialChars("Risque d\'orages".toUpperCase()) :
                            eval("today_icon_hour"+(x)).source = 'image://theme/icon-l-weather-n440-dark'
                            break;
                        case mainPage.replaceSpecialChars("Pluies orageuses".toUpperCase()) :
                            eval("today_icon_hour"+(x)).source = 'image://theme/icon-l-weather-n440-dark'
                            break;
                        case mainPage.replaceSpecialChars("Averses orageuses".toUpperCase()) :
                            eval("today_icon_hour"+(x)).source = 'image://theme/icon-l-weather-n440-dark'
                            break;
                        case mainPage.replaceSpecialChars("Ciel voile".toUpperCase()) :
                            eval("today_icon_hour"+(x)).source = 'image://theme/icon-l-weather-n600-dark'
                            break;
                        case mainPage.replaceSpecialChars("Ciel voile nuit".toUpperCase()) :
                            eval("today_icon_hour"+(x)).source = 'image://theme/icon-l-weather-n500-dark'
                            break;
                        case mainPage.replaceSpecialChars("Eclaircies".toUpperCase()) :
                            eval("today_icon_hour"+(x)).source = 'image://theme/icon-l-weather-d200-dark'
                            break;
                        case mainPage.replaceSpecialChars("Peu nuageux".toUpperCase()) :
                            eval("today_icon_hour"+(x)).source = 'image://theme/icon-l-weather-d100-dark'
                            break;
                        case mainPage.replaceSpecialChars("Pluie forte".toUpperCase()) :
                            eval("today_icon_hour"+(x)).source = 'image://theme/icon-l-weather-d430-dark'
                            break;
                        case mainPage.replaceSpecialChars("Bruine / pluie faible".toUpperCase()) :
                            eval("today_icon_hour"+(x)).source = 'image://theme/icon-l-weather-d410-dark'
                            break;
                        case mainPage.replaceSpecialChars("Bruine".toUpperCase()) :
                            eval("today_icon_hour"+(x)).source = 'image://theme/icon-l-weather-d210-dark'
                            break;
                        case mainPage.replaceSpecialChars("Pluies eparses / rares averses".toUpperCase()) :
                            eval("today_icon_hour"+(x)).source = 'image://theme/icon-l-weather-d430-dark'
                            break;
                        case mainPage.replaceSpecialChars("Pluies eparses".toUpperCase()) :
                            eval("today_icon_hour"+(x)).source = 'image://theme/icon-l-weather-d430-dark'
                            break;
                        case mainPage.replaceSpecialChars("Rares averses".toUpperCase()) :
                            eval("today_icon_hour"+(x)).source = 'image://theme/icon-l-weather-d220-dark'
                            break;
                        case mainPage.replaceSpecialChars("Pluie moderee".toUpperCase()) :
                            eval("today_icon_hour"+(x)).source = 'image://theme/icon-l-weather-d420-dark'
                            break;
                        case mainPage.replaceSpecialChars("Pluie / averses".toUpperCase()) :
                            eval("today_icon_hour"+(x)).source = 'image://theme/icon-l-weather-d220-dark'
                            break;
                        case mainPage.replaceSpecialChars("Pluie faible".toUpperCase()) :
                            eval("today_icon_hour"+(x)).source = 'image://theme/icon-l-weather-d410-dark'
                            break;
                        case mainPage.replaceSpecialChars("Averses".toUpperCase()) :
                            eval("today_icon_hour"+(x)).source = 'image://theme/icon-l-weather-d210-dark'
                            break;
                        case mainPage.replaceSpecialChars("Pluie".toUpperCase()) :
                            eval("today_icon_hour"+(x)).source = 'image://theme/icon-l-weather-d410-dark'
                            break;
                        case mainPage.replaceSpecialChars("Neige".toUpperCase()) :
                            eval("today_icon_hour"+(x)).source = 'image://theme/icon-l-weather-d422-dark'
                            break;
                        case mainPage.replaceSpecialChars("Neige forte".toUpperCase()) :
                            eval("today_icon_hour"+(x)).source = 'image://theme/icon-l-weather-d432-dark'
                            break;
                        case mainPage.replaceSpecialChars("Quelques flocons".toUpperCase()) :
                            eval("today_icon_hour"+(x)).source = 'image://theme/icon-l-weather-d412-dark'
                            break;
                        case mainPage.replaceSpecialChars("Averses de neige".toUpperCase()) :
                            eval("today_icon_hour"+(x)).source = 'image://theme/icon-l-weather-d411-dark'
                            break;
                        case mainPage.replaceSpecialChars("Neige / averses de neige".toUpperCase()) :
                            eval("today_icon_hour"+(x)).source = 'image://theme/icon-l-weather-d421-dark'
                            break;
                        case mainPage.replaceSpecialChars("Pluie et neige".toUpperCase()) :
                            eval("today_icon_hour"+(x)).source = 'image://theme/icon-l-weather-d421-dark'
                            break;
                        case mainPage.replaceSpecialChars("Pluie verglacante".toUpperCase()) :
                            eval("today_icon_hour"+(x)).source = 'image://theme/icon-l-weather-d431-dark'
                            break;
                        case mainPage.replaceSpecialChars("Ensoleillé".toUpperCase()) :
                            eval("today_icon_hour"+(x)).source = 'image://theme/icon-l-weather-d000-light'
                            break;
                        default :
                            eval("today_icon_hour"+(x)).visible = false
                            //console.log('Description ' + eval("today_icon_hour"+(x)).text + ' introuvable')
                            //console.log(mainPage.replaceSpecialChars(eval("today_icon_hour"+(x)).text).toUpperCase())
                        }
                    }
                }
                // Déterminer le logo d'aujourd'hui
                switch(mainPage.replaceSpecialChars(today_desc.text.toUpperCase())) {

                case mainPage.replaceSpecialChars("Nuit claire".toUpperCase()) :
                    today_logo.source = 'image://theme/icon-l-weather-n000-dark'
                    break
                case mainPage.replaceSpecialChars("Tres nuageux".toUpperCase()) :
                    today_logo.source = 'image://theme/icon-l-weather-d400-dark'
                    break;
                case mainPage.replaceSpecialChars("Couvert".toUpperCase()) :
                    today_logo.source = 'image://theme/icon-l-weather-d200-dark'
                    break;
                case mainPage.replaceSpecialChars("Brume".toUpperCase()) :
                    today_logo.source = 'image://theme/icon-l-weather-d500-dark'
                    break;
                case mainPage.replaceSpecialChars("Brume ou bancs de brouillard".toUpperCase()) :
                    today_logo.source = 'image://theme/icon-l-weather-d500-dark'
                    break;
                case mainPage.replaceSpecialChars("Brouillard".toUpperCase()) :
                    today_logo.source = 'image://theme/icon-l-weather-d600-dark'
                    break;
                case mainPage.replaceSpecialChars("Brouillard givrant".toUpperCase()) :
                    today_logo.source = 'image://theme/icon-l-weather-d600-dark'
                    break;
                case mainPage.replaceSpecialChars("Risque de grele".toUpperCase()) :
                    today_logo.source = 'image://theme/icon-l-weather-d432-dark'
                    break;
                case mainPage.replaceSpecialChars("Orages".toUpperCase()) :
                    today_logo.source = 'image://theme/icon-l-weather-n440-dark'
                    break;
                case mainPage.replaceSpecialChars("Risque d\'orages".toUpperCase()) :
                    today_logo.source = 'image://theme/icon-l-weather-n440-dark'
                    break;
                case mainPage.replaceSpecialChars("Pluies orageuses".toUpperCase()) :
                    today_logo.source = 'image://theme/icon-l-weather-n440-dark'
                    break;
                case mainPage.replaceSpecialChars("Averses orageuses".toUpperCase()) :
                    today_logo.source = 'image://theme/icon-l-weather-n440-dark'
                    break;
                case mainPage.replaceSpecialChars("Ciel voile".toUpperCase()) :
                    today_logo.source = 'image://theme/icon-l-weather-n600-dark'
                    break;
                case mainPage.replaceSpecialChars("Ciel voile nuit".toUpperCase()) :
                    today_logo.source = 'image://theme/icon-l-weather-n500-dark'
                    break;
                case mainPage.replaceSpecialChars("Eclaircies".toUpperCase()) :
                    today_logo.source = 'image://theme/icon-l-weather-d200-dark'
                    break;
                case mainPage.replaceSpecialChars("Peu nuageux".toUpperCase()) :
                    today_logo.source = 'image://theme/icon-l-weather-d100-dark'
                    break;
                case mainPage.replaceSpecialChars("Pluie forte".toUpperCase()) :
                    today_logo.source = 'image://theme/icon-l-weather-d430-dark'
                    break;
                case mainPage.replaceSpecialChars("Bruine / pluie faible".toUpperCase()) :
                    today_logo.source = 'image://theme/icon-l-weather-d410-dark'
                    break;
                case mainPage.replaceSpecialChars("Bruine".toUpperCase()) :
                    today_logo.source = 'image://theme/icon-l-weather-d210-dark'
                    break;
                case mainPage.replaceSpecialChars("Pluies eparses / rares averses".toUpperCase()) :
                    today_logo.source = 'image://theme/icon-l-weather-d430-dark'
                    break;
                case mainPage.replaceSpecialChars("Pluies eparses".toUpperCase()) :
                    today_logo.source = 'image://theme/icon-l-weather-d430-dark'
                    break;
                case mainPage.replaceSpecialChars("Rares averses".toUpperCase()) :
                    today_logo.source = 'image://theme/icon-l-weather-d220-dark'
                    break;
                case mainPage.replaceSpecialChars("Pluie moderee".toUpperCase()) :
                    today_logo.source = 'image://theme/icon-l-weather-d420-dark'
                    break;
                case mainPage.replaceSpecialChars("Pluie / averses".toUpperCase()) :
                    today_logo.source = 'image://theme/icon-l-weather-d220-dark'
                    break;
                case mainPage.replaceSpecialChars("Pluie faible".toUpperCase()) :
                    today_logo.source = 'image://theme/icon-l-weather-d410-dark'
                    break;
                case mainPage.replaceSpecialChars("Averses".toUpperCase()) :
                    today_logo.source = 'image://theme/icon-l-weather-d210-dark'
                    break;
                case mainPage.replaceSpecialChars("Pluie".toUpperCase()) :
                    today_logo.source = 'image://theme/icon-l-weather-d410-dark'
                    break;
                case mainPage.replaceSpecialChars("Neige".toUpperCase()) :
                    today_logo.source = 'image://theme/icon-l-weather-d422-dark'
                    break;
                case mainPage.replaceSpecialChars("Neige forte".toUpperCase()) :
                    today_logo.source = 'image://theme/icon-l-weather-d432-dark'
                    break;
                case mainPage.replaceSpecialChars("Quelques flocons".toUpperCase()) :
                    today_logo.source = 'image://theme/icon-l-weather-d412-dark'
                    break;
                case mainPage.replaceSpecialChars("Averses de neige".toUpperCase()) :
                    today_logo.source = 'image://theme/icon-l-weather-d411-dark'
                    break;
                case mainPage.replaceSpecialChars("Neige / averses de neige".toUpperCase()) :
                    today_logo.source = 'image://theme/icon-l-weather-d421-dark'
                    break;
                case mainPage.replaceSpecialChars("Pluie et neige".toUpperCase()) :
                    today_logo.source = 'image://theme/icon-l-weather-d421-dark'
                    break;
                case mainPage.replaceSpecialChars("Pluie verglacante".toUpperCase()) :
                    today_logo.source = 'image://theme/icon-l-weather-d431-dark'
                    break;
                case mainPage.replaceSpecialChars("Ensoleillé".toUpperCase()) :
                    today_logo.source = 'image://theme/icon-l-weather-d000-light'
                    break;
                default :
                    today_logo.visible = false
                    //console.log('Description today introuvable')
                    //console.log(mainPage.replaceSpecialChars(today_desc.text).toUpperCase())
                }
                cover_icon.source = today_logo.source //Pour la cover
                // Les informations de demain
                tomorrow_desc.text = vtomorrow.Desc
                tomorrow_date.text = vtomorrow.Date
                tomorrow_temperature.text = vtomorrow.Temperature + qsTr(" °C ")
                tomorrow_humidity.text = vtomorrow.Humidity + " % "
                tomorrow_wind.text = vtomorrow.Wind + "km/h "
                // TODO
                // les informations sur 6 heures le lendemain
                var data6hours_tomorrow = forecast.getXHours(24,30);
                var tomorrow_tmp
                for(var j = 0; j<data6hours_tomorrow.length; j++) {
                    tomorrow_tmp = data6hours_tomorrow[j]
                    if(tomorrow_tmp) {
                        eval("tomorrow_date_hour" + j).text = data6hours_tomorrow[j].Date
                        eval("tomorrow_temp_hour" + j).text = data6hours_tomorrow[j].Temperature + "°C"
                        eval("tomorrow_wind_hour" + j).text = data6hours_tomorrow[j].Wind + " km/h"
                        // Afficher les logos correspondant sur les 6 prochaines heures
                        switch(mainPage.replaceSpecialChars(data6hours_tomorrow[j].Desc.toUpperCase())) {

                        case mainPage.replaceSpecialChars("Nuit claire".toUpperCase()) :
                            eval("tomorrow_icon_hour"+(j)).source = 'image://theme/icon-l-weather-n000-dark'
                            break
                        case mainPage.replaceSpecialChars("Tres nuageux".toUpperCase()) :
                            eval("tomorrow_icon_hour"+(j)).source = 'image://theme/icon-l-weather-d400-dark'
                            break;
                        case mainPage.replaceSpecialChars("Couvert".toUpperCase()) :
                            eval("tomorrow_icon_hour"+(j)).source = 'image://theme/icon-l-weather-d200-dark'
                            break;
                        case mainPage.replaceSpecialChars("Brume".toUpperCase()) :
                            eval("tomorrow_icon_hour"+(j)).source = 'image://theme/icon-l-weather-d500-dark'
                            break;
                        case mainPage.replaceSpecialChars("Brume ou bancs de brouillard".toUpperCase()) :
                            eval("tomorrow_icon_hour"+(j)).source = 'image://theme/icon-l-weather-d500-dark'
                            break;
                        case mainPage.replaceSpecialChars("Brouillard".toUpperCase()) :
                            eval("tomorrow_icon_hour"+(j)).source = 'image://theme/icon-l-weather-d600-dark'
                            break;
                        case mainPage.replaceSpecialChars("Brouillard givrant".toUpperCase()) :
                            eval("tomorrow_icon_hour"+(j)).source = 'image://theme/icon-l-weather-d600-dark'
                            break;
                        case mainPage.replaceSpecialChars("Risque de grele".toUpperCase()) :
                            eval("tomorrow_icon_hour"+(j)).source = 'image://theme/icon-l-weather-d432-dark'
                            break;
                        case mainPage.replaceSpecialChars("Orages".toUpperCase()) :
                            eval("tomorrow_icon_hour"+(j)).source = 'image://theme/icon-l-weather-n440-dark'
                            break;
                        case mainPage.replaceSpecialChars("Risque d\'orages".toUpperCase()) :
                            eval("tomorrow_icon_hour"+(j)).source = 'image://theme/icon-l-weather-n440-dark'
                            break;
                        case mainPage.replaceSpecialChars("Pluies orageuses".toUpperCase()) :
                            eval("tomorrow_icon_hour"+(j)).source = 'image://theme/icon-l-weather-n440-dark'
                            break;
                        case mainPage.replaceSpecialChars("Averses orageuses".toUpperCase()) :
                            eval("tomorrow_icon_hour"+(j)).source = 'image://theme/icon-l-weather-n440-dark'
                            break;
                        case mainPage.replaceSpecialChars("Ciel voile".toUpperCase()) :
                            eval("tomorrow_icon_hour"+(j)).source = 'image://theme/icon-l-weather-n600-dark'
                            break;
                        case mainPage.replaceSpecialChars("Ciel voile nuit".toUpperCase()) :
                            eval("tomorrow_icon_hour"+(j)).source = 'image://theme/icon-l-weather-n500-dark'
                            break;
                        case mainPage.replaceSpecialChars("Eclaircies".toUpperCase()) :
                            eval("tomorrow_icon_hour"+(j)).source = 'image://theme/icon-l-weather-d200-dark'
                            break;
                        case mainPage.replaceSpecialChars("Peu nuageux".toUpperCase()) :
                            eval("tomorrow_icon_hour"+(j)).source = 'image://theme/icon-l-weather-d100-dark'
                            break;
                        case mainPage.replaceSpecialChars("Pluie forte".toUpperCase()) :
                            eval("tomorrow_icon_hour"+(j)).source = 'image://theme/icon-l-weather-d430-dark'
                            break;
                        case mainPage.replaceSpecialChars("Bruine / pluie faible".toUpperCase()) :
                            eval("tomorrow_icon_hour"+(j)).source = 'image://theme/icon-l-weather-d410-dark'
                            break;
                        case mainPage.replaceSpecialChars("Bruine".toUpperCase()) :
                            eval("tomorrow_icon_hour"+(j)).source = 'image://theme/icon-l-weather-d210-dark'
                            break;
                        case mainPage.replaceSpecialChars("Pluies eparses / rares averses".toUpperCase()) :
                            eval("tomorrow_icon_hour"+(j)).source = 'image://theme/icon-l-weather-d430-dark'
                            break;
                        case mainPage.replaceSpecialChars("Pluies eparses".toUpperCase()) :
                            eval("tomorrow_icon_hour"+(j)).source = 'image://theme/icon-l-weather-d430-dark'
                            break;
                        case mainPage.replaceSpecialChars("Rares averses".toUpperCase()) :
                            eval("tomorrow_icon_hour"+(j)).source = 'image://theme/icon-l-weather-d220-dark'
                            break;
                        case mainPage.replaceSpecialChars("Pluie moderee".toUpperCase()) :
                            eval("tomorrow_icon_hour"+(j)).source = 'image://theme/icon-l-weather-d420-dark'
                            break;
                        case mainPage.replaceSpecialChars("Pluie / averses".toUpperCase()) :
                            eval("tomorrow_icon_hour"+(j)).source = 'image://theme/icon-l-weather-d220-dark'
                            break;
                        case mainPage.replaceSpecialChars("Pluie faible".toUpperCase()) :
                            eval("tomorrow_icon_hour"+(j)).source = 'image://theme/icon-l-weather-d410-dark'
                            break;
                        case mainPage.replaceSpecialChars("Averses".toUpperCase()) :
                            eval("tomorrow_icon_hour"+(j)).source = 'image://theme/icon-l-weather-d210-dark'
                            break;
                        case mainPage.replaceSpecialChars("Pluie".toUpperCase()) :
                            eval("tomorrow_icon_hour"+(j)).source = 'image://theme/icon-l-weather-d410-dark'
                            break;
                        case mainPage.replaceSpecialChars("Neige".toUpperCase()) :
                            eval("tomorrow_icon_hour"+(j)).source = 'image://theme/icon-l-weather-d422-dark'
                            break;
                        case mainPage.replaceSpecialChars("Neige forte".toUpperCase()) :
                            eval("tomorrow_icon_hour"+(j)).source = 'image://theme/icon-l-weather-d432-dark'
                            break;
                        case mainPage.replaceSpecialChars("Quelques flocons".toUpperCase()) :
                            eval("tomorrow_icon_hour"+(j)).source = 'image://theme/icon-l-weather-d412-dark'
                            break;
                        case mainPage.replaceSpecialChars("Averses de neige".toUpperCase()) :
                            eval("tomorrow_icon_hour"+(j)).source = 'image://theme/icon-l-weather-d411-dark'
                            break;
                        case mainPage.replaceSpecialChars("Neige / averses de neige".toUpperCase()) :
                            eval("tomorrow_icon_hour"+(j)).source = 'image://theme/icon-l-weather-d421-dark'
                            break;
                        case mainPage.replaceSpecialChars("Pluie et neige".toUpperCase()) :
                            eval("tomorrow_icon_hour"+(j)).source = 'image://theme/icon-l-weather-d421-dark'
                            break;
                        case mainPage.replaceSpecialChars("Pluie verglacante".toUpperCase()) :
                            eval("tomorrow_icon_hour"+(j)).source = 'image://theme/icon-l-weather-d431-dark'
                            break;
                        case mainPage.replaceSpecialChars("Ensoleillé".toUpperCase()) :
                            eval("tomorrow_icon_hour"+(j)).source = 'image://theme/icon-l-weather-d000-light'
                            break;
                        default :
                            eval("tomorrow_icon_hour"+(j)).visible = false
                            //console.log('Description ' + eval("tomorrow_icon_hour"+(j)).text + ' introuvable')
                            //console.log(mainPage.replaceSpecialChars(eval("tomorrow_icon_hour"+(j)).text).toUpperCase())
                        }
                    }
                }

                // Déterminer le logo de demain
                switch(mainPage.replaceSpecialChars(tomorrow_desc.text.toUpperCase())) {

                case mainPage.replaceSpecialChars("Nuit claire".toUpperCase()) :
                    tomorrow_logo.source = 'image://theme/icon-l-weather-n000-dark'
                    break
                case mainPage.replaceSpecialChars("Tres nuageux".toUpperCase()) :
                    tomorrow_logo.source = 'image://theme/icon-l-weather-d400-dark'
                    break;
                case mainPage.replaceSpecialChars("Couvert".toUpperCase()) :
                    tomorrow_logo.source = 'image://theme/icon-l-weather-d200-dark'
                    break;
                case mainPage.replaceSpecialChars("Brume".toUpperCase()) :
                    tomorrow_logo.source = 'image://theme/icon-l-weather-d500-dark'
                    break;
                case mainPage.replaceSpecialChars("Brume ou bancs de brouillard".toUpperCase()) :
                    tomorrow_logo.source = 'image://theme/icon-l-weather-d500-dark'
                    break;
                case mainPage.replaceSpecialChars("Brouillard".toUpperCase()) :
                    tomorrow_logo.source = 'image://theme/icon-l-weather-d600-dark'
                    break;
                case mainPage.replaceSpecialChars("Brouillard givrant".toUpperCase()) :
                    tomorrow_logo.source = 'image://theme/icon-l-weather-d600-dark'
                    break;
                case mainPage.replaceSpecialChars("Risque de grele".toUpperCase()) :
                    tomorrow_logo.source = 'image://theme/icon-l-weather-d432-dark'
                    break;
                case mainPage.replaceSpecialChars("Orages".toUpperCase()) :
                    tomorrow_logo.source = 'image://theme/icon-l-weather-n440-dark'
                    break;
                case mainPage.replaceSpecialChars("Risque d\'orages".toUpperCase()) :
                    tomorrow_logo.source = 'image://theme/icon-l-weather-n440-dark'
                    break;
                case mainPage.replaceSpecialChars("Pluies orageuses".toUpperCase()) :
                    tomorrow_logo.source = 'image://theme/icon-l-weather-n440-dark'
                    break;
                case mainPage.replaceSpecialChars("Averses orageuses".toUpperCase()) :
                    tomorrow_logo.source = 'image://theme/icon-l-weather-n440-dark'
                    break;
                case mainPage.replaceSpecialChars("Ciel voile".toUpperCase()) :
                    tomorrow_logo.source = 'image://theme/icon-l-weather-n600-dark'
                    break;
                case mainPage.replaceSpecialChars("Ciel voile nuit".toUpperCase()) :
                    tomorrow_logo.source = 'image://theme/icon-l-weather-n500-dark'
                    break;
                case mainPage.replaceSpecialChars("Eclaircies".toUpperCase()) :
                    tomorrow_logo.source = 'image://theme/icon-l-weather-d200-dark'
                    break;
                case mainPage.replaceSpecialChars("Peu nuageux".toUpperCase()) :
                    tomorrow_logo.source = 'image://theme/icon-l-weather-d100-dark'
                    break;
                case mainPage.replaceSpecialChars("Pluie forte".toUpperCase()) :
                    tomorrow_logo.source = 'image://theme/icon-l-weather-d430-dark'
                    break;
                case mainPage.replaceSpecialChars("Bruine / pluie faible".toUpperCase()) :
                    tomorrow_logo.source = 'image://theme/icon-l-weather-d410-dark'
                    break;
                case mainPage.replaceSpecialChars("Bruine".toUpperCase()) :
                    tomorrow_logo.source = 'image://theme/icon-l-weather-d210-dark'
                    break;
                case mainPage.replaceSpecialChars("Pluies eparses / rares averses".toUpperCase()) :
                    tomorrow_logo.source = 'image://theme/icon-l-weather-d430-dark'
                    break;
                case mainPage.replaceSpecialChars("Pluies eparses".toUpperCase()) :
                    tomorrow_logo.source = 'image://theme/icon-l-weather-d430-dark'
                    break;
                case mainPage.replaceSpecialChars("Rares averses".toUpperCase()) :
                    tomorrow_logo.source = 'image://theme/icon-l-weather-d220-dark'
                    break;
                case mainPage.replaceSpecialChars("Pluie moderee".toUpperCase()) :
                    tomorrow_logo.source = 'image://theme/icon-l-weather-d420-dark'
                    break;
                case mainPage.replaceSpecialChars("Pluie / averses".toUpperCase()) :
                    tomorrow_logo.source = 'image://theme/icon-l-weather-d220-dark'
                    break;
                case mainPage.replaceSpecialChars("Pluie faible".toUpperCase()) :
                    tomorrow_logo.source = 'image://theme/icon-l-weather-d410-dark'
                    break;
                case mainPage.replaceSpecialChars("Averses".toUpperCase()) :
                    tomorrow_logo.source = 'image://theme/icon-l-weather-d210-dark'
                    break;
                case mainPage.replaceSpecialChars("Pluie".toUpperCase()) :
                    tomorrow_logo.source = 'image://theme/icon-l-weather-d410-dark'
                    break;
                case mainPage.replaceSpecialChars("Neige".toUpperCase()) :
                    tomorrow_logo.source = 'image://theme/icon-l-weather-d422-dark'
                    break;
                case mainPage.replaceSpecialChars("Neige forte".toUpperCase()) :
                    tomorrow_logo.source = 'image://theme/icon-l-weather-d432-dark'
                    break;
                case mainPage.replaceSpecialChars("Quelques flocons".toUpperCase()) :
                    tomorrow_logo.source = 'image://theme/icon-l-weather-d412-dark'
                    break;
                case mainPage.replaceSpecialChars("Averses de neige".toUpperCase()) :
                    tomorrow_logo.source = 'image://theme/icon-l-weather-d411-dark'
                    break;
                case mainPage.replaceSpecialChars("Neige / averses de neige".toUpperCase()) :
                    tomorrow_logo.source = 'image://theme/icon-l-weather-d421-dark'
                    break;
                case mainPage.replaceSpecialChars("Pluie et neige".toUpperCase()) :
                    tomorrow_logo.source = 'image://theme/icon-l-weather-d421-dark'
                    break;
                case mainPage.replaceSpecialChars("Pluie verglacante".toUpperCase()) :
                    tomorrow_logo.source = 'image://theme/icon-l-weather-d431-dark'
                    break;
                case mainPage.replaceSpecialChars("Ensoleillé".toUpperCase()) :
                    tomorrow_logo.source = 'image://theme/icon-l-weather-d000-light'
                    break;
                default :
                    tomorrow_logo.visible = false
                    //console.log('Description tomorrow introuvable')
                    //console.log(mainPage.replaceSpecialChars(tomorrow_desc.text).toUpperCase())
                }

                var data15days = forecast.getXDaysData(0,15);
                var tmp
                // Les informations sur 15 jours
                for (var i = 0; i<data15days.length; i++) {
                    tmp = data15days[i];
                    if(tmp){
                        eval("day_date"+(i+1)).text = data15days[i].Date
                        eval("day_desc"+(i+1)).text = data15days[i].Desc
                        eval("day_temperature"+(i+1)).text = data15days[i].TemperatureMin + "°C - " +
                                data15days[i].TemperatureMax + "°C"
                        eval("day_humidity"+(i+1)).text = data15days[i].HumidityMin + "% - " +
                                data15days[i].HumidityMax + "%"
                        // Afficher les logos correspondant sur les 15 jours
                        switch(mainPage.replaceSpecialChars(eval("day_desc"+(i+1)).text.toUpperCase())) {

                        case mainPage.replaceSpecialChars("Nuit claire".toUpperCase()) :
                            eval("day_logo"+(i+1)).source = 'image://theme/icon-l-weather-n000-dark'
                            break
                        case mainPage.replaceSpecialChars("Tres nuageux".toUpperCase()) :
                            eval("day_logo"+(i+1)).source = 'image://theme/icon-l-weather-d400-dark'
                            break;
                        case mainPage.replaceSpecialChars("Couvert".toUpperCase()) :
                            eval("day_logo"+(i+1)).source = 'image://theme/icon-l-weather-d200-dark'
                            break;
                        case mainPage.replaceSpecialChars("Brume".toUpperCase()) :
                            eval("day_logo"+(i+1)).source = 'image://theme/icon-l-weather-d500-dark'
                            break;
                        case mainPage.replaceSpecialChars("Brume ou bancs de brouillard".toUpperCase()) :
                            eval("day_logo"+(i+1)).source = 'image://theme/icon-l-weather-d500-dark'
                            break;
                        case mainPage.replaceSpecialChars("Brouillard".toUpperCase()) :
                            eval("day_logo"+(i+1)).source = 'image://theme/icon-l-weather-d600-dark'
                            break;
                        case mainPage.replaceSpecialChars("Brouillard givrant".toUpperCase()) :
                            eval("day_logo"+(i+1)).source = 'image://theme/icon-l-weather-d600-dark'
                            break;
                        case mainPage.replaceSpecialChars("Risque de grele".toUpperCase()) :
                            eval("day_logo"+(i+1)).source = 'image://theme/icon-l-weather-d432-dark'
                            break;
                        case mainPage.replaceSpecialChars("Orages".toUpperCase()) :
                            eval("day_logo"+(i+1)).source = 'image://theme/icon-l-weather-n440-dark'
                            break;
                        case mainPage.replaceSpecialChars("Risque d\'orages".toUpperCase()) :
                            eval("day_logo"+(i+1)).source = 'image://theme/icon-l-weather-n440-dark'
                            break;
                        case mainPage.replaceSpecialChars("Pluies orageuses".toUpperCase()) :
                            eval("day_logo"+(i+1)).source = 'image://theme/icon-l-weather-n440-dark'
                            break;
                        case mainPage.replaceSpecialChars("Averses orageuses".toUpperCase()) :
                            eval("day_logo"+(i+1)).source = 'image://theme/icon-l-weather-n440-dark'
                            break;
                        case mainPage.replaceSpecialChars("Ciel voile".toUpperCase()) :
                            eval("day_logo"+(i+1)).source = 'image://theme/icon-l-weather-n600-dark'
                            break;
                        case mainPage.replaceSpecialChars("Ciel voile nuit".toUpperCase()) :
                            eval("day_logo"+(i+1)).source = 'image://theme/icon-l-weather-n500-dark'
                            break;
                        case mainPage.replaceSpecialChars("Eclaircies".toUpperCase()) :
                            eval("day_logo"+(i+1)).source = 'image://theme/icon-l-weather-d200-dark'
                            break;
                        case mainPage.replaceSpecialChars("Peu nuageux".toUpperCase()) :
                            eval("day_logo"+(i+1)).source = 'image://theme/icon-l-weather-d100-dark'
                            break;
                        case mainPage.replaceSpecialChars("Pluie forte".toUpperCase()) :
                            eval("day_logo"+(i+1)).source = 'image://theme/icon-l-weather-d430-dark'
                            break;
                        case mainPage.replaceSpecialChars("Bruine / pluie faible".toUpperCase()) :
                            eval("day_logo"+(i+1)).source = 'image://theme/icon-l-weather-d410-dark'
                            break;
                        case mainPage.replaceSpecialChars("Bruine".toUpperCase()) :
                            eval("day_logo"+(i+1)).source = 'image://theme/icon-l-weather-d210-dark'
                            break;
                        case mainPage.replaceSpecialChars("Pluies eparses / rares averses".toUpperCase()) :
                            eval("day_logo"+(i+1)).source = 'image://theme/icon-l-weather-d430-dark'
                            break;
                        case mainPage.replaceSpecialChars("Pluies eparses".toUpperCase()) :
                            eval("day_logo"+(i+1)).source = 'image://theme/icon-l-weather-d430-dark'
                            break;
                        case mainPage.replaceSpecialChars("Rares averses".toUpperCase()) :
                            eval("day_logo"+(i+1)).source = 'image://theme/icon-l-weather-d220-dark'
                            break;
                        case mainPage.replaceSpecialChars("Pluie moderee".toUpperCase()) :
                            eval("day_logo"+(i+1)).source = 'image://theme/icon-l-weather-d420-dark'
                            break;
                        case mainPage.replaceSpecialChars("Pluie / averses".toUpperCase()) :
                            eval("day_logo"+(i+1)).source = 'image://theme/icon-l-weather-d220-dark'
                            break;
                        case mainPage.replaceSpecialChars("Pluie faible".toUpperCase()) :
                            eval("day_logo"+(i+1)).source = 'image://theme/icon-l-weather-d410-dark'
                            break;
                        case mainPage.replaceSpecialChars("Averses".toUpperCase()) :
                            eval("day_logo"+(i+1)).source = 'image://theme/icon-l-weather-d210-dark'
                            break;
                        case mainPage.replaceSpecialChars("Pluie".toUpperCase()) :
                            eval("day_logo"+(i+1)).source = 'image://theme/icon-l-weather-d410-dark'
                            break;
                        case mainPage.replaceSpecialChars("Neige".toUpperCase()) :
                            eval("day_logo"+(i+1)).source = 'image://theme/icon-l-weather-d422-dark'
                            break;
                        case mainPage.replaceSpecialChars("Neige forte".toUpperCase()) :
                            eval("day_logo"+(i+1)).source = 'image://theme/icon-l-weather-d432-dark'
                            break;
                        case mainPage.replaceSpecialChars("Quelques flocons".toUpperCase()) :
                            eval("day_logo"+(i+1)).source = 'image://theme/icon-l-weather-d412-dark'
                            break;
                        case mainPage.replaceSpecialChars("Averses de neige".toUpperCase()) :
                            eval("day_logo"+(i+1)).source = 'image://theme/icon-l-weather-d411-dark'
                            break;
                        case mainPage.replaceSpecialChars("Neige / averses de neige".toUpperCase()) :
                            eval("day_logo"+(i+1)).source = 'image://theme/icon-l-weather-d421-dark'
                            break;
                        case mainPage.replaceSpecialChars("Pluie et neige".toUpperCase()) :
                            eval("day_logo"+(i+1)).source = 'image://theme/icon-l-weather-d421-dark'
                            break;
                        case mainPage.replaceSpecialChars("Pluie verglacante".toUpperCase()) :
                            eval("day_logo"+(i+1)).source = 'image://theme/icon-l-weather-d431-dark'
                            break;
                        case mainPage.replaceSpecialChars("Ensoleillé".toUpperCase()) :
                            eval("day_logo"+(i+1)).source = 'image://theme/icon-l-weather-d000-light'
                            break;
                        default :
                            eval("day_logo"+(i+1)).visible = false
                            //console.log('Description ' + eval("day_desc"+(i+1)).text + ' introuvable')
                            //console.log(mainPage.replaceSpecialChars(eval("day_desc"+(i+1)).text).toUpperCase())
                        }
                    }
                }
            });
            menu.enabled = true
            mainWindow.cover = coverData
        }
    }
    // Une fonction destinée à ignorer les accents sur les mots
    function replaceSpecialChars(str) {
        str = str.replace(/[ÀÁÂÃÄÅ]/,"A");
        str = str.replace(/[àáâãäå]/,"a");
        str = str.replace(/[ÈÉÊË]/,"E");
        str = str.replace(/[Ç]/,"C");
        str = str.replace(/[ç]/,"c");

        // o resto

        return str;
    }
    // Page du "à propos"
    Component {
        id: propos
        Page {
            backNavigation: true

            SilicaFlickable {
                anchors.fill: parent
                contentHeight: column.height


                Column {

                    width: parent.width
                    spacing: Theme.paddingLarge

                    SectionHeader{
                        text: "France Météo"
                    }

                    Column{

                        width: parent.width

                        SectionHeader {
                            text: qsTr("Description")
                        }

                        Label {
                            width: parent.width
                            text: "Voici un prototype d'application donnant les informations météorologiques basiques avec l'API de Météo-France. Vous retrouverez ici " +
                                  "les informations d'aujourd'hui, de demain mais aussi sur les 15 prochains jours. De plus, un mode géolocalisation " +
                                  "est également mis à votre disposition (ce mode est initialement activé au lancement de l'application)"
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.Wrap
                            font.pixelSize: Theme.fontSizeSmall
                        }
                    }

                    Column{

                        width: parent.width
                        spacing: Theme.paddingLarge

                        SectionHeader {
                            text: qsTr("Auteurs")
                        }

                        Column {

                            width: parent.width

                            Label {
                                text: "Aziz Tchakounte"
                                anchors {
                                    horizontalCenter: parent.horizontalCenter
                                }
                            }

                            Label {
                                text: "Manka"
                                anchors {
                                    horizontalCenter: parent.horizontalCenter
                                }
                            }

                            Label {
                                text: "Jaeemiel Rey"
                                anchors {
                                    horizontalCenter: parent.horizontalCenter
                                }
                            }
                        }
                    }

                    Column{

                        width: parent.width

                        SectionHeader {
                            text: qsTr("Code Source")
                        }

                        Label {
                            text: qsTr("Licence GNU GPL v3")
                            font.pixelSize: Theme.fontSizeSmall
                            anchors {
                                horizontalCenter: parent.horizontalCenter
                            }
                        }

                        Text {
                            text: "<a href=\"https://gitlab.com/adelnoureddine/harbour-france-meteo\">" + qsTr("View source code on GitLab") + "</a>"
                            anchors {
                                horizontalCenter: parent.horizontalCenter
                            }
                            font.pixelSize: Theme.fontSizeSmall
                            linkColor: Theme.highlightColor

                            onLinkActivated: Qt.openUrlExternally("https://gitlab.com/adelnoureddine/harbour-france-meteo")
                        }
                    }


                }
            }

        }
    }
    // Les informations du cover
    CoverBackground {
        id: coverData
        visible: false

        SilicaFlickable {
            anchors.fill: parent
            contentHeight: column.height/2


            Column {
                width: parent.width

                Column{
                    width: parent.width
                    Label {
                        text: "     "
                    }
                    Image {
                        source: "harbour-france-meteo.png"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }

                Column{
                    width: parent.width
                    Label {
                        width: parent.width
                        id: cover_city
                        horizontalAlignment: Text.AlignHCenter
                        text: " "
                        wrapMode: Text.Wrap
                    }

                    Icon{
                        id: cover_icon
                        source: "image://theme/icon-l-dismiss"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Label {
                        id: cover_desc
                        text: " "
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.Wrap
                        width: parent.width
                    }

                    Label {
                        id: cover_temperature
                        text: " "
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }
        }
    }
}
