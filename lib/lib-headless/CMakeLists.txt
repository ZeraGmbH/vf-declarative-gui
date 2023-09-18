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
    )

