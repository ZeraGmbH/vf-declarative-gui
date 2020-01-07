
# This file needs to be included from CMakeLists.txt in vf-declarative-gui
# It has no stand alone functions 

##3dPaerty includes
include_directories(${PROJECT_SOURCE_DIR}/3rdparty/qnanopainter/libqnanopainter)
include_directories(${PROJECT_SOURCE_DIR}/3rdparty/qnanopainter/libqnanopainter/data)
include_directories(${PROJECT_SOURCE_DIR}/3rdparty/qnanopainter/libqnanopainter/ext)
include_directories(${PROJECT_SOURCE_DIR}/3rdparty/qnanopainter/libqnanopainter/nanovg)
include_directories(${PROJECT_SOURCE_DIR}/3rdparty/qnanopainter/libqnanopainter/private)
include_directories(${PROJECT_SOURCE_DIR}/3rdparty/JsonSettingsQML)
include_directories(${PROJECT_SOURCE_DIR}/3rdparty/SortFilterProxyModel)

##qnanopainter

set(QNANO_HEADERS 
    ${PROJECT_SOURCE_DIR}/3rdparty/qnanopainter/libqnanopainter/private/qnanobrush.h 
    ${PROJECT_SOURCE_DIR}/3rdparty/qnanopainter/libqnanopainter/qnanopainter.h 
    ${PROJECT_SOURCE_DIR}/3rdparty/qnanopainter/libqnanopainter/qnanocolor.h 
    ${PROJECT_SOURCE_DIR}/3rdparty/qnanopainter/libqnanopainter/qnanolineargradient.h 
    ${PROJECT_SOURCE_DIR}/3rdparty/qnanopainter/libqnanopainter/qnanoimagepattern.h 
    ${PROJECT_SOURCE_DIR}/3rdparty/qnanopainter/libqnanopainter/qnanoimage.h 
    ${PROJECT_SOURCE_DIR}/3rdparty/qnanopainter/libqnanopainter/qnanofont.h 
    ${PROJECT_SOURCE_DIR}/3rdparty/qnanopainter/libqnanopainter/qnanoradialgradient.h 
    ${PROJECT_SOURCE_DIR}/3rdparty/qnanopainter/libqnanopainter/qnanoboxgradient.h 
    ${PROJECT_SOURCE_DIR}/3rdparty/qnanopainter/libqnanopainter/private/qnanodataelement.h 
    ${PROJECT_SOURCE_DIR}/3rdparty/qnanopainter/libqnanopainter/private/qnanobackend.h 
    ${PROJECT_SOURCE_DIR}/3rdparty/qnanopainter/libqnanopainter/private/qnanobackendfactory.h 
    ${PROJECT_SOURCE_DIR}/3rdparty/qnanopainter/libqnanopainter/qnanowindow.h 
    ${PROJECT_SOURCE_DIR}/3rdparty/qnanopainter/libqnanopainter/private/qnanodebug.h
    ${PROJECT_SOURCE_DIR}/3rdparty/qnanopainter/libqnanopainter/nanovg/nanovg.h
    ${PROJECT_SOURCE_DIR}/3rdparty/qnanopainter/libqnanopainter/qnanowidget.h
    ${PROJECT_SOURCE_DIR}/3rdparty/qnanopainter/libqnanopainter/qnanoquickitem.h 
    ${PROJECT_SOURCE_DIR}/3rdparty/qnanopainter/libqnanopainter/qnanoquickitempainter.h
    )

###Choose between openGL and GLES
if(${useGles})
    set(QNANO_HEADERS 
        ${QNANO_HEADERS} 
        ${PROJECT_SOURCE_DIR}/3rdparty/qnanopainter/libqnanopainter/private/qnanobackendgles2.h 
        ${PROJECT_SOURCE_DIR}/3rdparty/qnanopainter/libqnanopainter/private/qnanobackendgles3.h
        )
else()
    set(QNANO_HEADERS 
        ${QNANO_HEADERS} 
        ${PROJECT_SOURCE_DIR}/3rdparty/qnanopainter/libqnanopainter/private/qnanobackendgl2.h 
        ${PROJECT_SOURCE_DIR}/3rdparty/qnanopainter/libqnanopainter/private/qnanobackendgl3.h
        )
endif()


file(GLOB QNANO_SOURCES ${PROJECT_SOURCE_DIR}/3rdparty/qnanopainter/libqnanopainter/*.cpp)

set(QNANO_SOURCES 
    ${QNANO_SOURCES}
    ${PROJECT_SOURCE_DIR}/3rdparty/qnanopainter/libqnanopainter/private/qnanodebug.cpp
    ${PROJECT_SOURCE_DIR}/3rdparty/qnanopainter/libqnanopainter/nanovg/nanovg.c

    )
###Choose between openGL and GLES
if(${useGles})
    set(QNANO_SOURCES
        ${QNANO_SOURCES} 
        ${PROJECT_SOURCE_DIR}/3rdparty/qnanopainter/libqnanopainter/private/qnanobackendgles2.h 
        ${PROJECT_SOURCE_DIR}/3rdparty/qnanopainter/libqnanopainter/private/qnanobackendgles3.h
        )
else()
    set(QNANO_SOURCES
        ${QNANO_SOURCES} 
        ${PROJECT_SOURCE_DIR}/3rdparty/qnanopainter/libqnanopainter/private/qnanobackendgl2.cpp 
        ${PROJECT_SOURCE_DIR}/3rdparty/qnanopainter/libqnanopainter/private/qnanobackendgl3.cpp
        )
endif()

file(GLOB QNANO_RESOURCES
    ${PROJECT_SOURCE_DIR}/3rdparty/qnanopainter/libqnanopainter/*.qrc
    )
##JsonSettingsQML
file(GLOB JSONSET_HEADERS
    ${PROJECT_SOURCE_DIR}/3rdparty/JsonSettingsQML/*.h    	
    )

file(GLOB_RECURSE JSONSET_SOURCES
    ${PROJECT_SOURCE_DIR}/3rdparty/JsonSettingsQML/*.cpp
    )

file(GLOB JSONSET_RESOURCES

    )
##SortFilterProxyModel

file(GLOB SORTF_HEADERS
    ${PROJECT_SOURCE_DIR}/3rdparty/SortFilterProxyModel/*.h    	
    )

file(GLOB SORTF_SOURCES
    ${PROJECT_SOURCE_DIR}/3rdparty/SortFilterProxyModel/*.cpp
    )

file(GLOB SORTF_RESOURCES
    ${PROJECT_SOURCE_DIR}/3rdparty/SortFilterProxyModel/*.qrc
    )

# sum up 3rdParty sources
set(3RDPARTY_SOURCES   ${QNANO_SOURCES} ${JSONSET_SOURCES} ${SORTF_SOURCES})
set(3RDPARTY_HEADERS   ${QNANO_HEADERS} ${JSONSET_HEADERS} ${SORTF_HEADERS})
set(3RDPARTY_RESOURCES ${QNANO_RESOURCES} ${JSONSET_RESOURCES} ${SORTF_RESOURCES})


