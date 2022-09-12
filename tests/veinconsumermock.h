#ifndef VEINCONSUMERMOCK_H
#define VEINCONSUMERMOCK_H

#include "vfeventconsumerinterface.h"


class VeinConsumerMock : public VfEventConsumerInterface
{
public:
    void handleComponentChange(const VeinComponent::ComponentData *cData) override;
    struct TComponentInfo
    {
        int entityId = -1;
        QString componentName;
        QVariant value;
    };
    QList<TComponentInfo> getComponentChangeList();
private:
    QList<TComponentInfo> m_componentChangeList;
};

#endif // VEINCONSUMERMOCK_H
