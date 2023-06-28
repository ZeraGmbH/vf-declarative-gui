cmake_minimum_required(VERSION 3.1)

project(vf-declarative-gui LANGUAGES CXX C)
set(PROJECT_VERSION "1.4.0")

cmake_policy(SET CMP0071 NEW)
set(CMAKE_AUTOMOC ON)

include(FeatureSummary)

find_package(Qt5 "5.12.0" COMPONENTS Core Widgets DBus Xml Quick QuickControls2 Qml Test CONFIG REQUIRED COMPONENTS)
find_package(Qt5QuickCompiler CONFIG REQUIRED)
find_package(PkgConfig REQUIRED)
pkg_check_modules(QWT REQUIRED Qt5Qwt6)

find_package(FontAweSomeQml REQUIRED)
find_package(VeinFramework REQUIRED)
find_Package(VfNet2 REQUIRED ) 
find_Package(VfTcp REQUIRED )
find_Package(VfQml REQUIRED )
find_package(SortFilterProxyModel REQUIRED)
find_package(ZeraTranslation REQUIRED)
find_Package(zera-json-qml REQUIRED)
find_Package(VfQmlLibs REQUIRED)

##enable useful warnings
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -Wextra -Wparentheses -Wsuggest-attribute=const -Wformat -Wformat-security -Wdeprecated -Wcast-align -Woverloaded-virtual")

file(GLOB HEADERS
    src/*.h
    src/itemmodels/*.h
    )

file(GLOB_RECURSE SOURCES
    src/itemmodels/*.cpp
    src/gluelogicpropertymap.cpp
    src/jsonsettingsfile.cpp
    src/modelrowpair.cpp
    src/qmlappstarterforwebgl.cpp
    src/qmlfileio.cpp
    src/tableeventconsumer.cpp
    src/vfcomponenteventdispatcher.cpp
    )

add_library(vf-declarative-gui-lib STATIC
    ${SOURCES}
    ${HEADERS}
    )

target_include_directories(vf-declarative-gui-lib
    PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src/itemmodels>
    )

target_link_libraries(vf-declarative-gui-lib
    PUBLIC
    Qt5::Core
    Qt5::Widgets
    Qt5::Quick
    Qt5::QuickControls2
    Qt5::DBus
    Qt5::Xml
    Zera::VfHelpers
    Zera::VfEvent
    Zera::VfComponent
    VeinMeta::VfNet2
    VeinMeta::VfTcp
    VeinMeta::VfQml
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
    Zera::notificationmanager
    Zera::ZVKeyboardLayout
    "-Wl,--as-needed"
    #Other Libs
    ${QWT_LIBRARIES}
    FontAweSomeQml::FontAweSomeQml
    )

if("${CMAKE_BUILD_TYPE}" STREQUAL "Debug")
    qt5_add_resources(RESOURCES appdata.qrc)
else()
    qtquick_compiler_add_resources(RESOURCES appdata.qrc)
endif()

add_executable(vf-declarative-gui
    ${RESOURCES}
    src/main.cpp
    )

target_include_directories(vf-declarative-gui
    PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/src
    ${CMAKE_CURRENT_SOURCE_DIR}/src/itemmodels
    ${QWT_INCLUDE_DIRS}
    )

target_link_libraries(vf-declarative-gui
    PRIVATE
    vf-declarative-gui-lib
    )

target_compile_definitions(vf-declarative-gui PRIVATE $<$<CONFIG:Debug>:QT_QML_DEBUG>)

install(TARGETS vf-declarative-gui
    EXPORT vf-declarative-gui
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    )

enable_testing()
add_subdirectory(tests)

feature_summary(WHAT ALL FATAL_ON_MISSING_REQUIRED_PACKAGES)
