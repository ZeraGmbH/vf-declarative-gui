import QtQuick 2.14
import QtQuick.Window 2.14
import GlobalConfig 1.0

Item {
    readonly property int winWidth: {
        let width = Screen.desktopAvailableWidth
        if(BUILD_TYPE === "debug") {
            switch(screenResolution) {
            case 0:
                width = 800
                break
            case 1:
                width = 1024
                break
            case 2:
                width = 1280
                break
            default:
                width = Screen.width
                break;
            }
        }
        return width
    }
    readonly property int winHeight: {
        let height = Screen.desktopAvailableHeight
        if(BUILD_TYPE === "debug") {
            switch(screenResolution) {
            case 0:
                height = 480;
                break
            case 1:
                height = 600;
                break
            case 2:
                height = 800;
                break
            /*default:
                height = Screen.height
                break;*/
            }
        }
        return height
    }

    property int screenResolution: GC.screenResolution
    // Notes on resolutions:
    // * for production we use desktop sizes: We have one monitor & bars
    // * for debug we use screen sizes for multi monitor environments
    Shortcut {
        enabled: BUILD_TYPE === "debug"
        sequence: "F3"
        autoRepeat: false
        onActivated: {
            screenResolution = (screenResolution+1) % 4
            GC.setScreenResolution(screenResolution)
        }
    }
}
