file(GLOB SOURCES
    ${CMAKE_CURRENT_SOURCE_DIR}/*.cpp
    )

file(GLOB HEADERS
    ${CMAKE_CURRENT_SOURCE_DIR}/*.h
    )

add_library(recorder-caching STATIC
    ${SOURCES}
    ${HEADERS}
)

target_link_libraries(recorder-caching
    PUBLIC
    ${QTX}::Core
)

target_include_directories(recorder-caching
    PUBLIC
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/vf-declarative-gui/recorder-caching>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
)

set_target_properties(recorder-caching PROPERTIES VERSION ${PROJECT_VERSION})

#add_subdirectory(tests)
