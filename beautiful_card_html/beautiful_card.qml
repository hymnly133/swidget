import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt5Compat.GraphicalEffects
import "../common" 1.0

pragma ComponentBehavior: Bound

/**
 * @brief Beautiful Card - 美观的卡片式组件
 * 
 * 一个美观的卡片式组件，采用渐变背景和动态动画效果：
 * - 渐变背景：从文件颜色到主题色的渐变，支持动态调整渐变停止点
 * - 动态位置调整：聚焦时显示文件名，非聚焦时隐藏，带有流畅的动画过渡
 * - 背景图：聚焦时显示图标背景，增强视觉效果
 * - 渐变动画：聚焦时渐变停止点从10%移动到50%，失焦时恢复
 * 
 * 使用方法：
 * 1. 右键点击组件，选择"选择文件"来设置代理文件
 * 2. 设置后会自动显示文件图标和名称
 * 3. 聚焦时显示文件名和背景图，失焦时隐藏
 */

SWidget {
    id: root

    // ==================== 属性定义 ====================
    property int cardRadius: unitRadius || 16
    property int iconSize: Math.min(width, height) * 0.6
    property int iconMargin: 6
    property int nameMargin: 15
    property int animationDuration: 600
    
    // 颜色配置 - 使用新的样式属性
    property color fileColor: proxyFileColor || styleThemeColor
    property color themeColor: styleThemeColor
    property color highlightColor: styleHighlightColor
    property color textColor: "#FFFFFF"  // 固定使用白色
    
    // 鼠标按下状态（active）
    property bool isPressed: false
    
    // 计算目标颜色：不聚焦时使用主题色，聚焦时使用高亮色
    property color targetColor: root.unitIsFocus ? root.highlightColor : root.themeColor
    
    // 计算当前状态的不透明度：使用 styleUnfocusedAlpha 或 styleFocusedAlpha
    property real currentAlpha: Math.sqrt(root.unitIsFocus 
        ? (root.styleFocusedAlpha / 255.0) 
        : (root.styleUnfocusedAlpha / 255.0))
    
    // 渐变停止点配置（动态调整）
    // active 时：90%，focused 时：50%，默认：10%
    property real gradientStop: root.isPressed ? 0.9 : (root.unitIsFocus ? 0.5 : 0.1)
    
    // 边框配置 - 使用文件色+高alpha
    property color borderColor: {
        // 使用文件色，如果没有文件色则使用主题色
        var borderBaseColor = root.fileColor
        var borderAlpha = root.currentAlpha * 0.8  // 高alpha
        
        if (root.isPressed) {
            // active 状态：降低不透明度
            borderAlpha = root.currentAlpha * 0.5
        }
        
        return Qt.rgba(
            borderBaseColor.r,
            borderBaseColor.g,
            borderBaseColor.b,
            borderAlpha
        )
    }
    
    globalRoundCornerEnabled: false
    fpsDisplayMode: SWidget.FpsDisplayMode.Never
    
    // 处理代理文件被删除事件
    function onProxyFileRemoved() {
        console.log("Beautiful Card: 代理文件被删除")
    }

    // ==================== 主容器 ====================
    Rectangle {
        id: cardContainer
        anchors.fill: parent
        radius: root.cardRadius
        
        // 边框
        border.width: 2
        border.color: root.borderColor
        
        // 鼠标点击区域（用于检测active状态）
        MouseArea {
            id: cardMouseArea
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
            onPressed: {
                root.isPressed = true
            }
            onReleased: {
                root.isPressed = false
            }
            onCanceled: {
                root.isPressed = false
            }
        }
        
        // 渐变背景：从文件颜色到主题色
        // 注意：QML 的 Gradient 不支持对角线，使用水平渐变模拟
        gradient: Gradient {
            id: backgroundGradient
            orientation: Gradient.Horizontal
            
            GradientStop { 
                id: gradientStop1
                position: 0.0
                color: {
                    if (root.proxyFilePath && root.proxyFilePath !== "") {
                        // 如果有文件色，直接使用文件色，不进行混合
                        return Qt.rgba(
                            root.fileColor.r,
                            root.fileColor.g,
                            root.fileColor.b,
                            root.currentAlpha
                        )
                    } else {
                        // 默认使用目标颜色（主题色或高亮色）
                        return Qt.rgba(
                            root.targetColor.r,
                            root.targetColor.g,
                            root.targetColor.b,
                            root.currentAlpha
                        )
                    }
                }
                
                // 颜色变化动画
                Behavior on color {
                    ColorAnimation {
                        duration: root.animationDuration
                        easing.type: Easing.Bezier
                        easing.bezierCurve: [0.25, 0.8, 0.25, 1.0, 1.0, 1.0]
                    }
                }
            }
            
            GradientStop { 
                id: gradientStop2
                position: root.gradientStop
                color: {
                    if (root.proxyFilePath && root.proxyFilePath !== "") {
                        // 如果有文件色，直接使用文件色，不进行混合
                        return Qt.rgba(
                            root.fileColor.r,
                            root.fileColor.g,
                            root.fileColor.b,
                            root.currentAlpha
                        )
                    } else {
                        // 默认使用目标颜色（主题色或高亮色）
                        return Qt.rgba(
                            root.targetColor.r,
                            root.targetColor.g,
                            root.targetColor.b,
                            root.currentAlpha
                        )
                    }
                }
                
                // 颜色变化动画
                Behavior on color {
                    ColorAnimation {
                        duration: root.animationDuration
                        easing.type: Easing.Bezier
                        easing.bezierCurve: [0.25, 0.8, 0.25, 1.0, 1.0, 1.0]
                    }
                }
                
                // 渐变停止点动画
                Behavior on position {
                    NumberAnimation {
                        duration: root.animationDuration
                        easing.type: Easing.Bezier
                        easing.bezierCurve: [0.25, 0.8, 0.25, 1.0, 1.0, 1.0]
                    }
                }
            }
            
            GradientStop { 
                id: gradientStop3
                position: 1.0
                // 渐变终点：使用目标颜色（主题色或高亮色），不透明度较低
                color: Qt.rgba(
                    root.targetColor.r,
                    root.targetColor.g,
                    root.targetColor.b,
                    root.currentAlpha
                )
                
                // 颜色变化动画
                Behavior on color {
                    ColorAnimation {
                        duration: root.animationDuration
                        easing.type: Easing.Bezier
                        easing.bezierCurve: [0.25, 0.8, 0.25, 1.0, 1.0, 1.0]
                    }
                }
            }
        }
        
        // 边框颜色动画
        Behavior on border.color {
            ColorAnimation {
                duration: root.animationDuration
                easing.type: Easing.Bezier
                easing.bezierCurve: [0.25, 0.8, 0.25, 1.0, 1.0, 1.0]
            }
        }
        
        
        // ==================== 图标背景层 ====================
        // 聚焦时显示淡淡的图标背景
        Image {
            id: iconBackground
            anchors.fill: parent
            source: root.proxyFileIcon && root.proxyFileIcon !== "" 
                ? root.proxyFileIcon 
                : ""
            fillMode: Image.PreserveAspectFit
            horizontalAlignment: Image.AlignHCenter
            verticalAlignment: Image.AlignVCenter
            opacity: root.unitIsFocus ? 0.05 : 0.0
            smooth: true
            asynchronous: true
            z: 1
            
            // 图标背景透明度动画
            Behavior on opacity {
                NumberAnimation {
                    duration: root.animationDuration
                    easing.type: Easing.Bezier
                    easing.bezierCurve: [0.25, 0.8, 0.25, 1.0, 1.0, 1.0]
                }
            }
        }
        
        // ==================== 内容区域 ====================
        // 使用居中布局，根据内容宽度动态调整位置
        Row {
            id: contentRow
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 0
            
            // 计算内容总宽度：图标宽度 + 间距 + 名字容器宽度
            // 直接绑定到 nameContainer.width，会自动跟随文字动画，保持同步
            width: iconContainer.width  + nameContainer.width
            
            
            // ==================== 图标容器 ====================
            Item {
                id: iconContainer
                width: root.iconSize
                height: root.iconSize
                anchors.verticalCenter: parent.verticalCenter
                z: 2
                
                // 鼠标悬停检测区域
                MouseArea {
                    id: iconMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.NoButton  // 不处理点击，只检测悬停
                }
                
                // 图标背景（圆形，带渐变）
                Rectangle {
                    id: iconBackgroundRect
                    anchors.fill: parent
                    radius: root.cardRadius
                    
                    gradient: Gradient {
                        GradientStop { 
                            position: 0.0
                            color: Qt.rgba(1.0, 1.0, 1.0, 0.15)
                        }
                        GradientStop { 
                            position: 1.0
                            color: Qt.rgba(1.0, 1.0, 1.0, 0.1)
                        }
                    }
                    
                    // 图标
                    Image {
                        id: fileIcon
                        anchors.fill: parent
                        anchors.margins: parent.width * 0.2
                        source: root.proxyFileIcon && root.proxyFileIcon !== "" 
                            ? root.proxyFileIcon 
                            : ""
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                        asynchronous: true
                        
                        // 图标加载状态
                        onStatusChanged: {
                            if (status === Image.Error) {
                                console.log("Beautiful Card: 图标加载失败")
                            }
                        }
                    }
                    
                    // 占位图标（当没有图标时显示）
                    Text {
                        anchors.centerIn: parent
                        text: root.proxyFilePath && root.proxyFilePath !== "" ? "📄" : "➕"
                        font.pixelSize: 20  // 与HTML版本一致：font-size: 20px
                        font.family: "Segoe UI, Microsoft YaHei, sans-serif"
                        visible: !fileIcon.source || fileIcon.status === Image.Error
                    }
                }
                
                // 图标缩放动画：鼠标悬停在图标上时才放大
                scale: iconMouseArea.containsMouse ? 1.2 : (root.unitIsFocus ? 1.1 : 1.0)
                Behavior on scale {
                    NumberAnimation {
                        duration: root.animationDuration * 0.67
                        easing.type: Easing.OutCubic
                    }
                }
            }
            
            // ==================== 文件名容器 ====================
            Item {
                id: nameContainer
                width: {
                    // 精简模式且非聚焦状态 - 隐藏文字
                    if (root.unitSimpleMode && !root.unitIsFocus) {
                        return 0
                    }
                    // 其他情况均显示文字
                    // 计算文本实际宽度，加上边距
                    var textWidth = fileNameText.implicitWidth
                    // 最大宽度：父容器宽度减去图标宽度和间距，再减去一些边距
                    var maxWidth = cardContainer.width - iconContainer.width - root.nameMargin - root.iconMargin * 2
                    return Math.min(textWidth + root.nameMargin * 2, maxWidth)
                }
                height: parent.height
                anchors.verticalCenter: parent.verticalCenter
                clip: true
                // 精简模式且非聚焦状态 - 隐藏文字，其他情况均显示
                opacity: (root.unitSimpleMode && !root.unitIsFocus) ? 0.0 : 1.0
                
                // 文件名文本（使用 OpacityMask 实现右侧渐隐）
                Item {
                    id: textItem
                    anchors.fill: parent
                    
                    Text {
                        id: fileNameText
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: root.nameMargin
                        text: root.proxyFileName && root.proxyFileName !== "" 
                            ? root.proxyFileName 
                            : "未选择文件"
                        color: "#FFFFFF"  // 固定使用白色
                        font.pixelSize: 30
                        font.weight: Font.DemiBold  // 相当于 font-weight: 600
                        font.family: "Segoe UI, Microsoft YaHei, sans-serif"
                        font.letterSpacing: 0.8  // 字间距，与HTML版本一致
                        elide: Text.ElideNone
                        
                        // 文字阴影：0 1px 2px rgba(0, 0, 0, 0.3) - 简化渲染
                        layer.enabled: true
                        layer.effect: DropShadow {
                            color: "#4D000000"  // rgba(0, 0, 0, 0.3)
                            radius: 1
                            samples: 5
                            horizontalOffset: 0
                            verticalOffset: 1
                            transparentBorder: true
                        }
                    }
                    
                    // 右侧渐隐遮罩（使用 OpacityMask）
                    layer.enabled: nameContainer.width > 0
                    layer.effect: OpacityMask {
                        maskSource: Rectangle {
                            width: nameContainer.width
                            height: nameContainer.height
                            gradient: Gradient {
                                orientation: Gradient.Horizontal
                                GradientStop { 
                                    position: 0.0
                                    color: "black"
                                }
                                GradientStop { 
                                    position: Math.max(0.0, 1.0 - Math.min(20, nameContainer.width * 0.12) / nameContainer.width)
                                    color: "black"
                                }
                                GradientStop { 
                                    position: 1.0
                                    color: "transparent"
                                }
                            }
                        }
                    }
                }
                
                // 文件名容器宽度动画
                Behavior on width {
                    NumberAnimation {
                        duration: root.animationDuration * 0.83
                        easing.type: Easing.Bezier
                        easing.bezierCurve: [0.19, 1.0, 0.22, 1.0, 1.0, 1.0]
                    }
                }
                
                // 文件名透明度动画
                Behavior on opacity {
                    NumberAnimation {
                        duration: root.animationDuration * 0.83
                        easing.type: Easing.Bezier
                        easing.bezierCurve: [0.19, 1.0, 0.22, 1.0, 1.0, 1.0]
                    }
                }
            }
        }
    }
    
    // ==================== 状态绑定 ====================
    // 注意：gradientStop 和 borderColor 现在通过属性绑定自动更新
    // 不需要手动设置，它们会根据 isPressed 和 unitIsFocus 自动计算
    
    // 文件变化时更新渐变颜色
    onProxyFileColorChanged: {
        // 渐变颜色会自动更新（通过绑定）
    }
    
}

