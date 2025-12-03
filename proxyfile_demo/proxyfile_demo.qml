import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Basic
import Qt5Compat.GraphicalEffects
import "../common" 1.0

/**
 * @brief ProxyFile功能演示组件
 * 
 * 功能展示：
 * - 显示代理文件信息（图标、文件名、路径）
 * - 展示计算属性的自动更新
 * - 提供文件操作按钮（打开文件、打开文件位置、文件属性）
 * - 展示文件变化监听（文件删除通知）
 * - 展示如何通过右键菜单选择文件
 * 
 * 使用方法：
 * 1. 右键点击组件，选择"选择文件"来设置代理文件
 * 2. 设置后会自动显示文件信息
 * 3. 可以通过按钮进行文件操作
 * 4. 如果文件被删除，会自动收到通知并清除显示
 */

SWidget {
    id: root

    property int globalRadius: unitRadius || 8
    property int globalMargin: 12
    
    globalRoundCornerEnabled: true
    fpsDisplayMode: SWidget.FpsDisplayMode.Never
    // 处理代理文件被删除事件
    function onProxyFileRemoved() {
        console.log("ProxyFile演示: 代理文件被删除")
        // 可以在这里添加自定义处理逻辑
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
                        text: "ProxyFile 功能演示"
                        color: "#FFFFFF"
                        font.pixelSize: 16
                        font.bold: true
                    }

                    Item { Layout.fillWidth: true }

                    // 状态指示器
                    Rectangle {
                        width: 12
                        height: 12
                        radius: 6
                        color: root.proxyFilePath && root.proxyFilePath !== "" ? "#00FF00" : "#FF6666"
                    }

                    Text {
                        text: root.proxyFilePath && root.proxyFilePath !== "" ? "已设置" : "未设置"
                        color: root.proxyFilePath && root.proxyFilePath !== "" ? "#00FF00" : "#FF6666"
                        font.pixelSize: 12
                    }
                }
            }

            // ==================== 文件信息显示区域 ====================
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "#2D2D2D"
                radius: 6

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 12

                    // 文件图标
                    Rectangle {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.preferredWidth: 80
                        Layout.preferredHeight: 80
                        radius: 8
                        color: "#3D3D3D"
                        visible: root.proxyFilePath && root.proxyFilePath !== ""

                        Image {
                            id: fileIconImage
                            anchors.fill: parent
                            anchors.margins: 8
                            source: root.proxyFileIcon && root.proxyFileIcon !== "" 
                                ? root.proxyFileIcon 
                                : ""
                            fillMode: Image.PreserveAspectFit
                            visible: root.proxyFileIcon && root.proxyFileIcon !== ""
                        }

                        // 占位图标
                        Text {
                            anchors.centerIn: parent
                            text: "📄"
                            font.pixelSize: 40
                            visible: !fileIconImage.visible
                        }
                    }

                    // 文件名
                    Text {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignHCenter
                        text: root.proxyFileName && root.proxyFileName !== "" 
                            ? root.proxyFileName 
                            : "未选择文件"
                        color: root.proxyFileName && root.proxyFileName !== "" ? "#FFFFFF" : "#888888"
                        font.pixelSize: 14
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        elide: Text.ElideMiddle
                    }

                    // 文件路径
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 40
                        color: "#3D3D3D"
                        radius: 4
                        visible: root.proxyFilePath && root.proxyFilePath !== ""

                        Text {
                            anchors.fill: parent
                            anchors.margins: 8
                            text: root.proxyFilePath || ""
                            color: "#CCCCCC"
                            font.pixelSize: 11
                            font.family: "Consolas, monospace"
                            elide: Text.ElideMiddle
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    Item { Layout.fillHeight: true }

                    // ==================== 操作按钮区域 ====================
                    GridLayout {
                        Layout.fillWidth: true
                        columns: 2
                        rowSpacing: 8
                        columnSpacing: 8

                        // 打开文件按钮
                        Button {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 36
                            text: "打开文件"
                            enabled: root.proxyFilePath && root.proxyFilePath !== "" && root.unit && root.unit.qmlModule
                            onClicked: {
                                if (root.unit && root.unit.qmlModule) {
                                    root.unit.qmlModule.openProxyFile()
                                }
                            }
                        }

                        // 打开文件位置按钮
                        Button {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 36
                            text: "打开位置"
                            enabled: root.proxyFilePath && root.proxyFilePath !== "" && root.unit && root.unit.qmlModule
                            onClicked: {
                                if (root.unit && root.unit.qmlModule) {
                                    root.unit.qmlModule.openProxyFileLocation()
                                }
                            }
                        }

                        // 文件属性按钮
                        Button {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 36
                            text: "文件属性"
                            enabled: root.proxyFilePath && root.proxyFilePath !== "" && root.unit && root.unit.qmlModule
                            onClicked: {
                                if (root.unit && root.unit.qmlModule) {
                                    root.unit.qmlModule.openProxyFileProperty()
                                }
                            }
                        }

                        // 清除文件按钮
                        Button {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 36
                            text: "清除文件"
                            enabled: root.proxyFilePath && root.proxyFilePath !== "" && root.unit && root.unit.qmlModule
                            onClicked: {
                                // 通过C++端清除代理文件
                                if (root.unit && root.unit.qmlModule) {
                                    root.unit.qmlModule.removeProxyFile();
                                }
                            }
                        }
                    }
                }
            }

            // ==================== 说明文本 ====================
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 60
                color: "#2D2D2D"
                radius: 6
                visible: !root.proxyFilePath || root.proxyFilePath === ""

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 4

                    Text {
                        Layout.fillWidth: true
                        text: "使用说明："
                        color: "#FFFFFF"
                        font.pixelSize: 12
                        font.bold: true
                    }

                    Text {
                        Layout.fillWidth: true
                        text: "1. 右键点击组件，选择\"选择文件\"来设置代理文件"
                        color: "#CCCCCC"
                        font.pixelSize: 10
                    }

                    Text {
                        Layout.fillWidth: true
                        text: "2. 设置后会自动显示文件图标、名称和路径"
                        color: "#CCCCCC"
                        font.pixelSize: 10
                    }

                    Text {
                        Layout.fillWidth: true
                        text: "3. 可以通过按钮进行文件操作"
                        color: "#CCCCCC"
                        font.pixelSize: 10
                    }
                }
            }

            // ==================== 功能特性展示 ====================
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 80
                color: "#2D2D2D"
                radius: 6

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 4

                    Text {
                        Layout.fillWidth: true
                        text: "功能特性："
                        color: "#FFFFFF"
                        font.pixelSize: 12
                        font.bold: true
                    }

                    Text {
                        Layout.fillWidth: true
                        text: "✓ 计算属性自动更新（proxyFileName、proxyFileIcon）"
                        color: "#00FF00"
                        font.pixelSize: 10
                    }

                    Text {
                        Layout.fillWidth: true
                        text: "✓ 文件变化监听（文件删除自动通知）"
                        color: "#00FF00"
                        font.pixelSize: 10
                    }

                    Text {
                        Layout.fillWidth: true
                        text: "✓ 持久化存储（重启后自动恢复）"
                        color: "#00FF00"
                        font.pixelSize: 10
                    }

                    Text {
                        Layout.fillWidth: true
                        text: "✓ 右键菜单集成（选择文件、打开文件等）"
                        color: "#00FF00"
                        font.pixelSize: 10
                    }
                }
            }
        }
    }
}

