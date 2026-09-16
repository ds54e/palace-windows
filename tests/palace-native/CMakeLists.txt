find_package(Catch2 3 REQUIRED)
add_executable(windows-port-tests main.cpp
  ${CMAKE_SOURCE_DIR}/../test/unit/test-memoryreporting.cpp
  ${CMAKE_SOURCE_DIR}/../test/unit/test-tablecsv.cpp)
target_link_libraries(windows-port-tests PRIVATE Catch2::Catch2 libpalace)
target_compile_definitions(windows-port-tests PRIVATE
  "PALACE_TEST_DATA_DIR=\"${CMAKE_SOURCE_DIR}/../test/data\"")
