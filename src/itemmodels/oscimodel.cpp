#include "oscimodel.h"
#include "vfcomponenteventdispatcher.h"

OsciModel::OsciModel(QStringList componentNames) :
    TableEventItemModelBase(3,128),
    m_componentNames(componentNames)
{
}

void OsciModel::setLabelsAndUnits()
{
    // fill in the x axis values
    for(int i=0; i<columnCount(); ++i) {
        QModelIndex tmpIndex = index(0, i);
        setData(tmpIndex, i, Qt::DisplayRole);
    }
}

void OsciModel::setupMapping()
{
    using namespace CommonTable;
    QHash<QString, QPoint> *osciMap = new QHash<QString, QPoint>();
    for(int i=0; i<m_componentNames.size(); ++i) {
        auto componentName = m_componentNames[i];
        osciMap->insert(componentName, QPoint(Qt::DisplayRole, i+1));
    }
    m_valueMapping.insert(static_cast<int>(Modules::OsciModule), osciMap);
}

QHash<int, QByteArray> OsciModel::roleNames() const
{
    return QHash<int, QByteArray>();
}

void OsciModel::handleComponentChangeCoord(const VeinComponent::ComponentData *cData, const QPoint valueCoordiates)
{
    if(cData->entityId() == static_cast<int>(Modules::OsciModule)) {
        const QList<double> tmpData = qvariant_cast<QList<double> >(cData->newValue());
        QSignalBlocker blocker(this); //no need to send dataChanged for every iteration
        int row = valueCoordiates.y();
        for(int i=0; i<tmpData.length(); ++i) {
            QModelIndex tmpIndex = index(row, i);
            setData(tmpIndex, tmpData.at(i), Qt::DisplayRole);
        }
        blocker.unblock();
        emit dataChanged(index(row, 0), index(row, tmpData.length()-1));
     }
}
