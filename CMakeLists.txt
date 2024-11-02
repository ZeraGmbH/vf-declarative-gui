cmake_minimum_required(VERSION 3.1)

project(vf-declarative-gui LANGUAGES CXX C)
set(PROJECT_VERSION "1.4.0")

cmake_policy(SET CMP0071 NEW)
set(CMAKE_AUTOMOC ON)

include(FeatureSummary)

find_package(Qt5 "5.12.0" COMPONENTS Core DBus Xml Quick QuickControls2 Qml Test CONFIG REQUIRED COMPONENTS)
find_package(Qt5QuickCompiler CONFIG REQUIRED)
find_package(PkgConfig REQUIRED)
pkg_check_modules(QWT REQUIRED Qt5Qwt6)

find_package(FontAweSomeQml REQUIRED)
find_package(VeinFramework REQUIRED)
find_package(SortFilterProxyModel REQUIRED)
find_package(ZeraTranslation REQUIRED)
find_Package(zera-json-qml REQUIRED)
find_Package(VfQmlLibs REQUIRED)
find_package(VfFiles REQUIRED)
find_package(simplecmdiobase REQUIRED)

##enable useful warnings
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -Wextra -Wparentheses -Wformat -Wformat-security -Wdeprecated -Wcast-align -Woverloaded-virtual")

enable_testing()
add_subdirectory(app)
add_subdirectory(lib)

feature_summary(WHAT ALL FATAL_ON_MISSING_REQUIRED_PACKAGES)
