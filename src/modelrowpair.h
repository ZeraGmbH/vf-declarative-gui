#ifndef MODELROWPAIR_H
#define MODELROWPAIR_H

#include <QStandardItemModel>

class ModelRowPair
{
public:
    ModelRowPair(QStandardItemModel * t_model, int t_row) :
        m_model(t_model),
        m_row(t_row)
    {
    }

    QStandardItemModel * m_model=nullptr;
    int m_row=0;
};

#endif // MODELROWPAIR_H
