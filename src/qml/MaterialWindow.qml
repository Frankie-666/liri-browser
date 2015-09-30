import QtQuick 2.0
import QtQuick.Controls 1.2 as Controls
import QtQuick.Window 2.0
import Material 0.1
import Material.Extras 0.1
import QtGraphicalEffects 1.0

Controls.ApplicationWindow {
    id: __window
    /*!
       Set to \c true to include window decorations in your app's toolbar and hide
       the regular window decorations header.
     */
    property bool clientSideDecorations
    flags:   root.app.customFrame ? Qt.FramelessWindowHint : Qt.Window
    color: "transparent"
    /*!
       \qmlproperty Page initialPage

       The initial page shown when the application starts.
     */
    property alias initialPage: __pageStack.initialItem

    /*!
       \qmlproperty PageStack pageStack

       The \l PageStack used for controlling pages and transitions between pages.
     */
    property alias pageStack: __pageStack

    /*!
       \qmlproperty AppTheme theme

       A grouped property that allows the application to customize the the primary color, the
       primary dark color, and the accent color. See \l Theme for more details.
     */
    property alias theme: __theme

    AppTheme {
        id: __theme
    }

    ResizeArea{
        id:resizeArea
        anchors.fill: parent
        dragHeight: systemBar.height + 50
        anchors.margins: root.app.customFrame ? 5 : 0
        target: __window
        minSize: Qt.size(100,100)
        enabled: true

        RectangularGlow {
            id: outGlow
            width: __pageStack.width - parent.anchors.margins * 2
            height: __pageStack.height + __toolbar.height - parent.anchors.margins * 2 + systemBar.height
            x: 10
            y: 10
            visible: root.app.customFrame
            glowRadius: 10
            spread: 0.1
            color: "#A0000000"
            cornerRadius:  glowRadius

        }
    }

    SystemBar {
        id: systemBar
        visible: root.app.customFrame
        anchors.margins: 10
    }

    PageStack {
        id: __pageStack
        anchors {
            left: parent.left
            right: parent.right
            top: __toolbar.bottom
            bottom: parent.bottom
            margins: root.app.customFrame ? 10 : 0
            topMargin: root.app.customFrame ? systemBar.height : 0
        }

        onPushed: __toolbar.push(page)
        onPopped: __toolbar.pop(page)
        onReplaced: __toolbar.replace(page)
    }

    Toolbar {
        id: __toolbar
        clientSideDecorations: app.clientSideDecorations
        anchors.margins : root.app.customFrame ? 10 : 0
    }

    OverlayLayer {
        id: dialogOverlayLayer
        objectName: "dialogOverlayLayer"
    }

    OverlayLayer {
        id: tooltipOverlayLayer
        objectName: "tooltipOverlayLayer"
    }

    OverlayLayer {
        id: overlayLayer
    }

    width: Units.dp(800)
    height: Units.dp(600)

    Dialog {
        id: errorDialog

        property var promise

        positiveButtonText: "Retry"

        onAccepted: {
            promise.resolve()
            promise = null
        }

        onRejected: {
            promise.reject()
            promise = null
        }
    }

    /*!
       Show an error in a dialog, with the specified secondary button text (defaulting to "Close")
       and an optional retry button.

       Returns a promise which will be resolved if the user taps retry and rejected if the user
       cancels the dialog.
     */
    function showError(title, text, secondaryButtonText, retry) {
        if (errorDialog.promise) {
            errorDialog.promise.reject()
            errorDialog.promise = null
        }

        errorDialog.negativeButtonText = secondaryButtonText ? secondaryButtonText : "Close"
        errorDialog.positiveButton.visible = retry || false

        errorDialog.promise = new Promises.Promise()
        errorDialog.title = title
        errorDialog.text = text
        errorDialog.open()

        return errorDialog.promise
    }

    Component.onCompleted: {

        Units.pixelDensity = Qt.binding(function() {
            return Screen.pixelDensity
        });

        Device.type = Qt.binding(function () {
            var diagonal = Math.sqrt(Math.pow((Screen.width/Screen.pixelDensity), 2) +
                    Math.pow((Screen.height/Screen.pixelDensity), 2)) * 0.039370;

            if (diagonal >= 3.5 && diagonal < 5) { //iPhone 1st generation to phablet
                Units.multiplier = 1;
                return Device.phone;
            } else if (diagonal >= 5 && diagonal < 6.5) {
                Units.multiplier = 1;
                return Device.phablet;
            } else if (diagonal >= 6.5 && diagonal < 10.1) {
                Units.multiplier = 1;
                return Device.tablet;
            } else if (diagonal >= 10.1 && diagonal < 29) {
                return Device.desktop;
            } else if (diagonal >= 29 && diagonal < 92) {
                return Device.tv;
            } else {
                return Device.unknown;
            }
        });

        // Nasty hack because singletons cannot import the module they were declared in, so
        // the grid unit cannot be defined in either Device or Units, because it requires both.
        Units.gridUnit = Qt.binding(function() {
            return Device.type === Device.phone || Device.type === Device.phablet
                    ? Units.dp(48) : Device.type == Device.tablet ? Units.dp(56) : Units.dp(64)
        })
    }

    function colorLuminance(hex, lum) {
    	hex = String(hex).replace(/[^0-9a-f]/gi, '');
    	if (hex.length < 6) {
    	       hex = hex[0]+hex[0]+hex[1]+hex[1]+hex[2]+hex[2];
    	}
    	lum = lum || 0;
    	var rgb = "#", c, i;
    	for (i = 0; i < 3; i++) {
    		c = parseInt(hex.substr(i*2,2), 16);
    		c = Math.round(Math.min(Math.max(0, c + (c * lum)), 255)).toString(16);
    		rgb += ("00"+c).substr(c.length);
    	}

    	return rgb;
    }


}