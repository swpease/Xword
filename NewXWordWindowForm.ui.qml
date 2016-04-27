import QtQuick 2.4
import QtQuick.Controls 1.3

Item {
    width: 400
    height: 400

    Button {
        id: button1
        x: 139
        y: 143
        text: qsTr("OK")
    }

    Button {
        id: button2
        x: 258
        y: 143
        text: qsTr("Cancel")
        isDefault: true
    }

    ComboBox {
        id: comboBox1
        x: 44
        y: 81
    }

    ComboBox {
        id: comboBox2
        x: 216
        y: 81
    }

    Label {
        id: label1
        x: 90
        y: 59
        text: qsTr("Across")
    }

    Label {
        id: label2
        x: 262
        y: 59
        text: qsTr("Down")
    }
}

