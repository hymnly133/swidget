import QtQuick 2.15
import QtQuick.Controls 2.15
import QtWebEngine 1.15
import QtWebChannel 1.15
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
 * 
 * 使用方法：
 * SWebWidget {
 *     // WebEngineView会自动创建并填充
 *     // 通过webUrl属性设置要加载的URL或本地文件路径
 *     webUrl: "file:///path/to/file.html"
 * }
 */
SWidget {
    id: swebwidget
    objectName: "SWebWidget"
    
    // ==================== WebEngineView特有属性 ====================
    property url webUrl: webUrlFromContext||""  // 要加载的URL或本地文件路径（从上下文属性获取）
    // property url webUrlFromContext: ""  // 从C++端通过上下文属性设置的URL
    property var webBridge: null  // C++端的SWidgetWebBridge对象（由C++端设置）
    
    // ==================== 隐藏SWidget的默认contentItem ====================
    // 隐藏SWidget的默认contentItem，使用WebEngineView替代
    Component.onCompleted: {
        // swebwidget.contentItem.visible = false
        console.log("webUrlFromContext:", webUrlFromContext);
        console.log("webUrl:", webUrl);
    }
    
    // ==================== WebEngineView组件 ====================
    WebEngineView {
        id: webView
        anchors.fill: parent
        backgroundColor: "transparent"
        z: 1
        
        // 设置WebEngineView属性
        settings.javascriptEnabled: true
        settings.showScrollBars: false
        settings.allowRunningInsecureContent: true
        settings.localContentCanAccessFileUrls: true
        
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
        
        // 当webBridge属性变化时，重新注册
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
            }
        }
        
        // 在Qt6中，确保WebEngineView正确支持透明渲染
        Component.onCompleted: {
            // 确保背景色始终透明
            backgroundColor = "transparent";
        }
    }
}

