file(GLOB SOURCES
    ${CMAKE_CURRENT_SOURCE_DIR}/*.cpp
    )

file(GLOB HEADER
    ${CMAKE_CURRENT_SOURCE_DIR}/*.h
    )

add_library(energygraphs-testlib STATIC
    ${SOURCES}
    ${HEADER}
    )

target_link_libraries(energygraphs-testlib
    PUBLIC
    ${QTX}::Test
    energy-graphs
    )

target_include_directories(energygraphs-testlib
    PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
    )
