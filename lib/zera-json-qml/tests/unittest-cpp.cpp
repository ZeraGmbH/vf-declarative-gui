#include <gtest/gtest.h>
#include <QDir>
#include <QJsonDocument>
#include <declarativejsonitem.h>

// positive in out same
TEST(TEST_CPP,TYPE_LOAD_UNLOAD_COMPARE) {
    QFile jsonFile(":/json-test-files/TEST_CPP,TYPE_LOAD_UNLOAD_COMPARE.json");
    QJsonObject jsonOrigData;
    if(jsonFile.open(QIODevice::Unbuffered | QIODevice::ReadOnly))
        jsonOrigData = QJsonDocument::fromJson(jsonFile.readAll()).object();

    DeclarativeJsonItem declarativeJsonItem;
    declarativeJsonItem.fromJson(jsonOrigData);
    QJsonObject jsonReturnedData = declarativeJsonItem.toJson();
    EXPECT_EQ(jsonOrigData, jsonReturnedData);
}

// positive: check if double is not casted to int (by QVariant magic)
TEST(TEST_CPP, NO_UNWANTED_INT_CAST) {
    QJsonObject jsonObj;
    QString strKey = "testInt";
    jsonObj.insert(strKey, 1);
    DeclarativeJsonItem declarativeJsonItem;
    declarativeJsonItem.fromJson(jsonObj);
    double newValue = 1.001;
    declarativeJsonItem[strKey] = newValue;
    QJsonObject jsonReturnedData = declarativeJsonItem.toJson();
    EXPECT_EQ(jsonReturnedData[strKey], newValue);
}
