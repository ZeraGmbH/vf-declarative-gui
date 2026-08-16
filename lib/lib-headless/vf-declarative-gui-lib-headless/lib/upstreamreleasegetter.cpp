#include "upstreamreleasegetter.h"
#include <QUrl>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QJsonDocument>
#include <QJsonObject>

void UpstreamReleaseGetter::startGetLatestReleaseDetails()
{
    QUrl url("https://api.github.com/repos/ZeraGmbH/zenux-data/releases/latest");
    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::UserAgentHeader, "MyQtApp");
    QNetworkReply *reply = m_manager.get(request);

    connect(reply, &QNetworkReply::finished, this, [reply, this](){
        QJsonDocument doc = QJsonDocument::fromJson(reply->readAll());
        QJsonObject obj = doc.object();
        setReleaseVersion(obj["tag_name"].toString());
        setReleaseText(obj["body"].toString());
        reply->deleteLater();
    });
}

const QString &UpstreamReleaseGetter::getReleaseVersion() const
{
    return m_releaseVersion;
}

void UpstreamReleaseGetter::setReleaseVersion(const QString &releaseVersion)
{
    m_releaseVersion = releaseVersion;
    emit sigReleaseVersionChanged();
}

const QString &UpstreamReleaseGetter::getReleaseText() const
{
    return m_releaseText;
}

void UpstreamReleaseGetter::setReleaseText(const QString &releaseText)
{
    m_releaseText = releaseText;
    emit sigReleaseTextChanged();
}
