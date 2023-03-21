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
    static JsonSettingsFile *getStaticInstance(QQmlEngine *t_engine=nullptr, QJSEngine *t_scriptEngine=nullptr);

    Q_INVOKABLE bool fileExists(const QString &t_filePath) const;
    Q_INVOKABLE void reloadFile();
    Q_INVOKABLE bool loadFromStandardLocation(const QString &t_fileName);
    Q_INVOKABLE bool loadFromFile(const QString &t_filePath);
    Q_INVOKABLE void saveToFile(const QString &t_filePath, bool t_overwrite=false);
    Q_INVOKABLE QString getCurrentFilePath();

    Q_INVOKABLE bool hasOption(const QString &t_key);
    Q_INVOKABLE QString getOption(const QString &t_key, const QString &t_valueDefault);
    Q_INVOKABLE bool setOption(const QString &t_key, const QString &t_value);
    Q_INVOKABLE bool dropOption(const QString &t_key);
    Q_PROPERTY(bool fireChangeOnSet READ fireChangeOnSet WRITE setFireChangeOnSet NOTIFY fireChangeOnSetChanged)

    Q_INVOKABLE bool autoWriteBackEnabled() const;
    Q_INVOKABLE void setAutoWriteBackEnabled(bool t_autoWriteBackEnabled=true);
signals:
    void settingsChanged(JsonSettingsFile *settingsFile);
    void settingsSaveRequest(JsonSettingsFile *settingsFile);
    void fireChangeOnSetChanged();

public slots:

private:
    bool fireChangeOnSet() const;
    void setFireChangeOnSet(bool enabled);

    JsonSettingsFilePrivate *d_ptr;

    static JsonSettingsFile *s_globalSettings;

    Q_DECLARE_PRIVATE(JsonSettingsFile)
    Q_DISABLE_COPY(JsonSettingsFile)
};

#endif // JSONSETTINGSFILE_H
