import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2
import QtQuick.Window 2.2
import QtQuick.Layouts 1.1
import "Utils.js" as Utils

Item {
    id: gridContainer

    property bool forExporting: false
    property bool forFillingIn: false  // is someone supposed to be doing the crossword?
    property bool autoMoveDown: false
    property string directionArrow: autoMoveDown ? "↓" : "→"
    property alias rows: xGrid.rows
    property alias columns: xGrid.columns
    property alias gridRepeater: repeater

    function getDataForPdf() {
        /* Returns an array of [dims, states, letters, numbers]
         */
        var partA = Utils.collectData().slice(0, 3);
        var partB = Utils.collectData().pop();

//        console.log(partA[0], partA[1], partA[2]);
        partA.push(partB);
//        console.log(partA[0], partA[1], partA[2], partA[3]);
//        console.log(partB);

        return partA;
    }

    function setDataForPdf(data) {
        /* data = [dims, states, letters, numbers]
          */

        var dims = data[0];
        var states = data[1];
        var letters = data[2];
        var numbers = data[3];

        gridContainer.rows = dims[0];
        gridContainer.columns = dims[1];

        for (var i = 0; i < gridContainer.columns * gridContainer.rows; i++) {
            var box = gridRepeater.itemAt(i);
            box.state = states[i];
            box.number = numbers[i];
            if(!gridContainer.forFillingIn) {
                box.letter = letters[i];
            }
            states[i] == "" ? box.color = Utils.WHITE : box.color = Utils.BLACK;
        }

        return;
    }

    visible: false
    width: 700
    height: 700

    Grid {
        id: xGrid

        Repeater {
            id: repeater

            model: parent.columns * parent.rows
            onItemAdded: {
                // Only perform after the grid has been assembled.
                if ((index + 1 == xGrid.rows * xGrid.columns) && !forExporting)
                    Utils.assignNums(xGrid.rows, xGrid.columns)
            }

            Square { }
        }
    }
}
