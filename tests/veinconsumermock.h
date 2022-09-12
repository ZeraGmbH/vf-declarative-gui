#ifndef VEINCONSUMERMOCK_H
#define VEINCONSUMERMOCK_H

#include "vfeventconsumerinterface.h"


class VeinConsumerMock : public VfEventConsumerInterface

{
public:
    void handleComponentChange(const VeinComponent::ComponentData *cData) override;
};

#endif // VEINCONSUMERMOCK_H
