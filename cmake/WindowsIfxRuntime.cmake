# Repository overlay: validated native MSVC/ifx DLL-runtime ABI.
if(NOT WIN32 OR NOT MSVC OR NOT CMAKE_Fortran_COMPILER_ID MATCHES "IntelLLVM")
  message(FATAL_ERROR "WindowsIfxRuntime requires native Windows MSVC and ifx")
endif()
get_filename_component(_ifx_bin "${CMAKE_Fortran_COMPILER}" DIRECTORY)
get_filename_component(_ifx_prefix "${_ifx_bin}" DIRECTORY)
set(PW_IFX_RUNTIME_LIBRARIES)
foreach(_name libifcoremd libifportmd libmmd svml_dispmd)
  find_library(PW_${_name} NAMES ${_name} PATHS "${_ifx_prefix}/lib" NO_DEFAULT_PATH REQUIRED)
  list(APPEND PW_IFX_RUNTIME_LIBRARIES "${PW_${_name}}")
endforeach()
try_compile(PW_IFX_CXX_LINK_OK
  "${CMAKE_BINARY_DIR}/ifx-runtime-check"
  "${PW_WINDOWS_OVERLAY_DIR}/tests/ifx-runtime"
  windows_ifx_runtime ifx-runtime
  CMAKE_FLAGS
    "-DCMAKE_CXX_COMPILER:FILEPATH=${CMAKE_CXX_COMPILER}"
    "-DCMAKE_Fortran_COMPILER:FILEPATH=${CMAKE_Fortran_COMPILER}"
    "-DPW_IFX_RUNTIME_LIBRARIES:STRING=${PW_IFX_RUNTIME_LIBRARIES}"
  OUTPUT_VARIABLE _ifx_link_log)
file(WRITE "${CMAKE_BINARY_DIR}/ifx-runtime-link.log" "${_ifx_link_log}")
if(NOT PW_IFX_CXX_LINK_OK)
  message(FATAL_ERROR "MSVC/ifx explicit runtime link failed; see ifx-runtime-link.log")
endif()
message(STATUS "MSVC/ifx explicit runtime link passed: ${PW_IFX_RUNTIME_LIBRARIES}")
