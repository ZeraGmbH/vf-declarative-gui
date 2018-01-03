#include "qmlfileio.h"
#include <QFile>
#include <QFileInfo>
#include <QTextStream>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QJsonParseError>
#include <qqml.h>

namespace QmlFileIOPrivate
{
  void registerTypes()
  {
    // @uri QmlFileIO
    qmlRegisterSingletonType<QmlFileIO>("QmlFileIO", 1, 0, "QmlFileIO", QmlFileIO::getStaticInstance);
  }

  Q_COREAPP_STARTUP_FUNCTION(registerTypes)
}

QmlFileIO::QmlFileIO(QObject *t_parent) : QObject(t_parent)
{

}

QString QmlFileIO::readTextFile(const QString &t_fileName)
{
  QFile textFile(t_fileName);
  QString retVal;
  if(checkFile(textFile) && textFile.open(QFile::ReadOnly | QFile::Text))
  {
    QTextStream textStream(&textFile);
    retVal = textStream.readAll();
    textFile.close();
  }
  return retVal;
}

bool QmlFileIO::writeTextFile(const QString &t_fileName, const QString &t_content, bool t_overwrite, bool t_truncate)
{
  QFile textFile(t_fileName);
  bool retVal = false;
  if(textFile.exists() == false || t_overwrite == true)
  {
    bool fileIsOpen = false;
    if(t_truncate == true)
    {
      fileIsOpen = textFile.open(QFile::WriteOnly);
    }
    else
    {
      fileIsOpen = textFile.open(QFile::Append);
    }

    if(fileIsOpen == true)
    {
      retVal = true;
      QTextStream textStream(&textFile);
      textStream << t_content;
      textFile.close();
    }
    else
    {
      qWarning() << "QmlFileIO: Error opening file:" << t_fileName << "error:" << textFile.errorString();
    }
  }
  else
  {
    qWarning() << "QmlFileIO: Skipped writing existing file because of missing override flag" << t_fileName;
  }

  return retVal;
}

QVariant QmlFileIO::readJsonFile(const QString &t_fileName)
{
  QFile jsonFile(t_fileName);
  QVariant retVal;
  if(checkFile(jsonFile))
  {
    if(jsonFile.open(QFile::ReadOnly))
    {
      QJsonParseError errorObj;
      QJsonDocument jsonDoc = QJsonDocument::fromJson(jsonFile.readAll(), &errorObj);
      if(errorObj.error == QJsonParseError::NoError)
      {
        if(jsonDoc.isObject())
        {
          retVal = jsonDoc.object().toVariantMap();
        }
        else if(jsonDoc.isArray())
        {
          retVal = jsonDoc.array().toVariantList();
        }
      }
      else
      {
        qWarning() << "QmlFileIO: Error parsing JSON file:" << t_fileName << "error:" << errorObj.errorString();
      }
    }
    else
    {
      qWarning() << "QmlFileIO: Error opening file:" << t_fileName << "error:" << jsonFile.errorString();
    }
  }

  return retVal;
}

bool QmlFileIO::writeJsonFile(const QString &t_fileName, const QVariant &t_content, bool t_overwrite)
{
  bool retVal = false;
  QFile jsonFile(t_fileName);
  QJsonDocument jsonDoc;
  if(jsonFile.exists() == false || t_overwrite == true)
  {
    bool dataIsValid = false;

    if(t_content.type() == QVariant::Map)
    {
      QJsonObject jsonObj = QJsonObject::fromVariantMap(t_content.toMap());
      jsonDoc.setObject(jsonObj);
      dataIsValid = true;
    }
    else if(t_content.type() == QVariant::List)
    {
      QJsonArray jsonArray = QJsonArray::fromVariantList(t_content.toList());
      jsonDoc.setArray(jsonArray);
      dataIsValid = true;
    }
    else
    {
      qWarning() << "QmlFileIO: Expected list or object type to write JSON document:" << t_fileName << "instead provided type is:" << t_content.typeName();
    }

    if(jsonFile.open(QFile::WriteOnly) && dataIsValid == true)
    {
      jsonFile.write(jsonDoc.toJson(QJsonDocument::Indented));
      jsonFile.close();
      retVal = true;
    }
    else
    {
      qWarning() << "QmlFileIO: Error opening file:" << t_fileName << "error:" << jsonFile.errorString();
    }
  }
  else
  {
    qWarning() << "QmlFileIO: Skipped writing existing file because of missing override flag" << t_fileName;
  }
  return retVal;
}

QObject *QmlFileIO::getStaticInstance(QQmlEngine *t_engine, QJSEngine *t_scriptEngine)
{
  Q_UNUSED(t_engine);
  Q_UNUSED(t_scriptEngine);

  return s_instance;
}

void QmlFileIO::setStaticInstance(QmlFileIO *t_instance)
{
  if(s_instance == nullptr)
  {
    s_instance = t_instance;
  }
}

bool QmlFileIO::checkFile(const QFile &t_file)
{
  bool retVal = false;
  if(t_file.exists())
  {
    QFileInfo fInfo(t_file);
    const qint64 fileSize = fInfo.size();
    if(fileSize > 0 && fileSize < UINT32_MAX) //sanity check
    {
      retVal = true;
    }
    else
    {
      qWarning() << "QmlFileIO: Only files with 0 < size < 4GB are supported:" << t_file.fileName() << "has:" << fileSize << "bytes";
    }
  }
  else
  {
    qWarning() << "QmlFileIO: File can not be read:" << t_file.fileName();
  }

  return retVal;
}

QmlFileIO * QmlFileIO::s_instance = nullptr;
