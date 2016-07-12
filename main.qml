import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2
import QtQuick.Window 2.2
import QtQuick.Layouts 1.1
import "Utils.js" as Utils

ApplicationWindow {
    id: root

    property int extraHeight
    property bool stateChanged: false  // changes to check: clues, box state, box letter, grid existence
    property string currentFileUrl
    property string formerFileUrl
    onCurrentFileUrlChanged: stateChanged = false;  // Can I just do this?

    function overwriteFile() {
        // Slot connected to C++ FIleIO fileExists() signal.
        replaceDialog.open();
    }

    function save() {
        /* Chooses whether or not the saveDialog needs to be shown, depending
          on the current state vs the prior state.
          */
        currentFileUrl == "" ? saveDialog.open() : FileIO.on_save(currentFileUrl, Utils.saveData());
    }

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
            MenuSeparator { }
            MenuItem {
                text: qsTr("Save")
                shortcut: StandardKey.Save
                enabled: root.stateChanged;
                onTriggered: {
                    root.save();
                    root.stateChanged = false;
                }
            }

            MenuItem {
                text: qsTr("Save As")
                shortcut: StandardKey.SaveAs
                enabled: xGrid.rows == -1 ? false : true;  // Alt: test if currentFileUrl is empty
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
            MenuSeparator { }
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
        text: "Welcome to the crossword puzzle editor!"
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
        onFileUrlChanged: {
            root.formerFileUrl = root.currentFileUrl;
            root.currentFileUrl = fileUrl;
            FileIO.on_saveAs(fileUrl, Utils.saveData());
        }
    }

    FileDialog {
        id: openDialog
        title: "Select a file to open:"
        nameFilters: [ "Crossword files: (*.xwd)" ]
        folder: shortcuts.home
        onFileUrlChanged: {
            if(root.stateChanged) {
                saveOnOpenDialog.open();
            } else {
                Utils.loadData(FileIO.on_open(fileUrl));
                root.currentFileUrl = fileUrl;
            }
        }
    }

    MessageDialog {
        id: replaceDialog
        icon: StandardIcon.Question
        text: "A file with this name already exists. Do you want to replace it?"
        standardButtons: StandardButton.Yes | StandardButton.No | StandardButton.Cancel
        onYes: FileIO.on_save(saveDialog.fileUrl, Utils.saveData());
        onNo: {
            root.currentFileUrl = root.formerFileUrl;
            saveDialog.open();
        }
        onRejected: {
            root.currentFileUrl = root.formerFileUrl;
            replaceDialog.close();
        }
    }

    MessageDialog {
        id: saveOnOpenDialog
        icon: StandardIcon.Question
        text: "There are unsaved changes to the current crossword. Do you want to save?"
        standardButtons: StandardButton.Yes | StandardButton.No | StandardButton.Cancel
        onYes: {
            root.save();
            Utils.loadData(FileIO.on_open(openDialog.fileUrl));
            root.currentFileUrl = openDialog.fileUrl;
        }
        onNo: {
            Utils.loadData(FileIO.on_open(openDialog.fileUrl));
            root.currentFileUrl = openDialog.fileUrl;
        }
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
        Component.onDestruction: {
            if(root.stateChanged) {
                //window about saving
            }
        }

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
