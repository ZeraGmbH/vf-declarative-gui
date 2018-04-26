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

!exists($$PWD/3rdparty/qnanopainter/libqnanopainter/include.pri) {
  error("Dependency 3rdparty/libnanopainter not found")
}
!exists($$PWD/3rdparty/JsonSettingsQML/json-settings.pri) {
  error("Dependency 3rdparty/JsonSettingsQML not found")
}
!exists($$PWD/3rdparty/SortFilterProxyModel/SortFilterProxyModel.pri) {
  error("Dependency 3rdparty/SortFilterProxyModel not found")
}

include($$PWD/3rdparty/qnanopainter/libqnanopainter/include.pri)
include($$PWD/3rdparty/JsonSettingsQML/json-settings.pri)
include($$PWD/3rdparty/SortFilterProxyModel/SortFilterProxyModel.pri)


!contains(DEFINES, OE_BUILD) {
  message(Developer build)

  isEmpty(VF_INCDIR) {
    error("Set VF_INCDIR to the vein-framework includepath")
    #(example) in QtCreator add qmake argument: VF_INCDIR=<some path>/vein-framework/include/
  }
  isEmpty(VF_LIBDIR) {
    error("Set VF_LIBDIR to the path containing the vein-framework libraries")
    #(example) in QtCreator add qmake argument: VF_LIBDIR=<some path>/vein-framework/libs_Qt_$${QT_MAJOR_VERSION}_$${QT_MINOR_VERSION}_$${QT_PATCH_VERSION}
  }

  isEmpty(QWT_INCDIR) {
    error("Set QWT_INCDIR to the qwt includepath")
    #(example) in QtCreator add qmake argument: QWT_INCDIR=<some path>/qwt-6.1.2/src/
  }
  isEmpty(QWT_LIBDIR) {
    error("Set QWT_LIBDIR to the path containing libqwt")
    #(example) in QtCreator add qmake argument: QWT_LIBDIR=<some path>/build-qwt-Desktop_Qt_$${QT_MAJOR_VERSION}_$${QT_MINOR_VERSION}_$${QT_PATCH_VERSION}_GCC_64bit-Debug/lib
  }


  INCLUDEPATH += $${VF_INCDIR}
  INCLUDEPATH += $${QWT_INCDIR}
  LIBS += -L$${VF_LIBDIR}
  LIBS += -L$${QWT_LIBDIR}
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
