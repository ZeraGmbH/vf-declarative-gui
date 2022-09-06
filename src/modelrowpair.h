#ifndef MODELROWPAIR_H
#define MODELROWPAIR_H

#include <QStandardItemModel>
#include <QTimer>

class ModelRowPair
{
public:
    ModelRowPair(QStandardItemModel * t_model, int t_row) :
        m_model(t_model),
        m_row(t_row)
    {
    }

    bool isNull() const
    {
        return (m_model == nullptr || m_row == 0);
    }

    QStandardItemModel * m_model=nullptr;
    //optional timer used for values that change too frequently
    QTimer *m_updateInterval=nullptr; //uses the qt parent system to cleanup the instance
    int m_row=0;
};

#endif // MODELROWPAIR_H
