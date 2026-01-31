import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Services.Mpris
import qs.Components
import qs.config

Item {
    id: root
    
    required property var player
    
    readonly property bool isActive: root.visible && root.player

    property string artUrl: (isActive && player.trackArtUrl) ? player.trackArtUrl : ""
    property string title: (isActive && player.trackTitle) ? player.trackTitle : "No Media"
    property string artist: (isActive && player.trackArtist) ? player.trackArtist : ""
    property double progress: (isActive && player.length > 0) ? (player.position / player.length) : 0

    ColumnLayout {
        anchors.fill: parent
        spacing: 15

        // --- 顶部信息栏 ---
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 60
            spacing: 15

            Rectangle {
                Layout.preferredWidth: 60; Layout.preferredHeight: 60
                radius: 12; color: Colorsheme.background; clip: true
                Image {
                    anchors.fill: parent; source: root.artUrl; fillMode: Image.PreserveAspectCrop
                    asynchronous: true; visible: root.artUrl !== "" && status === Image.Ready
                }
                Text {
                    anchors.centerIn: parent; text: "♫"; color: "#555"; font.pixelSize: 28
                    visible: root.artUrl === ""
                }
            }

            ColumnLayout {
                Layout.fillWidth: true; Layout.alignment: Qt.AlignVCenter; spacing: 4
                Text {
                    text: root.title; color: "white"; font.bold: true; font.pixelSize: 16
                    Layout.fillWidth: true; elide: Text.ElideRight
                }
                Text {
                    text: root.artist; color: "#aaa"; font.pixelSize: 13
                    Layout.fillWidth: true; elide: Text.ElideRight
                }
            }
        }

        // --- 进度条 ---
        Item {
            Layout.fillWidth: true; Layout.preferredHeight: 6
            Rectangle {
                id: trackBg; anchors.fill: parent; color: "#333333"; radius: 3
                Rectangle {
                    height: parent.height; radius: 3; color: "white"
                    width: Math.max(0, root.progress * parent.width)
                    Behavior on width { enabled: root.visible; NumberAnimation { duration: 250 } }
                }
            }
        }

        // --- 控制按钮 ---
        Item {
            Layout.fillWidth: true; Layout.fillHeight: true
            
            // 【修改】这里改用 RowLayout，更稳定，且自动处理对齐
            RowLayout {
                anchors.centerIn: parent
                spacing: 45 
                
                // 1. 上一曲
                MouseArea {
                    Layout.preferredWidth: 40; Layout.preferredHeight: 40
                    cursorShape: Qt.PointingHandCursor
                    onClicked: if(root.player) root.player.previous()
                    
                    Image {
                        id: prevIcon
                        anchors.centerIn: parent
                        width: 24; height: 24
                        source: SvgIcon.previous
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                        visible: false
                    }
                    ColorOverlay {
                        anchors.fill: prevIcon; source: prevIcon; color: "white"
                    }
                }

                // 2. 播放/暂停
                MouseArea {
                    Layout.preferredWidth: 40; Layout.preferredHeight: 40
                    cursorShape: Qt.PointingHandCursor
                    onClicked: if(root.player) root.player.togglePlaying()
                    
                    Image {
                        id: playPauseIcon
                        anchors.centerIn: parent
                        width: 32; height: 32
                        source: (root.player && root.player.isPlaying) ? SvgIcon.pause : SvgIcon.play
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                        visible: false
                    }
                    ColorOverlay {
                        anchors.fill: playPauseIcon; source: playPauseIcon; color: "white"
                    }
                }

                // 3. 下一曲
                MouseArea {
                    Layout.preferredWidth: 40; Layout.preferredHeight: 40
                    cursorShape: Qt.PointingHandCursor
                    onClicked: if(root.player) root.player.next()
                    
                    Image {
                        id: nextIcon
                        anchors.centerIn: parent
                        width: 24; height: 24
                        source: SvgIcon.next
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                        visible: false
                    }
                    ColorOverlay {
                        anchors.fill: nextIcon; source: nextIcon; color: "white"
                    }
                }
            }
        }
    }
}
