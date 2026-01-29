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
        Zera::zera-modulemanager-testlib
        Zera::xml-compare-testlib
        energygraphs-testlib
    )
    endforeach()
endfunction()

SETUP_TESTS(
    test_axisautoscaler
    test_recorder_caching
    test_scaling
    test_draw_charts
)

target_sources(test_draw_charts
  PRIVATE
  test-data/testdata.qrc
)

target_sources(test_recorder_caching
    PRIVATE
    test-data/testdata.qrc
)
