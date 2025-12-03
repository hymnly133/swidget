import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Basic
import QtQuick.Layouts 1.15
import QtQuick.Dialogs
import QtMultimedia 6.8
import Qt5Compat.GraphicalEffects
import "../common"

/**
 * @brief MP4视频播放QML组件
 * 
 * 功能：
 * - 选择单个MP4文件
 * - 持续循环播放
 * - 支持持久化数据保存（通过SWidget）
 * 
 * 使用SWidget作为标准化接口，通过registerPersistentProperty注册持久化属性
 */

SWidget {
    id: root

    property int globalRadius: unitRadius || 8
    property int globalMargin: 3
    
    // 视频相关属性
    property string videoPath: ""
    property bool hasVideo: videoPath !== ""

    globalRoundCornerEnabled: true

    fpsDisplayMode: SWidget.FpsDisplayMode.Never
    onUnitVisibleChanged: {
        console.log("组件可见性变化:", unitVisible)
        console.log("当前透明度:", opacity)

        if (!unitVisible) {
            console.log("组件变为不可见，暂停视频播放")
            if (mediaPlayer.playbackState === MediaPlayer.PlayingState) {
                mediaPlayer.pause()
            }
        } else {
            console.log("组件变为可见，恢复视频播放")
            if (hasVideo && mediaPlayer.playbackState === MediaPlayer.PausedState) {
                mediaPlayer.play()
            }
        }
    }
    
    // 监听视频路径变化
    onVideoPathChanged: {
        console.log("=== 视频路径变化 ===")
        console.log("新视频路径:", videoPath)
        
        if (videoPath) {
            console.log("设置视频源并准备播放")
            // 清除之前的错误信息
            if (errorText) {
                errorText.visible = false
            }

        } else {
            console.log("清除视频源")

            // 清除错误信息
            if (errorText) {
                errorText.visible = false
            }
        }
    }
    

    // 组件加载完成时的处理
    Component.onCompleted: {
        console.log("=== MP4视频播放组件加载完成 ===")
        console.log("主题色:", unitMainColor)
        console.log("当前主题色:", currentThemeColor)
        console.log("当前操作模式:", currentOperationMode, "类型:", typeof currentOperationMode)
        console.log("焦点状态:", unitIsFocus)
        console.log("unit可见性" , unitVisible)
        
        // 注册持久化属性
        registerPersistentProperty("videoPath", "")
        console.log("已注册持久化属性: videoPath")
        console.log("=== 组件初始化完成 ===")
    }


            
    Rectangle {
        // 设置根元素大小
        anchors.fill: parent
        
        // 简单背景色
        color: "transparent"
        
        // 圆角效果
        radius: root.globalRadius
        


     // 文件对话框 - 支持多种视频格式
    FileDialog {
        id: videoFileDialog
        title: "选择视频文件"
        nameFilters: [
            "MP4视频文件 (*.mp4)",
            "AVI视频文件 (*.avi)", 
            "MOV视频文件 (*.mov)",
            "WMV视频文件 (*.wmv)",
            "所有视频文件 (*.mp4 *.avi *.mov *.wmv)"
        ]

        onAccepted: {
            console.log("选择的视频文件:", selectedFile)
            
            var newVideoPath = selectedFile.toString()
            console.log("选择的视频路径:", newVideoPath)
            
            // 设置视频路径
            root.videoPath = newVideoPath
            console.log("更新后的视频路径:", root.videoPath)
            console.log("hasVideo状态:", root.hasVideo)
        }
        onRejected: {
            console.log("取消选择视频文件")
        }
    }
   
    // 视频显示区域 - 铺满整个组件
    Rectangle {
        id: videoContainer
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.3)
        radius: root.globalRadius
        border.color: root.currentThemeColor
        border.width: 1
        
        
        MouseArea {
            id: videoMouseArea
            anchors.fill: parent
            hoverEnabled: true
            preventStealing: false
            propagateComposedEvents: true
            
            // 让点击事件穿透到下层组件
            onClicked: function(mouse) {
                console.log("MouseArea点击事件穿透")
                mouse.accepted = false  // 不处理点击事件，让事件继续传播
            }
            
            onDoubleClicked: function(mouse) {
                console.log("MouseArea双击事件穿透")
                mouse.accepted = false  // 不处理双击事件，让事件继续传播
            }
            
            onPressed: function(mouse) {
                console.log("MouseArea按下事件穿透")
                if(root.hasVideo) {
                    mouse.accepted = false  // 不处理点击事件，让事件继续传播
                    return
                }
                else{
                    if(root.currentOperationMode != "edit"){
                        videoFileDialog.open()
                        mouse.accepted = true
                    }
                    else{
                        mouse.accepted = false
                    }
                }
            }
            
            onReleased: function(mouse) {
                console.log("MouseArea释放事件穿透")
                mouse.accepted = false  // 不处理释放事件，让事件继续传播
            }
            
            // 媒体播放器
            MediaPlayer {
                id: mediaPlayer
                autoPlay: true
                loops: MediaPlayer.Infinite
                source: root.videoPath
                videoOutput: videoPlayer
                

                onSourceChanged: {
                    console.log("MediaPlayer源变化:", source)
                }
                
                
                // 播放状态变化
                onPlaybackStateChanged: {
                    console.log("播放状态变化:", playbackState, "状态名称:", getPlaybackStateName(playbackState))
                    if (playbackState === MediaPlayer.PlayingState) {
                        console.log("视频开始播放")
                    } else if (playbackState === MediaPlayer.PausedState) {
                        console.log("视频暂停")
                    } else if (playbackState === MediaPlayer.StoppedState) {
                        console.log("视频停止")
                    }
                }
                
                // 辅助函数：获取状态名称
                function getStatusName(status) {
                    switch(status) {
                        case MediaPlayer.NoMedia: return "NoMedia"
                        case MediaPlayer.LoadingMedia: return "LoadingMedia"
                        case MediaPlayer.LoadedMedia: return "LoadedMedia"
                        case MediaPlayer.BufferingMedia: return "BufferingMedia"
                        case MediaPlayer.BufferedMedia: return "BufferedMedia"
                        case MediaPlayer.EndOfMedia: return "EndOfMedia"
                        case MediaPlayer.InvalidMedia: return "InvalidMedia"
                        case MediaPlayer.StalledMedia: return "StalledMedia"
                        default: return "Unknown(" + status + ")"
                    }
                }
                
                // 辅助函数：获取播放状态名称
                function getPlaybackStateName(state) {
                    switch(state) {
                        case MediaPlayer.StoppedState: return "StoppedState"
                        case MediaPlayer.PlayingState: return "PlayingState"
                        case MediaPlayer.PausedState: return "PausedState"
                        default: return "Unknown(" + state + ")"
                    }
                }
            }
            
            // 视频输出
            VideoOutput {
                id: videoPlayer
                anchors.fill: parent
                // anchors.margins: root.globalMargin
                visible: root.hasVideo
                fillMode: VideoOutput.PreserveAspectCrop
                
            
                // 辅助函数：获取播放状态名称
                function getPlaybackStateName(state) {
                    switch(state) {
                        case MediaPlayer.StoppedState: return "StoppedState"
                        case MediaPlayer.PlayingState: return "PlayingState"
                        case MediaPlayer.PausedState: return "PausedState"
                        default: return "Unknown(" + state + ")"
                    }
                }
            }

            //     Rectangle {
            //         id: maskRect
            //         anchors.fill: parent
            //         color: "black"
            //         radius: root.globalRadius
            //     }
            // OpacityMask {
            //     anchors.fill: parent
            //     source: videoPlayer
            //     maskSource: maskRect
            //     visible: root.hasVideo
            // }
 
            // 无视频时的提示
            Text {
                anchors.centerIn: parent
                text: root.currentOperationMode == "edit" ? "点击下方按钮选择MP4视频" : "点击此处或者下方按钮选择MP4视频"
                color: "white"
                font.pixelSize: 14
                visible: !root.hasVideo
                renderType: Text.NativeRendering
                antialiasing: true
            }
            
            // 错误提示
            Text {
                id: errorText
                anchors.centerIn: parent
                color: "#FF6B6B"
                font.pixelSize: 12
                visible: false
                horizontalAlignment: Text.AlignHCenter
                renderType: Text.NativeRendering
                antialiasing: true
                wrapMode: Text.WordWrap
                width: parent.width - 20
            }
        }
    }
    
    // 按钮控制区域 - 叠加在视频底部
    Rectangle {
        id: buttonContainer
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: Math.max(120, buttonLayout.implicitHeight + 20)  // 动态高度，最小120px
        color: Qt.rgba(0, 0, 0, 0.7)  // 半透明黑色背景
        radius: 6
        visible: (root.currentOperationMode || "desktop") == "edit"
        

        
        // 按钮布局
        ColumnLayout {
            id: buttonLayout
            anchors.fill: parent
            anchors.margins: 10
            spacing: 8
            
            // 视频选择按钮
            Button {
                visible: (root.currentOperationMode || "desktop") == "edit"
                id: selectVideoButton
                text: root.hasVideo ? "更换视频文件" : "选择MP4视频文件"
                Layout.fillWidth: true
                
                background: Rectangle {
                    color: selectVideoButton.pressed ? Qt.darker("#4CAF50", 1.3) : "#4CAF50"
                    radius: 4
                    border.color: "white"
                    border.width: 1
                    

                }
                
                contentItem: Text {
                    text: selectVideoButton.text
                    color: "white"
                    font.pixelSize: 12
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    renderType: Text.NativeRendering
                    antialiasing: true
                }
                
                onClicked: {
                    videoFileDialog.open()
                }
            }
            
            // 第二行按钮 - 水平排列
            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                
                // 清除视频按钮
                Button {
                    visible: (root.currentOperationMode || "desktop") == "edit" && root.hasVideo
                    id: clearButton
                    text: "清除视频"
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
                        root.videoPath = ""
                        console.log("清除视频文件")
                    }
                }
                
                // 测试播放按钮
                Button {
                    visible: (root.currentOperationMode || "desktop") == "edit" && root.hasVideo
                    id: testPlayButton
                    text: "测试播放"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 24
                    
                    background: Rectangle {
                        color: testPlayButton.pressed ? Qt.darker("#2196F3", 1.3) : "#2196F3"
                        radius: 4
                        border.color: "white"
                        border.width: 1
   
                    }
                    
                    contentItem: Text {
                        text: testPlayButton.text
                        color: "white"
                        font.pixelSize: 10
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        renderType: Text.NativeRendering
                        antialiasing: true
                    }
                    
                    onClicked: {
                        console.log("=== 手动测试播放 ===")
                        console.log("当前视频源:", mediaPlayer.source)
                        console.log("当前状态:", mediaPlayer.mediaStatus)
                        console.log("当前播放状态:", mediaPlayer.playbackState)
                        console.log("videoPath:", root.videoPath)
                        
                        if (root.hasVideo) {
                            console.log("强制重新设置视频源")
                            // mediaPlayer.source = videoPath
                            mediaPlayer.play()

                        } else {
                            console.log("没有视频文件，无法播放")
                        }
                    }
                }
            }
            
            // 第三行按钮
            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                
                // 调试按钮 - 显示当前视频路径
                Button {
                    visible: (root.currentOperationMode || "desktop") == "edit"
                    id: debugButton
                    text: "调试信息"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 24
                    
                    background: Rectangle {
                        color: debugButton.pressed ? Qt.darker("#FF9800", 1.3) : "#FF9800"
                        radius: 4
                        border.color: "white"
                        border.width: 1
                        

                    }
                    
                    contentItem: Text {
                        text: debugButton.text
                        color: "white"
                        font.pixelSize: 10
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        renderType: Text.NativeRendering
                        antialiasing: true
                    }
                    
                    onClicked: {
                        console.log("=== 调试信息 ===")
                        console.log("hasVideo:", root.hasVideo)
                        console.log("videoPath:", root.videoPath)
                        console.log("mediaPlayer.source:", mediaPlayer.source)
                        console.log("mediaPlayer.status:", mediaPlayer.mediaStatus)
                        console.log("mediaPlayer.playbackState:", mediaPlayer.playbackState)
                        console.log("mediaPlayer.duration:", mediaPlayer.duration)
                        console.log("mediaPlayer.position:", mediaPlayer.position)
                    }
                }
                
            }
        }
    }
    }
    



    // 组件销毁时的处理
    Component.onDestruction: {
        console.log("MP4视频播放组件即将销毁")
        if (mediaPlayer.playbackState === MediaPlayer.PlayingState) {
            mediaPlayer.stop()
        }
    }
    
    // 定义可被C++调用的方法
    function mouseEntered() {
        console.log("鼠标进入MP4视频播放组件")
        if(root.unit.logDebug) {
            root.unit.logDebug("MP4视频播放组件收到鼠标进入事件")
        } else {
            console.log("找不到unit.logDebug")
        }
    }
    
    function mouseLeft() {
        console.log("鼠标离开MP4视频播放组件")
        root.unit.logDebug("鼠标离开MP4视频播放组件")
    }
    
    function singleClicked() {
        console.log("MP4视频播放组件收到单击事件")
        root.unit.logDebug("MP4视频播放组件收到单击事件")
    }
    
    function doubleClicked() {
        console.log("MP4视频播放组件收到双击事件")
    }
    
}
