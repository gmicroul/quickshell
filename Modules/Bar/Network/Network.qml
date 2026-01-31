import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import qs.Services
import qs.config

Rectangle {
    id: root
    
    // --- 胶囊样式 ---
    color: Colorsheme.background
    radius: Sizes.cornerRadius
    implicitHeight: Sizes.barHeight
    implicitWidth: layout.width + 24

    // --- 交互区域 ---
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        
        // 点击打开 nm-connection-editor
        onClicked: Quickshell.execDetached(["nm-connection-editor"])
        
        // 【已删除】 鼠标悬停提示代码已移除
    }

    // --- 内容布局 ---
    RowLayout {
        id: layout
        anchors.centerIn: parent
        spacing: 8

        // 1. 图标
        Text {
            // 确保使用支持图标的字体
            font.family: "Font Awesome 6 Free Regular" 
            font.pixelSize: 16
            
            // 颜色：连上是青色，断开是红色
            color: Network.connected ? Colorsheme.on_tertiary_container : "#ff5555"
            
            // 根据 Service 返回的类型来决定显示什么图标
            text: {
                if (Network.activeConnectionType === "WIFI") return ""
                if (Network.activeConnectionType === "ETHERNET") return ""
                return "⚠"
            }
        }

        // 2. 文字 (SSID 或 连接名)
        Text {
            font.bold: true
            font.pixelSize: 14
            color: Colorsheme.on_primary_container
            
            // 直接读取 Service 数据
            text: Network.activeConnection
        }
    }
}
