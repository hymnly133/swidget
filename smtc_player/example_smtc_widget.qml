import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Basic
import Qt5Compat.GraphicalEffects
import "../common" 1.0

/**
 * @brief SMTC媒体播放器QML组件
 * 
 * 功能：
 * - 显示SMTC媒体信息（标题、艺术家、专辑等）
 * - 显示播放进度和时间
 * - 显示专辑封面
 * - 提供媒体控制（播放、暂停、停止、上一首、下一首、跳转）
 * - 支持会话选择
 * - 显示控制能力状态
 * 
 * 使用SWidget作为标准化接口，通过SMTC属性获取媒体信息
 */

SWidget {
    id: root

    property int globalRadius: unitRadius || 8
    property int globalMargin: 8
    
    globalRoundCornerEnabled: true
    fpsDisplayMode: SWidget.FpsDisplayMode.Never

    // 格式化时间显示（毫秒转 mm:ss）
    function formatTime(milliseconds) {
        if (milliseconds <= 0) return "00:00"
        var totalSeconds = Math.floor(milliseconds / 1000)
        var minutes = Math.floor(totalSeconds / 60)
        var seconds = totalSeconds % 60
        return (minutes < 10 ? "0" : "") + minutes + ":" + (seconds < 10 ? "0" : "") + seconds
    }

    // 格式化进度百分比
    function formatProgress(progress) {
        return progress + "%"
    }

    Rectangle {
        id: contentItem
        anchors.fill: parent
        color: "#1E1E1E"
        radius: root.globalRadius

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: root.globalMargin
            spacing: 12

            // ==================== 标题栏 ====================
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                color: "#2D2D2D"
                radius: 6

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 8

                    Text {
                        text: "SMTC 媒体播放器"
                        color: "#FFFFFF"
                        font.pixelSize: 16
                        font.bold: true
                    }

                    Item { Layout.fillWidth: true }

                    // SMTC状态指示器
                    Rectangle {
                        radius: 6
                        color: root.smtcEnabled ? "#00FF00" : "#FF0000"
                    }

                    Text {
                        text: root.smtcEnabled ? "已启用" : "未启用"
                        color: root.smtcEnabled ? "#00FF00" : "#FF6666"
                        font.pixelSize: 12
                    }
                }
            }

            // ==================== 会话选择 ====================
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                color: "#2D2D2D"
                radius: 6
                visible: root.smtcSessionCount > 0

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 4

                    Text {
                        text: "当前会话 (" + root.smtcSessionCount + ")"
                        color: "#AAAAAA"
                        font.pixelSize: 11
                    }

                    ComboBox {
                        id: sessionComboBox
                        Layout.fillWidth: true
                        model: root.smtcSessionIds
                        currentIndex: {
                            var idx = root.smtcSessionIds.indexOf(root.currentSMTCSessionId)
                            return idx >= 0 ? idx : 0
                        }
                        onActivated: function(index) {
                            if (root.smtcEnabled && root.unit && root.unit.smtcModule) {
                                root.setSMTCSession(root.smtcSessionIds[index])
                            }
                        }

                        delegate: ItemDelegate {
                            width: sessionComboBox.width
                            text: modelData
                            highlighted: sessionComboBox.highlightedIndex === index
                        }

                        contentItem: Text {
                            text: sessionComboBox.displayText
                            color: "#FFFFFF"
                            font.pixelSize: 12
                            verticalAlignment: Text.AlignVCenter
                            leftPadding: 8
                        }

                        background: Rectangle {
                            color: "#3D3D3D"
                            radius: 4
                            border.color: "#555555"
                            border.width: 1
                        }
                    }
                }
            }

            // ==================== 专辑封面 ====================
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 200
                color: "#2D2D2D"
                radius: 6

                Image {
                    id: albumArtImage
                    anchors.fill: parent
                    anchors.margins: 8
                    source: root.smtcAlbumArtBase64 ? "data:image/jpeg;base64," + root.smtcAlbumArtBase64 : ""
                    fillMode: Image.PreserveAspectFit
                    visible: root.smtcAlbumArtBase64 !== ""

                    Rectangle {
                        anchors.fill: parent
                        color: "#1E1E1E"
                        radius: 4
                        visible: root.smtcAlbumArtBase64 === ""

                        Text {
                            anchors.centerIn: parent
                            text: "无封面"
                            color: "#666666"
                            font.pixelSize: 14
                        }
                    }
                }

                // 封面信息
                Column {
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: 8
                    spacing: 4
                    visible: root.smtcAlbumArtSize !== ""

                    Text {
                        text: "尺寸: " + root.smtcAlbumArtSize
                        color: "#AAAAAA"
                        font.pixelSize: 10
                    }
                }
            }

            // ==================== 媒体信息 ====================
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 120
                color: "#2D2D2D"
                radius: 6

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 8

                    // 标题
                    Text {
                        Layout.fillWidth: true
                        text: root.smtcMediaTitle || "未知标题"
                        color: "#FFFFFF"
                        font.pixelSize: 18
                        font.bold: true
                        elide: Text.ElideRight
                        maximumLineCount: 1
                    }

                    // 艺术家
                    Text {
                        Layout.fillWidth: true
                        text: root.smtcMediaArtist || "未知艺术家"
                        color: "#CCCCCC"
                        font.pixelSize: 14
                        elide: Text.ElideRight
                        maximumLineCount: 1
                    }

                    // 专辑和应用
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        Text {
                            text: root.smtcMediaAlbum || "未知专辑"
                            color: "#AAAAAA"
                            font.pixelSize: 12
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }

                        Text {
                            text: root.smtcAppName || "未知应用"
                            color: "#888888"
                            font.pixelSize: 11
                            font.italic: true
                        }
                    }
                }
            }

            // ==================== 播放进度 ====================
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 60
                color: "#2D2D2D"
                radius: 6

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 6

                    // 进度条
                    ProgressBar {
                        id: progressBar
                        Layout.fillWidth: true
                        value: root.smtcPlaybackProgress / 100.0
                        from: 0
                        to: 1

                        background: Rectangle {
                            color: "#3D3D3D"
                            radius: 4
                        }

                        contentItem: Item {
                            Rectangle {
                                width: progressBar.visualPosition * parent.width
                                height: parent.height
                                radius: 4
                                color: root.unitMainColor
                            }
                        }

                        // 可点击跳转
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                if (root.smtcCanSeek && root.smtcPlaybackDuration > 0) {
                                    var percent = mouseX / width * 100
                                    seekSMTCToPosition(Math.max(0, Math.min(100, percent)))
                                }
                            }
                        }
                    }

                    // 时间信息
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Text {
                            text: formatTime(root.smtcPlaybackPosition)
                            color: "#CCCCCC"
                            font.pixelSize: 12
                        }

                        Item { Layout.fillWidth: true }

                        Text {
                            text: formatProgress(root.smtcPlaybackProgress)
                            color: "#AAAAAA"
                            font.pixelSize: 11
                        }

                        Item { Layout.fillWidth: true }

                        Text {
                            text: formatTime(root.smtcPlaybackDuration)
                            color: "#CCCCCC"
                            font.pixelSize: 12
                        }
                    }
                }
            }

            // ==================== 播放状态 ====================
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 30
                color: "#2D2D2D"
                radius: 6

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 8

                    Text {
                        text: "状态:"
                        color: "#AAAAAA"
                        font.pixelSize: 11
                    }

                    Text {
                        text: root.smtcPlaybackStatus || "未知"
                        color: {
                            if (root.smtcPlaybackStatus === "播放中") return "#00FF00"
                            if (root.smtcPlaybackStatus === "暂停") return "#FFFF00"
                            if (root.smtcPlaybackStatus === "停止") return "#FF6666"
                            return "#AAAAAA"
                        }
                        font.pixelSize: 12
                        font.bold: true
                    }

                    Item { Layout.fillWidth: true }

                    Text {
                        text: root.smtcControlCapabilities || "无可用控制"
                        color: "#888888"
                        font.pixelSize: 10
                    }
                }
            }

            // ==================== 控制按钮 ====================
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 70
                color: "#2D2D2D"
                radius: 6

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 12

                    // 上一首
                    Button {
                        enabled: root.smtcCanSkipPrevious
                        onClicked: root.skipSMTCPrevious()

                        contentItem: Text {
                            text: "⏮"
                            color: parent.enabled ? "#FFFFFF" : "#666666"
                            font.pixelSize: 20
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        background: Rectangle {
                            color: parent.enabled ? (parent.pressed ? "#555555" : "#3D3D3D") : "#2D2D2D"
                            radius: 6
                            border.color: parent.enabled ? "#555555" : "#1D1D1D"
                            border.width: 1
                        }
                    }

                    // 播放/暂停
                    Button {
                        enabled: root.smtcCanPlay || root.smtcCanPause
                        onClicked: {
                            if (root.smtcPlaybackStatus === "播放中") {
                                root.pauseSMTCMedia()
                            } else {
                                root.playSMTCMedia()
                            }
                        }

                        contentItem: Text {
                            text: root.smtcPlaybackStatus === "播放中" ? "⏸" : "▶"
                            color: parent.enabled ? "#FFFFFF" : "#666666"
                            font.pixelSize: 28
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        background: Rectangle {
                            color: parent.enabled ? (parent.pressed ? root.unitMainColor : Qt.lighter(root.unitMainColor, 1.2)) : "#2D2D2D"
                            radius: 8
                            border.color: parent.enabled ? root.unitMainColor : "#1D1D1D"
                            border.width: 2
                        }
                    }

                    // 停止
                    Button {
                        enabled: root.smtcCanStop
                        onClicked: root.stopSMTCMedia()

                        contentItem: Text {
                            text: "⏹"
                            color: parent.enabled ? "#FFFFFF" : "#666666"
                            font.pixelSize: 20
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        background: Rectangle {
                            color: parent.enabled ? (parent.pressed ? "#555555" : "#3D3D3D") : "#2D2D2D"
                            radius: 6
                            border.color: parent.enabled ? "#555555" : "#1D1D1D"
                            border.width: 1
                        }
                    }

                    // 下一首
                    Button {
                        enabled: root.smtcCanSkipNext
                        onClicked: root.skipSMTCNext()

                        contentItem: Text {
                            text: "⏭"
                            color: parent.enabled ? "#FFFFFF" : "#666666"
                            font.pixelSize: 20
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        background: Rectangle {
                            color: parent.enabled ? (parent.pressed ? "#555555" : "#3D3D3D") : "#2D2D2D"
                            radius: 6
                            border.color: parent.enabled ? "#555555" : "#1D1D1D"
                            border.width: 1
                        }
                    }
                }
            }

            // ==================== 详细信息 ====================
            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumHeight: 100

                TextArea {
                    id: detailTextArea
                    readOnly: true
                    text: root.smtcMediaInfo || "等待媒体信息..."
                    color: "#CCCCCC"
                    font.pixelSize: 11
                    font.family: "Consolas, monospace"
                    background: Rectangle {
                        color: "#2D2D2D"
                        radius: 6
                    }
                    wrapMode: TextArea.Wrap
                }
            }

            Item { Layout.fillHeight: true }
        }
    }

    // ==================== 初始化 ====================
    Component.onCompleted: {
        console.log("SMTC播放器组件加载完成")
        console.log("SMTC启用状态:", root.smtcEnabled)
        console.log("可用会话数量:", root.smtcSessionCount)
    }

    // ==================== 监听SMTC属性变化 ====================
    onSmtcEnabledChanged: {
        console.log("SMTC启用状态变化:", root.smtcEnabled)
        // 如果SMTC已启用且有可用会话且未选择，自动选择第一个
        console.log("所有会话：", root.smtcSessionIds)
        if (root.smtcEnabled && root.smtcSessionIds.length > 0 && root.currentSMTCSessionId === "") {
            console.log("自动选择第一个会话")
            setSMTCSession(root.smtcSessionIds[0])
        }
    }

    onSmtcSessionIdsChanged: {
        console.log("SMTC会话列表变化:", root.smtcSessionIds)
        if (smtcSessionIds.length > 0 && currentSMTCSessionId === "") {
            root.setSMTCSession(root.smtcSessionIds[0])
        }
    }

    onSmtcMediaTitleChanged: {
        console.log("媒体标题变化:", smtcMediaTitle)
    }

    onSmtcPlaybackStatusChanged: {
        console.log("播放状态变化:", smtcPlaybackStatus)
    }
}

