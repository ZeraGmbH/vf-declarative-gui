
if("${QT_MAJOR_VER}" STREQUAL "6")
    qt6_add_resources(RESOURCES appdata.qrc)
else()
    if("${CMAKE_BUILD_TYPE}" STREQUAL "Debug")
        qt5_add_resources(RESOURCES appdata.qrc)
    else()
        qtquick_compiler_add_resources(RESOURCES appdata.qrc)
    endif()
endif()

add_executable(vf-declarative-gui
    ${RESOURCES}
    main.cpp
    )

target_include_directories(vf-declarative-gui
    PUBLIC
    ${QWT_INCLUDE_DIRS}
    )

target_link_libraries(vf-declarative-gui
    PRIVATE
    vf-declarative-gui-lib
    Zera::zera-json-settings
    )

target_compile_definitions(vf-declarative-gui PRIVATE $<$<CONFIG:Debug>:QT_QML_DEBUG>)

install(TARGETS vf-declarative-gui
    EXPORT vf-declarative-gui
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    )

