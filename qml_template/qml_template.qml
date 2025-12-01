import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Basic
import QtQuick.Layouts 1.15
import QtQuick.Dialogs
import QtMultimedia 6.8
import Qt5Compat.GraphicalEffects
import "../common"

/**
 * @brief QML模板
 * 
 * 功能：
 * - 提供一个QML模板，用于快速创建新的QML组件
 */

SWidget {
    id: root

    property int globalRadius: unitRadius || 8
    property int globalMargin: 3
    
    // 是否启用内置圆角裁切，可能会有些许性能消耗和bug, 建议自己实现圆角
    globalRoundCornerEnabled: false

    // FPS显示模式
    fpsDisplayMode: SWidget.FpsDisplayMode.Never

    // 持久化属性
    property string persistentString: "this is default value"
    property int persistentInt: 100
    property bool persistentBool: true
    property var persistentVar: "this is default value"
    property list<string> persistentStringList: ["item1", "item2", "item3"]

    property string persistentStringListText: "persistentStringList: " + persistentStringList.join(", ")

    Column {
        anchors.centerIn: parent
        spacing: 10
        
        Text {
            text: "persistentString: " + persistentString
            font.pixelSize: 16
            color: "white"
        }
        
        Text {
            text: "persistentInt: " + persistentInt
            font.pixelSize: 16
            color: "white"
        }
        
        Text {
            text: "persistentBool: " + persistentBool
            font.pixelSize: 16
            color: "white"
        }
        
        Text {
            text: "persistentVar: " + persistentVar
            font.pixelSize: 16      
            color: "white"
        }
        Text {
            text: "persistentStringList size: " + persistentStringList.length
            font.pixelSize: 16      
            color: "white"
        }
        
        Text {
            text: persistentStringListText
            font.pixelSize: 16
            color: "white"
        }
        Text {
            text: "themeColor: " + styleThemeColor
            font.pixelSize: 16
            color: styleThemeColor
        }
        Text {
            text: "smtc: " + smtcEnabled
            font.pixelSize: 16
            color: smtcEnabled ? "green" : "red"
        }


    }

    Column {
        spacing: 10
        Button {
            text: "随机改变持久化属性"
            onClicked: {
                persistentString = "this is random value " + Math.random().toString()
                persistentInt = Math.random() * 100
                persistentBool = Math.random() > 0.5
                persistentVar = "this is random value " + Math.random().toString()
                persistentStringList.push("item" + Math.random().toString())
                console.log("persistentStringListText: " + persistentStringListText)
                console.log("persistentStringList: " + persistentStringList)
            }
        }

        Button {
            text: "重置持久化属性"
            onClicked: {
                persistentString = "this is default value"
                persistentInt = 100
                persistentBool = true
                persistentVar = "this is default value"
                persistentStringList = ["item1", "item2", "item3"]
            }
        }
    }
    // 随机改变持久化属性


    // 组件创建完成时的处理
    Component.onCompleted: {
        console.log("模板创建完成，注册持久化属性")
        registerPersistentProperty("persistentString", "this is default value")
        registerPersistentProperty("persistentInt", 100)
        registerPersistentProperty("persistentBool", true)
        registerPersistentProperty("persistentVar", "this is default value")
        registerPersistentProperty("persistentStringList", ["item1", "item2", "item3"])
    }
}
