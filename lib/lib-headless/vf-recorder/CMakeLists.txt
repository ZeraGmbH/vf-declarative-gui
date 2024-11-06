file(GLOB SOURCES
    ${CMAKE_CURRENT_SOURCE_DIR}/*.cpp
    )

file(GLOB HEADERS
    ${CMAKE_CURRENT_SOURCE_DIR}/*.h
    )

add_library(vf-recorder SHARED
    ${SOURCES}
    ${HEADERS}
)

target_link_libraries(vf-recorder
    PUBLIC
    Zera::VfCpp
    Zera::VfStorage
)

target_include_directories(vf-recorder
    PUBLIC
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/vf-declarative-gui/vf-recorder>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
    )

set_target_properties(vf-recorder PROPERTIES VERSION ${PROJECT_VERSION})

add_subdirectory(tests)
