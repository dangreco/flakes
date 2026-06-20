cmake_minimum_required(VERSION 3.20)
project(project C)

set(CMAKE_C_STANDARD 23)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON) # -> build/compile_commands.json for clangd

# Library: every .c under src/ except the entrypoint, auto-discovered.
file(GLOB_RECURSE LIB_SOURCES CONFIGURE_DEPENDS src/*.c)
list(FILTER LIB_SOURCES EXCLUDE REGEX ".*/main\\.c$")
add_library(project_lib ${LIB_SOURCES})
target_include_directories(project_lib PUBLIC include)
target_compile_options(project_lib PRIVATE -Wall -Wextra)

# Executable.
add_executable(project src/main.c)
target_link_libraries(project PRIVATE project_lib)
target_compile_options(project PRIVATE -Wall -Wextra)

# Tests: every .c under tests/ becomes a CTest entry, auto-discovered.
include(CTest)
if(BUILD_TESTING)
  find_package(PkgConfig REQUIRED)
  pkg_check_modules(CRITERION REQUIRED IMPORTED_TARGET criterion)

  file(GLOB TEST_SOURCES CONFIGURE_DEPENDS tests/*.c)
  foreach(test_file ${TEST_SOURCES})
    get_filename_component(test_name ${test_file} NAME_WE)
    add_executable(${test_name} ${test_file})
    target_link_libraries(${test_name} PRIVATE project_lib PkgConfig::CRITERION)
    add_test(NAME ${test_name} COMMAND ${test_name})
  endforeach()
endif()
