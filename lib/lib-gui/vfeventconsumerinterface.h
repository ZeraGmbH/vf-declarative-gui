#ifndef VFEVENTCONSUMERINTERFACE_H
#define VFEVENTCONSUMERINTERFACE_H

#include <vcmp_componentdata.h>
#include <ve_eventdata.h>

class VfEventConsumerInterface
{
public:
    virtual ~VfEventConsumerInterface() {};

    virtual void handleComponentChange(const VeinComponent::ComponentData *cData) = 0;
};

#endif // VFEVENTCONSUMERINTERFACE_H
