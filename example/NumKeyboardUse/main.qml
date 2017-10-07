import QtQuick 2.7
import QtQuick.Window 2.2

import "components" as Components

Window {
    visible: true
    width: 640
    height: 480
    title: qsTr("Пример ввода")

    Text {
        id: title
        text: "Нажмите на индикатор"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 20
        anchors.top: parent.top
        verticalAlignment: Text.AlignVCenter
    }

    TextEdit {
        id: textEdit
        text: "0.0"
        verticalAlignment: Text.AlignVCenter
        anchors.top: title.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 20
        readOnly: true
        Rectangle {
            anchors.fill: parent
            anchors.margins: -10
            color: "transparent"
            border.width: 1
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if(!num_keyboard.isVisible()) {
                        num_keyboard.placeholderValue = textEdit.text
                        num_keyboard.show()
                    }
                }
            }
        }        
    }

    Components.NumBoxKeyboard {
        id: num_keyboard
        minimumValue: -124.124
        maximumValue: 124.124
        precision: 3
        //enableSequenceGrid: true // если захочится пременить шаговую сетку
        //sequenceStep: 0.004 // шаг сетки (любой)
        anchors.fill: parent
    }

    Connections {
        target: num_keyboard
        onOk: {
            textEdit.text = number
        }
    }
}
