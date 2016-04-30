import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2
import QtQuick.Window 2.2
import QtQuick.Layouts 1.1
import "Utils.js" as Utils

/*
  https://www.ics.com/files/qtdocs/qml-extending-types.html
  excerpt:
  Aliased properties are also useful for allowing external objects
  to directly modify and access child objects in a component.
  [...]
  Obviously, exposing child objects in this manner should be done with care,
  as it allows external objects to modify them freely.
  */


/*
  Could potentially use aliases in order to split the major would-be Components up,
  but it seems like a hassle for something that won't be re-instantiated ever.
  */


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

    SystemPalette { id: palette }  // Now can use native coloring schemes.

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
        title: "Clue Editor 2400"
        visible: false
        height: 500
        width: 500
        color: palette.window
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

            TextField {
                // This is a dummy object so that I can access the implicit height of
                // a text field so that I can align the clue numbers (tye: Label{}) with the
                // clue editing TextFields.
                visible: false
                id: dummy
            }

            // TODO: wrap Flickable with a Text Header in an Item{} (same for the other Flickable)
            // Item {id: acrossClues } with Rectangle or Text, then the Flickable anchored below it

            // I could make this its own .qml custom type...
            Flickable {
                id: acrossColFlick
                width: clueEditor.width / 2
//                anchors.top: acrossCluesHeader.bottom
                Layout.minimumWidth: 200
                Layout.fillWidth: true
                contentHeight: acrossCluesCol.height

                Rectangle {
                    id: acrossCluesHeader

                    width: acrossColFlick.width
                    height: 40
//                    color: "#8888ff"
                    gradient: Gradient {
                        GradientStop { position: 1.0; color: palette.window }
                        GradientStop { position: 0.0; color: "#8888ff" }
                    }

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

            property bool autoMoveDown: false
            property string directionArrow: autoMoveDown ? "↓" : "→" //Put here or in 'box'?

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
                    border{
                        width: 1
                        color: Utils.BLACK
                    }
                    color: focus ? Utils.LIGHTBLUE : palette.window

                    states: [
                        State {
                            name: "BLANKSPACE"
                            PropertyChanges {
                                target: box
                                color: focus ? Utils.DARKGREY : Utils.BLACK
                            }
                        }
                    ]
                    onFocusChanged: focus ? directionChild.text = xGrid.directionArrow : directionChild.text = ""

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
                }
            }
        }
    }
}

