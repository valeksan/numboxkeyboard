import QtQuick 2.7
import QtQuick.Window 2.2

Window {
    visible: true
    width: 640
    height: 480
    title: "Example"
    contentItem.antialiasing: true

    Text {
        id: title
        text: "Click on the indicator"
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
                    if (!numKeyboard.isVisible()) {
                        //numKeyboard.show(); // and so you can!
                        //numKeyboard.show(1.8); and so you can!
                        numKeyboard.show(textEdit.text);
                    }
                }
            }
        }
    }

    NumBoxKeyboard {
        id: numKeyboard
        minimumValue: -5.5
        maximumValue: 10.9
        precision: 3
        decimals: 3
        antialiasing: true
        placeholderValue: textEdit.text
        //enableSequenceGrid: true // if you want to change the step grid
        //sequenceStep: 0.004 // grid step (any)
        anchors.fill: parent
    }

    Connections {
        target: numKeyboard
        onOk: {
            textEdit.text = number;
        }
    }
}
