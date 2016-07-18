import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2
import QtQuick.Window 2.2
import QtQuick.Layouts 1.1

Window {
    id: metaData

    property alias puzzleName: puzzleNameText.text
    property alias date: dateText.text
    property alias author: authorText.text

    visible: false
    height: 170
    width: 300

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

        TextField {
            id: puzzleNameText
            width: 80
            height: 20
            font.pixelSize: 12
        }

        TextField {
            id: dateText
            width: 80
            height: 20
            font.pixelSize: 12
        }

        TextField {
            id: authorText
            width: 80
            height: 20
            font.pixelSize: 12
        }
    }
}
