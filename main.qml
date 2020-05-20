import QtQuick 2.7
import QtQuick.Window 2.2

Window {
    visible: true
    width: 640
    height: 480
    title: qsTr("Пример ввода")
    contentItem.antialiasing: true

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
        text: "000"
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
                        //num_keyboard.show(); // и так можно!
                        //num_keyboard.show(1.8); // и так можно!
                        num_keyboard.show(textEdit.text);
                    }
                }
            }
        }
    }

    NumBoxKeyboard {
        id: num_keyboard
        minimumValue: 40
        maximumValue: 300
        precision: 0
        decimals: 3
        antialiasing: true
        placeholderValue: textEdit.text
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
