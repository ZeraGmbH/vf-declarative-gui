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
    roles.insert(VECTOR_L1, "VectorL1");
    roles.insert(VECTOR_L2, "VectorL2");
    roles.insert(VECTOR_L3, "VectorL3");
    roles.insert(VECTOR_L4, "VectorL4");
    roles.insert(VECTOR_L5, "VectorL5");
    roles.insert(VECTOR_L6, "VectorL6");
    roles.insert(VECTOR_L7, "VectorL7");
    roles.insert(VECTOR_L8, "VectorL8");

    return roles;
}
