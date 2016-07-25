import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2
import QtQuick.Window 2.2
import QtQuick.Layouts 1.1
import "Utils.js" as Utils

ApplicationWindow {
    id: root

    property int extraHeight
    property bool stateChanged: false
    property string currentFileUrl
    property string formerFileUrl

    function concat_clues(clues, nums) {
        /* Combines the clue numbers and clues into an array of strings
          for pdf exporting.
          */
        var formatted_clues = []
        for(var i = 0; i < clues.length; i++) {
            var text_concat = nums[i] + ".  " + clues[i];
            formatted_clues.push(text_concat);
        }
        return formatted_clues;
    }

    function displayPdfLocation(fileName) {
        // Slot connected to C++ Export export_completed(QVariant) signal.
        pdfDialog.informativeText = fileName;
        pdfDialog.open();
    }

    function overwriteFile() {
        // Slot connected to C++ FIleIO fileExists() signal.
        replaceDialog.open();
    }

    function afterSaving() {
        /* Slot connected to C++ FileIO fileSaved() signal.
          1. resets the stateChanged property
          2. loads (if applicable) the pending file to open / newly make
        */
        root.stateChanged = false;

        if(saveBeforeOpenDialog.pendingOpen == true) {
            Utils.loadData(FileIO.on_open(openDialog.fileUrl));
            root.currentFileUrl = openDialog.fileUrl;
            saveBeforeOpenDialog.pendingOpen = false;
        }

        if(saveBeforeNewDialog.pendingNew == true) {
            startUpWindow.newGrid();
            root.currentFileUrl = "";
            saveBeforeNewDialog.pendingNew = false;
        }
    }

    function save() {
        /* Chooses whether or not the saveDialog needs to be shown.
          */
        currentFileUrl == "" ? saveDialog.open() : FileIO.on_save(currentFileUrl, Utils.saveData());
    }

    visible: true
    title: metadataForm.puzzleName == "" ? qsTr("Crossword Maker 5100") : metadataForm.puzzleName;
    color: palette.window
    contentItem {
        implicitWidth: xWord.width
        implicitHeight: xWord.height
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
                onTriggered: root.save();
            }

            MenuItem {
                text: qsTr("Save As")
                shortcut: StandardKey.SaveAs
                enabled: xWord.rows == -1 ? false : true;
                onTriggered: saveDialog.open();
            }
            MenuSeparator { }
            MenuItem {
                text: qsTr("Export to PDF")
                shortcut: StandardKey.Print
                onTriggered:  {
                    var text_data = Utils.getCluesAndInfo();  // [clues, metadata, numbers]
                    var across_clues = text_data[0][0]
                    var down_clues = text_data[0][1]
                    var across_nums = Utils.collectClueNums()[0]
                    var down_nums = Utils.collectClueNums()[1]

                    var formatted_acrosses = concat_clues(across_clues, across_nums);
                    var formatted_downs = concat_clues(down_clues, down_nums);
                    formatted_acrosses.unshift("ACROSS");
                    formatted_downs.unshift("DOWN");

                    ExportPDF.add_clues(formatted_acrosses, formatted_downs);  // adding clues
                    ExportPDF.add_metadata(text_data[1])  // adding metadata list

                    pdfXwordBlank.setDataForPdf(pdfXwordBlank.getDataForPdf());
                    pdfXwordAnswers.setDataForPdf(pdfXwordAnswers.getDataForPdf());

                    pdfXwordBlank.grabToImage(function(blankXword) {
                        ExportPDF.add_image(blankXword.image);
                    });
                    pdfXwordAnswers.grabToImage(function(answersXword) {
                        ExportPDF.add_image(answersXword.image);

                        ExportPDF.export_pdf(xWord.columns);  // The actual printing function.
                    });
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
                    clueEditor.visible = true;
                }
            }
            MenuItem {
                text: qsTr("Puzzle Info")
                onTriggered: metadataForm.visible = true;
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

    // Exporting PDF
    MessageDialog {
        id: pdfDialog

        title: "Crossword Successfully Exported"
        text: "Your crossword was saved to the following location: "
        icon: StandardIcon.Information
        standardButtons: StandardButton.Ok
    }

    // FILE IO
    FileDialog {
        id: saveDialog
        selectExisting: false
        title: "Type a name for your file to save"
        folder: AppPath
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
        folder: AppPath
        onFileUrlChanged: {
            if(root.stateChanged) {
                saveBeforeOpenDialog.open();
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
            // can remove below line.
            root.stateChanged = true;
        }
    }

    MessageDialog {
        id: saveBeforeOpenDialog

        property bool pendingOpen: false

        icon: StandardIcon.Question
        text: "There are unsaved changes to the current crossword. Do you want to save?"
        standardButtons: StandardButton.Yes | StandardButton.No | StandardButton.Cancel
        onYes: {
            pendingOpen = true;
            root.save();
        }
        onNo: {
            Utils.loadData(FileIO.on_open(openDialog.fileUrl));
            root.currentFileUrl = openDialog.fileUrl;
            root.stateChanged = false;
        }
    }

    MessageDialog {
        id: saveBeforeNewDialog

        property bool pendingNew: false

        icon: StandardIcon.Question
        text: "There are unsaved changes to the current crossword. Do you want to save?"
        standardButtons: StandardButton.Yes | StandardButton.No | StandardButton.Cancel
        onYes: {
            pendingNew = true;
            root.save();
        }
        onNo: {
            startUpWindow.newGrid();
            root.currentFileUrl = "";
        }
        onRejected: startUpWindow.closeWindow();
    }

    // SETTING SIZE OF CROSSWORD
    StartUpWindow {
        id: startUpWindow
        onSaveBeforeNew: saveBeforeNewDialog.open();
    }

    // CROSSWORD METADATA
    MetadataForm { id: metadataForm }

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
    CrosswordGrid { id: xWord }

    // FOR PDF EXPORTING
    CrosswordGrid {
        id: pdfXwordBlank

        forExporting: true
        forFillingIn: true
    }

    CrosswordGrid {
        id: pdfXwordAnswers

        forExporting: true
    }
}
