include_guard(GLOBAL)

set(Z_VCPKG_CMAKE_GET_VARS_CURRENT_LIST_DIR "${CMAKE_CURRENT_LIST_DIR}" CACHE INTERNAL "")

function(vcpkg_cmake_get_vars out_file)
    cmake_parse_arguments(PARSE_ARGV 1 arg "" "" "")

    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION} was passed extra arguments: ${arg_UNPARSED_ARGUMENTS}")
    endif()

    if(NOT DEFINED CACHE{Z_VCPKG_CMAKE_GET_VARS_FILE})
        set(Z_VCPKG_CMAKE_GET_VARS_FILE "${CURRENT_BUILDTREES_DIR}/cmake-get-vars-${TARGET_TRIPLET}.cmake.log"
            CACHE PATH "The file to include to access the CMake variables from a generated project.")

            # Add debug messages to track paths and configuration
            message(STATUS "Generating vars files for triplet: ${TARGET_TRIPLET}")
            message(STATUS "Output log file: ${Z_VCPKG_CMAKE_GET_VARS_FILE}")
        
            vcpkg_cmake_configure(
            SOURCE_PATH "${Z_VCPKG_CMAKE_GET_VARS_CURRENT_LIST_DIR}/cmake_get_vars"
            OPTIONS_DEBUG "-DVCPKG_OUTPUT_FILE:PATH=${CURRENT_BUILDTREES_DIR}/cmake-get-vars-${TARGET_TRIPLET}-dbg.cmake.log"
            OPTIONS_RELEASE "-DVCPKG_OUTPUT_FILE:PATH=${CURRENT_BUILDTREES_DIR}/cmake-get-vars-${TARGET_TRIPLET}-rel.cmake.log"
            LOGFILE_BASE cmake-get-vars-${TARGET_TRIPLET}
            Z_CMAKE_GET_VARS_USAGE # be quiet, don't set variables...
        )

        set(include_string "")
        if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
            string(APPEND include_string "include(\"\${CMAKE_CURRENT_LIST_DIR}/cmake-get-vars-${TARGET_TRIPLET}-rel.cmake.log\")\n")
        endif()
        if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
            string(APPEND include_string "include(\"\${CMAKE_CURRENT_LIST_DIR}/cmake-get-vars-${TARGET_TRIPLET}-dbg.cmake.log\")\n")
        endif()
        file(WRITE "${Z_VCPKG_CMAKE_GET_VARS_FILE}" "${include_string}")
         # Debugging the content of the central include file
         message(STATUS "Generated include file content:\n${include_string}")
    endif()

    set("${out_file}" "${Z_VCPKG_CMAKE_GET_VARS_FILE}" PARENT_SCOPE)
endfunction()
