if("${CMAKE_BUILD_TYPE}" STREQUAL "Debug")
    qt5_add_resources(RESOURCES appdata.qrc)
else()
    qtquick_compiler_add_resources(RESOURCES appdata.qrc)
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
    )

target_compile_definitions(vf-declarative-gui PRIVATE $<$<CONFIG:Debug>:QT_QML_DEBUG>)

install(TARGETS vf-declarative-gui
    EXPORT vf-declarative-gui
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    )

