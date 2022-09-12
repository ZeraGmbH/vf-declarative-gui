#include "test_veindisributor.h"
#include "veinconsumermock.h"
#include "vfeventdispatcher.h"

void test_veindisributor::init()
{
}

void test_veindisributor::initialCompileTest()
{
    std::shared_ptr<VfEventConsumerInterface> mock = std::make_shared<VeinConsumerMock>();
    VfEventDispatcher distributor(mock);
}

QTEST_MAIN(test_veindisributor)

