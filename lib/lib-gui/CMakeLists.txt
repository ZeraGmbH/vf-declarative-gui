file(GLOB HEADERS
    *.h
    itemmodels/*.h
    itemmodels/EMOB/*.h
    itemmodels/LEM_DC/*.h
    )

file(GLOB SOURCES
    *.cpp
    itemmodels/*.cpp
    itemmodels/EMOB/*.cpp
    itemmodels/LEM_DC/*.cpp
    )

add_library(vf-declarative-gui-lib STATIC
    ${SOURCES}
    ${HEADERS}
    )

target_include_directories(vf-declarative-gui-lib
    PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/itemmodels>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/itemmodels/EMOB>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/itemmodels/LEM_DC>
    )

target_link_libraries(vf-declarative-gui-lib
    PUBLIC
    Qt5::Core
    Qt5::Widgets
    Qt5::Quick
    Qt5::QuickControls2
    Qt5::DBus
    Qt5::Xml
    vf-declarative-gui-lib-headless
    Zera::VfEvent
    Zera::VfComponent
    Zera::VfNet2
    Zera::VfTcp
    Zera::VfQml
    "-Wl,--no-as-needed"
    Zera::zerafa
    Zera::anmlib
    Zera::uivlib
    SortFilterProxyModel::SortFilterProxyModel
    ZeraTranslation::ZeraTranslation
    Zera::zeracomponents
    Zera::qmlhelpers
    Zera::zeraveincomponents
    Zera::qwtcharts
    zera-json-qml
    Zera::ZVKeyboardLayout
    "-Wl,--as-needed"
    #Other Libs
    ${QWT_LIBRARIES}
    FontAweSomeQml::FontAweSomeQml
    )

