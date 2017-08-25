TEMPLATE = app

QT += qml quick widgets opengl svg concurrent printsupport sql

CONFIG += c++11


contains(DEFINES, OE_BUILD) {
  message(Openembedded build)
  include($$PWD/3rdparty/qnanopainter/libqnanopainter/include.pri)
  include($$PWD/3rdparty/json-settings/include.pri)
  include($$PWD/3rdparty/SortFilterProxyModel/SortFilterProxyModel.pri)
}
else {
  include(/work/downloads/git-clones/qnanopainter/libqnanopainter/libqnanopainter.pri)
  include(/work/qt_projects/JsonSettingsQML/json-settings.pri)
  include(/work/downloads/git-clones/SortFilterProxyModel/SortFilterProxyModel.pri)

  INCLUDEPATH += /work/qt_projects/distrib/usr/include/
  INCLUDEPATH += /work/downloads/qwt-6.1.2/src/

  #LIBS += -L/work/qt_projects/distrib/usr/lib/

  unix:!android:LIBS += -L/work/qt_projects/vein-framework/libs
  unix:!android:LIBS += -L/work/downloads/build-qwt-Desktop_Qt_5_7_0_GCC_64bit-Debug/lib/
  android:LIBS += -L/work/qt_projects/vein-framework/libs-android
  android:LIBS += -L/work/downloads/build-qwt-Android_f_r_armeabi_v7a_GCC_4_8_Qt_5_6_0-Debug/lib

  contains(ANDROID_TARGET_ARCH,armeabi-v7a) {
    ANDROID_EXTRA_LIBS = \
      /work/qt_projects/vein-framework/libs-android/libvein-event.so \
      /work/downloads/protobuf-2.5.0/build/lib/libprotobuf.so \
      /work/qt_projects/vein-framework/libs-android/libvein-framework-protobuf.so \
      /work/qt_projects/vein-framework/libs-android/libxiqnet.so \
      /work/qt_projects/vein-framework/libs-android/libvein-component.so \
      /work/qt_projects/vein-framework/libs-android/libvein-hash.so \
      /work/qt_projects/vein-framework/libs-android/libvein-net.so \
      /work/qt_projects/vein-framework/libs-android/libqml-veinentity.so \
      /work/downloads/build-qwt-Android_f_r_armeabi_v7a_GCC_4_8_Qt_5_6_0-Debug/lib/libqwt.so
  }
}

SOURCES += main.cpp \
    fpscounter.cpp \
    com5003gluelogic.cpp \
    fftbarchart.cpp \
    barscaledraw.cpp \
    bardata.cpp \
    barchart.cpp \
    cbar.cpp \
    com5003translation.cpp \
    phasordiagram.cpp \
    gluelogicpropertymap.cpp

RESOURCES += \
    qml.qrc \
    data.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

target.path = /usr/bin

# Default rules for deployment.
include(deployment.pri)

LIBS += -lvein-event -lvein-component -lvein-net -lvein-framework-protobuf -lxiqnet -lqml-veinentity -lvein-logger
LIBS += -lqwt

HEADERS += \
    fpscounter.h \
    com5003gluelogic.h \
    fftbarchart.h \
    barscaledraw.h \
    bardata.h \
    barchart.h \
    cbar.h \
    com5003translation.h \
    phasordiagram.h \
    gluelogicpropertymap.h

#Qt 5.6.3 / 5.7.2 / 5.8 should not need this, see: https://bugreports.qt.io/browse/QTBUG-53206
lupdate_only {
SOURCES += *.qml \
          pages/*.qml \
          common/*.qml
}

ZGUI_CONFIG_FILES = settings.json

config_files.files = $$ZGUI_CONFIG_FILES
config_files.path = /etc/skel/.config/vf-gui-com5003/
INSTALLS += config_files

OTHER_FILES += $$ZGUI_CONFIG_FILES \
               TODO
