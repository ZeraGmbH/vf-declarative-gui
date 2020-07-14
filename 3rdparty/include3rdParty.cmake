
# This file needs to be included from CMakeLists.txt in vf-declarative-gui
# It has no stand alone functions 

##3dPaerty includes
include_directories(${PROJECT_SOURCE_DIR}/3rdparty/qnanopainter/libqnanopainter)
include_directories(${PROJECT_SOURCE_DIR}/3rdparty/qnanopainter/libqnanopainter/data)
include_directories(${PROJECT_SOURCE_DIR}/3rdparty/qnanopainter/libqnanopainter/ext)
include_directories(${PROJECT_SOURCE_DIR}/3rdparty/qnanopainter/libqnanopainter/nanovg)
include_directories(${PROJECT_SOURCE_DIR}/3rdparty/qnanopainter/libqnanopainter/private)
include_directories(${PROJECT_SOURCE_DIR}/3rdparty/JsonSettingsQML)

##JsonSettingsQML
file(GLOB JSONSET_HEADERS
    ${PROJECT_SOURCE_DIR}/3rdparty/JsonSettingsQML/*.h    	
    )

file(GLOB_RECURSE JSONSET_SOURCES
    ${PROJECT_SOURCE_DIR}/3rdparty/JsonSettingsQML/*.cpp
    )

file(GLOB JSONSET_RESOURCES

    )

# sum up 3rdParty sources
set(3RDPARTY_SOURCES   ${QNANO_SOURCES} ${JSONSET_SOURCES} ${SORTF_SOURCES})
set(3RDPARTY_HEADERS   ${QNANO_HEADERS} ${JSONSET_HEADERS} ${SORTF_HEADERS})
set(3RDPARTY_RESOURCES ${QNANO_RESOURCES} ${JSONSET_RESOURCES} ${SORTF_RESOURCES})


