#include "zeragluelogic.h"
#include "zeragluelogicprivate.h"

#include <QHash>
#include <QPoint>

#include <ve_commandevent.h>
#include <vcmp_componentdata.h>

#include <functional>


//harmonic power values

ZeraGlueLogic::ZeraGlueLogic(GlueLogicPropertyMap *t_propertyMap, QObject *t_parent) :
    VeinEvent::EventSystem(t_parent),
    m_dPtr(new ZeraGlueLogicPrivate(this, t_propertyMap))
{
}

ZeraGlueLogic::~ZeraGlueLogic()
{
    delete m_dPtr;
    m_dPtr=nullptr;
}

bool ZeraGlueLogic::processEvent(QEvent *t_event)
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

