# Automatically generated by boost-vcpkg-helpers/generate-ports.ps1

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/test
    REF boost-1.69.0
    SHA512 3a265dc888d749ec1aa5cd13889963b19705d7dbe4092941d8943d3f84a82fc67cee9c3e49cecd9769229b9adea1f09b45a7f4a494cca73cf894a402487ea621
    HEAD_REF master
)

file(READ "${SOURCE_PATH}/build/Jamfile.v2" _contents)
string(REPLACE "import ../../predef/check/predef" "import predef/check/predef" _contents "${_contents}")
file(WRITE "${SOURCE_PATH}/build/Jamfile.v2" "${_contents}")
file(COPY "${CURRENT_INSTALLED_DIR}/share/boost-predef/check" DESTINATION "${SOURCE_PATH}/build/predef")

include(${CURRENT_INSTALLED_DIR}/share/boost-build/boost-modular-build.cmake)
boost_modular_build(SOURCE_PATH ${SOURCE_PATH})
include(${CURRENT_INSTALLED_DIR}/share/boost-vcpkg-helpers/boost-modular-headers.cmake)
boost_modular_headers(SOURCE_PATH ${SOURCE_PATH})
if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/lib/manual-link)
    file(GLOB MONITOR_LIBS ${CURRENT_PACKAGES_DIR}/lib/*_exec_monitor*)
    file(COPY ${MONITOR_LIBS} DESTINATION ${CURRENT_PACKAGES_DIR}/lib/manual-link)
    file(REMOVE ${MONITOR_LIBS})
endif()

if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/lib/manual-link)
    file(GLOB DEBUG_MONITOR_LIBS ${CURRENT_PACKAGES_DIR}/debug/lib/*_exec_monitor*)
    file(COPY ${DEBUG_MONITOR_LIBS} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib/manual-link)
    file(REMOVE ${DEBUG_MONITOR_LIBS})
endif()

