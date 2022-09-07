#ifndef TABLEEVENTCONSUMERINTERFACE_H
#define TABLEEVENTCONSUMERINTERFACE_H

#include <vcmp_componentdata.h>
#include <ve_eventdata.h>

class TableEventConsumerInterface
{
public:
    virtual ~TableEventConsumerInterface() {};

    virtual void handleComponentChange(const VeinComponent::ComponentData *cData) = 0;
};

#endif // TABLEEVENTCONSUMERINTERFACE_H
