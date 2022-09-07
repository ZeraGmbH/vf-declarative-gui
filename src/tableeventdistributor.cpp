#include "tableeventdistributor.h"
#include "tableeventconsumer.h"

#include <QHash>
#include <QPoint>

#include <ve_commandevent.h>
#include <vcmp_componentdata.h>

#include <functional>


//harmonic power values

TableEventDistributor::TableEventDistributor(GlueLogicPropertyMap *t_propertyMap, QObject *t_parent) :
    VeinEvent::EventSystem(t_parent),
    m_dPtr(new TableEventConsumer(this, t_propertyMap))
{
}

TableEventDistributor::~TableEventDistributor()
{
    delete m_dPtr;
    m_dPtr=nullptr;
}

bool TableEventDistributor::processEvent(QEvent *t_event)
{
    using namespace VeinEvent;
    bool retVal = false;
    if(t_event->type()==CommandEvent::eventType())
    {
        CommandEvent *cEvent = static_cast<CommandEvent *>(t_event);
        Q_ASSERT(cEvent != nullptr);

        EventData *evData = cEvent->eventData();
        Q_ASSERT(evData != nullptr);

        if (cEvent->eventSubtype() == CommandEvent::EventSubtype::NOTIFICATION
                && evData->type() == VeinComponent::ComponentData::dataType())
        {
            const VeinComponent::ComponentData *cmpData = static_cast<VeinComponent::ComponentData *>(evData);
            Q_ASSERT(cmpData != nullptr);
            m_dPtr->handleComponentChange(cmpData, evData);
        }
    }
    return retVal;
}

