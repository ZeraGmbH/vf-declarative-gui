#include "harmonicpowertablemodel.h"

HarmonicPowerTableModel::HarmonicPowerTableModel(int t_rows, int t_columns, QObject *t_parent) :
    QStandardItemModel(t_rows, t_columns, t_parent)
{
    setupTimer();
}

HarmonicPowerTableModel::~HarmonicPowerTableModel()
{
}

QHash<int, QByteArray> HarmonicPowerTableModel::roleNames() const
{
    QHash<int, QByteArray> roles;

    roles.insert(POWER_S1_P, "PowerS1P");
    roles.insert(POWER_S2_P, "PowerS2P");
    roles.insert(POWER_S3_P, "PowerS3P");
    roles.insert(POWER_S1_Q, "PowerS1Q");
    roles.insert(POWER_S2_Q, "PowerS2Q");
    roles.insert(POWER_S3_Q, "PowerS3Q");
    roles.insert(POWER_S1_S, "PowerS1S");
    roles.insert(POWER_S2_S, "PowerS2S");
    roles.insert(POWER_S3_S, "PowerS3S");

    return roles;
}

void HarmonicPowerTableModel::setupTimer()
{
    m_dataChangeTimer.setInterval(1000);
    m_dataChangeTimer.setSingleShot(false);
    QObject::connect(&m_dataChangeTimer, &QTimer::timeout, this, [&]() {
        emit dataChanged(index(0, 0), index(rowCount()-1, columnCount()-1));
    });
    m_dataChangeTimer.start();
}
