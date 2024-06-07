#include "screencapture.h"
#include "QScreen"
#include <QGuiApplication>
#include <QFile>
#include <QPixmap>

ScreenCapture::ScreenCapture(QObject *parent)
    : QObject{parent}
{}

void ScreenCapture::capture()
{
    QScreen *screen = QGuiApplication::primaryScreen();
    QPixmap pixmap = screen->grabWindow(0);
    QFile file("/home/operator/Desktop/ScreenFile.PNG");
    file.open(QIODevice::WriteOnly);
    if(file.isOpen())
        pixmap.save(&file, "PNG");
}
