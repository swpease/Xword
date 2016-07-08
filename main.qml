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
                    startUpWindow.visible = true;
                    startUpWindow.raise();
                }
            }
            MenuItem {
                text: qsTr("Open")
                shortcut: StandardKey.Open
                onTriggered: openDialog.open();
            }
            MenuItem {
                text: qsTr("Save")
                shortcut: StandardKey.Save
            }

            MenuItem {
                // do something like: have a bool property called save vs saveas
                // then check if the fileurl is empty for the saveDialog
                // put the logic in the onTriggered thing below
                text: qsTr("Save As")
                shortcut: StandardKey.SaveAs
                onTriggered: saveDialog.open();
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
                    clueEditor.visible = true;
                }
            }
            MenuItem {
                text: qsTr("Resquareify")
                onTriggered: {
                    var contentHeight = root.height - root.extraHeight
                    root.width > contentHeight ? root.width = contentHeight : root.height = root.width + root.extraHeight
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
        text: "Welcome to the crossword puzzle editor!\nPress ⌘N or go to FILE → NEW to get started!"
        horizontalAlignment: Text.AlignHCenter
        font.pointSize: 24
        color: palette.windowText
    }

    // FILE IO
    FileDialog {
        id: saveDialog
        selectExisting: false
        title: "Type a name for your file to save"
        folder: shortcuts.home
        onFileUrlChanged: FileIO.on_saveAs(fileUrl, Utils.saveData());
    }

    FileDialog {
        id: openDialog
        title: "Select a file to open:"
        nameFilters: [ "Crossword files: (*.xwd)" ]
        folder: shortcuts.home
        onFileUrlChanged: Utils.loadData(FileIO.on_open(fileUrl))
    }

    // SETTING SIZE OF CROSSWORD
    StartUpWindow { id: startUpWindow }

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

        Shortcut {
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

        Grid {
            id: xGrid
            // xGrid.rows and xGrid.columns set by:
            //     (1) StartUpWindow.qml
            //     (2) openDialog

            property bool autoMoveDown: false
            property string directionArrow: autoMoveDown ? "↓" : "→"

            Repeater {
                id: gridRepeater

                model: parent.columns * parent.rows
                onItemAdded: {
                    // Only perform after the grid has been assembled.
                    if (index + 1 == xGrid.rows * xGrid.columns)
                        Utils.assignNums(xGrid.rows, xGrid.columns)
                }

                Square { }
            }
        }
    }
}
