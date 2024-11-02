#ifndef SCREENCAPTURE_H
#define SCREENCAPTURE_H

#include <QObject>
#include <QStringList>

class ScreenCapture : public QObject
{
    Q_OBJECT
public:
    explicit ScreenCapture(QObject *parent = nullptr);
    Q_INVOKABLE bool capture(QString path);
    Q_INVOKABLE bool captureMounted(QStringList mountedPaths);
};

#endif // SCREENCAPTURE_H
