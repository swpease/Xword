import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2
import QtQuick.Window 2.2
import QtQuick.Layouts 1.1

Window {
    id: startUp

    function closeWindow()
    {
        numHigh.value = 0;
        numWide.value = 0;
        numHigh.focus = false;
        numWide.focus = false;
        startUp.close();
    }

    visible: false
    height: 150
    width: root.width * 0.7
    maximumHeight: root.height / 2
    maximumWidth: root.width
    color: palette.window

    Shortcut {
        sequence: StandardKey.Close
        onActivated: closeWindow();
    }

    ColumnLayout {
        id: column

        anchors { top: parent.top; left: parent.left; right: parent.right; margins: column.spacing }

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
                    SpinBox { id: numHigh; maximumValue: 100; suffix: "  squares" }
                }

                ColumnLayout {
                    Label { text: "Crossword Width" }
                    SpinBox { id: numWide; maximumValue: 100; suffix: "  squares" }
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
                        xGrid.columns = numWide.value
                        xGrid.rows = numHigh.value
                        gridContainer.visible = true

                        root.stateChanged = true;
                        closeWindow();
                    }
                }

                Button {
                    id: startUpCancel

                    text: "Cancel"
                    onClicked: closeWindow();
                }
            }
        }
    }
}
