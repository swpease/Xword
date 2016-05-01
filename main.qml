import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2
import QtQuick.Window 2.2
import QtQuick.Layouts 1.1
import "Utils.js" as Utils

ApplicationWindow {
    id: root

    property int extraHeight

    visible: true
    title: qsTr("Crossword Maker 5100")
    color: palette.window
    contentItem {
        implicitWidth: gridContainer.width
        implicitHeight: gridContainer.height
        minimumWidth: 100
        minimumHeight: 100
    }
    Component.onCompleted: extraHeight = height - contentItem.implicitHeight

    menuBar: MenuBar {
        Menu {
            title: qsTr("File")
            MenuItem {
                text: qsTr("New")
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
                shortcut: "Ctrl+E"
                onTriggered: {
                    var numClues = Utils.numberOfClues();
                    acrossClues.model = numClues[0];
                    downClues.model = numClues[1];
//                    acrossCluesRepeater.model = numClues[0];
//                    downCluesRepeater.model = numClues[1];
                    clueEditor.visible = true;
                }
            }
        }
    }

    toolBar: ToolBar {
        RowLayout {
            anchors.fill: parent

            Item { Layout.fillWidth: true }
            CheckBox {
                id: blackBoxToggle
                text: qsTr("Edit Blank Spaces")
            }
            CheckBox {
                id: symmetric
                text: qsTr("Auto-symmetry")
                checked: true
            }
        }
    }

    SystemPalette { id: palette }

    Text {
        id: welcomeText

        anchors.centerIn: parent
        text: "Welcome to Scott's amazing crossword puzzle editor!\nPress ⌘N or go to FILE → NEW to get started!"
        horizontalAlignment: Text.AlignHCenter
        font.pointSize: 24
        color: palette.windowText
    }

    // BRINGS UP A WINDOW FOR CREATING A NEW XWORD PROJECT
    Window {
        id: startUp
        visible: false
        height: 150
        width: root.width * 0.7
        maximumHeight: root.height / 2
        maximumWidth: root.width
        color: palette.window

        //Keys.onReturnPressed: startUpOK.clicked()   // IS THIS RIGHT??? No.

        Shortcut {  // This WORKS, so I'm not sure why it's misdiagnosing it.
            sequence: StandardKey.Close
            onActivated: {
                numHigh.value = 0
                numWide.value = 0
                numHigh.focus = false
                numWide.focus = false
                startUp.close()
            }
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

                            numHigh.value = 0
                            numWide.value = 0
                            numHigh.focus = false
                            numWide.focus = false
                            startUp.close()
                        }
                    }

                    Button {
                        id: startUpCancel
                        text: "Cancel"
                        onClicked: {
                            numHigh.value = 0
                            numWide.value = 0
                            numHigh.focus = false
                            numWide.focus = false
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

        visible: false
        title: "Clue Editor 2400"
        height: 500
        width: 500
        minimumHeight: 100
        minimumWidth: acrossClues.Layout.minimumWidth + downClues.Layout.minimumWidth
        color: palette.window

        Shortcut {  // This WORKS, so I'm not sure why it's misdiagnosing it.
            sequence: StandardKey.Close
            onActivated: clueEditor.close()
        }

        SplitView {
            id: cluesSplit
            anchors.fill: parent
            visible: true

            CluesColumn {
                id: acrossClues

                headerName: "Across"
                width: clueEditor.width / 2
                Layout.fillWidth: true
            }

            CluesColumn {
                id: downClues

                headerName: "Down"
                width: clueEditor.width / 2
            }
        }
    }

    // THE ACTUAL CROSSWORD GRID
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

            property bool autoMoveDown: false
            property string directionArrow: autoMoveDown ? "↓" : "→" //Put here or in 'box'?

            columns: gridContainer.cols
            rows: gridContainer.rows

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
                    property alias number: numberChild.text
                    property alias letter: letterChild.text
                    property string clue

                    width: root.width / xGrid.columns
                    height: (root.height - root.extraHeight) / xGrid.rows
                    border { width: 1; color: Utils.BLACK }
                    color: focus ? Utils.LIGHTBLUE : palette.window

                    onFocusChanged: (focus && !blackBoxToggle.checked) ? directionChild.text = xGrid.directionArrow : directionChild.text = ""
                    onStateChanged: letter = ""

                    Keys.onPressed: {
                        Utils.keysMove(event, index)

                        if (Utils.KEYS.indexOf(event.key) !== -1 && !blackBoxToggle.checked && state == "") {
                            letter = event.text.toUpperCase();
                            Utils.autoMove(box);
                            event.accepted = true;
                        }
                        if (event.key == Qt.Key_Backspace || event.key == Qt.Key_Delete) {
                            if (blackBoxToggle.checked && state == "BLANKSPACE") {
                                Utils.blackWhite(box);
                                Utils.assignNums(xGrid.rows, xGrid.columns);
                            } else {
                                letter = "";
                            }
                            event.accepted = true
                        }
                        if ((event.key == Qt.Key_Enter || event.key == Qt.Key_Return) && blackBoxToggle.checked && state == "") {
                            Utils.blackWhite(box);
                            Utils.assignNums(xGrid.rows, xGrid.columns);
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
                                xGrid.autoMoveDown = !xGrid.autoMoveDown
                                directionChild.text = xGrid.directionArrow
                            }

                            parent.focus = true

                            if (blackBoxToggle.checked) {
                                Utils.blackWhite(parent)
                                Utils.assignNums(xGrid.rows, xGrid.columns)
                            }
                        }
                    }

                    Connections {
                        target: blackBoxToggle
                        onClicked: {
                            if (color == Utils.LIGHTBLUE || color == Utils.DARKGREY) {
                                directionChild.text == "" ? directionChild.text = xGrid.directionArrow : directionChild.text = "";
                            }
                        }
                    }

                    states: [
                        State {
                            name: "BLANKSPACE"
                            PropertyChanges {
                                target: box
                                color: focus ? Utils.DARKGREY : Utils.BLACK
                            }
                        }
                    ]
                }
            }
        }
    }
}
