import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2

Item {
    width: 300
    height: 170
    visible: true


    ColumnLayout {
        id: columnLayout1
        x: 8
        y: 9
        width: 112
        height: 153

        Label {
            id: label1
            text: qsTr("Puzzle name:")
            visible: true
        }

        Label {
            id: label2
            text: qsTr("Date:")
        }

        Label {
            id: label3
            text: qsTr("Author:")
        }
    }

    ColumnLayout {
        id: columnLayout2
        x: 122
        y: 9
        width: 170
        height: 153

        TextInput {
            id: textInput1
            width: 80
            height: 20
            text: qsTr("Text Input")
            font.pixelSize: 12
        }

        TextInput {
            id: textInput2
            width: 80
            height: 20
            text: qsTr("Text Input")
            font.pixelSize: 12
        }

        TextInput {
            id: textInput3
            width: 80
            height: 20
            text: qsTr("Text Input")
            font.pixelSize: 12
        }
    }
}

