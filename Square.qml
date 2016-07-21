import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2
import QtQuick.Window 2.2
import QtQuick.Layouts 1.1
import "Utils.js" as Utils

/*
  Might want to clean up the references to objects in main.qml...
  https://doc.qt.io/qt-4.8/qdeclarativescope.html
  */

Rectangle {
    id: box

    property bool forExporting: false
    property int constIndex: index
    property alias number: numberChild.text
    property alias letter: letterChild.text

    width: forExporting == true ? (root.contentItem.implicitWidth / xWord.columns) : (root.width / xWord.columns);
    height: forExporting == true ? (root.contentItem.implicitHeight / xWord.rows) : ((root.height - root.extraHeight) / xWord.rows);
    border { width: 1; color: Utils.BLACK }
    color: focus ? Utils.LIGHTBLUE : palette.window

    onFocusChanged: (focus && !blackBoxToggle.checked) ? directionChild.text = xWord.directionArrow : directionChild.text = ""
    onStateChanged: {
        letter = "";
        root.stateChanged = true;
    }

    // Behavior producing some lag effect when switching states w/ symmetry on.
    // Looks bad anyway...

    Keys.onPressed: {
        Utils.keysMove(event, index)

        if (Utils.KEYS.indexOf(event.key) !== -1 && !blackBoxToggle.checked && state == "") {
            letter = event.text.toUpperCase();
            Utils.autoMove(box);
            root.stateChanged = true;
            event.accepted = true;
        }
        if (event.key == Qt.Key_Backspace || event.key == Qt.Key_Delete) {
            if (blackBoxToggle.checked && state == "BLANKSPACE") {
                Utils.blackWhite(box);
                Utils.assignNums(xWord.rows, xWord.columns);
            } else {
                letter = "";
            }
            root.stateChanged = true;
            event.accepted = true;
        }
        if ((event.key == Qt.Key_Enter || event.key == Qt.Key_Return) && blackBoxToggle.checked && state == "") {
            Utils.blackWhite(box);
            Utils.assignNums(xWord.rows, xWord.columns);
            root.stateChanged = true;
            event.accepted = true;
        }
    }

    Text {
        id: letterChild

        font.pixelSize: parent.height * 0.7
        anchors {
            centerIn: parent
            horizontalCenterOffset: parent.width * 0.05
            verticalCenterOffset: parent.height * 0.05
        }
    }

    Text {
        id: numberChild

        font.pixelSize: parent.width * 0.25
        anchors {
            left: parent.left
            leftMargin: 2
            top: parent.top
            topMargin: 2
        }
    }

    Text {
        id: directionChild

        font.pixelSize: parent.width * 0.25
        anchors {
            right: parent.right
            rightMargin: 2
            top: parent.top
            topMargin: 2
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: { border.color = Utils.BLUE; border.width = 2 }
        onExited: { border.color = Utils.BLACK; border.width = 1 }
        onClicked: {
            if (parent.focus && !blackBoxToggle.checked) {
                xWord.autoMoveDown = !xWord.autoMoveDown
                directionChild.text = xWord.directionArrow
            }

            parent.focus = true

            if (blackBoxToggle.checked) {
                Utils.blackWhite(parent)
                Utils.assignNums(xWord.rows, xWord.columns)
            }
        }
    }

    Connections {
        target: blackBoxToggle
        onClicked: {
            if (color == Utils.LIGHTBLUE || color == Utils.DARKGREY) {
                directionChild.text == "" ? directionChild.text = xWord.directionArrow : directionChild.text = "";
            }
        }
    }

    states: State {
        name: "BLANKSPACE"
        PropertyChanges {
            target: box
            color: focus ? Utils.DARKGREY : Utils.BLACK
        }
    }

    transitions: Transition {
        to: "*"
        ColorAnimation { duration: 100 }
    }
}
