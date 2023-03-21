#ifndef JSONSETTINGSFILE_H
#define JSONSETTINGSFILE_H

#include <QQmlEngine>

class JsonSettingsFilePrivate;

class JsonSettingsFile : public QObject
{
    Q_OBJECT
public:
    explicit JsonSettingsFile(QObject *t_parent = nullptr);
    static JsonSettingsFile *getInstance();
    static JsonSettingsFile *getStaticInstance(QQmlEngine *t_engine, QJSEngine *t_scriptEngine);
    bool loadFromStandardLocation(const QString &t_fileName);
    void setAutoWriteBackEnabled(bool t_autoWriteBackEnabled=true);

    Q_INVOKABLE QString getOption(const QString &t_key, const QString &t_valueDefault);
    Q_INVOKABLE bool setOption(const QString &t_key, const QString &t_value);
signals:
    void settingsChanged(JsonSettingsFile *settingsFile);
    void settingsSaveRequest(JsonSettingsFile *settingsFile);

private:
    bool loadFromFile(const QString &t_filePath);
    void saveToFile(const QString &t_filePath, bool t_overwrite=false);
    QString getCurrentFilePath();
    bool hasOption(const QString &t_key);

    JsonSettingsFilePrivate *d_ptr;

    static JsonSettingsFile *s_globalSettings;

    Q_DECLARE_PRIVATE(JsonSettingsFile)
    Q_DISABLE_COPY(JsonSettingsFile)
};

#endif // JSONSETTINGSFILE_H
