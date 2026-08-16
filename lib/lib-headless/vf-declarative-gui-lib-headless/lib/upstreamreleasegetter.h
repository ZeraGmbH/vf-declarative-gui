#ifndef UPSTREAMRELEASEGETTER_H
#define UPSTREAMRELEASEGETTER_H

#include <QObject>
#include <QNetworkAccessManager>

class UpstreamReleaseGetter : public QObject
{
    Q_OBJECT
public:
    Q_INVOKABLE void startGetLatestReleaseDetails();
    Q_PROPERTY(QString releaseVersion READ getReleaseVersion NOTIFY sigReleaseVersionChanged);
    Q_PROPERTY(QString releaseText READ getReleaseText NOTIFY sigReleaseTextChanged);

    const QString &getReleaseVersion() const;
    void setReleaseVersion(const QString &releaseVersion);
    const QString &getReleaseText() const;
    void setReleaseText(const QString &releaseText);
signals:
    void sigReleaseVersionChanged();
    void sigReleaseTextChanged();

private:
    QString m_releaseVersion;
    QString m_releaseText;
    QNetworkAccessManager m_manager;
};

#endif // UPSTREAMRELEASEGETTER_H
