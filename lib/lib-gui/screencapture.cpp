#include "screencapture.h"
#include "QScreen"
#include <QGuiApplication>
#include <QFile>
#include <QPixmap>
#include <QDateTime>
#include <QDir>

ScreenCapture::ScreenCapture(QObject *parent)
    : QObject{parent}
{
}

bool ScreenCapture::capture(QString path)
{
    QScreen *screen = QGuiApplication::primaryScreen();
    QPixmap pixmap = screen->grabWindow(0);
    QFile file(path);
    if(file.open(QIODevice::WriteOnly)) {
        pixmap.save(&file, "PNG");
        return true;
    }
    return false;
}

bool ScreenCapture::captureOnFirstMounted(QStringList mountedPaths)
{
    if(mountedPaths.size()) {
        QDateTime now = QDateTime::currentDateTime();
        QString filePath = mountedPaths[0] + "/screenshot-" + now.toString("dd-MM-yyyy HH_mm") + ".PNG";
        filePath = QDir::cleanPath(filePath);
        if(capture(filePath))
            return true;
        else
            qWarning("Error ScreenCapture");
    }
    return false;

}
