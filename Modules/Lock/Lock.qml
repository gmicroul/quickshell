import Quickshell
import Quickshell.Wayland
import QtQuick

ShellRoot {
    // 共享上下文
    LockContext {
        id: lockContext
        
        onUnlocked: {
            // 先解锁 Session，再退出程序
            sessionLock.locked = false;
            Qt.quit();
        }
    }

    WlSessionLock {
        id: sessionLock
        
        // 启动即锁屏
        locked: true

        // 为每一个屏幕创建一个锁屏表面
        WlSessionLockSurface {
            LockSurface {
                context: lockContext
            }
        }
    }
}
