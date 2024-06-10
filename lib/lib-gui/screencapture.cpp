#include "screencapture.h"
#include "QScreen"
#include <QGuiApplication>
#include <QFile>
#include <QPixmap>

ScreenCapture::ScreenCapture(QObject *parent)
    : QObject{parent}
{}

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
