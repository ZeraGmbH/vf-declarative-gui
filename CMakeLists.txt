cmake_minimum_required(VERSION 3.1)

project(vf-declarative-gui LANGUAGES CXX C)
set(PROJECT_VERSION "1.4.0")

cmake_policy(SET CMP0071 NEW)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

include(FeatureSummary)

set(QT_MAJOR_VER "5" CACHE STRING "Qt major version")
set(QTX "Qt${QT_MAJOR_VER}")

if("${QT_MAJOR_VER}" STREQUAL "6")
    find_package(Qt6 COMPONENTS Core Core5Compat StateMachine DBus Xml Quick QuickControls2 Qml Test CONFIG REQUIRED COMPONENTS)
else()
    find_package(Qt5 COMPONENTS Core DBus Xml Quick QuickControls2 Qml Test CONFIG REQUIRED COMPONENTS)
    find_package(Qt5QuickCompiler CONFIG REQUIRED)
endif()

find_package(PkgConfig REQUIRED)
pkg_check_modules(QWT REQUIRED ${QTX}Qwt6)

find_package(ZeraClasses REQUIRED)
find_package(FontAweSomeQml REQUIRED)
find_package(VeinFramework REQUIRED)
find_package(SortFilterProxyModel REQUIRED)
find_package(ZeraTranslation REQUIRED)
find_Package(zera-json-helpers REQUIRED)
find_Package(VfQmlLibs REQUIRED)
find_package(VfFiles REQUIRED)
find_package(simplecmdiobase REQUIRED)

##enable useful warnings
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -Wextra -Wparentheses -Wformat -Wformat-security -Wdeprecated -Wcast-align -Woverloaded-virtual")

enable_testing()

add_subdirectory(app)
add_subdirectory(lib)

feature_summary(WHAT ALL FATAL_ON_MISSING_REQUIRED_PACKAGES)
