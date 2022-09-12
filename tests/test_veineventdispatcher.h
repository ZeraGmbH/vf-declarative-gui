#ifndef TEST_VEINDISRIBUTOR_H
#define TEST_VEINDISRIBUTOR_H

#include <vftesttemplate.h>
#include <QTest>

class test_veineventdispatcher : public QObject, public VfTestTemplate
{
    Q_OBJECT
private slots:
    void init();
    void cleanup();

    void zeroEvents();
    void oneEvent();
    void twoEvents();
    void twoEventsTwoEntities();
    void twoEventsTwoComponents();
};

#endif // TEST_VEINDISRIBUTOR_H
