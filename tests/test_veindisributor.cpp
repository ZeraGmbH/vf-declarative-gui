#include "test_veindisributor.h"
#include "veinconsumermock.h"
#include "tableeventdistributor.h"

void test_veindisributor::init()
{
}

void test_veindisributor::initialCompileTest()
{
    std::shared_ptr<TableEventConsumerInterface> mock = std::make_shared<VeinConsumerMock>();
    TableEventDistributor distributor(mock);
}

QTEST_MAIN(test_veindisributor)

