/*
 * LingmoNix Calamares slideshow — shows the LingmoOS logo + a welcome message.
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.0;
import calamares.slideshow 1.0;

Presentation
{
    id: presentation

    function nextSlide() {
        presentation.goToNextSlide();
    }

    Timer {
        id: advanceTimer
        interval: 10000
        running: presentation.activatedInCalamares
        repeat: true
        onTriggered: nextSlide()
    }

    Slide {
        Image {
            id: logo
            source: "lingmo-logo.png"
            width: 640
            height: 220
            fillMode: Image.PreserveAspectFit
            anchors.centerIn: parent
        }
        Text {
            anchors.top: logo.bottom
            anchors.topMargin: 24
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Welcome to LingmoNix"
            font.pixelSize: 32
            color: "#ffffff"
        }
    }

    Slide {
        Text {
            anchors.centerIn: parent
            text: "The LingmoOS desktop environment on NixOS"
            font.pixelSize: 28
            wrapMode: Text.WordWrap
            width: presentation.width
            horizontalAlignment: Text.Center
            color: "#ffffff"
        }
    }
}
