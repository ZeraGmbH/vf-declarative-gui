#include "actualvaluemodel.h"

ActualValueModel::ActualValueModel(int t_rows, int t_columns, QObject *t_parent) : QStandardItemModel(t_rows, t_columns, t_parent)
{
}

ActualValueModel::~ActualValueModel()
{
}

QHash<int, QByteArray> ActualValueModel::roleNames() const
{
    using namespace CommonTable;
    QHash<int, QByteArray> roles;
    roles.insert(RoleIndexes::NAME, "Name");
    roles.insert(RoleIndexes::L1, "L1");
    roles.insert(RoleIndexes::L2, "L2");
    roles.insert(RoleIndexes::L3, "L3");
    roles.insert(RoleIndexes::AUX, "AUX");
    roles.insert(RoleIndexes::SUM, "Sum");
    roles.insert(RoleIndexes::UNIT, "Unit");
    return roles;
}
