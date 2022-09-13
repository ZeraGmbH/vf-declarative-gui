#include "vfcomponenteventdispatcher.h"
#include <ve_commandevent.h>
#include <vcmp_componentdata.h>

VfComponentEventDispatcher::VfComponentEventDispatcher(std::shared_ptr<VfEventConsumerInterface> consumer) :
    m_consumer(consumer)
{
}

VfComponentEventDispatcher::~VfComponentEventDispatcher()
{
}

bool VfComponentEventDispatcher::processEvent(QEvent *t_event)
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
            m_consumer->handleComponentChange(cmpData);
        }
    }
    return retVal;
}
