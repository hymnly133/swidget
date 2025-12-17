import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import Qt5Compat.GraphicalEffects
import QtWebEngine
/**
 * Sapphire Version: 1.6.0.2
 * @brief SWidget - QML小组件标准化接口
 * 
 * SWidget是C++端和QML自定义组件的标准化接口，提供：
 * - 基础属性绑定（主题色、焦点状态、操作模式等）
 * - 持久化属性管理方法
 * - 默认内容区域
 * 
 * 使用方法：
 * SWidget {
 *     // 用户内容直接放在这里
 *     Rectangle {
 *         anchors.fill: parent
 *         color: unitMainColor
 *     }
 *     
 *     Component.onCompleted: {
 *         // 注册持久化属性
 *         registerPersistentProperty("myProperty", "defaultValue")
 *     }
 *     
 *     // 可选：重写加载逻辑
 *     function onPersistentPropertyLoaded(name, value) {
 *         // 自定义加载逻辑
 *         onPersistentPropertyLoaded(name, value) // 调用默认实现
 *     }
 * }
 */
Item {
    id: swidget
    objectName: "SWidget"
    anchors.fill: parent
    // visible:true
    default property alias content: contentItem.children
    
    // ==================== 基础属性定义 ====================
    // 属性有默认值，C++端可以直接通过SWidget实例设置这些属性
    property var unit: unitContext || null  // SWidgetUnit实例，由C++端通过上下文设置
    
    // 使用属性绑定，直接从unit获取值（如果unit存在）
    // 注意：unitMainColor需要从StyleHelper获取themeColor，不是unit的属性，所以保持手动设置
    property color unitMainColor: "#007ACC"  // 由C++端通过StyleHelper信号自动更新
    property bool unitIsFocus: (unit && unit.isFocus !== undefined) ? unit.isFocus : false
    property bool unitIsSelect: (unit && unit.isSelect !== undefined) ? unit.isSelect : false
    property bool unitSimpleMode: (unit && unit.simpleMode !== undefined) ? unit.simpleMode : false
    property int unitRadius: 8  // 此属性由C++端通过StyleHelper信号自动更新
    
    // ==================== 样式颜色相关属性 ====================
    // 重命名currentThemeColor为styleThemeColor，并添加其他颜色相关属性
    property color styleThemeColor: "#007ACC"  // 主题色（根据配置可能返回系统主题色或自定义主题色）
    property color currentThemeColor: styleThemeColor //兼容旧名称
    property color styleBackgroundColor: "transparent"  // 背景色
    property color styleTextColor: "#FFFFFF"  // 文字色
    property color styleHighlightColor: "#007ACC"  // 高亮色
    
    // 聚焦相关颜色参数
    property int styleUnfocusedAlpha: 100  // 未聚焦时的背景方框颜色不透明度（0-255）
    property int styleFocusedAlpha: 255  // 聚焦时的背景方框颜色不透明度（0-255）
    property real styleUnfocusedColorRatio: 0.5  // 未聚焦时的色值混合比率（0.0-1.0）
    property real styleFocusedColorRatio: 1.0  // 聚焦时的色值混合比率（0.0-1.0）
    
    // 光效相关参数
    property int styleLightAlphaStart: 0  // 光效的起点不透明度（0-255）
    property int styleLightAlphaEnd: 255  // 光效的终点不透明度（0-255）
    
    // 阴影相关参数
    property int styleIconShadowAlpha: 100  // 图标阴影特效不透明度（0-255）
    property int styleIconShadowBlurRadius: 10  // 图标阴影特效半径（1-100）
    
    // UI整体参数
    property int styleUiOverallAlpha: 255  // UI整体不透明度（0-255）
    
    // ==================== 其他属性 ====================
    property string currentOperationMode: "desktop"  // 当前操作模式（desktop: 桌面模式，edit: 编辑模式）
    property bool unitVisible: (unit && unit.visible !== undefined) ? unit.visible : true  // 使用属性绑定，直接从unit获取可见性
    property string widgetDataPath: ""      // 组件数据路径（由C++端设置，QML端只读，你可以使用QSettings自行读取和保存数据）
    property bool globalRoundCornerEnabled: true  // 内置的全局圆角，若开启，则会为组件内容套上完整的蒙版，限制内部元素，你可以关闭并根据unitRadius自绘圆角
    /**
     * @brief 是否启用内置打开代理文件逻辑
     *
     * - 默认关闭（false）
     * - 开启后，如果当前小组件支持代理文件，则由SWidgetUnit根据全局设置
     *   enable_single_click_open 决定在单击还是双击时自动调用 openProxyFile()
     * - 建议小组件开发者通过此属性开启/关闭内置行为，而不再自行处理“打开文件”鼠标事件
     */
    property bool useBuiltInOpenProxyFile: (unit && unit.useBuiltInOpenProxyFile !== undefined)
                                           ? unit.useBuiltInOpenProxyFile
                                           : false
    
    // ==================== 鼠标状态属性 ====================
    /**
     * @brief 左键鼠标按下状态
     * 由C++端根据鼠标事件自动更新，QML端可以直接绑定使用
     */
    
    property bool leftButtonPressed: (unit && unit.leftButtonPressed !== undefined) ? unit.leftButtonPressed : false

    readonly property bool leftMousePressed: leftButtonPressed
    // 全局WebEngineProfile由C++端创建并通过globalWebEngineProfile暴露给QML
    // ==================== ProxyFile属性定义 ====================
    // 注意：所有ProxyFile相关属性都通过QProperty绑定自动更新，QML端只读
    // 使用属性绑定，直接从unit获取值（如果unit存在）
    // 当C++端的QProperty变化时，QML端会自动更新
    
    // 代理文件路径（由C++端QProperty自动更新）
    property string proxyFilePath: (unit && unit.proxyFilePath !== undefined) ? unit.proxyFilePath : ""
    
    // 代理文件名（由C++端QProperty自动更新）
    readonly property string proxyFileName: (unit && unit.proxyFileName !== undefined) ? unit.proxyFileName : ""
    
    // 代理文件图标（Base64编码，由C++端QProperty自动更新）
    readonly property string proxyFileIcon: (unit && unit.proxyFileIcon !== undefined) ? unit.proxyFileIcon : ""

    // 代理文件颜色（由C++端QProperty自动更新）
    readonly property color proxyFileColor: (unit && unit.proxyFileColor !== undefined) ? unit.proxyFileColor : styleThemeColor
    
    // ==================== 拖拽相关属性 ====================
    /**
     * @brief 是否支持文件代理（只读）
     * 由C++端根据metadata自动设置
     */
    readonly property bool canProxyFile: (unit && unit.qmlModule) 
        ? unit.qmlModule.canProxyFile() 
        : false
    
    /**
     * @brief 是否显示拖拽overlay
     * 当文件拖拽进入且支持文件代理时显示
     */
    property bool showDragOverlay: false
    // ==================== 鼠标事件接收模式 ====================
    /**
     * @brief 鼠标事件接收模式枚举值
     * 0: Always - 全部 - 始终接收鼠标事件
     * 1: OnlyEdit - 仅编辑模式 - 仅在编辑模式下接收鼠标事件
     * 2: OnlyNonEdit - 仅非编辑模式 - 仅在非编辑模式下接收鼠标事件
     * 3: Never - 从不 - 从不接收鼠标事件
     * 注意：这里的鼠标事件是“传输到QML内部”的事件，对于应用内默认事件，如leftMousePressed、unitIsFocus不受影响
     */
    enum MouseEventMode {
        Always = 0,
        OnlyEdit = 1,
        OnlyNonEdit = 2,
        Never = 3
    }
    property int mouseEventMode: SWidget.MouseEventMode.OnlyNonEdit // 鼠标事件接收模式，由C++端设置
    // ==================== FPS计数属性 ====================
    property real currentFps: 0.0
    property real lastSecondFps: 0.0
    property real tenSecondAverageFps: 0.0
    
    // ==================== FPS显示模式枚举 ====================
    /**
     * @brief FPS显示模式枚举值
     * 0: Always - 常显
     * 1: Hover - 鼠标悬停时显示
     * 2: Never - 从不显示
     */
    enum FpsDisplayMode {
        Always = 0,
        Hover = 1,
        Never = 2
    }  // 常显
    
    property int fpsDisplayMode: SWidget.FpsDisplayMode.Never // 控制FPS显示模式，默认常显
    
    // ==================== SMTC属性定义 ====================
    // SMTC基本状态属性
    // smtcEnabled: 表示SMTC功能是否启用（由C++端根据metadata自动设置，QML端只读）
    property bool smtcEnabled: false
    property int smtcSessionCount: 0
    property string currentSMTCSessionId: ""
    property var smtcSessionIds: []  // 可用会话ID列表
    
    // SMTC媒体信息属性
    property string smtcMediaTitle: ""
    property string smtcMediaArtist: ""
    property string smtcMediaAlbum: ""
    property string smtcPlaybackStatus: ""
    property string smtcAppName: ""
    property int smtcPlaybackProgress: 0  // 0-100
    property int smtcPlaybackDuration: 0    // 毫秒
    property int smtcPlaybackPosition: 0   // 毫秒
    
    // SMTC控制能力属性
    property bool smtcHasAlbumArt: false
    property bool smtcCanPlay: false
    property bool smtcCanPause: false
    property bool smtcCanStop: false
    property bool smtcCanSkipNext: false
    property bool smtcCanSkipPrevious: false
    property bool smtcCanSeek: false
    
    // SMTC详细信息字符串
    property string smtcMediaInfo: ""
    property string smtcControlCapabilities: ""
    
    // SMTC缩略图属性（使用最佳实践：Base64字符串，零拷贝）
    property string smtcAlbumArtBase64: ""  // Base64编码的JPEG图片数据
    property string smtcAlbumArtSize: ""    // "width x height"格式的尺寸信息
    
    // ==================== 默认内容区域 ====================
    /**
     * @brief 根据鼠标事件接收模式和当前操作模式判断是否应该接收鼠标事件
     * 判断逻辑由QML端实现，C++端只传入枚举值
     */
    property bool shouldAcceptMouseEvents: {
        switch (swidget.mouseEventMode) {
        case SWidget.MouseEventMode.Always:
            return true
        case SWidget.MouseEventMode.OnlyEdit:
            return currentOperationMode === "edit"
        case SWidget.MouseEventMode.OnlyNonEdit:
            return currentOperationMode !== "edit"
        case SWidget.MouseEventMode.Never:
            return false
        default:
            return false
        }
    }
    Rectangle {
        id: contentItem
        anchors.fill: swidget
        color: "transparent"
        visible : true
        opacity: swidget.globalRoundCornerEnabled? 0 : 1
        enabled: swidget.shouldAcceptMouseEvents
    }

    Rectangle {
        id: maskItem
        anchors.fill: parent
        color: "black"
        visible :false
        radius: swidget.unitRadius
    }


    OpacityMask {
        visible : swidget.globalRoundCornerEnabled? true : false
        anchors.fill: parent
        source: contentItem
        maskSource: maskItem
        cached:true
    }

    // ==================== FPS显示组件 ====================
    /**
     * @brief FPS计数器显示
     * 在SWidget顶层显示FPS信息，用于性能监控
     * 显示模式由fpsDisplayMode属性控制：
     * - Always: 常显
     * - Hover: 鼠标悬停在右上角区域时显示
     * - Never: 从不显示
     */
    Rectangle {
        id: fpsDisplay
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 4
        width: 120
        height: 70
        color: "#80000000" // 半透明黑色背景
        radius: 4
        visible: {
            if (swidget.fpsDisplayMode === SWidget.FpsDisplayMode.Always) {
                return true
            } else if (swidget.fpsDisplayMode === SWidget.FpsDisplayMode.Hover) {
                return fpsHoverArea.containsMouse
            } else {
                return false // Never
            }
        }
        z: 1000 // 确保在最顶层
        opacity: visible ? 1.0 : 0.0

        Behavior on opacity {
            NumberAnimation { duration: 200 }
        }

        Column {
            anchors.fill: parent
            anchors.margins: 6
            spacing: 3

            Text {
                text: "FPS: " + swidget.currentFps.toFixed(1)
                color: swidget.currentFps >= 55 ? "#00FF00" : (swidget.currentFps >= 30 ? "#FFFF00" : "#FF0000")
                font.pixelSize: 13
                font.bold: true
            }

            Text {
                text: "平均: " + swidget.tenSecondAverageFps.toFixed(1)
                color: "#CCCCCC"
                font.pixelSize: 10
            }

            Text {
                text: "上一秒: " + swidget.lastSecondFps.toFixed(1)
                color: "#CCCCCC"
                font.pixelSize: 10
            }

            Text {
                text: "帧数: " + Math.round(swidget.currentFps * 10)
                color: "#AAAAAA"
                font.pixelSize: 9
            }
        }
    }

    // 鼠标悬停区域（右上角）
    // 仅在Hover模式下启用
    MouseArea {
        id: fpsHoverArea
        anchors.top: parent.top
        anchors.right: parent.right
        width: 130
        height: 80
        hoverEnabled: swidget.fpsDisplayMode === SWidget.FpsDisplayMode.Hover
        acceptedButtons: Qt.NoButton
        z: 999
    }

    // ==================== 文件拖拽区域 ====================
    /**
     * @brief 文件拖拽检测区域
     * 仅在支持文件代理时启用
     * 注意：实际的拖拽处理在C++端的dragEnterEvent和dropEvent中完成
     * 这里的DropArea主要用于QML端的视觉反馈，接受所有拖拽让C++端验证
     */
    DropArea {
        id: fileDropArea
        anchors.fill: parent
        enabled: swidget.canProxyFile
        z: 1001 // 确保在最顶层，但低于overlay
        
        // 拖拽进入时接受（实际验证在C++端完成）
        onEntered: {
            drag.accepted = true
        }
        
        // 拖拽移动时保持接受状态
        onPositionChanged: {
            drag.accepted = true
        }
    }

    // ==================== 拖拽Overlay显示 ====================
    /**
     * @brief 文件拖拽overlay
     * 当文件拖拽进入且支持文件代理时显示
     */
    Rectangle {
        id: dragOverlay
        anchors.fill: parent
        color: "#80000000" // 半透明黑色背景
        visible: swidget.showDragOverlay && swidget.canProxyFile
        z: 1002 // 确保在最顶层
        opacity: visible ? 1.0 : 0.0

        Behavior on opacity {
            NumberAnimation { duration: 200 }
        }

        // 边框高亮
        Rectangle {
            anchors.fill: parent
            anchors.margins: 4
            color: "transparent"
            border.color: swidget.styleThemeColor
            border.width: 3
            radius: swidget.unitRadius
        }

        // 提示文本
        Column {
            anchors.centerIn: parent
            spacing: 16
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "拖放文件到这里"
                color: "white"
                font.pixelSize: 18
                font.bold: true
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "将代理此文件"
                color: "#CCCCCC"
                font.pixelSize: 14
            }
        }
    }

    // ==================== 持久化属性管理方法 ====================
    
    /**
     * @brief 注册持久化属性（仅在Component.onCompleted时调用）
     * @param name 属性名
     * @param defaultValue 默认值
     * 
     * 在Component.onCompleted中调用此方法注册需要持久化的属性
     */
    function registerPersistentProperty(name, defaultValue) {
        if (unit && unit.qmlModule) {
            unit.qmlModule.registerPersistentProperty(name, defaultValue)
            console.log("SWidget: 注册持久化属性:", name, "默认值:", defaultValue)
        } else {
            console.warn("SWidget: unit或qmlModule不可用，无法注册持久化属性:", name)
        }
    }
    
    /**
     * @brief 设置持久化属性值（由C++调用）
     * @param name 属性名
     * @param value 属性值
     * 
     * 此方法由C++端调用，直接设置属性并触发persistentPropertyLoaded通知
     */
    function setPersistentProperty(name, value) {
        console.log("SWidget: 设置持久化属性:", name, "值:", value)
        // 直接设置到对应属性（如果存在）
        if (swidget.hasOwnProperty(name)) {
            swidget[name] = value
            // 触发加载通知
            persistentPropertyLoaded(name, value)
        } else {
            console.log("SWidget: 属性不存在，跳过设置:", name)
        }
    }
    
    /**
     * @brief C++加载属性时通知
     * @param name 属性名
     * @param value 属性值
     * 
     */
    signal persistentPropertyLoaded(string name, var value)
    
    
    // ==================== SMTC方法 ====================
    
    /**
     * @brief 设置当前SMTC会话
     * @param sessionId 会话ID
     * 
     * 通过unit对象调用SMTC模块的方法设置当前会话
     */
    function setSMTCSession(sessionId) {
        if (unit && unit.smtcModule) {
            unit.smtcModule.setCurrentSession(sessionId)
            console.log("SWidget: 设置SMTC会话:", sessionId)
        } else {
            console.warn("SWidget: unit或SMTC模块不可用，无法设置会话")
        }
    }
    
    /**
     * @brief 播放媒体
     * @return 是否成功
     */
    function playSMTCMedia() {
        if (unit && unit.smtcModule) {
            return unit.smtcModule.playMedia()
        }
        return false
    }
    
    /**
     * @brief 暂停媒体
     * @return 是否成功
     */
    function pauseSMTCMedia() {
        if (unit && unit.smtcModule) {
            return unit.smtcModule.pauseMedia()
        }
        return false
    }
    
    /**
     * @brief 停止媒体
     * @return 是否成功
     */
    function stopSMTCMedia() {
        if (unit && unit.smtcModule) {
            return unit.smtcModule.stopMedia()
        }
        return false
    }
    
    /**
     * @brief 下一首
     * @return 是否成功
     */
    function skipSMTCNext() {
        if (unit && unit.smtcModule) {
            return unit.smtcModule.skipToNext()
        }
        return false
    }
    
    /**
     * @brief 上一首
     * @return 是否成功
     */
    function skipSMTCPrevious() {
        if (unit && unit.smtcModule) {
            return unit.smtcModule.skipToPrevious()
        }
        return false
    }
    
    /**
     * @brief 跳转到指定位置
     * @param position 位置（0-100的百分比）
     * @return 是否成功
     */
    function seekSMTCToPosition(position) {
        if (unit && unit.smtcModule) {
            return unit.smtcModule.seekToPosition(position)
        }
        return false
    }
    
    // ==================== ProxyFile方法 ====================
    
    /**
     * @brief 处理代理文件被删除事件（由C++端调用）
     * 注意：proxyFilePath是只读属性，由C++端负责清除，QML端不需要操作
     */
    signal proxyFileRemoved()
    
    /**
     * @brief 处理代理文件被重命名事件（由C++端调用）
     * @param oldPath 旧文件路径
     * @param newPath 新文件路径
     * 注意：proxyFilePath由C++端更新，proxyFileName和proxyFileIcon会自动更新（计算属性）
     */
    signal proxyFileRenamed(string oldPath, string newPath)


    // ==================== 打开代理文件方法 ====================
    /**
     * @brief 打开代理文件
     * 通过unit对象调用QML模块的方法打开代理文件
     */
    function openProxyFile() {
        if (unit && unit.qmlModule) {
            unit.qmlModule.openProxyFile()
            console.log("SWidget: 打开代理文件")
        } else {
            console.warn("SWidget: unit或QML模块不可用，无法打开文件")
        }
    }
    
    /**
     * @brief 打开代理文件所在位置
     * 通过unit对象调用QML模块的方法打开代理文件所在位置
     */
    function openProxyFileLocation() {
        if (unit && unit.qmlModule) {
            unit.qmlModule.openProxyFileLocation()
            console.log("SWidget: 打开代理文件所在位置")
        } else {
            console.warn("SWidget: unit或QML模块不可用，无法打开文件位置")
        }
    }

    // // 同步内置打开文件开关到C++侧
    // onUseBuiltInOpenProxyFileChanged: {
    //     if (unit && unit.useBuiltInOpenProxyFile !== undefined
    //             && unit.useBuiltInOpenProxyFile !== useBuiltInOpenProxyFile) {
    //         unit.useBuiltInOpenProxyFile = useBuiltInOpenProxyFile
    //         console.log("SWidget: 更新内置打开代理文件开关:", useBuiltInOpenProxyFile)
    //     }
    // }
    // ==================== 拖拽事件处理方法 ====================
    
    /**
     * @brief 拖拽进入时调用（由C++端调用）
     * 显示拖拽overlay
     */
    function onDragEnter() {
        if (swidget.canProxyFile) {
            swidget.showDragOverlay = true
            console.log("SWidget: 显示拖拽overlay")
        }
    }
    
    /**
     * @brief 拖拽离开时调用（由C++端调用）
     * 隐藏拖拽overlay
     */
    function onDragLeave() {
        swidget.showDragOverlay = false
        console.log("SWidget: 隐藏拖拽overlay")
    }

}

