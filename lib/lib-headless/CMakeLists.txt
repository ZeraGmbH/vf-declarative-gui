file(GLOB HEADERS
    *.h
    )

file(GLOB SOURCES
    *.cpp
    )

add_library(vf-declarative-gui-lib-headless STATIC
    ${SOURCES}
    ${HEADERS}
    )

target_include_directories(vf-declarative-gui-lib-headless
    PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
    )

target_link_libraries(vf-declarative-gui-lib-headless
    PUBLIC
    Qt5::Core
    VeinMeta::VfFiles
    simplecmdio-client
    )

set(SET_USB_STICK_PATH "/media/" CACHE STRING "Automount path")
add_definitions(-DUSB_STICK_PATH="${SET_USB_STICK_PATH}")
