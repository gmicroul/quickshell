import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects 
import Quickshell

Rectangle {
    id: root
    required property var context

    anchors.fill: parent
    color: "black"

    // ================= 背景 (Background) =================
    Image {
        id: bgImage
        anchors.fill: parent
        source: "file:///home/archirithm/.cache/wallpaper_rofi/current"
        fillMode: Image.PreserveAspectCrop
        cache: false 
        asynchronous: true
        visible: false 
        sourceSize.width: 1920 
    }

    FastBlur {
        anchors.fill: bgImage
        source: bgImage
        radius: 60 
        transparentBorder: false
        cached: true 
        
        // 背景淡入动画
        opacity: 0
        NumberAnimation on opacity { from: 0; to: 1; duration: 1500; easing.type: Easing.OutCubic }
    }

    // 黑色遮罩，增加文字对比度
    Rectangle {
        anchors.fill: parent
        color: "black"
        opacity: 0.3
    }

    // ================= 慢速动画加载器组件 =================
    component AnimLoader: Loader {
        id: animLoader
        
        property int startX: 0
        property int startY: 0
        property int delay: 0 

        opacity: 0
        scale: 0.9 
        transform: Translate { id: trans; x: animLoader.startX; y: animLoader.startY }

        SequentialAnimation {
            running: true
            
            PauseAnimation { duration: animLoader.delay }
            
            ParallelAnimation {
                // 透明度渐变
                NumberAnimation { 
                    target: animLoader; property: "opacity"; 
                    to: 1; duration: 1000; easing.type: Easing.OutQuad 
                }
                // 放大效果
                NumberAnimation { 
                    target: animLoader; property: "scale"; 
                    to: 1; duration: 1200; easing.type: Easing.OutBack; easing.overshoot: 0.6 
                }
                // 位移归位
                NumberAnimation { 
                    target: trans; property: "x"; 
                    to: 0; duration: 1200; easing.type: Easing.OutExpo 
                }
                NumberAnimation { 
                    target: trans; property: "y"; 
                    to: 0; duration: 1200; easing.type: Easing.OutExpo 
                }
            }
        }
    }

    // ================= 核心布局 =================
    RowLayout {
        anchors.centerIn: parent
        spacing: 20

        // --- 左侧列 (向左飞入) ---
        ColumnLayout {
            spacing: 20
            
            // 1. 头像
            AnimLoader {
                source: "./Cards/AvatarCard.qml"
                Layout.preferredWidth: 260; Layout.preferredHeight: 360
                startX: 150; delay: 0
            }
            
            // 2. 留言
            AnimLoader {
                source: "./Cards/MottoCard.qml"
                Layout.preferredWidth: 260; Layout.preferredHeight: 160
                startX: 150; delay: 100 
            }
        }

        // --- 中间列 (从下浮起) ---
        ColumnLayout {
            spacing: 20
            
            // 3. 系统
            AnimLoader {
                source: "./Cards/SystemCard.qml"
                Layout.preferredWidth: 420; Layout.preferredHeight: 110
                startY: 100; delay: 0
            }
            
            // 4. 时钟
            AnimLoader {
                source: "./Cards/ClockCard.qml"
                Layout.preferredWidth: 420; Layout.preferredHeight: 170
                startY: 100; delay: 100 
            }

            // 5. 天气
            AnimLoader {
                source: "./Cards/WeatherCard.qml"
                Layout.preferredWidth: 420; Layout.preferredHeight: 220
                startY: 100; delay: 200 
            }
        }

        // --- 右侧列 (向右飞入) ---
        ColumnLayout {
            spacing: 20
            
            // 6. 媒体
            AnimLoader {
                source: "./Cards/MediaCard.qml"
                Layout.preferredWidth: 280; Layout.preferredHeight: 260
                startX: -150; delay: 0
            }

            // 7. 终端 (密码输入)
            AnimLoader {
                id: termLoader
                source: "./Cards/TerminalCard.qml"
                Layout.preferredWidth: 280; Layout.preferredHeight: 260
                startX: -150; delay: 100

                // 核心：加载后注入 context 并聚焦
                onLoaded: {
                    if (item) {
                        item.context = root.context
                        item.forceActiveFocus()
                    }
                }
            }
        }
    }
}
