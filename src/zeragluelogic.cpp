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
            // start per-model handling replacing code below
            m_dPtr->handleComponentChange(cmpData);

            switch(static_cast<Modules>(evData->entityId()))
            {
            case Modules::OsciModule:
            {
                retVal = m_dPtr->handleOsciValues(cmpData);
                break;
            }
            case Modules::FftModule:
            {
                retVal = m_dPtr->handleFftValues(cmpData);
                break;
            }
            case Modules::Power3Module:
            {
                retVal = m_dPtr->handleHarmonicPowerValues(cmpData);
                break;
            }
            case Modules::Burden1Module:
            {
                const auto burdenMapping = m_dPtr->m_burden1Data->getValueMapping().value(evData->entityId(), nullptr);
                if(Q_UNLIKELY(burdenMapping != nullptr)) {
                    retVal = m_dPtr->handleBurdenValues(m_dPtr->m_burden1Data, burdenMapping, cmpData);
                }
                break;
            }
            case Modules::Burden2Module:
            {
                const auto burdenMapping = m_dPtr->m_burden2Data->getValueMapping().value(evData->entityId(), nullptr);
                if(Q_UNLIKELY(burdenMapping != nullptr)) {
                    retVal = m_dPtr->handleBurdenValues(m_dPtr->m_burden2Data, burdenMapping, cmpData);
                }
                break;
            }
            default: /// @note values handled earlier in the switch case will not show up in the actual values table!
            {
                QList<ZeraGlueLogicItemModelBase*> actValueModels = QList<ZeraGlueLogicItemModelBase*>()
                        << m_dPtr->m_actValueData
                        << m_dPtr->m_actValueOnlyPData
                        << m_dPtr->m_actValue4thPhaseDcData
                        << m_dPtr->m_actValueAcSumData;
                for(auto model : qAsConst(actValueModels)) {
                    const auto avMapping = model->getValueMapping().value(evData->entityId(), nullptr);
                    if(Q_UNLIKELY(avMapping != nullptr)) {
                        retVal = m_dPtr->handleActualValues(model, avMapping, cmpData);
                    }
                }

                QList<ZeraGlueLogicItemModelBase*> burdenModels = QList<ZeraGlueLogicItemModelBase*>()
                        << m_dPtr->m_burden1Data
                        << m_dPtr->m_burden2Data;
                for(auto model : qAsConst(burdenModels)) {
                    const auto burdenMapping = model->getValueMapping().value(evData->entityId(), nullptr);
                    if(Q_UNLIKELY(burdenMapping != nullptr)) { //rms values
                        retVal = true;
                        m_dPtr->handleBurdenValues(model, burdenMapping, cmpData);
                    }
                }
                break;
            }
            }
        }
    }
    return retVal;
}

