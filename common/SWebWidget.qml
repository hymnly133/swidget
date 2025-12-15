import QtQuick 2.15
import QtQuick.Controls 2.15
import QtWebEngine 6.10
import QtWebChannel 6.10
import Qt5Compat.GraphicalEffects
// import "qrc:/resources/widgets/common" as Common

/**
 * @brief SWebWidget - Web小组件标准化接口
 * 
 * SWebWidget继承自SWidget，提供WebEngineView功能：
 * - WebEngineView包装（替换SWidget的contentItem）
 * - WebChannel支持（C++与网页端双向通信）
 * - 鼠标事件处理（根据操作模式）
 * - 透明背景支持
 * - 响应式属性支持（通过WebChannel自动同步）
 * 
 * 使用方法：
 * SWebWidget {
 *     // WebEngineView会自动创建并填充
 *     // 通过webUrl属性设置要加载的URL或本地文件路径
 *     webUrl: "file:///path/to/file.html"
 * }
 * 
 * JavaScript端响应式属性使用示例：
 * // 在HTML中，通过WebChannel访问bridge对象
 * // bridge对象包含以下响应式属性：
 * // - bridge.smtcMediaInfo (JSON字符串，SMTC媒体信息)
 * // - bridge.smtcPlaybackStatus (JSON字符串，SMTC播放状态)
 * // - bridge.smtcControlCapabilities (JSON字符串，SMTC控制能力)
 * // - bridge.unitInfo (JSON字符串，小组件基础信息)
 * // - bridge.proxyFilePath (字符串，代理文件路径)
 * 
 * // 连接属性变化信号（响应式更新）
 * bridge.smtcMediaInfoChanged.connect(function() {
 *     var mediaInfo = JSON.parse(bridge.smtcMediaInfo);
 *     console.log("媒体信息更新:", mediaInfo);
 * });
 * 
 * bridge.unitInfoChanged.connect(function() {
 *     var unitInfo = JSON.parse(bridge.unitInfo);
 *     console.log("小组件信息更新:", unitInfo);
 *     // unitInfo包含：widgetName, widgetType, isFocus, isSelect, 
 *     // simpleMode, sizeX, sizeY, width, height, scale, opacity等
 * });
 */




SWidget {
    id: swebwidget
    objectName: "SWebWidget"
    
    // ==================== WebEngineView特有属性 ====================
    property url webUrl: webUrlFromContext||""  // 要加载的URL或本地文件路径（从上下文属性获取）
    // property url webUrlFromContext: ""  // 从C++端通过上下文属性设置的URL
    property var webBridge: null  // C++端的SWidgetWebBridge对象（由C++端设置）
    property double zoomFactor: 1.0  // 缩放因子（由C++端设置）
    
    // ==================== 隐藏SWidget的默认contentItem ====================

    Component.onCompleted: {
        console.log("webUrlFromContext:", webUrlFromContext);
        console.log("webUrl:", webUrl);
    }


    // ==================== WebEngineView组件 ====================
    WebEngineView {
        id: webView
        anchors.fill: parent
        backgroundColor: "transparent"
        z: 1

        profile: globalWebEngineProfile
        zoomFactor: swebwidget.zoomFactor

        // 在编辑模式下禁用WebEngineView的交互，但保持显示
        enabled: swebwidget.currentOperationMode !== "edit"
        
        // 禁用右键菜单
        onContextMenuRequested: function(request) {
            request.accepted = true;  // 阻止显示默认右键菜单
        }
        
        // 加载URL
        url: swebwidget.webUrl
        
        // ==================== WebChannel ====================
        // 创建WebChannel并注册bridge对象
        WebChannel {
            id: qmlWebChannel
            
            // 当webBridge对象设置后，注册到WebChannel
            Component.onCompleted: {
                if (swebwidget.webBridge) {
                    qmlWebChannel.registerObject("bridge", swebwidget.webBridge);
                    console.log("SWebWidget: bridge对象已注册到WebChannel");
                }
            }
        }
        
        // 设置WebChannel到WebEngineView
        webChannel: qmlWebChannel
        
        Connections {
            target: swebwidget
            function onWebBridgeChanged() {
                if (swebwidget.webBridge) {
                    qmlWebChannel.registerObject("bridge", swebwidget.webBridge);
                    console.log("SWebWidget: bridge对象已更新到WebChannel");

                }
            }
        }
        
        // 页面加载完成时设置透明背景
        onLoadingChanged: function(loadingInfo) {
            if (loadingInfo.status === WebEngineView.LoadSucceededStatus) {
                console.log("SWebWidget: 页面加载完成");

                // 通知C++端HTML页面已加载完成，可以发送持久化属性了
                // 先用 callLater 等待 WebChannel 初始化，再通过定时器延迟 200ms 触发
                Qt.callLater(function() {
                    notifyPersistentTimer.start();
                });
            }
        }

        // 延迟通知持久化属性加载完成（避免页面脚本和 WebChannel 尚未就绪）
        Timer {
            id: notifyPersistentTimer
            interval: 200
            repeat: false
            onTriggered: {
                if (swebwidget.webBridge) {
                    swebwidget.webBridge.notifyAllPersistentPropertiesLoaded();
                } else {
                    console.log("SWebWidget: webBridge对象未设置");
                    // console.log("mainSWebWidget: webBridge对象:", swebwidget.webBridge);
                }
            }
        }

    }
}

