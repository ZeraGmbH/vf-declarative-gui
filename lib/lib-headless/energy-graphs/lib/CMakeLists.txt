file(GLOB SOURCES
    ${CMAKE_CURRENT_SOURCE_DIR}/*.cpp
    )

file(GLOB HEADERS
    ${CMAKE_CURRENT_SOURCE_DIR}/*.h
    )

add_library(energy-graphs STATIC
    ${SOURCES}
    ${HEADERS}
)

target_link_libraries(energy-graphs
    PUBLIC
    ${QTX}::Core
    Zera::VfStorage
    Zera::VfConvenientCode
    ${QTX}::Charts
)

target_include_directories(energy-graphs
    PUBLIC
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/vf-declarative-gui/energy-graphs>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
)

set_target_properties(energy-graphs PROPERTIES VERSION ${PROJECT_VERSION})

#add_subdirectory(tests)
