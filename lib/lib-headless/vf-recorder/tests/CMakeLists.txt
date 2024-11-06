function(SETUP_QTESTS_BASE)
    SETUP_TESTS(${ARGN})
    foreach(_testname ${ARGN})
        target_link_libraries(${_testname}
            PUBLIC
            vf-recorder
            Zera::VfFrameworkTest
            )
    endforeach()
endfunction()

SETUP_QTESTS_BASE(
    test_vf_recorder
    test_vein_data_collector
)

target_sources(test_vf_recorder
  PRIVATE
  test-data/test-data.qrc
)
