import QtQuick
import Quickshell

MouseArea {
    id: root
    required property var modelData 
    
    implicitWidth: content.width
    implicitHeight: content.height
    
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    
    acceptedButtons: Qt.LeftButton | Qt.RightButton

    onClicked: (event) => {
        if (event.button === Qt.LeftButton) {
            modelData.activate();
        } else if (event.button === Qt.RightButton) {
            if (menuAnchor.menu) {
                menuAnchor.open();
            }
        }
    }

    QsMenuAnchor {
        id: menuAnchor
        menu: modelData.menu
        anchor.item: root
    }

    Image {
        id: content
        
        source: {
            const raw = root.modelData.icon;
            
            // 仅保留 Spotify 的修复逻辑
            // 只要名字里带 "spotify" (比如 spotify-client, spotify-linux-32等)，就强制用标准图标
            if (raw.indexOf("spotify") !== -1) {
                return "image://icon/spotify";
            }
            
            // 其他图标正常显示
            return raw;
        }
        
        width: 20
        height: 20
        
        cache: true
        asynchronous: true
        fillMode: Image.PreserveAspectFit
    }
}
