add_executable(zera-json-qml-unittest
    unittest-cpp.cpp
    resources.qrc
)

target_link_libraries(zera-json-qml-unittest
    gtest
    gtest_main
    zera-json-qml
)
add_test(NAME    zera-json-qml-unittest
         COMMAND zera-json-qml-unittest)
