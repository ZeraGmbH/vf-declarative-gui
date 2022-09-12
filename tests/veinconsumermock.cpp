#include "veinconsumermock.h"

void VeinConsumerMock::handleComponentChange(const VeinComponent::ComponentData *cData)
{
    TComponentInfo componentInfo;
    componentInfo.componentName = cData->componentName();
    componentInfo.entityId = cData->entityId();
    componentInfo.value = cData->newValue();
    m_componentChangeList.append(componentInfo);
}

QList<VeinConsumerMock::TComponentInfo> VeinConsumerMock::getComponentChangeList()
{
    return m_componentChangeList;
}
