#ifndef VEINCONSUMERMOCK_H
#define VEINCONSUMERMOCK_H

#include "tableeventconsumerinterface.h"


class VeinConsumerMock : public TableEventConsumerInterface

{
public:
    void handleComponentChange(const VeinComponent::ComponentData *cData) override;
};

#endif // VEINCONSUMERMOCK_H
