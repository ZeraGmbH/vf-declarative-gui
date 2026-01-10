#include "vfcomponenteventdispatcher.h"
#include <ve_commandevent.h>
#include <vcmp_componentdata.h>

VfComponentEventDispatcher::VfComponentEventDispatcher(std::shared_ptr<VfEventConsumerInterface> consumer) :
    m_consumer(consumer)
{
}

void VfComponentEventDispatcher::processEvent(QEvent *t_event)
{
    using namespace VeinEvent;
    if(t_event->type() == CommandEvent::getQEventType()) {
        const CommandEvent *cEvent = static_cast<CommandEvent *>(t_event);
        EventData *evData = cEvent->eventData();
        if(cEvent->eventSubtype() == CommandEvent::EventSubtype::NOTIFICATION &&
            evData->type() == VeinComponent::ComponentData::dataType()) {
            const VeinComponent::ComponentData *cmpData = static_cast<VeinComponent::ComponentData *>(evData);
            m_consumer->handleComponentChange(cmpData);
        }
    }
}
