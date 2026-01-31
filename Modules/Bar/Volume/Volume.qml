import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
// 引入你的服务模块
import qs.Services
import qs.config

Rectangle {
    id: root

    // --- 样式：完全复刻 Network.qml ---
    color: Colorsheme.background
    radius: Sizes.cornerRadius
    implicitHeight: Sizes.barHeight
    // 宽度自适应内容，左右各留 12px 边距 (24px)
    implicitWidth: layout.width + 24

    // --- 交互区域 ---
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        
        // 允许滚轮事件
        onWheel: (wheel) => {
            const step = 0.05
            let newVol = Volume.sinkVolume
            
            if (wheel.angleDelta.y > 0) {
                newVol += step
            } else {
                newVol -= step
            }

            Volume.setSinkVolume(newVol)
        }

        // 点击切换静音
        onClicked: {
          Quickshell.execDetached(["pavucontrol"])
        }
    }

    // --- 内容布局 ---
    RowLayout {
        id: layout
        anchors.centerIn: parent
        spacing: 8

        // 1. 图标
        Text {
            // 如果你的 Network.qml 用了 Font Awesome，这里最好也保持一致
            // font.family: "Font Awesome 6 Free Regular" 
            font.pixelSize: 16
            
            // 这里为了和 Network 的断开/连接颜色呼应：
            color: (Volume.sinkMuted || Volume.sinkVolume <= 0) ? "#ff5555" : Colorsheme.on_tertiary_container
            
            text: {
                if (Volume.isHeadphone) return ""
                if (Volume.sinkMuted || Volume.sinkVolume <= 0) return ""
                
                // 可选：根据音量大小显示不同喇叭
                if (Volume.sinkVolume < 0.5) return ""
                return ""
            }
        }

        // 2. 音量数值
        Text {
            font.bold: true
            font.pixelSize: 14
            color: Colorsheme.on_primary_container
            
            // 显示百分比
            text: Math.round(Volume.sinkVolume * 100) + "%"
        }
    }
}
