# Inspired by
# https://github.com/KDAB/kdabtv/blob/master/Qt-Widgets-and-more/UnitTests/Tests/CMakeLists.txt
function(SETUP_TESTS)
    foreach(_testname ${ARGN})
        add_test(NAME ${_testname}
            COMMAND ${_testname})
        add_executable(${_testname}
            ${_testname}.h
            ${_testname}.cpp
        )
    target_link_libraries(${_testname}
        PUBLIC
        ${QTX}::Test
        vf-declarative-gui-lib-headless
    )
endforeach()
endfunction()

SETUP_TESTS(
    test_rowautoscaler
    test_updatewrapper
    test_axisautoscaler
    )

target_sources(test_updatewrapper
    PRIVATE
    test-data/testdata.qrc
)
