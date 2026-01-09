#ifndef TEST_RECORDER_CACHING_H
#define TEST_RECORDER_CACHING_H

#include <modulemanagertestrunner.h>
#include <vf_core_stack_client.h>

class test_recorder_caching : public QObject
{
    Q_OBJECT
private slots:
    void initTestCase();
    void init();
    void cleanup();

    void isServerUp();
    void isClientUp();

    void initialIsEmpty();

private:
    void setupServer();
    bool setupClient();
    bool subscribeClient();
    void createModule(int entityId, QMap<QString, QVariant> components);

    std::unique_ptr<ModuleManagerTestRunner> m_testRunner;
    std::unique_ptr<VeinNet::NetworkSystem> m_netSystem;
    std::unique_ptr<VeinNet::TcpSystem> m_tcpSystem;
    VeinStorage::AbstractEventSystem* m_clientStorage;
    std::unique_ptr<VfCoreStackClient> m_clientStack;
};

#endif // TEST_RECORDER_CACHING_H
