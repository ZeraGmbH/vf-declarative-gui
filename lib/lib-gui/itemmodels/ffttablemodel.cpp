#include "ffttablemodel.h"

FftTableModel::FftTableModel(int t_rows, int t_columns, QObject *t_parent) :
    QStandardItemModel(t_rows, t_columns, t_parent)
{
}

FftTableModel::~FftTableModel()
{
}

QHash<int, QByteArray> FftTableModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    //    roles.insert(rowIndex, "RowIndex");
    roles.insert(AMP_L1, "AmplitudeL1"); //leave the first one for eventual harmonic order
    roles.insert(AMP_L2, "AmplitudeL2");
    roles.insert(AMP_L3, "AmplitudeL3");
    roles.insert(AMP_L4, "AmplitudeL4");
    roles.insert(AMP_L5, "AmplitudeL5");
    roles.insert(AMP_L6, "AmplitudeL6");
    roles.insert(AMP_L7, "AmplitudeL7");
    roles.insert(AMP_L8, "AmplitudeL8");
    roles.insert(VECTOR_L1, "AngleL1");
    roles.insert(VECTOR_L2, "AngleL2");
    roles.insert(VECTOR_L3, "AngleL3");
    roles.insert(VECTOR_L4, "AngleL4");
    roles.insert(VECTOR_L5, "AngleL5");
    roles.insert(VECTOR_L6, "AngleL6");
    roles.insert(VECTOR_L7, "AngleL7");
    roles.insert(VECTOR_L8, "AngleL8");

    return roles;
}
