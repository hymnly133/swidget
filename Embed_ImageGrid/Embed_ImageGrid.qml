import QtQuick 2.15
import QtQuick.Controls 2.15
//%IF_QT6 import QtQuick.Controls.Basic
import QtQuick.Layouts 1.15
//%IF_QT6 import QtQuick.Dialogs
//%IF_QT5 import QtQuick.Dialogs 1.3
//%IF_QT6 import Qt5Compat.GraphicalEffects
//%IF_QT5 import QtGraphicalEffects 1.15
import "@COMMON_IMPORT@"

//%QT6_BEGIN
pragma ComponentBehavior: Bound
//%QT6_END

/**
 * @brief 横幅图片QML组件
 *
 * 多张图片水平排列成一整条横幅，未悬停时呈现黑白色调，
 * 鼠标悬停某张图片时该图片动态加宽并恢复彩色，其余图片自动让位。
 * 支持多选图片，支持鼠标事件穿透，支持点击事件穿透，支持双击事件穿透，支持按下事件穿透，支持释放事件穿透
 */

SWidget{
    id: root
    globalRoundCornerEnabled: false
    fpsDisplayMode: SWidget.FpsDisplayMode.Never

    // 这里需要在内部定义，因为C++解析持久化数据时，会自动设置和保存这些属性
    //%QT6_BEGIN
    property list<string> imageList: []
    //%QT6_END

    //%QT5_BEGIN
    // Qt5不支持list<string>，使用var类型替代
    property var imageList: []
    // Qt5持久化属性：使用字符串存储图片列表（用分号分隔）
    property string imageListString: ""
    //%QT5_END

    property int imageCount: {
        //%QT6_BEGIN
        return imageList.length
        //%QT6_END

        //%QT5_BEGIN
        // Qt5中需要安全地获取数组长度
        if (!imageList || typeof imageList.length === 'undefined') {
            return 0
        }
        return imageList.length
        //%QT5_END
    }
    property bool hasImage: imageCount > 0

    // 布局相关属性
    property int gridSpacing: 2        // 图片间距
    property real hoverWidthRatio: 0.4 // 悬停图片占用的宽度比例 (0.0-1.0)
    property int minimumImageWidth: 100  // 单个图片的最小宽度
    property int minimumOtherWidth: 50   // 其他图片的最小宽度

    // 效果相关属性
    property int animationDuration: 300     // 动画持续时间(毫秒)
    property bool enableHoverEffect: true   // 是否启用悬停加宽效果
    property bool idleGrayscale: true       // 未悬停时是否黑白显示
    property real idleDarken: 0.5           // 未悬停时的暗化程度 (0.0-1.0)
    property int hoveredIndex: -1           // 当前悬停的图片索引，-1表示无悬停

    // 宽度动画状态（单一动画驱动：所有图片宽度由同一进度插值，任意时刻总和恒等于可用宽度，
    // 避免每张图各自 Behavior 动画导致中间帧总宽不满、其他图片来回跳动）
    property var currentWidths: []    // 当前每格宽度（绑定到各图片）
    property var animFromWidths: []   // 动画起始宽度
    property var animToWidths: []     // 动画目标宽度
    property real animProgress: 1.0   // 动画进度 0..1（已含缓动）

    // 目标宽度数组：总和精确等于可用宽度（舍入差额补到首格）
    function targetWidths() {
        var n = imageCount
        if (n <= 0) {
            return []
        }
        var availableWidth = imageGrid.width - (n - 1) * gridSpacing
        if (availableWidth <= 0) {
            return []
        }

        var widths = []
        var hovered = enableHoverEffect ? hoveredIndex : -1
        if (hovered >= 0 && hovered < n && n > 1) {
            var hoveredWidth = Math.max(minimumImageWidth, availableWidth * hoverWidthRatio)
            var otherWidth = Math.max(minimumOtherWidth, (availableWidth - hoveredWidth) / (n - 1))
            for (var i = 0; i < n; i++) {
                widths.push(i === hovered ? hoveredWidth : otherWidth)
            }
        } else {
            var equalWidth = Math.max(minimumOtherWidth, availableWidth / n)
            for (var j = 0; j < n; j++) {
                widths.push(equalWidth)
            }
        }

        // 修正浮点舍入，保证总和精确等于可用宽度
        var sum = 0
        for (var k = 0; k < n; k++) {
            sum += widths[k]
        }
        widths[0] += availableWidth - sum
        return widths
    }

    // 兼容接口：返回某格的目标宽度
    function calculateImageWidth(imageIndex) {
        var targets = targetWidths()
        if (targets.length === 0) {
            return Math.max(0, imageGrid.width)
        }
        if (imageIndex < 0 || imageIndex >= targets.length) {
            return 0
        }
        return targets[imageIndex]
    }

    // 绑定接口：返回某格当前（动画中）宽度
    function widthAt(imageIndex) {
        if (imageIndex < 0 || imageIndex >= currentWidths.length) {
            return 0
        }
        return currentWidths[imageIndex]
    }

    // 启动一次整体宽度动画；组件不可见或数量变化时直接跳变，避免后台白跑动画
    function startWidthAnimation() {
        var targets = targetWidths()
        if (targets.length === 0) {
            widthAnim.stop()
            currentWidths = []
            return
        }
        if (!root.unitVisible || currentWidths.length !== targets.length) {
            widthAnim.stop()
            animProgress = 1.0
            currentWidths = targets
            return
        }
        animFromWidths = currentWidths.slice()
        animToWidths = targets
        animProgress = 0.0
        widthAnim.restart()
    }

    // 动画进度驱动整体宽度更新（逐帧整体插值，任意中间帧各格宽度之和都精确等于可用宽度）
    onAnimProgressChanged: {
        var from = animFromWidths
        var to = animToWidths
        if (from.length !== to.length || to.length === 0) {
            currentWidths = to.slice()
            return
        }
        var t = animProgress
        var out = []
        for (var i = 0; i < to.length; i++) {
            out.push(from[i] + (to[i] - from[i]) * t)
        }
        currentWidths = out
    }

    onHoveredIndexChanged: startWidthAnimation()
    onImageCountChanged: startWidthAnimation()
    onEnableHoverEffectChanged: startWidthAnimation()

    //%QT5_BEGIN
    // Qt5辅助函数：将imageList数组序列化为字符串（用分号分隔）
    function updateImageListString() {
        if (!imageList || typeof imageList.length === 'undefined') {
            imageListString = ""
            root.registerPersistentResourcePaths("")
            return
        }
        var strArray = []
        for (var i = 0; i < imageList.length; i++) {
            if (imageList[i]) {
                strArray.push(imageList[i])
            }
        }
        imageListString = strArray.join(";")
        root.registerPersistentResourcePaths(imageListString)
    }

    // Qt5辅助函数：从字符串反序列化为imageList数组
    function parseImageListString() {
        if (!imageListString || imageListString === "") {
            imageList = []
            return
        }
        var paths = imageListString.split(";")
        var newList = []
        for (var i = 0; i < paths.length; i++) {
            var path = paths[i].trim()
            if (path !== "") {
                newList.push(path)
            }
        }
        imageList = newList
    }
    //%QT5_END

    // 监听imageList变化 - 同步持久化资源路径列表
    //%QT6_BEGIN
    onImageListChanged: {
        root.registerPersistentResourcePaths(imageList || [])
    }
    //%QT6_END

    //%QT5_BEGIN
    // Qt5中var类型修改数组内容不会自动触发onChanged信号，重新赋值时会触发
    onImageListChanged: {
        updateImageListString()  // 同步更新持久化字符串
    }
    //%QT5_END

    // 主要内容布局
    ColumnLayout {
        anchors.fill: parent
        spacing: 12

        // 文件对话框 - 支持多选
        //%QT6_BEGIN
        FileDialog {
            id: imageFileDialog
            title: "选择图片"
            fileMode : FileDialog.OpenFiles
            nameFilters: ["图片文件 (*.png *.jpg *.jpeg *.bmp *.gif)"]
            onAccepted: {
                // 处理多个文件路径
                for (var i = 0; i < selectedFiles.length; i++) {
                    var newImagePath = selectedFiles[i].toString()

                    // 检查是否已存在相同路径的图片
                    var isDuplicate = false
                    for (var j = 0; j < root.imageList.length; j++) {
                        if (root.imageList[j] === newImagePath) {
                            isDuplicate = true
                            break
                        }
                    }

                    // 如果不是重复图片，则添加到列表
                    if (!isDuplicate) {
                        root.imageList.push(newImagePath)
                    }
                }
            }
        }
        //%QT6_END

        //%QT5_BEGIN
        FileDialog {
            id: imageFileDialog
            title: "选择图片"
            selectMultiple: true  // Qt5使用selectMultiple属性
            nameFilters: ["图片文件 (*.png *.jpg *.jpeg *.bmp *.gif)"]
            onAccepted: {
                // Qt5中安全地获取fileUrls
                var urls = fileUrls
                if (!urls || typeof urls.length === 'undefined') {
                    return
                }

                // Qt5使用fileUrls而不是selectedFiles
                for (var i = 0; i < urls.length; i++) {
                    var urlItem = urls[i]
                    if (!urlItem) continue

                    var newImagePath = urlItem.toString()

                    // 检查是否已存在相同路径的图片
                    var isDuplicate = false
                    var currentListLength = 0
                    if (root.imageList && typeof root.imageList.length !== 'undefined') {
                        currentListLength = root.imageList.length
                    }

                    for (var j = 0; j < currentListLength; j++) {
                        if (root.imageList[j] === newImagePath) {
                            isDuplicate = true
                            break
                        }
                    }

                    // 如果不是重复图片，则添加到列表
                    // Qt5中需要重新赋值整个数组以触发onChanged信号
                    if (!isDuplicate) {
                        var newList = []
                        if (root.imageList && root.imageList.slice) {
                            newList = root.imageList.slice()  // 创建副本
                        }
                        newList.push(newImagePath)  // 修改副本
                        root.imageList = newList  // 重新赋值以触发onChanged
                    }
                }
            }
        }
        //%QT5_END

        // 图片横幅容器
        Rectangle {
            id: imageGridContainer
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: Qt.rgba(
                root.styleBackgroundColor.r,
                root.styleBackgroundColor.g,
                root.styleBackgroundColor.b,
                root.styleBackgroundColor.a * 0.3
            )
            border.color: Qt.rgba(
                root.styleThemeColor.r,
                root.styleThemeColor.g,
                root.styleThemeColor.b,
                root.styleThemeColor.a * 0.3
            )
            border.width: 2
            radius: root.unitRadius
            clip: true

            // 单一宽度动画：驱动 root.animProgress 0→1，各格宽度在 onAnimProgressChanged 中整体插值
            // 放在 Item 内声明（SWidget 根的 default property 只接受 Item 子对象）
            NumberAnimation {
                id: widthAnim
                target: root
                property: "animProgress"
                from: 0.0
                to: 1.0
                duration: root.animationDuration
                easing.type: Easing.OutQuad
            }

            // 水平布局容器 - 实现类似flex的横幅布局
            RowLayout {
                id: imageGrid
                anchors.fill: parent
                anchors.margins: 2
                spacing: root.gridSpacing

                // 容器尺寸变化时直接重排（不打断总宽不变量，也不对resize播动画）
                onWidthChanged: {
                    widthAnim.stop()
                    root.animProgress = 1.0
                    root.currentWidths = root.targetWidths()
                    root.animFromWidths = root.currentWidths
                    root.animToWidths = root.currentWidths
                }

                // 动态创建图片组件
                Repeater {
                    id: imageRepeater
                    model: root.imageList

                    // 单个图片组件
                    Rectangle {
                        id: imageSection
                        required property int index
                        required property string modelData
                        // 宽度由根组件的单一动画整体驱动（见 widthAt），任意时刻总宽恒等于可用宽度
                        Layout.preferredWidth: root.widthAt(index)
                        Layout.fillHeight: true
                        color: "transparent"
                        clip: true
                        radius: root.unitRadius > 2 ? root.unitRadius - 2 : 0

                        // 原始图片（作为特效源，不直接显示）
                        Image {
                            id: sectionImage
                            anchors.fill: parent
                            source: imageSection.modelData
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            // 限制解码尺寸，避免大图（4K+）占满显存/内存；横幅展示不需要原始分辨率
                            sourceSize.width: 1920
                            sourceSize.height: 1920
                            cache: true
                            visible: false
                        }

                        // 去色效果：未悬停时黑白，悬停时恢复彩色
                        Desaturate {
                            anchors.fill: parent
                            source: sectionImage
                            desaturation: (root.hoveredIndex === imageSection.index || !root.idleGrayscale) ? 0.0 : 1.0
                            Behavior on desaturation {
                                NumberAnimation {
                                    duration: root.animationDuration
                                    easing.type: Easing.OutQuad
                                }
                                // 组件不可见时不播动画，直接跳变
                                enabled: root.unitVisible
                            }
                        }

                        // 暗化遮罩层 - 未悬停时压暗，悬停时消退
                        Rectangle {
                            anchors.fill: parent
                            color: "black"
                            opacity: (root.hoveredIndex === imageSection.index || !root.idleGrayscale) ? 0.0 : root.idleDarken
                            Behavior on opacity {
                                NumberAnimation {
                                    duration: root.animationDuration
                                    easing.type: Easing.OutQuad
                                }
                                // 组件不可见时不播动画，直接跳变
                                enabled: root.unitVisible
                            }
                        }

                        // 鼠标区域
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            propagateComposedEvents: true

                            onEntered: {
                                root.hoveredIndex = imageSection.index
                            }

                            onExited: {
                                if (root.hoveredIndex === imageSection.index) {
                                    root.hoveredIndex = -1
                                }
                            }

                            // 让点击事件穿透到下层组件
                            onClicked: function(mouse) {
                                mouse.accepted = false
                            }

                            onDoubleClicked: function(mouse) {
                                mouse.accepted = false
                            }

                            onPressed: function(mouse) {
                                if (root.hasImage) {
                                    mouse.accepted = false
                                } else {
                                    if (root.currentOperationMode != "edit") {
                                        imageFileDialog.open()
                                        mouse.accepted = true
                                    } else {
                                        mouse.accepted = false
                                    }
                                }
                            }

                            onReleased: function(mouse) {
                                mouse.accepted = false
                            }
                        }
                    }
                }

                // 无图片时的提示
                Text {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    text: root.currentOperationMode == "edit" ? "点击下方按钮选择图片" : "点击此处或者下方按钮选择图片"
                    color: "white"
                    font.pixelSize: 14
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    visible: !root.hasImage
                    renderType: Text.NativeRendering
                    antialiasing: true

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (root.currentOperationMode != "edit") {
                                imageFileDialog.open()
                            }
                        }
                    }
                }
            }
        }

        // 图片选择按钮
        Button {
            visible: (root.currentOperationMode || "desktop") == "edit"
            id: selectImageButton
            text: root.hasImage ? "添加更多图片" : "选择图片(可多选)"
            Layout.fillWidth: true
            Layout.preferredHeight: 32

            background: Rectangle {
                color: selectImageButton.pressed ? Qt.darker("#4CAF50", 1.3) : "#4CAF50"
                radius: 4
                border.color: "white"
                border.width: 1
            }

            contentItem: Text {
                text: selectImageButton.text
                color: "white"
                font.pixelSize: 12
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                renderType: Text.NativeRendering
                antialiasing: true
            }

            onClicked: {
                imageFileDialog.open()
            }
        }

        // 清除图片按钮
        Button {
            visible: (root.currentOperationMode || "desktop") == "edit" && root.hasImage
            id: clearButton
            text: "清除所有图片"
            Layout.fillWidth: true
            Layout.preferredHeight: 24

            background: Rectangle {
                color: clearButton.pressed ? Qt.darker("#F44336", 1.3) : "#F44336"
                radius: 4
                border.color: "white"
                border.width: 1
            }

            contentItem: Text {
                text: clearButton.text
                color: "white"
                font.pixelSize: 10
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                renderType: Text.NativeRendering
                antialiasing: true
            }

            onClicked: {
                //%QT6_BEGIN
                root.imageList = []
                //%QT6_END

                //%QT5_BEGIN
                // Qt5中需要重新赋值以触发onChanged信号
                root.imageList = []
                root.imageListString = ""  // 清空持久化字符串
                //%QT5_END

                root.hoveredIndex = -1
            }
        }
    }

    // 组件加载完成时的处理
    Component.onCompleted: function() {
        //%QT6_BEGIN
        root.registerPersistentProperty("imageList", [])
        root.registerPersistentResourcePaths(root.imageList || [])
        //%QT6_END

        //%QT5_BEGIN
        // Qt5中持久化属性不能直接使用列表，使用字符串辅助属性
        root.registerPersistentProperty("imageListString", "")
        // 如果imageListString有值，解析它
        if (root.imageListString && root.imageListString !== "") {
            root.parseImageListString()
        } else {
            // 如果没有持久化数据，初始化空数组
            root.imageList = []
        }
        root.registerPersistentResourcePaths(root.imageListString || "")
        //%QT5_END

        root.registerPersistentProperty("idleGrayscale", true)
        root.registerPersistentProperty("enableHoverEffect", true)

        // 初始化当前宽度（不经动画）
        root.currentWidths = root.targetWidths()
        root.animToWidths = root.currentWidths
        root.animFromWidths = root.currentWidths
    }

    //%QT5_BEGIN
    // Qt5中监听imageListString变化，自动解析
    // 注意：这个信号会在C++端设置持久化属性时触发
    onImageListStringChanged: {
        // 避免在Component.onCompleted之前解析（此时imageList可能还未初始化）
        if (typeof imageList !== 'undefined') {
            if (imageListString && imageListString !== "") {
                parseImageListString()
            } else {
                imageList = []
            }
        }
    }
    //%QT5_END
}
