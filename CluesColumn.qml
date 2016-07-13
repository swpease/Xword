import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2
import QtQuick.Window 2.2
import QtQuick.Layouts 1.1
import "Utils.js" as Utils


Flickable {
    id: colFlick

    property alias headerName: directionName.text
    property alias model: cluesRepeater.model

    function getCluesText() {
        /* Returns an array of the strings of clues. */

        var clues = [];

        for (var i = 0; i < cluesRepeater.model; i++) {
            var clue = cluesRepeater.itemAt(i);
            clues.push(clue.text);
        }

        return clues;
    }

    function setCluesText(clueTexts) {
        /* clueTexts: an array of clues.
          Populates the clues from a saved crossword.
          */

        for (var i = 0; i < cluesRepeater.model; i++) {
            var clue = cluesRepeater.itemAt(i);
            clue.text = clueTexts[i];
        }
    }

    Layout.minimumWidth: 200
    contentHeight: cluesHeader.height + cluesCol.height + cluesCol.anchors.topMargin + cluesCol.spacing

    TextField { id: dummy; visible: false }  // To get the label heights right

    Rectangle {
        id: cluesHeader

        width: colFlick.width
        height: 40
        gradient: Gradient {
            GradientStop { position: 1.0; color: palette.window }
            GradientStop { position: 0.0; color: "#8888ff" }
        }

        Text { id: directionName; anchors.centerIn: parent }
    }

    Column {
        id: clueNumsCol

        anchors { left: parent.left; leftMargin: 20; top: cluesHeader.bottom; topMargin: 3 }
        spacing: 2

        Repeater {
            id: clueNumsRepeater

            model: cluesRepeater.model

            Label {
                id: clueLabel

                height: dummy.height
                // need component.oncompleted?
                text: {
                    if (colFlick.headerName == "Across") {
                        text = Utils.collectClueNums()[0][index]
                    } else if (colFlick.headerName == "Down"){
                        text = Utils.collectClueNums()[1][index]
                    } else {
                        console.log("need to change something in clueLabel")
                    }
                }
            }
        }
    }

    Column {
        id: cluesCol

        anchors { left: clueNumsCol.right; leftMargin: 20; top: cluesHeader.bottom; topMargin: 3 }
        spacing: 2

        Repeater {
            id: cluesRepeater

            model: 0
            anchors.horizontalCenter: parent.horizontalCenter

            TextField {
                id: clueEdit

                width: Math.floor(colFlick.width * 2 / 3)
                placeholderText: "Enter a clue..."
                onEditingFinished: focus = false;
                onTextChanged: root.stateChanged = true;
            }
        }
    }
}
