import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.plasma5support as Plasma5Support

PlasmoidItem {
    id: root
    Layout.minimumWidth: row.implicitWidth + 8
    Layout.preferredWidth: row.implicitWidth + 8
    Layout.fillHeight: true

    readonly property string scriptCmd: "bash /home/celo/projects/personal/claude_usage/claude_usage.sh"

    Plasma5Support.DataSource {
        id: cmd
        engine: "executable"
        connectedSources: [root.scriptCmd]
        interval: 300000
        onNewData: function(source, data) {
            if (parseInt(data["exit code"]) !== 0) return;
            var out = data["stdout"].trim();
            if (out.length > 0) label.text = out;
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            label.text = "…"
            cmd.disconnectSource(root.scriptCmd)
            cmd.connectSource(root.scriptCmd)
        }
    }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 5

        Image {
            source: Qt.resolvedUrl("../icons/claude.png")
            width: 14
            height: 14
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            id: label
            text: "Claude..."
            color: "white"
            font.pixelSize: 12
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
