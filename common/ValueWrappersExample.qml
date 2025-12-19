import QtQuick 2.15
import Sapphire.Widgets 1.0

/**
 * @brief ValueWrappers 使用示例
 * 
 * 演示如何在 Qt5/Qt6 兼容的方式下使用字符串、布尔值、整数和浮点数列表。
 * 
 * 这些包装器类解决了 Qt5 中 list 类型只能存储 QML 对象的问题。
 * 在 Qt5 中，不能使用 list<string>、list<bool> 等，但可以使用 list<StringWrapper> 等。
 */
Item {
    id: root
    width: 400
    height: 600

    // ==================== 字符串列表示例 ====================
    property list<StringWrapper> tags: [
        StringWrapper { value: "标签1" },
        StringWrapper { value: "标签2" },
        StringWrapper { value: "标签3" }
    ]

    // ==================== 布尔值列表示例 ====================
    property list<BoolWrapper> flags: [
        BoolWrapper { value: true },
        BoolWrapper { value: false },
        BoolWrapper { value: true }
    ]

    // ==================== 整数列表示例 ====================
    property list<IntWrapper> numbers: [
        IntWrapper { value: 1 },
        IntWrapper { value: 2 },
        IntWrapper { value: 3 }
    ]

    // ==================== 浮点数列表示例 ====================
    property list<DoubleWrapper> values: [
        DoubleWrapper { value: 1.5 },
        DoubleWrapper { value: 2.7 },
        DoubleWrapper { value: 3.14 }
    ]

    // ==================== 辅助函数：转换为 JavaScript 数组 ====================
    /**
     * @brief 将 StringWrapper 列表转换为 JavaScript 字符串数组
     */
    function getStringList() {
        var result = []
        for (var i = 0; i < tags.length; i++) {
            result.push(tags[i].value)
        }
        return result
    }

    /**
     * @brief 将 BoolWrapper 列表转换为 JavaScript 布尔数组
     */
    function getBoolList() {
        var result = []
        for (var i = 0; i < flags.length; i++) {
            result.push(flags[i].value)
        }
        return result
    }

    /**
     * @brief 将 IntWrapper 列表转换为 JavaScript 整数数组
     */
    function getIntList() {
        var result = []
        for (var i = 0; i < numbers.length; i++) {
            result.push(numbers[i].value)
        }
        return result
    }

    /**
     * @brief 将 DoubleWrapper 列表转换为 JavaScript 浮点数数组
     */
    function getDoubleList() {
        var result = []
        for (var i = 0; i < values.length; i++) {
            result.push(values[i].value)
        }
        return result
    }

    // ==================== UI 显示 ====================
    Column {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20

        Text {
            text: "字符串列表: " + getStringList().join(", ")
            font.pixelSize: 14
        }

        Text {
            text: "布尔值列表: " + getBoolList().join(", ")
            font.pixelSize: 14
        }

        Text {
            text: "整数列表: " + getIntList().join(", ")
            font.pixelSize: 14
        }

        Text {
            text: "浮点数列表: " + getDoubleList().join(", ")
            font.pixelSize: 14
        }

        // 示例：修改值
        Button {
            text: "修改第一个标签"
            onClicked: {
                if (tags.length > 0) {
                    tags[0].value = "新标签"
                }
            }
        }

        // 示例：添加新值
        Button {
            text: "添加新标签"
            onClicked: {
                tags.push(StringWrapper { value: ("新标签" + tags.length) })
            }
        }
    }

    Component.onCompleted: {
        console.log("字符串列表:", getStringList())
        console.log("布尔值列表:", getBoolList())
        console.log("整数列表:", getIntList())
        console.log("浮点数列表:", getDoubleList())
    }
}
