#ifndef SCREENCAPTURE_H
#define SCREENCAPTURE_H

#include <QObject>

class ScreenCapture : public QObject
{
    Q_OBJECT
public:
    explicit ScreenCapture(QObject *parent = nullptr);
    Q_INVOKABLE bool capture(QString path);
};

#endif // SCREENCAPTURE_H
