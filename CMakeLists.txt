cmake_minimum_required(VERSION 3.1)

project(vf-declarative-gui LANGUAGES CXX C)
set(PROJECT_VERSION "0.0.1")

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)


#Options

option(useGles "Using GLES instead of openGL" OFF)


# cmake macros
include(FeatureSummary)

#Required Packages

##Qt5 libs
find_package(Qt5 "5.12.0" COMPONENTS Core Widgets Quick QuickControls2 CONFIG REQUIRED Qml COMPONENTS)

##QWT libs
find_package(PkgConfig REQUIRED)
pkg_check_modules(QWT REQUIRED Qt5Qwt6)


find_Package(VfEvent REQUIRED )
find_Package(VfComponent REQUIRED )
find_Package(VfNet2 REQUIRED ) 
find_Package(VfTcp REQUIRED )
find_Package(VfQml REQUIRED )
find_Package(VfHelpers REQUIRED )

##use GLES or openGL GLES does not support find_package()
if(${useGles})
    pkg_check_modules(GLES glesv2)
    message(WARNING "You are using GLES. GLES build is not tested yet")
else()
    find_package(OpenGL REQUIRED)
endif()


#Compiler Flags

##set build with openGL
if(${useGles})
    add_definitions(-DQNANO_QT_GL_INCLUDE)
    add_definitions(-DQT_OPENGL_ES_2)
else()
    add_definitions(-DQ_OS_LINUX)
    add_definitions(-DQT_OPENGL_3)
    add_definitions(-DQNANO_ENABLE_GLES3)
    add_definitions(-DQT_OPENGL_3_2)
endif()



##enable useful warnings
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -Wextra -Wparentheses -Wsuggest-attribute=const -Wformat -Wformat-security -Wdeprecated -Wcast-align -Woverloaded-virtual")

#Check for 3rdParty dependencies
##https://github.com/QUItCoding/qnanopainter
if(NOT EXISTS "${PROJECT_SOURCE_DIR}/3rdparty/qnanopainter/libqnanopainter/include.pri") 
    message(FATAL_ERROR "Dependency 3rdparty/libnanopainter not found")
endif()

##https://github.com/ZeraGmbH/JsonSettingsQML
if(NOT EXISTS "${PROJECT_SOURCE_DIR}/3rdparty/JsonSettingsQML/json-settings.pri") 
    message(FATAL_ERROR "Dependency 3rdparty/JsonSettingsQML not found")
endif()

##https://github.com/oKcerG/SortFilterProxyModel
if(NOT EXISTS "${PROJECT_SOURCE_DIR}/3rdparty/SortFilterProxyModel/SortFilterProxyModel.pri") 
    message(FATAL_ERROR "Dependency 3rdparty/SortFilterProxyModel not found")
endif()


# All sources by type

##Application
file(GLOB APP_HEADERS
    src/*.h
    )

file(GLOB_RECURSE APP_SOURCES
    src/*.cpp
    )

file(GLOB APP_RESOURCES
    *.qrc
    )

##include 3RDPARTY sources in seperate file
include(${PROJECT_SOURCE_DIR}/3rdparty/include3rdParty.cmake)


##Sum up all properties
set(SOURCES   ${APP_SOURCES} ${3RDPARTY_SOURCES}   )
set(HEADERS   ${APP_HEADERS} ${3RDPARTY_HEADERS}    )
set(RESOURCES ${APP_RESOURCES} ${3RDPARTY_RESOURCES})


# our application
add_executable(vf-declarative-gui
    ${SOURCES} ${HEADERS} ${RESOURCES}
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
    #Zera Libs
    VeinMeta::VfEvent
    VeinMeta::VfComponent
    VeinMeta::VfNet2
    VeinMeta::VfTcp
    VeinMeta::VfQml
    VeinMeta::VfHelpers
    #Other Libs
    ${QWT_LIBRARIES}
    ${glLib}
    )


install(TARGETS vf-declarative-gui
    EXPORT vf-declarative-gui
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    )

#Display feature summary
feature_summary(WHAT ALL FATAL_ON_MISSING_REQUIRED_PACKAGES)











