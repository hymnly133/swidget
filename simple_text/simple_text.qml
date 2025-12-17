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
 * 
 * 使用方法：
 * 1. 右键点击组件，选择"选择文件"来设置代理文件
 * 2. 设置后会自动显示文件图标和名称
 * 3. 聚焦时显示文件名和背景图，失焦时隐藏
 */

SWidget {
    id: root
                
    // 文件名文本（使用 OpacityMask 实现右侧渐隐）
    Item {
        id: textItem
        anchors.fill: parent
        
        Text {
            id: fileNameText
            anchors.centerIn: parent
            anchors.verticalCenter: parent.verticalCenter
            text: "Hellow QML Widget"
            color: "#FFFFFF"  // 固定使用白色
            font.pixelSize: 30
            font.weight: Font.ExtraBold  // 相当于 font-weight: 600
            font.family: "Segoe UI"
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
    
}

