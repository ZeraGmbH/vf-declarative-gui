TEMPLATE = app

QT += qml quick widgets opengl svg concurrent printsupport sql

CONFIG += c++11

#enable usefull warnings (some disabled due to qnanopainter)
  QMAKE_CXXFLAGS += -Wall -Wextra -Wparentheses -Wsuggest-attribute=const #-Wold-style-cast
  QMAKE_CXXFLAGS += -Wformat -Wformat-security -Wdeprecated -Wcast-align -Woverloaded-virtual #-Wshadow

#give errors on nasty mistakes
  QMAKE_CXXFLAGS += -Werror=ignored-qualifiers -Werror=return-type -Werror=return-local-addr -Werror=empty-body #-Werror=non-virtual-dtor -Werror=cast-qual

#gcc refuses to optimize BBOM code, so warn about any such cases
  QMAKE_CXXFLAGS += -Wdisabled-optimization


contains(DEFINES, OE_BUILD) {
  message(Openembedded build)

  !exists($$PWD/3rdparty/qnanopainter/libqnanopainter/include.pri) {
    error("Dependency 3rdparty/libnanopainter not found")
  }
  !exists($$PWD/3rdparty/json-settings/include.pri) {
    error("Dependency 3rdparty/json-settings not found")
  }
  !exists($$PWD/3rdparty/SortFilterProxyModel/SortFilterProxyModel.pri) {
    error("Dependency 3rdparty/SortFilterProxyModel not found")
  }

  include($$PWD/3rdparty/qnanopainter/libqnanopainter/include.pri)
  include($$PWD/3rdparty/json-settings/include.pri)
  include($$PWD/3rdparty/SortFilterProxyModel/SortFilterProxyModel.pri)
}
else {
  include(/work/downloads/git-clones/qnanopainter/libqnanopainter/libqnanopainter.pri)
  include(/work/qt_projects/JsonSettingsQML/json-settings.pri)
  include(/work/downloads/git-clones/SortFilterProxyModel/SortFilterProxyModel.pri)

  INCLUDEPATH += /work/qt_projects/vein-framework/include/
  INCLUDEPATH += /work/downloads/qwt-6.1.2/src/

  #LIBS += -L/work/qt_projects/distrib/usr/lib/

  unix:!android:LIBS += -L/work/qt_projects/vein-framework/libs_Qt_$${QT_MAJOR_VERSION}_$${QT_MINOR_VERSION}_$${QT_PATCH_VERSION}
  unix:!android:LIBS += -L/work/downloads/build-qwt-Desktop_Qt_$${QT_MAJOR_VERSION}_$${QT_MINOR_VERSION}_$${QT_PATCH_VERSION}_GCC_64bit-Debug/lib/
  #android:LIBS += -L/work/qt_projects/vein-framework/libs-android
  #android:LIBS += -L/work/downloads/build-qwt-Android_f_r_armeabi_v7a_GCC_4_8_Qt_5_6_0-Debug/lib

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

SOURCES += src/main.cpp \
    src/fpscounter.cpp \
    src/fftbarchart.cpp \
    src/barscaledraw.cpp \
    src/bardata.cpp \
    src/barchart.cpp \
    src/cbar.cpp \
    src/phasordiagram.cpp \
    src/gluelogicpropertymap.cpp \
    src/zeragluelogic.cpp \
    src/zeratranslation.cpp \
    src/qmlfileio.cpp \
    src/hpwbarchart.cpp \
    src/sidescaledraw.cpp

RESOURCES += \
    qml.qrc \
    data.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =


# Default rules for deployment.
target.path = /usr/bin
export(target.path)
INSTALLS += target
export(INSTALLS)


LIBS += -lvein-event -lvein-component -lvein-net2 -lvein-framework-protobuf -lvein-tcp -lqml-veinentity -lvein-logger
LIBS += -lqwt

HEADERS += \
    src/fpscounter.h \
    src/fftbarchart.h \
    src/barscaledraw.h \
    src/bardata.h \
    src/barchart.h \
    src/cbar.h \
    src/phasordiagram.h \
    src/gluelogicpropertymap.h \
    src/zeragluelogic.h \
    src/zeratranslation.h \
    src/qmlfileio.h \
    src/hpwbarchart.h \
    src/sidescaledraw.h

INCLUDEPATH += src

ZGUI_CONFIG_FILES = settings.json

config_files.files = $$ZGUI_CONFIG_FILES
config_files.path = /etc/skel/.config/vf-gui-com5003/
INSTALLS += config_files

OTHER_FILES += $$ZGUI_CONFIG_FILES \
               TODO
