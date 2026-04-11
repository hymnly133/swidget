import QtQuick 2.15
import QtQuick.Controls 2.15
//%IF_QT6 import QtQuick.Controls.Basic
import QtQuick.Layouts 1.15
//%IF_QT6 import QtQuick.Dialogs
//%IF_QT5 import QtQuick.Dialogs 1.3
//%IF_QT6 import Qt5Compat.GraphicalEffects
//%IF_QT5 import QtGraphicalEffects 1.15
import "@COMMON_IMPORT@"
/**
 * @brief 图片轮播QML组件
 * 
 * 支持多选图片，支持自动轮播，支持3D旋转，支持圆角遮罩，支持鼠标事件穿透，支持点击事件穿透，支持双击事件穿透，支持按下事件穿透，支持释放事件穿透
 */

SWidget{
    // mainColor, isFocus, isSelect, simpleMode 都是支持数据绑定的预设置的属性

    id: root
    globalRoundCornerEnabled: false

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
    property int currentImageIndex: 0
    property bool hasImage: imageCount > 0
    property bool multipleImage: imageCount > 1    
    property real rotationScale: 1.0  // 图片放大倍数，用于容纳3D旋转
    property bool autoPlay: true
    // 存储所有图片页面的数组
    property var imagePages: []

    // 渲染优化设置
    layer.enabled: true
    layer.smooth: true
    layer.samples: 2  // 4x MSAA抗锯齿
    layer.mipmap: true

    // 同步imageList和imagePages - 维护增删逻辑
    function syncImagePages() {
        //%QT6_BEGIN
        var listLength = imageList.length
        //%QT6_END
        
        //%QT5_BEGIN
        // Qt5中安全地获取数组长度
        var listLength = 0
        if (imageList && typeof imageList.length !== 'undefined') {
            listLength = imageList.length
        }
        //%QT5_END
        
        console.log("同步图片页面，imageList长度:", listLength, "imagePages长度:", imagePages.length)

        imageStackView.clear()
        for (var i = 0; i < imagePages.length; i++) {
            if (imagePages[i]) {
                imagePages[i].destroy()
            }
        }
        imagePages = []
        
        // 添加或更新页面
        for (var i = 0; i < listLength; i++) {
            //%QT6_BEGIN
            var imageSource = imageList[i]
            //%QT6_END
            
            //%QT5_BEGIN
            // Qt5中安全地访问数组元素
            var imageSource = ""
            if (imageList && imageList[i]) {
                imageSource = imageList[i]
            }
            //%QT5_END
            
            var newPage = imagePageComponent.createObject(imageStackView, {
                imageSource: imageSource
            })
            imagePages.push(newPage)
            console.log("创建新页面:", imageSource)
        }
        
        console.log("同步完成，imagePages长度:", imagePages.length)
        for (var i = 0; i < imagePages.length; i++) {
            console.log("imagePages[", i, "]:", imagePages[i].imageSource)
        }

        switchToImage(0)
    }
    
    // 切换到下一张图片
    function nextImage() {
        if (multipleImage && hasImage) {
            //%QT6_BEGIN
            var listLength = imageList.length
            //%QT6_END
            
            //%QT5_BEGIN
            var listLength = 0
            if (imageList && typeof imageList.length !== 'undefined') {
                listLength = imageList.length
            }
            //%QT5_END
            
            var nextIndex = (currentImageIndex + 1) % listLength
            switchToImage(nextIndex)
        }
    }
    
    // 切换到上一张图片
    function previousImage() {
        if (multipleImage && hasImage) {
            //%QT6_BEGIN
            var listLength = imageList.length
            //%QT6_END
            
            //%QT5_BEGIN
            var listLength = 0
            if (imageList && typeof imageList.length !== 'undefined') {
                listLength = imageList.length
            }
            //%QT5_END
            
            var prevIndex = currentImageIndex > 0 ? currentImageIndex - 1 : listLength - 1
            switchToImage(prevIndex)
        }
    }
    
    // 图片切换函数 - 使用StackView.replace实现渐隐效果
    function switchToImage(newIndex) {
        //%QT6_BEGIN
        var listLength = imageList.length
        //%QT6_END
        
        //%QT5_BEGIN
        var listLength = 0
        if (imageList && typeof imageList.length !== 'undefined') {
            listLength = imageList.length
        }
        //%QT5_END
        
        if (!listLength || newIndex < 0 || newIndex >= listLength) {
            console.log("无效的图片索引:", newIndex)
            console.log("当前图片索引:", currentImageIndex)
            console.log("图片列表长度:", listLength)
            console.log("hasImage:", hasImage)
            return
        }
        
        if (newIndex === currentImageIndex && imageStackView.currentItem === imagePages[newIndex]) {
            console.log("已经是当前图片，不需要切换")
            return  // 已经是当前图片，不需要切换
        }
        
        console.log("切换到图片索引:", newIndex, "从:", currentImageIndex)
        
        // 更新当前索引
        currentImageIndex = newIndex
        
        // 确保页面存在
        if (!imagePages[newIndex]) {
            console.log("页面不存在，重新同步")
            syncImagePages()
        }

        imageStackView.replace(null, imagePages[newIndex])
        
    }
    

    // 监听imageList变化 - 同步页面并同步持久化资源路径列表
    //%QT6_BEGIN
    onImageListChanged: {
        root.registerPersistentResourcePaths(imageList || [])
        syncImagePages()
    }
    //%QT6_END
    
    //%QT5_BEGIN
    // Qt5中var类型修改数组内容不会自动触发onChanged信号
    // 使用Connections监听imageList的变化，或者手动调用syncImagePages
    // 由于Qt5的限制，我们需要在修改imageList后手动调用syncImagePages
    // 这里保留onImageListChanged作为备用，但主要依赖手动调用
    onImageListChanged: {
        updateImageListString()  // 同步更新持久化字符串
        syncImagePages()
    }
    
    // Qt5辅助函数：安全地修改imageList并触发同步
    function modifyImageList(operation) {
        // operation是一个函数，接收当前imageList并返回新的imageList
        var newList = operation(imageList)
        imageList = newList
        updateImageListString()  // 更新持久化字符串
        // 手动触发同步（因为var类型可能不会触发onChanged）
        syncImagePages()
    }
    
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
    
    // 监听currentImageIndex变化 - 切换图片
    onCurrentImageIndexChanged: {
    }
    


    // 主要内容布局
    ColumnLayout {
        anchors.fill: parent
        spacing: 12
        // 图片页面组件工厂 - 简化版本，遮罩和旋转在StackView层面应用
        Component {
            id: imagePageComponent
            
            Item {
                id: imagePage
                property string imageSource: ""

                
                // 图片显示（使用 file:// URL 确保 Windows 下本地路径能正确显示）
                Image {
                    id: pageImage
                    anchors.fill: parent
                    source: imagePage.imageSource
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    visible: true
                    cache: false
                    
                    // 渲染优化
                    layer.enabled: true
                    layer.smooth: true
                    layer.mipmap: true
                }
            }
        }
        // 自动轮播定时器：仅当组件可见时运行（unitVisible 由 SWidget 绑定，未就绪时默认为 false，避免多页同时轮播）
        Timer {
            id: autoSlideTimer
            interval: 3000 // 3秒自动切换
            repeat: true
            running: root.multipleImage && root.unitVisible && root.autoPlay

            onTriggered: {
                if (root.multipleImage) {
                    root.nextImage()
                }
            }
        }

        
        // 文件对话框 - 支持多选
        //%QT6_BEGIN
        FileDialog {
            id: imageFileDialog
            title: "选择图片"
            fileMode : FileDialog.OpenFiles
            nameFilters: ["图片文件 (*.png *.jpg *.jpeg *.bmp *.gif)"]
            onAccepted: {
                console.log("选择的文件数量:", selectedFiles.length)
                
                // 处理多个文件路径
                for (var i = 0; i < selectedFiles.length; i++) {
                    var newImagePath = selectedFiles[i].toString()
                    console.log("选择的图片路径 " + (i + 1) + ":", newImagePath)
                    
                    // 检查是否已存在相同路径的图片
                    var isDuplicate = false
                    for (var j = 0; j < root.imageList.length; j++) {
                        if (root.imageList[j] === newImagePath) {
                            isDuplicate = true
                            console.log("跳过重复图片:", newImagePath)
                            break
                        }
                    }
                    
                    // 如果不是重复图片，则添加到列表
                    if (!isDuplicate) {
                        root.imageList.push(newImagePath)
                        console.log("添加新图片:", newImagePath)
                    }
                }
                
                // 如果之前没有图片，设置当前索引为第一张
                if (root.imageList.length > 0 && root.currentImageIndex < 0) {
                    root.currentImageIndex = 0
                }
                
                console.log("更新后的图片列表:", root.imageList)
                console.log("当前图片索引:", root.currentImageIndex)
                console.log("hasImage状态:", root.hasImage)
            }
            onRejected: {
                console.log("取消选择图片")
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
                    console.log("没有选择文件或fileUrls为null")
                    return
                }
                
                console.log("选择的文件数量:", urls.length)
                
                // Qt5使用fileUrls而不是selectedFiles
                // 处理多个文件路径
                for (var i = 0; i < urls.length; i++) {
                    var urlItem = urls[i]
                    if (!urlItem) continue
                    
                    var newImagePath = urlItem.toString()
                    console.log("选择的图片路径 " + (i + 1) + ":", newImagePath)
                    
                    // 检查是否已存在相同路径的图片
                    var isDuplicate = false
                    var currentListLength = 0
                    if (root.imageList && typeof root.imageList.length !== 'undefined') {
                        currentListLength = root.imageList.length
                    }
                    
                    for (var j = 0; j < currentListLength; j++) {
                        if (root.imageList[j] === newImagePath) {
                            isDuplicate = true
                            console.log("跳过重复图片:", newImagePath)
                            break
                        }
                    }
                    
                    // 如果不是重复图片，则添加到列表
                    // Qt5中需要重新赋值整个数组以触发onChanged信号
                    if (!isDuplicate) {
                        var newList = []
                        if (root.imageList && typeof root.imageList.slice === 'function') {
                            newList = root.imageList.slice()  // 创建副本
                        }
                        newList.push(newImagePath)  // 修改副本
                        root.imageList = newList  // 重新赋值以触发onChanged
                        root.updateImageListString()  // 更新持久化字符串
                        console.log("添加新图片:", newImagePath)
                    }
                }
                
                // 如果之前没有图片，设置当前索引为第一张
                var finalListLength = 0
                if (root.imageList && typeof root.imageList.length !== 'undefined') {
                    finalListLength = root.imageList.length
                }
                if (finalListLength > 0 && root.currentImageIndex < 0) {
                    root.currentImageIndex = 0
                }
                
                // Qt5中手动触发同步（确保即使onChanged未触发也能同步）
                root.syncImagePages()
                
                console.log("更新后的图片列表:", root.imageList)
                console.log("当前图片索引:", root.currentImageIndex)
                console.log("hasImage状态:", root.hasImage)
            }
            onRejected: {
                console.log("取消选择图片")
            }
        }
        //%QT5_END
    
    

        // 图片显示区域 - 使用StackView实现渐隐效果
        Rectangle {
            id: imageContainer
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


            // 渲染优化
            layer.enabled: true
            layer.smooth: true
            
            // StackView包装容器 - 应用遮罩和旋转效果
            Item {
                id: stackViewContainer
                anchors.fill: parent
                anchors.margins: 2
                clip: true
                
                // StackView管理图片页面
                StackView {
                    id: imageStackView
                    anchors.fill: parent
                    visible: true  // 隐藏原始StackView，通过OpacityMask显示
                    opacity:0
                    
                    // 自定义替换过渡动画 - 渐隐效果
                    replaceEnter: Transition {
                        PropertyAnimation {
                            property: "opacity"
                            from: 0.0
                            to: 1.0
                            duration: 400
                            easing.type: Easing.InOutQuad
                        }
                    }
                    
                    replaceExit: Transition {
                        PropertyAnimation {
                            property: "opacity"
                            from: 1.0
                            to: 0.0
                            duration: 400
                            easing.type: Easing.InOutQuad
                        }
                    }
                }
                
                // 圆角遮罩
                Rectangle {
                    id: imageMask
                    anchors.fill: parent
                    color: "black"
                    radius: root.unitRadius
                    visible: false
                }
                
                // 图片显示项 - 用于3D旋转和遮罩
                Item {
                    id: imageDisplayItem
                    anchors.centerIn: parent
                    width: parent.width * root.rotationScale
                    height: parent.height * root.rotationScale
                    visible: root.hasImage
                    
                    // 应用圆角遮罩到StackView
                    OpacityMask {
                        anchors.fill: parent
                        source: imageStackView
                        maskSource: imageMask
                        visible: true
                        
                        // 3D偏移变换
                        transform: [
                            Rotation {
                                origin.x: imageDisplayItem.width / 2
                                origin.y: imageDisplayItem.height / 2
                                axis { x: 1; y: 0; z: 0 }
                                angle: -15 * imageMouseArea.offsetY
                            },
                            Rotation {
                                origin.x: imageDisplayItem.width / 2
                                origin.y: imageDisplayItem.height / 2
                                axis { x: 0; y: 1; z: 0 }
                                angle: 15 * imageMouseArea.offsetX
                            }
                        ]
                        Behavior on transform {
                            NumberAnimation { 
                                duration: 150
                                easing.type: Easing.OutQuad 
                            }
                        }
                    }
                }
            }
            
            MouseArea {
                id: imageMouseArea
                anchors.fill: parent
                hoverEnabled: true
                propagateComposedEvents: true
                
                property real offsetX: 0
                property real offsetY: 0
                
                // 3D偏移动画
                Behavior on offsetX {
                    NumberAnimation { 
                        duration: 150
                        easing.type: Easing.OutQuad 
                    }
                }
                Behavior on offsetY {
                    NumberAnimation { 
                        duration: 150
                        easing.type: Easing.OutQuad 
                    }
                }

                onEntered: function() {

                }

                onExited: function() {
                    offsetX = 0
                    offsetY = 0
                }
                
                onPositionChanged: function(mouse) {
                    // 计算相对中心的偏移，范围[-1,1]
                    var cx = width / 2
                    var cy = height / 2
                    offsetX = (mouse.x - cx) / cx
                    offsetY = (mouse.y - cy) / cy
                }

                onPressed: function(mouse) {
                    console.log("outImageMouseArea按下事件")
                    if(root.hasImage) {
                        console.log("MouseArea按下事件穿透,有图片")
                        mouse.accepted = false
                        return
                    }
                    else{
                        if(root.currentOperationMode != "edit"){
                            console.log("MouseArea接受,无图片,打开文件对话框")
                            imageFileDialog.open()
                            mouse.accepted = true
                        }
                        else{
                            console.log("MouseArea按下事件穿透,无图片,不打开文件对话框")
                            mouse.accepted = false
                        }
                    }
                }
                // 无图片时的提示
                Text {
                    anchors.centerIn: parent
                    text: root.currentOperationMode == "edit" ? "点击下方按钮选择图片" : "点击此处或者下方按钮选择图片"
                    color: "white"
                    font.pixelSize: 14
                    visible: !root.hasImage
                    renderType: Text.NativeRendering
                    antialiasing: true
                    z: 10
                }
                
                // 右侧控制面板
                Rectangle {
                    id: rightControlPanel
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: 120
                    color: Qt.rgba(0, 0, 0, 0.3)
                    visible: root.multipleImage
                    opacity: (imageMouseArea.containsMouse && root.currentOperationMode == "edit") ? 1 : 0
                    
                    // 淡入淡出动画
                    Behavior on opacity {
                        NumberAnimation { 
                            duration: 200; 
                            easing.type: Easing.OutQuad 
                        }
                    }
                    
                    Column {
                        anchors.centerIn: parent
                        spacing: 10
                        
                        // 自动轮播控制按钮
                        Rectangle {
                            width: 100
                            height: 30
                            radius: 15
                            color: autoSlideTimer.running ? "#FF5722" : "#4CAF50"
                            border.color: "white"
                            border.width: 1
                            
                            Text {
                                anchors.centerIn: parent
                                text: autoSlideTimer.running ? "停止自动" : "开始自动"
                                color: "white"
                                font.pixelSize: 10
                                font.bold: true
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                
                                onEntered: {
                                    parent.color = root.autoPlay ? Qt.darker("#FF5722", 1.2) : Qt.darker("#4CAF50", 1.2)
                                }
                                
                                onExited: {
                                    parent.color = root.autoPlay ? "#FF5722" : "#4CAF50"
                                }

                                onPressed: function(mouse) {
                                    mouse.accepted = true
                                    root.autoPlay = !root.autoPlay
                                }

                            }
                        }
                        
                        // 图片指示器
                        Rectangle {
                            width: 100
                            height: 25
                            radius: 12
                            color: Qt.rgba(0, 0, 0, 0.8)
                            border.color: "white"
                            border.width: 1
                            
                            Text {
                                anchors.centerIn: parent
                                text: (root.currentImageIndex + 1) + "/" + root.imageCount
                                color: "white"
                                font.pixelSize: 12
                                font.bold: true
                            }
                        }
                        
                        // 自动轮播状态
                        Rectangle {
                            width: 100
                            height: 20
                            radius: 10
                            color: autoSlideTimer.running ? Qt.rgba(76, 175, 80, 0.8) : Qt.rgba(158, 158, 158, 0.8)
                            
                            Text {
                                anchors.centerIn: parent
                                text: autoSlideTimer.running ? "自动轮播中" : "手动模式"
                                color: "white"
                                font.pixelSize: 8
                            }
                        }
                    }
                }
                
                // 底部轮播控制按钮
                Row {
                    id: bottomControlButtons
                    anchors {
                        bottom: parent.bottom
                        horizontalCenter: parent.horizontalCenter
                        margins: 8
                    }
                    spacing: 8
                    visible: root.multipleImage
                    opacity: (imageMouseArea.containsMouse) ? 1 : 0
                    
                    // 淡入淡出动画
                    Behavior on opacity {
                        NumberAnimation { 
                            duration: 200; 
                            easing.type: Easing.OutQuad 
                        }
                    }
                    
                    // 调试信息
                    Component.onCompleted: {
                        console.log("轮播控制按钮可见性检查:")
                        console.log("  hasImage:", root.hasImage)
                        console.log("  imageList.length:", root.imageList.length)
                        console.log("  visible:", visible)
                    }
                    
                    // 上一张按钮
                    Rectangle {
                        width: 40
                        height: 40
                        radius: 20
                        color: Qt.rgba(0, 0, 0, 0.8)
                        border.color: "white"
                        border.width: 2
                        
                        Text {
                            anchors.centerIn: parent
                            text: "‹"
                            color: "white"
                            font.pixelSize: 24
                            font.bold: true
                        }
                        
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            preventStealing: true
                            propagateComposedEvents: true

                            onEntered: {
                                console.log("鼠标进入上一张按钮")
                                parent.color = Qt.rgba(0.8, 0.42, 0.42, 0.9)
                            }
                            
                            onExited: {
                                console.log("鼠标离开上一张按钮")
                                parent.color = Qt.rgba(0, 0, 0, 0.8)
                            }

                            onPressed: function(mouse) {
                                console.log("按下上一张按钮")
                                root.previousImage()
                                mouse.accepted = true
                            }

                            onReleased: function(mouse){
                                console.log("释放上一张按钮")
                                mouse.accepted = false
                            }
                            

                        }
                    }
                    
                    // 下一张按钮
                    Rectangle {
                        width: 40
                        height: 40
                        radius: 20
                        color: Qt.rgba(0, 0, 0, 0.8)
                        border.color: "white"
                        border.width: 2
                        
                        Text {
                            anchors.centerIn: parent
                            text: "›"
                            color: "white"
                            font.pixelSize: 24
                            font.bold: true
                        }
                        
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            
                            onEntered: {
                                parent.color = Qt.rgba(0.8, 0.42, 0.42, 0.9)
                            }
                            
                            onExited: {
                                parent.color = Qt.rgba(0, 0, 0, 0.8)
                            }
                            
                            onPressed: function(mouse) {
                                root.nextImage()
                                mouse.accepted = true
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
                // 手动触发同步（确保即使onChanged未触发也能同步）
                root.syncImagePages()
                //%QT5_END
                
                root.currentImageIndex = 0
                console.log("清除所有图片")
            }
        }
    
    }

    
    // 组件加载完成时的处理
    Component.onCompleted:  function() {
        console.log("=== QML组件加载完成 ===")
        console.log("主题色:", unitMainColor)
        console.log("当前主题色:", currentThemeColor)
        console.log("当前操作模式:", currentOperationMode, "类型:", typeof currentOperationMode)
        console.log("焦点状态:", unitIsFocus)
        console.log("初始imageList:", imageList)
        console.log("初始currentImageIndex:", currentImageIndex)
        console.log("初始hasImage:", hasImage)

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
        
        root.registerPersistentProperty("autoPlay", true)
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
