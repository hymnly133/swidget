import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15

/**
 * @brief SColorDialog - 自定义颜色选择对话框（独立窗口）
 * 
 * 用于替代Qt WebEngine默认的颜色选择对话框
 * 布局参照 scolorpicker.cpp：
 * - 左侧：HSV色彩图和色相条
 * - 右侧：颜色预览、Hex输入、RGB输入、HSV输入
 */
Window {
    id: colorDialog
    
    property color selectedColor: "#000000"  // 当前选择的颜色
    property color initialColor: "#000000"   // 初始颜色
    property bool updatingFromInputs: false   // 标志：是否正在从输入更新颜色
    
    // HSV值（0.0-1.0）
    property real currentHue: 0.0
    property real currentSat: 0.0
    property real currentVal: 0.0
    
    title: "选择颜色"
    modality: Qt.ApplicationModal
    flags: Qt.Dialog | Qt.WindowTitleHint | Qt.WindowCloseButtonHint
    width: 900
    height: 500
    minimumWidth: 800
    minimumHeight: 450
    
    // 初始化颜色
    Component.onCompleted: {
        selectedColor = initialColor
        updateColorFromColor(initialColor)
        // 居中显示
        if (Qt.application.screens.length > 0) {
            var screen = Qt.application.screens[0]
            x = (screen.width - width) / 2
            y = (screen.height - height) / 2
        }
    }
    
    // RGB转HSV
    function rgbToHsv(r, g, b) {
        var max = Math.max(r, Math.max(g, b))
        var min = Math.min(r, Math.min(g, b))
        var delta = max - min
        
        var h = 0
        var s = 0
        var v = max
        
        if (delta !== 0) {
            s = delta / max
            if (r === max) {
                h = ((g - b) / delta) % 6
            } else if (g === max) {
                h = (b - r) / delta + 2
            } else {
                h = (r - g) / delta + 4
            }
            h = h / 6
            if (h < 0) h += 1
        }
        
        return {h: h, s: s, v: v}
    }
    
    // HSV转RGB
    function hsvToRgb(h, s, v) {
        var c = v * s
        var x = c * (1 - Math.abs((h * 6) % 2 - 1))
        var m = v - c
        var r = 0, g = 0, b = 0
        
        if (h < 1/6) {
            r = c; g = x; b = 0
        } else if (h < 2/6) {
            r = x; g = c; b = 0
        } else if (h < 3/6) {
            r = 0; g = c; b = x
        } else if (h < 4/6) {
            r = 0; g = x; b = c
        } else if (h < 5/6) {
            r = x; g = 0; b = c
        } else {
            r = c; g = 0; b = x
        }
        
        return {r: r + m, g: g + m, b: b + m}
    }
    
    // 从颜色更新HSV值
    function updateColorFromColor(color) {
        if (updatingFromInputs) return
        updatingFromInputs = true
        
        var hsv = rgbToHsv(color.r, color.g, color.b)
        currentHue = hsv.h
        currentSat = hsv.s
        currentVal = hsv.v
        
        selectedColor = color
        updateInputs()
        updatingFromInputs = false
    }
    
    // 从HSV更新颜色
    function updateColorFromHSV() {
        if (updatingFromInputs) return
        updatingFromInputs = true
        
        var rgb = hsvToRgb(currentHue, currentSat, currentVal)
        selectedColor = Qt.rgba(rgb.r, rgb.g, rgb.b, 1.0)
        
        updateInputs()
        updatingFromInputs = false
    }
    
    // 更新所有输入控件
    function updateInputs() {
        // 设置标志，防止更新输入时触发回调
        updatingFromInputs = true
        
        // 更新Hex
        hexTextField.text = selectedColor.toString().toUpperCase()
        
        // 更新RGB
        redSpinBox.value = Math.round(selectedColor.r * 255)
        greenSpinBox.value = Math.round(selectedColor.g * 255)
        blueSpinBox.value = Math.round(selectedColor.b * 255)
        
        // 更新HSV
        hueSpinBox.value = Math.round(currentHue * 359)
        satSpinBox.value = Math.round(currentSat * 100)
        valSpinBox.value = Math.round(currentVal * 100)
        
        // 重置标志
        updatingFromInputs = false
    }
    
    // 从RGB更新颜色
    function updateColorFromRGB() {
        if (updatingFromInputs) return
        
        var newColor = Qt.rgba(
            redSpinBox.value / 255.0,
            greenSpinBox.value / 255.0,
            blueSpinBox.value / 255.0,
            1.0
        )
        
        updateColorFromColor(newColor)
    }
    
    // 从HSV输入更新颜色
    function updateColorFromHSVInputs() {
        if (updatingFromInputs) return
        
        currentHue = hueSpinBox.value / 359.0
        currentSat = satSpinBox.value / 100.0
        currentVal = valSpinBox.value / 100.0
        
        updateColorFromHSV()
    }
    
    // 从Hex更新颜色
    function updateColorFromHex() {
        if (updatingFromInputs) return
        
        var text = hexTextField.text.trim()
        if (!text.startsWith("#")) {
            text = "#" + text
        }
        
        if (/^#[0-9A-Fa-f]{6}$/.test(text)) {
            var newColor = Qt.color(text)
            if (newColor) {
                updateColorFromColor(newColor)
            } else {
                // 颜色无效，恢复为当前颜色
                updatingFromInputs = true
                hexTextField.text = selectedColor.toString().toUpperCase()
                updatingFromInputs = false
            }
        } else {
            // 格式无效，恢复为当前颜色
            updatingFromInputs = true
            hexTextField.text = selectedColor.toString().toUpperCase()
            updatingFromInputs = false
        }
    }
    
    // 从色彩图位置更新颜色
    function updateColorFromColorMapPos(x, y) {
        if (updatingFromInputs) return
        
        currentSat = Math.max(0, Math.min(1, x / colorMapCanvas.width))
        currentVal = Math.max(0, Math.min(1, 1.0 - y / colorMapCanvas.height))
        
        updateColorFromHSV()
    }
    
    // 从色相条位置更新颜色
    function updateColorFromHueSliderPos(y) {
        if (updatingFromInputs) return
        
        currentHue = Math.max(0, Math.min(1, y / hueSliderCanvas.height))
        
        updateColorFromHSV()
    }
    
    Rectangle {
        anchors.fill: parent
        color: "#F5F5F5"
        
        RowLayout {
            anchors.fill: parent
            anchors.margins: 15
            spacing: 15
            
            // ==================== 左侧：调色盘 ====================
            ColumnLayout {
                spacing: 10
                
                RowLayout {
                    spacing: 10
                    
                    // HSV色彩图
                    Canvas {
                        id: colorMapCanvas
                        Layout.preferredWidth: 300
                        Layout.preferredHeight: 300
                        
                        onPaint: {
                            var ctx = getContext("2d")
                            var w = width
                            var h = height
                            
                            // 绘制HSV色彩图
                            for (var y = 0; y < h; y++) {
                                for (var x = 0; x < w; x++) {
                                    var sat = x / w
                                    var val = 1.0 - y / h
                                    var rgb = colorDialog.hsvToRgb(colorDialog.currentHue, sat, val)
                                    
                                    ctx.fillStyle = Qt.rgba(rgb.r, rgb.g, rgb.b, 1.0)
                                    ctx.fillRect(x, y, 1, 1)
                                }
                            }
                            
                            // 绘制选择指示器
                            var indicatorX = colorDialog.currentSat * w
                            var indicatorY = (1.0 - colorDialog.currentVal) * h
                            ctx.strokeStyle = "white"
                            ctx.lineWidth = 2
                            ctx.beginPath()
                            ctx.arc(indicatorX, indicatorY, 5, 0, 2 * Math.PI)
                            ctx.stroke()
                        }
                        
                        // // 监听属性变化，自动重绘
                        // Connections {
                        //     target: colorDialog
                        //     function onCurrentHueChanged() { colorMapCanvas.requestPaint() }
                        //     function onCurrentSatChanged() { colorMapCanvas.requestPaint() }
                        //     function onCurrentValChanged() { colorMapCanvas.requestPaint() }
                        // }
                        
                        MouseArea {
                            anchors.fill: parent
                            onPressed: function(mouse) {
                                colorDialog.updateColorFromColorMapPos(mouse.x, mouse.y)
                            }
                            onPositionChanged: function(mouse) {
                                if (pressed) {
                                    colorDialog.updateColorFromColorMapPos(mouse.x, mouse.y)
                                }
                            }
                        }
                    }
                    
                    // 色相条
                    Canvas {
                        id: hueSliderCanvas
                        Layout.preferredWidth: 40
                        Layout.preferredHeight: 300
                        
                        onPaint: {
                            var ctx = getContext("2d")
                            var w = width
                            var h = height
                            
                            // 绘制色相渐变
                            for (var y = 0; y < h; y++) {
                                var hue = y / h
                                var rgb = colorDialog.hsvToRgb(hue, 1.0, 1.0)
                                ctx.fillStyle = Qt.rgba(rgb.r, rgb.g, rgb.b, 1.0)
                                ctx.fillRect(0, y, w, 1)
                            }
                            
                            // 绘制选择指示器
                            var indicatorY = colorDialog.currentHue * h
                            ctx.strokeStyle = "white"
                            ctx.lineWidth = 2
                            ctx.beginPath()
                            ctx.moveTo(0, indicatorY)
                            ctx.lineTo(w, indicatorY)
                            ctx.stroke()
                        }
                        
                        // // 监听属性变化，自动重绘
                        // Connections {
                        //     target: colorDialog
                        //     function onCurrentHueChanged() { hueSliderCanvas.requestPaint() }
                        // }
                        
                        MouseArea {
                            anchors.fill: parent
                            onPressed: function(mouse) {
                                colorDialog.updateColorFromHueSliderPos(mouse.y)
                            }
                            onPositionChanged: function(mouse) {
                                if (pressed) {
                                    colorDialog.updateColorFromHueSliderPos(mouse.y)
                                }
                            }
                        }
                    }
                }
            }
            
            // ==================== 右侧：数值显示 ====================
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 25
                
                // 颜色预览
                Rectangle {
                    Layout.preferredWidth: 150
                    Layout.preferredHeight: 150
                    Layout.alignment: Qt.AlignHCenter
                    color: colorDialog.selectedColor
                    border.color: "#CCCCCC"
                    border.width: 2
                    radius: 8
                }
                
                // 输入表单
                GridLayout {
                    columns: 2
                    rowSpacing: 20
                    columnSpacing: 15
                    Layout.fillWidth: true
                    
                    // Hex输入
                    Label {
                        text: "Hex:"
                        Layout.minimumWidth: 60
                        horizontalAlignment: Text.AlignRight
                        font.pixelSize: 15
                    }
                    TextField {
                        id: hexTextField
                        Layout.fillWidth: true
                        placeholderText: "#RRGGBB"
                        font.pixelSize: 15
                        onEditingFinished: {
                            if (!colorDialog.updatingFromInputs) {
                                colorDialog.updateColorFromHex()
                            }
                        }
                    }
                    
                    // RGB输入
                    Label {
                        text: "RGB:"
                        Layout.minimumWidth: 60
                        horizontalAlignment: Text.AlignRight
                        font.pixelSize: 15
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 15
                        SpinBox {
                            id: redSpinBox
                            from: 0
                            to: 255
                            font.pixelSize: 15
                            onValueChanged: {
                                if (!colorDialog.updatingFromInputs) {
                                    colorDialog.updateColorFromRGB()
                                }
                            }
                        }
                        SpinBox {
                            id: greenSpinBox
                            from: 0
                            to: 255
                            font.pixelSize: 15
                            onValueChanged: {
                                if (!colorDialog.updatingFromInputs) {
                                    colorDialog.updateColorFromRGB()
                                }
                            }
                        }
                        SpinBox {
                            id: blueSpinBox
                            from: 0
                            to: 255
                            font.pixelSize: 15
                            onValueChanged: {
                                if (!colorDialog.updatingFromInputs) {
                                    colorDialog.updateColorFromRGB()
                                }
                            }
                        }
                    }
                    
                    // HSV输入
                    Label {
                        text: "HSV:"
                        Layout.minimumWidth: 60
                        horizontalAlignment: Text.AlignRight
                        font.pixelSize: 15
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 15
                        SpinBox {
                            id: hueSpinBox
                            from: 0
                            to: 359
                            font.pixelSize: 15
                            onValueChanged: {
                                if (!colorDialog.updatingFromInputs) {
                                    colorDialog.updateColorFromHSVInputs()
                                }
                            }
                        }
                        SpinBox {
                            id: satSpinBox
                            from: 0
                            to: 100
                            font.pixelSize: 15
                            onValueChanged: {
                                if (!colorDialog.updatingFromInputs) {
                                    colorDialog.updateColorFromHSVInputs()
                                }
                            }
                        }
                        SpinBox {
                            id: valSpinBox
                            from: 0
                            to: 100
                            font.pixelSize: 15
                            onValueChanged: {
                                if (!colorDialog.updatingFromInputs) {
                                    colorDialog.updateColorFromHSVInputs()
                                }
                            }
                        }
                    }
                }
                
                Item {
                    Layout.fillHeight: true
                }
                
                // 按钮
                RowLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter
                    
                    Item {
                        Layout.fillWidth: true
                    }
                    
                    Button {
                        text: "取消"
                        Layout.preferredWidth: 120
                        Layout.preferredHeight: 40
                        font.pixelSize: 15
                        onClicked: {
                            colorDialog.rejected()
                            colorDialog.close()
                        }
                    }
                    
                    Button {
                        text: "确定"
                        Layout.preferredWidth: 120
                        Layout.preferredHeight: 40
                        font.pixelSize: 15
                        onClicked: {
                            colorDialog.accepted()
                            colorDialog.close()
                        }
                    }
                    
                    Item {
                        Layout.fillWidth: true
                    }
                }
            }
        }
    }
    
    // 信号
    signal accepted()
    signal rejected()
}
