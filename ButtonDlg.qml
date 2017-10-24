import QtQuick 2.7
import QtQuick.Controls 2.1

Button {
    id: control
    property color color: "white"
    property color backgroundColorOn: color
    property color backgroundColorOff: Qt.darker(color, 1.2)
    property color textColor: "black"
    property color textColorOn: textColor
    property color textColorOff: textColorOn
    property bool  textBoldByOn: true
    property bool on: false
    property alias textFont: button_text.font
    property int radius: 0
    property bool enableOnPressIndicate: true
    property bool trigger_press: false
    text: ""
    height: 50
    width: 180
    implicitHeight: height
    implicitWidth: width

    background: Rectangle {
        function getColor() {
            if(!enableOnPressIndicate) {
                return (control.on ? (control.down ? Qt.darker(control.backgroundColorOn,1.5):control.backgroundColorOn) : (control.down ? Qt.darker(control.backgroundColorOff,1.5) : control.backgroundColorOff));
            } else {
                if(trigger_press) return control.backgroundColorOn;
                else  return (control.on ? (control.down ? Qt.darker(control.backgroundColorOn,1.5):control.backgroundColorOn) : (control.down ? Qt.darker(control.backgroundColorOff,1.5) : control.backgroundColorOff));
            }
        }
        color: getColor()
        radius: control.radius
        border.color: Qt.darker(color, 1.5)
    }
    contentItem: Text {
        id: button_text
        text: control.text
        font {
            pixelSize: 16
            bold: control.textBoldByOn ? ( (!control.on) ? false : true) : control.font.bold
        }
        opacity: enabled ? 1.0 : 0.3
        color: control.down ? ( (control.on) ? Qt.darker(control.textColorOn,1.5) : Qt.darker(control.textColorOff,1.5)) : ( (control.on) ? control.textColorOn : control.textColorOff)
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    onPressed: {
        trigger_press = true
    }
    onReleased: {
        trigger_press = false
    }
}
