cmake_minimum_required(VERSION 3.1)

project(vf-declarative-gui LANGUAGES CXX C)
set(PROJECT_VERSION "1.4.0")

cmake_policy(SET CMP0071 NEW)
set(CMAKE_AUTOMOC ON)
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
# cmake macros
include(FeatureSummary)

#Required Packages

##Qt5
find_package(Qt5 "5.12.0" COMPONENTS Core Widgets DBus Xml Quick QuickControls2 Qml CONFIG REQUIRED COMPONENTS)
find_package(Qt5QuickCompiler CONFIG REQUIRED)

##QWT libs
find_package(PkgConfig REQUIRED)
pkg_check_modules(QWT REQUIRED Qt5Qwt6)

find_Package(VfEvent REQUIRED )
find_Package(VfComponent REQUIRED )
find_Package(VfNet2 REQUIRED ) 
find_Package(VfTcp REQUIRED )
find_Package(VfQml REQUIRED )
find_Package(VfHelpers REQUIRED )
find_Package(ZVKeyboard REQUIRED)
find_package(SortFilterProxyModelCmake REQUIRED)
find_package(zerafa REQUIRED)
find_Package(anmlib REQUIRED)
find_Package(uivlib REQUIRED)
find_package(OpenGL REQUIRED)
find_package(ZeraTranslation REQUIRED)
find_package(zeracomponents REQUIRED)
find_package(qmlhelpers REQUIRED)
find_package(zeraveincomponents REQUIRED)
find_package(qwtcharts REQUIRED)
find_package(JsonSettingsQml REQUIRED)

##enable useful warnings
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -Wextra -Wparentheses -Wsuggest-attribute=const -Wformat -Wformat-security -Wdeprecated -Wcast-align -Woverloaded-virtual")

# All sources by type

##Application
file(GLOB APP_HEADERS
    src/*.h
    )

file(GLOB_RECURSE APP_SOURCES
    src/*.cpp
    )

if("${CMAKE_BUILD_TYPE}" STREQUAL "Debug")
    qt5_add_resources(APP_RESOURCES ${CMAKE_CURRENT_LIST_DIR}/appdata.qrc)
else()
    qtquick_compiler_add_resources(APP_RESOURCES ${CMAKE_CURRENT_LIST_DIR}/appdata.qrc)
endif()

# our application
add_executable(vf-declarative-gui
    ${APP_HEADERS}
    ${APP_SOURCES}
    ${APP_RESOURCES}
    )

# dependencies
target_include_directories(vf-declarative-gui
    PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/src
    ${QWT_INCLUDE_DIRS}
    )

## Choose between openGL and GLES
if(${useGles})
    set (glLib ${GLES2_LIBRARIES})
    target_include_directories(vf-declarative-gui PUBLIC ${GLES2_INCLUDE_DIR})
else()
    set(glLib ${OPENGL_LIBRARIES})
endif()

## linking
target_link_libraries(vf-declarative-gui
    PRIVATE
    Qt5::Core
    Qt5::Widgets
    Qt5::Quick
    Qt5::QuickControls2
    Qt5::DBus
    Qt5::Xml
    #Zera Libs
    VeinMeta::VfEvent
    VeinMeta::VfComponent
    VeinMeta::VfNet2
    VeinMeta::VfTcp
    VeinMeta::VfQml
    VeinMeta::VfHelpers
    "-Wl,--no-as-needed"
    ZeraQml::ZVKeyboard
    ZeraQml::zerafa
    ZeraQml::anmlib
    ZeraQml::uivlib
    ZeraQml::SortFilterProxyModelCmake
    ZeraTranslation::ZeraTranslation
    ZeraQml::zeracomponents
    ZeraQml::qmlhelpers
    ZeraQml::zeraveincomponents
    ZeraQml::qwtcharts
    ZeraQml::JsonSettingsQml
    "-Wl,--as-needed"
    #Other Libs
    ${QWT_LIBRARIES}
    ${glLib}
    )

# add Qml-Debug for Debug build envirionemt only
target_compile_definitions(vf-declarative-gui PRIVATE $<$<CONFIG:Debug>:QT_QML_DEBUG>)

install(TARGETS vf-declarative-gui
    EXPORT vf-declarative-gui
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    )

#Display feature summary
feature_summary(WHAT ALL FATAL_ON_MISSING_REQUIRED_PACKAGES)











