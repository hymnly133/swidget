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
 * - 内容方向：支持自动、竖向、横向三种布局方向
 *   * 自动模式：根据卡片宽高比自动选择方向（高度>宽度时竖向，否则横向）
 *   * 竖向模式：图标在上，文字在下，文字动画使用高度变化
 *   * 横向模式：图标在左，文字在右，文字动画使用宽度变化
 * 
 * 使用方法：
 * 1. 右键点击组件，选择"选择文件"来设置代理文件
 * 2. 设置后会自动显示文件图标和名称
 * 3. 聚焦时显示文件名和背景图，失焦时隐藏
 * 4. 通过 contentOrientation 属性设置内容方向（0=自动，1=竖向，2=横向）
 */

SWidget {
    id: root

    Component.onCompleted: {
        root.unit.useBuiltInOpenProxyFile = true
    }


    // ==================== 属性定义 ====================
    property int cardRadius: unitRadius || 16
    // 图标大小计算：使用缓冲函数，大尺寸时比例更小
    // 基础比例0.55，随尺寸增大逐渐减小，使用平方根函数实现平滑缓冲
    property int iconSize: {
        var minSize = Math.min(width, height)
        // 使用平方根函数实现缓冲效果：sqrt(x) / sqrt(基准值)
        // 当尺寸增大时，比例逐渐减小，但变化更平滑
        var baseSize = 200  // 基准尺寸
        var ratio = 0.55 * Math.sqrt(baseSize) / Math.sqrt(Math.max(minSize, baseSize))
        return minSize * ratio
    }
    // 字体大小计算：使用缓冲函数，基础比例更小（0.15），大尺寸时比例更小
    // 使用平方根函数实现平滑缓冲，比例比图标更小
    property int fontSize: {
        var minSize = Math.min(width, height)
        // 使用平方根函数实现缓冲效果：sqrt(x) / sqrt(基准值)
        // 当尺寸增大时，比例逐渐减小，但变化更平滑
        var baseSize = 200  // 基准尺寸
        var ratio = 0.20 * Math.sqrt(baseSize) / Math.sqrt(Math.max(minSize, baseSize))
        return Math.max(minSize * ratio, 30)  // 最小字体大小12px
    }
    property int iconMargin: 6
    property int nameMargin: 0
    property int animationDuration: 600

    enum ContentOrientation {
        Auto = 0,
        Vertical = 1,
        Horizontal = 2
    }
    
    // 内容方向枚举：0=自动，1=竖向，2=横向
    property int contentOrientation: 0  // 默认自动
    
    // 计算实际方向：如果是自动模式，根据宽高比决定
    property int actualOrientation: {
        if (contentOrientation === 0) {
            // 自动模式：高度大于宽度时使用竖向，否则使用横向
            return height > width ? 1 : 2
        }
        return contentOrientation
    }
    
    // 是否为竖向布局
    property bool isVertical: actualOrientation === 1
    
    // 颜色配置 - 使用新的样式属性
    property color fileColor: proxyFileColor || styleThemeColor
    property color themeColor: styleThemeColor
    property color highlightColor: styleHighlightColor
    property color textColor: "#FFFFFF"  // 固定使用白色
    property bool showName: (!root.unitSimpleMode || root.unitIsFocus) ? 1 : 0
        
    // 鼠标按下状态（active）- 直接绑定到SWidget的leftMousePressed属性
    property bool isPressed: root.leftMousePressed
    
    // 计算目标颜色：不聚焦时使用主题色，聚焦时使用高亮色
    property color targetColor: root.unitIsFocus ? root.highlightColor : root.themeColor
    
    // 计算当前状态的不透明度：使用 styleUnfocusedAlpha 或 styleFocusedAlpha
    property real currentAlpha: Math.sqrt(root.unitIsFocus 
        ? (root.styleFocusedAlpha / 255.0) 
        : (root.styleUnfocusedAlpha / 255.0))

    property bool showBorder: false
    
    // 渐变停止点配置（动态调整）
    // active 时：90%，focused 时：50%，默认：10%
    property real gradientStop: root.isPressed ? 0.9 : (root.unitIsFocus||root.unitIsSelect ? 0.5 : 0.1)
    
    // 边框配置 - 采用HTML版本的设置
    property color borderColor: {
        if (root.proxyFilePath && root.proxyFilePath !== "" && root.fileColor) {
            // 如果有文件色，使用文件色，alpha为0.3（与HTML版本一致）
            return Qt.rgba(
                root.fileColor.r,
                root.fileColor.g,
                root.fileColor.b,
                0.3
            )
        } else {
            // 如果没有文件色，使用白色，根据状态调整alpha
            if (root.isPressed) {
                // active 状态：rgba(255, 255, 255, 0.147)
                return Qt.rgba(1.0, 1.0, 1.0, 0.147)
            } else if (root.unitIsFocus) {
                // focused 状态：rgba(255, 255, 255, 0.4)
                return Qt.rgba(1.0, 1.0, 1.0, 0.4)
            } else {
                // 默认状态：rgba(255, 255, 255, 0.2)
                return Qt.rgba(1.0, 1.0, 1.0, 0.2)
            }
        }
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
        color: "transparent"
        
        // 边框
        border.width: 2
        border.color: root.borderColor
        
        Rectangle {
            id: rect1
            anchors.fill: parent
            radius: root.cardRadius
            visible: false
        }
        
        // 渐变背景：从文件颜色到主题色
        // 注意：QML 的 Gradient 不支持对角线，使用水平渐变模拟
        LinearGradient{ 
            anchors.fill: parent
            start: Qt.point(0,0)
            end: Qt.point(width*0.9,height*0.9)
            // radius: cardRadius
            source:rect1
            // color: "transparent"
            z: 0  // 最底层：背景渐变
            gradient: Gradient {
            id: backgroundGradient
      
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
                // 渐变终点：使用主题色，不透明度固定（与HTML版本一致）
                // 有文件色时：0.2，无文件色时：0.1
                color: {
                    if (root.proxyFilePath && root.proxyFilePath !== "") {
                        // 有文件色时：使用主题色，alpha固定为0.2
                        return Qt.rgba(
                            root.themeColor.r,
                            root.themeColor.g,
                            root.themeColor.b,
                            root.currentAlpha*0.5
                        )
                    } else {
                        // 无文件色时：使用主题色，alpha固定为0.1
                        return Qt.rgba(
                            root.themeColor.r,
                            root.themeColor.g,
                            root.themeColor.b,
                            root.currentAlpha*0.5
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
        }
        }
        
        // 边框颜色动画 - 与HTML版本一致：0.4s cubic-bezier(0.25, 0.8, 0.25, 1)
        Behavior on border.color {
            ColorAnimation {
                duration: root.animationDuration * 0.67  // 0.4s (600ms * 0.67 ≈ 400ms)
                easing.type: Easing.Bezier
                easing.bezierCurve: [0.25, 0.8, 0.25, 1.0, 1.0, 1.0]
            }
        }
        
        
        // ==================== 图标背景层 ====================
        // 聚焦时显示淡淡的图标背景
        // 层级：位于背景渐变和内容区域之间
        Image {
            id: iconBackground
            anchors.fill: parent
            source: root.proxyFileIcon && root.proxyFileIcon !== "" 
                ? root.proxyFileIcon 
                : ""
            fillMode: Image.PreserveAspectFit
            horizontalAlignment: Image.AlignHCenter
            verticalAlignment: Image.AlignVCenter
            opacity: root.unitIsFocus ? 0.05 : 0.02
            smooth: true
            mipmap: true  // 启用多级纹理，改善大图片缩小时的锯齿问题
            cache: true  // 启用缓存，提高性能
            asynchronous: true
            z: 1  // 中间层：图标背景（在背景渐变之上，内容区域之下）
            
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
        // 层级：最顶层，显示图标和文件名
        // 根据方向动态切换 Row 或 Column
        Loader {
            id: contentLoader
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            z: 2  // 最顶层：内容区域（图标和文件名）
            sourceComponent: root.isVertical ? columnLayout : rowLayout
        }
        
        // 横向布局组件
        Component {
            id: rowLayout
            Row {
                id: contentRow
                spacing: root.showName ? cardContainer.width * 0.05 : 0

                Behavior on spacing {
                    NumberAnimation {
                        duration: root.animationDuration * 0.83
                        easing.type: Easing.Bezier
                        easing.bezierCurve: [0.19, 1.0, 0.22, 1.0, 1.0, 1.0]
                    }
                }
            
            // 计算内容总宽度：图标宽度 + 间距 + 名字容器宽度
            // 直接绑定到 nameContainer.width，会自动跟随文字动画，保持同步
            // width: iconContainer.width  + nameContainer.width
            
            
            // ==================== 图标容器 ====================
            Item {

                Rectangle {
                    anchors.fill: parent
                    color: "transparent"
                    border.width: 2
                    border.color: "green"
                    visible: root.showBorder
                }
                id: iconContainer
                width: root.proxyFileIcon && root.proxyFileIcon !== "" ? root.iconSize : 1
                height: root.iconSize
                anchors.verticalCenter: parent.verticalCenter
                // z-order 由父容器 contentRow 统一管理
                
                // 鼠标悬停检测区域
                MouseArea {
                    id: iconMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.NoButton  // 不处理点击，只检测悬停
                }
                
                // 图标
                Image {
                    id: fileIcon
                    anchors.fill: parent
                    source: root.proxyFileIcon && root.proxyFileIcon !== "" 
                        ? root.proxyFileIcon 
                        : ""
                    fillMode: Image.PreserveAspectFit
                    // smooth: true
                    antialiasing: true
                    mipmap: true  // 启用多级纹理，改善大图片缩小时的锯齿问题
                    // cache: true  // 启用缓存，提高性能
                    asynchronous: true
                    // samples:4
                    
                    // 图标阴影 - filter: drop-shadow(0 2px 4px rgba(0, 0, 0, 0.2))
                    layer.enabled: true
                    layer.effect: DropShadow {
                        color: "#33000000"  // rgba(0, 0, 0, 0.2)
                        radius: 4
                        samples: 7
                        horizontalOffset: 0
                        verticalOffset: 2
                        transparentBorder: true
                    }
                    layer.samples: 4
                    
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
                    font.family: "Segoe UI"
                    visible: !root.proxyFileIcon || root.proxyFileIcon === ""
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
                Rectangle {
                    anchors.fill: parent
                    color: "transparent"
                    border.width: 2
                    border.color: "white"
                    visible: root.showBorder
                }
                width: {
                    // 精简模式且非聚焦状态 - 隐藏文字
                    if (!root.showName) {
                        return 0
                    }
                    // 其他情况均显示文字
                    // 计算文本实际宽度，加上边距
                    var textWidth = fileNameText.implicitWidth
                    // 最大宽度：父容器宽度减去图标宽度和间距，再减去一些边距
                    var maxWidth = cardContainer.width - iconContainer.width
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
                            : "请右键选择文件或拖动到此处"
                        color: "#FFFFFF"  // 固定使用白色
                        font.pixelSize: root.fontSize
                        font.weight: Font.Black  // 相当于 font-weight: 600
                        // font.family: "Segoe UI"
                        font.letterSpacing: 0.8  // 字间距，与HTML版本一致
                        elide: Text.ElideNone
                        
                        // 文字阴影：0 1px 2px rgba(0, 0, 0, 0.3) - 与HTML版本一致
                        layer.enabled: true
                        layer.effect: DropShadow {
                            color: "#4D000000"  // rgba(0, 0, 0, 0.3)
                            radius: 2
                            samples: 7
                            horizontalOffset: 0
                            verticalOffset: 1
                            transparentBorder: true
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

                // 占位容器：用于防止靠右
                Item {
                    width: 0
                    height: parent.height
                    Rectangle {
                        anchors.fill: parent
                        color: "transparent"
                        border.width: 2
                        border.color: "blue"
                        visible: root.showBorder
                    }
                }
            }
        }
        
        // 竖向布局组件
        Component {
            id: columnLayout
            Column {
                id: contentColumn
                spacing: root.showName ? cardContainer.height * 0.05 : 0

                Behavior on spacing {
                    NumberAnimation {
                        duration: root.animationDuration * 0.83
                        easing.type: Easing.Bezier
                        easing.bezierCurve: [0.19, 1.0, 0.22, 1.0, 1.0, 1.0]
                    }
                }
                
                // ==================== 图标容器 ====================
                Item {
                    Rectangle {
                        anchors.fill: parent
                        color: "transparent"
                        border.width: 2
                        border.color: "green"
                        visible: root.showBorder
                    }
                    id: iconContainerVertical
                    width: root.proxyFileIcon && root.proxyFileIcon !== "" ? root.iconSize : 1
                    height: root.iconSize
                    anchors.horizontalCenter: parent.horizontalCenter
                    
                    // 鼠标悬停检测区域
                    MouseArea {
                        id: iconMouseAreaVertical
                        anchors.fill: parent
                        hoverEnabled: true
                        acceptedButtons: Qt.NoButton
                    }
                    
                    // 图标
                    Image {
                        id: fileIconVertical
                        anchors.fill: parent
                        source: root.proxyFileIcon && root.proxyFileIcon !== "" 
                            ? root.proxyFileIcon 
                            : ""
                        fillMode: Image.PreserveAspectFit
                        antialiasing: true
                        mipmap: true
                        asynchronous: true
                        
                        layer.enabled: true
                        layer.effect: DropShadow {
                            color: "#33000000"
                            radius: 4
                            samples: 7
                            horizontalOffset: 0
                            verticalOffset: 2
                            transparentBorder: true
                        }
                        layer.samples: 4
                        
                        onStatusChanged: {
                            if (status === Image.Error) {
                                console.log("Beautiful Card: 图标加载失败")
                            }
                        }
                    }
                    
                    // 占位图标
                    Text {
                        anchors.centerIn: parent
                        text: root.proxyFilePath && root.proxyFilePath !== "" ? "📄" : "➕"
                        font.pixelSize: 20
                        font.family: "Segoe UI"
                        visible: !root.proxyFileIcon || root.proxyFileIcon === ""
                    }
                    
                    // 图标缩放动画
                    scale: iconMouseAreaVertical.containsMouse ? 1.2 : (root.unitIsFocus ? 1.1 : 1.0)
                    Behavior on scale {
                        NumberAnimation {
                            duration: root.animationDuration * 0.67
                            easing.type: Easing.OutCubic
                        }
                    }
                }
                
                // ==================== 文件名容器（竖向）====================
                Item {
                    id: nameContainerVertical
                    Rectangle {
                        anchors.fill: parent
                        color: "transparent"
                        border.width: 2
                        border.color: "white"
                        visible: root.showBorder
                    }
                    width: {
                        // 计算文本实际宽度，加上边距
                        var textWidth = fileNameTextVertical.implicitWidth
                        // 最大宽度：卡片宽度减去一些边距
                        var maxWidth = cardContainer.width * 0.9
                        return Math.min(textWidth + root.nameMargin * 2, maxWidth)
                    }
                    height: {
                        // 精简模式且非聚焦状态 - 隐藏文字
                        if (!root.showName) {
                            return 0
                        }
                        // 其他情况均显示文字
                        // 计算文本实际高度，加上边距
                        var textHeight = fileNameTextVertical.implicitHeight
                        // 最大高度：父容器高度减去图标高度和间距
                        var maxHeight = cardContainer.height - iconContainerVertical.height
                        return Math.min(textHeight + root.nameMargin * 2, maxHeight)
                    }
                    anchors.horizontalCenter: parent.horizontalCenter
                    clip: true
                    opacity: (root.unitSimpleMode && !root.unitIsFocus) ? 0.0 : 1.0
                    
                    // 文件名文本
                    Item {
                        id: textItemVertical
                        anchors.fill: parent

                        Text {
                            id: fileNameTextVertical
                            anchors.top: parent.top
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.topMargin: root.nameMargin
                            text: root.proxyFileName && root.proxyFileName !== "" 
                                ? root.proxyFileName 
                                : "请右键选择文件或拖动到此处"
                            color: "#FFFFFF"
                            font.pixelSize: root.fontSize
                            font.weight: Font.Black
                            font.letterSpacing: 0.8
                            elide: Text.ElideNone
                            
                            layer.enabled: true
                            layer.effect: DropShadow {
                                color: "#4D000000"
                                radius: 2
                                samples: 7
                                horizontalOffset: 0
                                verticalOffset: 1
                                transparentBorder: true
                            }
                        }
                    }
                    
                    // 文件名容器高度动画（竖向时使用高度动画）
                    Behavior on height {
                        NumberAnimation {
                            duration: root.animationDuration * 0.83
                            easing.type: Easing.Bezier
                            easing.bezierCurve: [0.19, 1.0, 0.22, 1.0, 1.0, 1.0]
                        }
                    }
                    
                    // 文件名容器宽度动画（确保宽度变化时也有平滑过渡）
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


    }
    
    // ==================== 状态绑定 ====================
    // 注意：gradientStop 和 borderColor 现在通过属性绑定自动更新
    // 不需要手动设置，它们会根据 isPressed 和 unitIsFocus 自动计算
    
    // 文件变化时更新渐变颜色
    onProxyFileColorChanged: {
        // 渐变颜色会自动更新（通过绑定）
    }
    
}

