import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt5Compat.GraphicalEffects
import "../common" 1.0

pragma ComponentBehavior: Bound

/**
 * @brief ProxyFile卡片式组件
 * 
 * 一个美观的文件代理组件，采用Web端卡片式设计：
 * - 背景使用文件颜色和主题色的渐变
 * - 简洁风格：左侧图标，右侧名称
 * - 丰富的视觉效果（阴影、模糊、动画）
 * - 聚焦时显示名称，非聚焦时仅显示图标，带有流畅的动画过渡
 * 
 * 使用方法：
 * 1. 右键点击组件，选择"选择文件"来设置代理文件
 * 2. 设置后会自动显示文件图标
 * 3. 聚焦时显示文件名，失焦时隐藏文件名
 */

SWidget {
    id: root

    // ==================== 属性定义 ====================
    property int cardRadius: unitRadius || 12
    property int iconSize: 48
    property int iconMargin: 16
    property int nameMargin: 12
    property real focusScale: 1.05
    property int animationDuration: 300
    
    // 颜色配置
    property color fileColor: proxyFileColor || currentThemeColor
    property color themeColor: currentThemeColor || "#007ACC"
    property color textColor: "#FFFFFF"
    
    // 阴影配置
    property color shadowColor: "#40000000"
    property real shadowRadius: 16
    property real shadowSamples: 25
    property real shadowHorizontalOffset: 0
    property real shadowVerticalOffset: 4
    
    // 模糊配置
    property real blurRadius: 8
    
    globalRoundCornerEnabled: true
    fpsDisplayMode: SWidget.FpsDisplayMode.Never
    
    // 处理代理文件被删除事件
    function onProxyFileRemoved() {
        console.log("ProxyFile卡片: 代理文件被删除")
    }

    // ==================== 主容器 ====================
    Rectangle {
        id: cardContainer
        anchors.fill: parent
        radius: root.cardRadius
        
        // 渐变背景：文件颜色到主题色
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { 
                position: 0.0
                color: Qt.rgba(
                    root.fileColor.r * 0.7 + 0.1,
                    root.fileColor.g * 0.7 + 0.1,
                    root.fileColor.b * 0.7 + 0.1,
                    0.9
                )
            }
            GradientStop { 
                position: 1.0
                color: Qt.rgba(
                    root.themeColor.r * 0.6 + 0.15,
                    root.themeColor.g * 0.6 + 0.15,
                    root.themeColor.b * 0.6 + 0.15,
                    0.85
                )
            }
        }
        
        // 背景光晕效果
        Rectangle {
            anchors.fill: parent
            radius: root.cardRadius
            gradient: Gradient {
                GradientStop { 
                    position: 0.0
                    color: Qt.rgba(root.fileColor.r, root.fileColor.g, root.fileColor.b, 0.1)
                }
                GradientStop { 
                    position: 1.0
                    color: Qt.rgba(root.themeColor.r, root.themeColor.g, root.themeColor.b, 0.1)
                }
            }
            opacity: root.unitIsFocus ? 0.6 : 0.3
            
            Behavior on opacity {
                NumberAnimation {
                    duration: root.animationDuration
                    easing.type: Easing.OutCubic
                }
            }
        }
        
        // 内容区域
        Row {
            id: contentRow
            anchors.fill: parent
            anchors.margins: root.iconMargin
            spacing: root.nameMargin
            
            // ==================== 文件图标 ====================
            Item {
                id: iconContainer
                width: root.iconSize
                height: root.iconSize
                anchors.verticalCenter: parent.verticalCenter
                
                // 图标阴影容器
                Item {
                    id: iconShadowContainer
                    anchors.fill: parent
                    
                    layer.enabled: true
                    layer.effect: DropShadow {
                        color: root.shadowColor
                        radius: root.shadowRadius
                        samples: root.shadowSamples
                        horizontalOffset: root.shadowHorizontalOffset
                        verticalOffset: root.shadowVerticalOffset
                        transparentBorder: true
                    }
                    
                    // 图标背景（圆形，带渐变）
                    Rectangle {
                        id: iconBackground
                        anchors.fill: parent
                        radius: width / 2
                        
                        gradient: Gradient {
                            GradientStop { 
                                position: 0.0
                                color: Qt.rgba(1.0, 1.0, 1.0, 0.25)
                            }
                            GradientStop { 
                                position: 1.0
                                color: Qt.rgba(1.0, 1.0, 1.0, 0.1)
                            }
                        }
                        
                        // 边框
                        border.width: 1
                        border.color: Qt.rgba(1.0, 1.0, 1.0, 0.3)
                        
                        // 图标
                        Image {
                            id: fileIcon
                            anchors.fill: parent
                            anchors.margins: 8
                            source: root.proxyFileIcon && root.proxyFileIcon !== "" 
                                ? root.proxyFileIcon 
                                : ""
                            fillMode: Image.PreserveAspectFit
                            smooth: true
                            mipmap: true
                            asynchronous: true
                            
                            // 图标加载状态
                            onStatusChanged: {
                                if (status === Image.Error) {
                                    console.log("ProxyFile卡片: 图标加载失败")
                                }
                            }
                        }
                        
                        // 占位图标（当没有图标时显示）
                        Text {
                            anchors.centerIn: parent
                            text: "📄"
                            font.pixelSize: root.iconSize * 0.5
                            visible: !fileIcon.source || fileIcon.status === Image.Error
                        }
                    }
                }
                
                // 图标动画：聚焦时缩放
                Behavior on scale {
                    NumberAnimation {
                        duration: root.animationDuration
                        easing.type: Easing.OutCubic
                    }
                }
                
                // 图标背景动画
                Behavior on opacity {
                    NumberAnimation {
                        duration: root.animationDuration
                        easing.type: Easing.OutCubic
                    }
                }
            }
            
            // ==================== 文件名 ====================
            Item {
                id: nameContainer
                width: root.unitIsFocus ? Math.min(fileNameText.implicitWidth + root.nameMargin * 2, contentRow.width - iconContainer.width - root.iconMargin * 2 - root.nameMargin) : 0
                height: parent.height
                anchors.verticalCenter: parent.verticalCenter
                clip: true
                opacity: root.unitIsFocus ? 1.0 : 0.0
                
                // 文件名文本
                Text {
                    id: fileNameText
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: root.nameMargin
                    text: root.proxyFileName && root.proxyFileName !== "" 
                        ? root.proxyFileName 
                        : "未选择文件"
                    color: root.textColor
                    font.pixelSize: 16
                    font.bold: true
                    elide: Text.ElideMiddle
                    visible: root.unitIsFocus
                    
                    // 文字阴影和发光效果
                    layer.enabled: true
                    layer.effect: DropShadow {
                        color: "#80000000"
                        radius: 3
                        samples: 7
                        horizontalOffset: 1
                        verticalOffset: 1
                    }
                }
                
                // 文件名容器宽度动画
                Behavior on width {
                    NumberAnimation {
                        duration: root.animationDuration
                        easing.type: Easing.OutCubic
                    }
                }
                
                // 文件名透明度动画
                Behavior on opacity {
                    NumberAnimation {
                        duration: root.animationDuration
                        easing.type: Easing.OutCubic
                    }
                }
            }
        }
        
        // 卡片整体动画：聚焦时轻微放大
        Behavior on scale {
            NumberAnimation {
                duration: root.animationDuration
                easing.type: Easing.OutCubic
            }
        }
        
        // 卡片阴影动画
        Behavior on opacity {
            NumberAnimation {
                duration: root.animationDuration
                easing.type: Easing.OutCubic
            }
        }
    }
    
    // ==================== 卡片阴影效果 ====================
    Item {
        id: cardShadowContainer
        anchors.fill: parent
        z: -1
        opacity: root.unitIsFocus ? 1.0 : 0.7
        
        layer.enabled: true
        layer.effect: DropShadow {
            color: root.shadowColor
            radius: root.shadowRadius * 1.5
            samples: root.shadowSamples
            horizontalOffset: root.shadowHorizontalOffset
            verticalOffset: root.shadowVerticalOffset + 2
            transparentBorder: true
        }
        
        Rectangle {
            anchors.fill: parent
            radius: root.cardRadius
            color: "transparent"
        }
        
        // 阴影透明度动画
        Behavior on opacity {
            NumberAnimation {
                duration: root.animationDuration
                easing.type: Easing.OutCubic
            }
        }
    }
    
    // ==================== 状态绑定 ====================
    // 聚焦状态变化时更新UI
    onUnitIsFocusChanged: {
        if (unitIsFocus) {
            // 聚焦：显示名称，放大图标和卡片
            iconContainer.scale = root.focusScale
            cardContainer.scale = root.focusScale * 0.98
            nameContainer.opacity = 1.0
            iconBackground.opacity = 1.0
            cardShadowContainer.opacity = 1.0
        } else {
            // 失焦：隐藏名称，恢复图标和卡片大小
            iconContainer.scale = 1.0
            cardContainer.scale = 1.0
            nameContainer.opacity = 0.0
            iconBackground.opacity = 0.8
            cardShadowContainer.opacity = 0.7
        }
    }
    
    // 文件变化时更新图标
    onProxyFileIconChanged: {
        if (proxyFileIcon && proxyFileIcon !== "") {
            // 图标加载动画
            iconContainer.scale = 1.1
            Qt.callLater(function() {
                iconContainer.scale = root.unitIsFocus ? root.focusScale : 1.0
            })
        }
    }
    
    // 初始化
    Component.onCompleted: {
        // 初始状态：非聚焦
        iconContainer.scale = 1.0
        cardContainer.scale = 1.0
        nameContainer.opacity = 0.0
        iconBackground.opacity = 0.8
        cardShadowContainer.opacity = 0.7
        
        // 如果初始就是聚焦状态，应用聚焦样式
        if (unitIsFocus) {
            iconContainer.scale = root.focusScale
            cardContainer.scale = root.focusScale * 0.98
            nameContainer.opacity = 1.0
            iconBackground.opacity = 1.0
            cardShadowContainer.opacity = 1.0
        }
    }
}

