import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2
import QtQuick.Window 2.2
import QtQuick.Layouts 1.1
import "Utils.js" as Utils

/*
  Could potentially use aliases in order to split the major would-be Components up,
  but it seems like a hassle for something that won't be re-instantiated ever.
  */


ApplicationWindow {
    id: root
    visible: true
//    width: 640  // LOOK INTO IMPLICIT WIDTH AND HEIGHT
//    height: 480
    title: qsTr("Crossword Maker 5100")
    color: palette.window
    contentItem {
        implicitWidth: gridContainer.width
        implicitHeight: gridContainer.height
    }
    property int extraHeight: contentItem.implicitHeight
    Component.onCompleted: extraHeight = height - contentItem.implicitHeight
    onClosing: console.log(extraHeight, height, contentItem.implicitHeight)

    TextField {
        // This is a dummy object so that I can access the implicit height of
        // a text field so that I can align the clue numbers (tye: Label{}) with the
        // clue editing TextFields.
        visible: false
        id: dummy
    }

    SystemPalette { id: palette }  // Now can use native coloring schemes.

    Text {
        anchors.centerIn: parent
        text: "Welcome to Scott's amazing crossword puzzle editor!\n\
Hit (CTRL+N) or go to FILE -> NEW to get started!"
        font.pointSize: 24
        color: palette.windowText
    }

//    Image {
//        source: "go-next-200px.png"
//        width: 25
//        height: 25
//    }


    menuBar: MenuBar {
        Menu {
            title: qsTr("File")
            MenuItem {
                text: qsTr("&New")
                shortcut: StandardKey.New
                onTriggered: {
                    startUp.visible = true;
                    startUp.raise();
                }
            }
        }
        Menu {
            title: qsTr("Edit")
            MenuItem {
                text: qsTr("Clues")
                onTriggered: {
                    var numClues = Utils.numberOfClues();
                    acrossCluesRepeater.model = numClues[0];
                    downCluesRepeater.model = numClues[1];
                    clueEditor.visible = true;
                }
            }
        }
    }
    
    toolBar: ToolBar {
        RowLayout {
            anchors.fill: parent
            CheckBox {
                id: blackBoxToggle
                text: qsTr("Edit Blank Spaces")
            }
            CheckBox {
                id: symmetric
                text: qsTr("Auto-symmetry")
            }
        }
    }



    // BRINGS UP A WINDOW FOR CREATING A NEW XWORD PROJECT
    Window {
        id: startUp
        visible: false
        height: root.height / 2
        width: root.width
        maximumHeight: root.height / 2
        maximumWidth: root.width
        color: palette.window

        //Keys.onReturnPressed: startUpOK.clicked()   // IS THIS RIGHT??? No.

        Shortcut {  // This WORKS, so I'm not sure why it's misdiagnosing it.
            sequence: StandardKey.Close
            onActivated: startUp.close()
        }

        ColumnLayout {
            id: column
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: column.spacing

            // Setting the Xword dimensions:
            GroupBox {
                Layout.fillWidth: true
                title: "Crossword Puzzle Size"
                RowLayout {
                    anchors.fill: parent
                    Keys.onReturnPressed: {
                        if (numHigh.value && numWide.value) {
                        startUpOK.clicked();
                        }
                    }
                    ColumnLayout {
                        Label { text: "Crossword Height" }
                        SpinBox {
                            id: numHigh
                            maximumValue: 100
                            suffix: "  squares"
                        }
                    }
                    ColumnLayout {
                        Label { text: "Crossword Width" }
                        SpinBox {
                            id: numWide
                            maximumValue: 100
                            suffix: "  squares"
                        }
                    }
                }
            }

            // Buttons to accept/cancel:
            GroupBox {
                Layout.fillWidth: true
                RowLayout {
                    anchors.fill: parent
                    Item { Layout.fillWidth: true }
                    Button {
                        id: startUpOK
                        text: "OK"
                        isDefault: true
                        onClicked: {
                            gridContainer.cols = numWide.value
                            gridContainer.rows = numHigh.value

                            gridContainer.visible = true
//                            clueEditor.visible = true

                            numHigh.value = 0
                            numWide.value = 0
                            numHigh.focus = true
                            startUp.close()
                        }
                    }

                    Button {
                        id: startUpCancel
                        text: "Cancel"
                        onClicked: {
                            numHigh.value = 0
                            numWide.value = 0
                            numHigh.focus = true
                            startUp.close()
                        }
                    }
                }
            }
        }
    }



    // MAKING THE CLUES FOR THE CROSSWORD
    Window {
        id: clueEditor
        title: "Clue Editor 2400"
        visible: false
        height: 500
        width: 500
//        property alias numAcrosses: acrossCluesRepeater.model
//        property alias numDowns: downCluesRepeater.model

        Shortcut {  // This WORKS, so I'm not sure why it's misdiagnosing it.
            sequence: StandardKey.Close
            onActivated: clueEditor.close()
        }

        SplitView {
            id: theSplit
            anchors.fill: parent
            visible: true

            // TODO: wrap Flickable with a Text Header in an Item{} (same for the other Flickable)
            // Item {id: acrossClues } with Rectangle or Text, then the Flickable anchored below it

            Flickable {
                id: acrossColFlick
                width: clueEditor.width / 2
//                anchors.top: acrossCluesHeader.bottom
                Layout.minimumWidth: 200
                contentHeight: acrossCluesCol.height

                Rectangle {
                    id: acrossCluesHeader
                    width: clueEditor.width / 2
                    height: 40
                    color: "blue"
                    Text {
                        anchors.centerIn: parent
                        text: "Across"
                    }
                }

                Column {
                    id: acrossClueNumsCol
//                    columns: 2
//                    rows: acrossCluesRepeater.model
//                    columnSpacing: 20
//                    rowSpacing: 2
//                    flow: GridLayout.TopToBottom
                    anchors.left: parent.left
                    anchors.leftMargin: 20
                    anchors.top: acrossCluesHeader.bottom
                    anchors.topMargin: 3
                    spacing: 2

                    Repeater {
                        id: acrossClueNumsRepeater
                        model: acrossCluesRepeater.model

                        Label {
                            id: acrossClueLabel
                            height: dummy.height
                            text: Utils.collectClueNums()[0][index]
                        }
                    }
                }
                Column {
                    id: acrossCluesCol
                    anchors.left: acrossClueNumsCol.right
                    anchors.leftMargin: 20
                    anchors.top: acrossCluesHeader.bottom
                    anchors.topMargin: 3
                    spacing: 2

                    Repeater {
                        id: acrossCluesRepeater
                        model: 0
                        anchors.horizontalCenter: parent.horizontalCenter

                        TextField {
                            id: acrossClueEdit
                            width: Math.floor(acrossColFlick.width * 2 / 3)
                            placeholderText: "Enter a clue..."
                            onEditingFinished: {
                                focus = false
                            }
                        }
                    }
                }
            }

            Flickable {
                id: downColFlick
                width: clueEditor.width / 2
                Layout.minimumWidth: 150
                contentHeight: downCluesCol.height

                Column {
                    id: downCluesCol
                    spacing: 2
                    anchors.horizontalCenter: parent.horizontalCenter

                    Repeater {
                        id: downCluesRepeater
                        model: 0  // Just point to what it needs to.
                        anchors.horizontalCenter: parent.horizontalCenter  // Stacking the anchors...

                        TextField {
                            id: downClueEdit
                            width: { downColFlick.width < 200 ? 133 : downColFlick.width * 2 / 3 }
                            placeholderText: "Enter a clue..."
                            onEditingFinished: {
                                displayText.text = downClueEdit.text
                                focus = false
                            }
                        }
//                        Label{}
                    }
                }
            }
        }
    }



    // THE ACTUAL CROSSWORD GRID
    // Changing from Window{} to Item{}, commenting out onClosing:
    Item {
        id: gridContainer
        visible: false
        width: 700
        height: 700
        property int rows
        property int cols

        //onClosing: clueEditor.visible = false

        Grid {
            id: xGrid
            columns: gridContainer.cols
            rows: gridContainer.rows

            property int autoMoveDirection

            Repeater{
                id: gridRepeater
                model: parent.columns * parent.rows
                onItemAdded: {
                    // Only perform after the grid has been assembled.
                    if (index + 1 == xGrid.rows * xGrid.columns) {
                        Utils.assignNums(xGrid.rows, xGrid.columns)
                    }
                }

                Rectangle {
                    id: box
                    property int constIndex: index
                    property string number  // Used to pass assigned clue numbers to the Text{id: number} children
                    // Used as a string instead of an int to be able to pass empty values
                    property string letter
                    property string clue

//                    width: gridContainer.width / xGrid.columns
//                    height: gridContainer.height / xGrid.rows
                    width: root.width / xGrid.columns
                    height: (root.height - root.extraHeight) / xGrid.rows
                    border{
                        width: 1
                        color: Utils.BLACK
                    }
                    color: palette.window
                    onFocusChanged: {
                        if (color != Utils.BLACK) {
                        color == palette.window ? color = Utils.LIGHTBLUE : color = palette.window
                        }
                    }

                    Keys.onPressed: {
                        Utils.keysMove(event, index)

                        if (Utils.KEYS.indexOf(event.key) !== -1 && blackBoxToggle.checked == false && color != Utils.BLACK) {
                            letter = event.text.toUpperCase();
                            Utils.autoMove(box);
                            event.accepted = true;
                        }

                        if (event.key == Qt.Key_Backspace || event.key == Qt.Key_Delete) {
                            letter = "";
                            event.accepted = true;
                        }
                    }

                    Text {
                        id: letterChild
                        anchors {
                            centerIn: parent
                            horizontalCenterOffset: parent.width * 0.05
                            verticalCenterOffset: parent.height * 0.05
                        }
                        text: parent.letter
                        font.pixelSize: parent.height * 0.7
                    }

                    Text {
                        id: numberChild
                        text: parent.number
                        anchors {
                            left: parent.left
                            leftMargin: 2
                            top: parent.top
                            topMargin: 2
                        }

                        font.pixelSize: parent.width * 0.25
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: { border.color = Utils.BLUE; border.width = 2 }
                        onExited: { border.color = Utils.BLACK; border.width = 1 }
                        onClicked: {
                            if (!parent.focus) {
                                xGrid.autoMoveDirection %= 2;
                            } else {
                                xGrid.autoMoveDirection += 1;
                            }

                            parent.focus = true
                            if (blackBoxToggle.checked) {
                                Utils.blackWhite(parent)
                                Utils.assignNums(xGrid.rows, xGrid.columns)
                            }
                        }
                    }
                }
            }
        }
    }

}

