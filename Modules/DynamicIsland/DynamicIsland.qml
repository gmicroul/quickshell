import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris
import Quickshell.Services.Pipewire
import qs.Services
import qs.config
import qs.Modules.DynamicIsland.ClockContent
import qs.Modules.DynamicIsland.MediaContent
import qs.Modules.DynamicIsland.NotificationContent
import qs.Modules.DynamicIsland.VolumeContent
import qs.Modules.DynamicIsland.LauncherContent
import qs.Modules.DynamicIsland.WallpaperContent
import qs.Modules.DynamicIsland.DashboardContent

Rectangle {
    id: root

    // =================状态定义=================
    property bool showDashboard: false
    property bool showWallpaper: false
    property bool showLauncher: false
    
    property bool expanded: false
    property bool showVolume: false

    // 优先级判断 (Dashboard > Wallpaper > Launcher)
    property bool isDashboardMode: showDashboard
    property bool isWallpaperMode: showWallpaper && !showDashboard
    property bool isLauncherMode: showLauncher && !showWallpaper && !showDashboard
    property bool isVolumeMode: showVolume && !expanded && !showLauncher && !showWallpaper && !showDashboard
    property bool isNotifMode: notifManager.hasNotifs && !expanded && !showVolume && !showLauncher && !showWallpaper && !showDashboard

    // =================尺寸定义=================
    property int dashW: 810; property int dashH: 240
    property int wallW: 810; property int wallH: 180
    property int launchW: 400; property int launchH: 500
    property int expandedW: 420; property int expandedH: 180
    property int collapsedW: 220; property int collapsedH: 32
    property int notifW: 380; property int notifH: (notifManager.model.count * 70) + 20
    property int volW: 220; property int volH: 40
    
    color: Colorsheme.background
    clip: true
    z: 100
    
    // 圆角逻辑
    radius: (expanded || isNotifMode || isVolumeMode || isLauncherMode || isWallpaperMode || isDashboardMode) ? 24 : height / 2

    // 宽高动态切换
    width: isDashboardMode ? dashW : (isWallpaperMode ? wallW : (isLauncherMode ? launchW : (expanded ? expandedW : (isVolumeMode ? volW : (isNotifMode ? notifW : collapsedW)))))
    height: isDashboardMode ? dashH : (isWallpaperMode ? wallH : (isLauncherMode ? launchH : (expanded ? expandedH : (isVolumeMode ? volH : (isNotifMode ? notifH : collapsedH)))))

    Behavior on width { NumberAnimation { duration: 500; easing.type: Easing.OutBack; easing.overshoot: 0.8 } }
    Behavior on height { NumberAnimation { duration: 500; easing.type: Easing.OutBack; easing.overshoot: 0.8 } }
    Behavior on radius { NumberAnimation { duration: 500 } }

    // =================IPC 监听=================
    Process {
        id: ipcListener
        command: ["bash", "-c", "
            PIPE=/tmp/qs_launcher.pipe;
            if [ ! -p $PIPE ]; then rm -f $PIPE && mkfifo $PIPE; fi;
            while true; do cat $PIPE; done
        "]
        running: true 
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: (data) => {
                if (data.indexOf("dashboard") !== -1) {
                    if (root.showDashboard) root.showDashboard = false;
                    else {
                        root.showLauncher = false;
                        root.showWallpaper = false; root.expanded = false;
                        root.showDashboard = true; 
                    }
                }
                else if (data.indexOf("wallpaper") !== -1) {
                    if (root.showWallpaper) root.showWallpaper = false;
                    else {
                        root.showLauncher = false;
                        root.showDashboard = false; root.expanded = false;
                        root.showWallpaper = true;
                    }
                }
                else if (data.indexOf("toggle") !== -1) {
                    root.showDashboard = false;
                    root.showWallpaper = false;
                    if (root.showLauncher) root.showLauncher = false;
                    else { root.expanded = false; root.showLauncher = true; }
                }
            }
        }
        onExited: (code, status) => { restartTimer.start() }
    }
    Timer { id: restartTimer; interval: 100; onTriggered: ipcListener.running = true }

    // ================= 音频与通知服务 =================
    PwObjectTracker { objects: [ Pipewire.defaultAudioSink ] }
    property var audioNode: Pipewire.defaultAudioSink ? Pipewire.defaultAudioSink.audio : null

    // ★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★
    // 【核心修复】音量 OSD 监听逻辑
    // ★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★
    
    // 1. 自动隐藏定时器
    Timer {
        id: volHideTimer
        interval: 2000 // 2秒后自动消失
        onTriggered: root.showVolume = false
    }

    // 2. 监听 Pipewire 信号
    Connections {
        target: root.audioNode // 绑定到当前音频节点
        ignoreUnknownSignals: true

        // 当音量数值改变时触发 (包括系统调节和鼠标拖动)
        function onVolumeChanged() {
            triggerVolumeOSD()
        }

        // 当静音状态改变时触发
        function onMutedChanged() {
            triggerVolumeOSD()
        }
    }

    // 3. 触发显示的逻辑函数
    function triggerVolumeOSD() {
        // 如果正在显示看板、启动器或壁纸，或者已经展开，就不要打断它们
        if (root.showDashboard || root.showLauncher || root.showWallpaper || root.expanded) return;
        
        // 显示音量条并重置消失倒计时
        root.showVolume = true;
        volHideTimer.restart();
    }
    // ★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★


    NotificationManager { id: notifManager }
    property var allPlayers: Mpris.players.values
    property var currentPlayer: {
        if (allPlayers.length === 0) return null;
        for (let i = 0; i < allPlayers.length; i++) { if (allPlayers[i].isPlaying) return allPlayers[i]; }
        return allPlayers[0];
    }

    // 点击关闭区域
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        enabled: !isNotifMode && !isVolumeMode
        onClicked: {
            if (root.showDashboard) root.showDashboard = false;
            else if (root.showWallpaper) root.showWallpaper = false;
            else if (root.showLauncher) root.showLauncher = false;
            else root.expanded = !root.expanded;
        }
    }

    // =================视图内容=================
    Item {
        anchors.fill: parent

        ClockContent {
            anchors.fill: parent
            player: root.currentPlayer
            opacity: (!root.expanded && !root.isNotifMode && !root.isVolumeMode && !root.isLauncherMode && !root.isWallpaperMode && !root.isDashboardMode) ? 1 : 0
            visible: opacity > 0
            Behavior on opacity { NumberAnimation { duration: 200 } }
        }

        VolumeContent { 
            anchors.fill: parent;
            audioNode: root.audioNode; // 确保传入 audioNode
            opacity: root.isVolumeMode ? 1 : 0; 
            visible: opacity > 0;
            Behavior on opacity { NumberAnimation { duration: 200 } } 
        }
        
        NotificationContent { 
            anchors.fill: parent;
            anchors.margins: 10; 
            manager: notifManager; 
            opacity: root.isNotifMode ? 1 : 0; 
            visible: opacity > 0;
            Behavior on opacity { NumberAnimation { duration: 200 } } 
        }
        
        MediaContent {
            anchors.fill: parent
            anchors.margins: 20
            player: root.expanded ? root.currentPlayer : null
            opacity: root.expanded ? 1 : 0
            visible: opacity > 0
            Behavior on opacity { NumberAnimation { duration: 200 } }
        }
        
        LauncherContent { 
            anchors.fill: parent;
            onLaunchRequested: root.showLauncher = false; 
            opacity: root.isLauncherMode ? 1 : 0; 
            visible: opacity > 0;
            Behavior on opacity { NumberAnimation { duration: 200 } } 
        }

        WallpaperContent {
            anchors.fill: parent
            onWallpaperChanged: root.showWallpaper = false
            opacity: root.isWallpaperMode ? 1 : 0
            visible: opacity > 0
            Behavior on opacity { NumberAnimation { duration: 200 } }
        }

        DashboardContent {
            anchors.fill: parent
            opacity: root.isDashboardMode ? 1 : 0
            visible: opacity > 0
            Behavior on opacity { NumberAnimation { duration: 200 } }
        }
    }
}
