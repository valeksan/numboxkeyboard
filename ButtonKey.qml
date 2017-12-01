import QtQuick 2.7

Rectangle {
    id: button_border
    width: 100
    height: 50

    property string text: ""
    property string textOff: text
    property string textOn: text

    //property color name: value
    color: "#f7a363"
    property color colorOff: color
    property color colorOn: Qt.lighter(color, 1.5)
    property color colorDimmed: Qt.darker(colorOff, 1.5)

    property color textColor: "black"
    property color textColorOn: textColor
    property color textColorOff: textColor
    property color textColorDimmed: Qt.lighter(textColor, 1.3)

    property int textPixelSizeValue: 14
    property int gradientBorder: 0
    property int gradientBorderWidth: 10
    property bool enableGradientBorder: false

    property alias font: button_state_text.font

    property bool enableOnPressIndicate: true
    property bool trigger_press: false

    signal clicked
    signal pressed
    signal released

    state: "off"

    function putColor() {
        if(enableOnPressIndicate) {
            if(trigger_press) {
                switch(state) {
                case "off": return colorOn;
                case "on": return colorOff;
                case "dimmed": return colorDimmed;
                }
            } else {
                switch(state) {
                case "off": return colorOff;
                case "on": return colorOn;
                case "dimmed": return colorDimmed;
                }
            }
        } else {
            switch(state) {
            case "off": return colorOff;
            case "on": return colorOn;
            case "dimmed": return colorDimmed;
            }
        }
        return color;
    }

    Rectangle
    {
        id: button
        anchors.centerIn: button_border
        height: enableGradientBorder ? button_border.height - gradientBorderWidth : button_border.height
        color: putColor()
        width: enableGradientBorder ? button_border.width - gradientBorderWidth : button_border.width
        radius: gradientBorder
        border.color: Qt.darker(color, 1.5)
        Text {
            id: button_state_text
            anchors.fill: parent
            anchors.margins: 2
            font.bold: true
            font.pixelSize: 16
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            wrapMode: Text.WordWrap
        }
        MouseArea {
            anchors.fill: parent
            enabled: (button_border.state !== "dimmed")
            onClicked: { button_border.clicked(); }
            onPressed: {
                trigger_press = true
                button_border.pressed();
            }
            onReleased: {
                trigger_press = false
                button_border.released();
            }
        }

    }

    states: [
        State {
            name: "off";
            PropertyChanges { target: button; color: colorOff }
            PropertyChanges { target: button_state_text; color: textColorOff; text: textOff; }
        },
        State {
            name: "on";
            PropertyChanges { target: button; color: colorOn }
            PropertyChanges { target: button_state_text; color: textColorOn; text: textOn; }
        },
        State {
            name: "dimmed"
            PropertyChanges { target: button; color: colorDimmed }
            PropertyChanges { target: button_state_text; color: "black"; text: textOff; }
        }

    ]

    radius: gradientBorder
    gradient: enableGradientBorder ? defaultGradient : null

    Gradient {
        id: defaultGradient
        GradientStop {
            position: 0.00;
            color: "#808080";
        }
        GradientStop {
            position: 0.49;
            color: "#ffffff";
        }
        GradientStop {
            position: 0.99;
            color: "#808080";
        }
    }
}
