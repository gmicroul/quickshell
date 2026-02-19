//@ pragma UseQApplication
import Quickshell
import Quickshell.Wayland
import Quickshell.Io  // 【新增】用于 IPC 通信
import QtQuick        // 【新增】用于 Loader
import qs.Modules.Bar

ShellRoot {
    // 你的状态栏保持不变
    Bar {}

    // ================= 锁屏管理器 =================
    Loader {
        id: lockLoader
        active: false // 平时是关闭的
        
        // 【注意】这里填你的 Lock.qml 的相对路径或绝对路径
        // 假设 shell.qml 在 ~/.config/quickshell/，那么下面这样写：
        source: "Modules/Lock/Lock.qml"
        
        // 监听锁屏发出的“解锁成功”信号
        Connections {
            target: lockLoader.item // 连接到 Lock.qml 的根对象
            ignoreUnknownSignals: true
            
            // 当 Lock.qml 发出 unlocked() 信号时
            function onUnlocked() {
                // 销毁锁屏组件（解锁）
                lockLoader.active = false
            }
        }
    }

    // ================= IPC 控制接口 =================
    IpcHandler {
        target: "lock" // 对讲机频道名称
        
        // 命令: quickshell ipc call lock open
        function open() {
            // 如果已经锁了，就啥也不干；没锁就加载锁屏
            if (!lockLoader.active) {
                lockLoader.active = true
                return "LOCKED"
            }
            return "ALREADY_LOCKED"
        }
    }
}

