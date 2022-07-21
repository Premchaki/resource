vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mysql/mysql-connector-cpp
    REF 1.1.13
    SHA512 76cf3d8c9dbaa006ccbb3c672538c540167c7a9cf3406a371313dc346598b119515f25fea2a786bb8cab12d96fd607b69f320a6d897aaeeb668eff831920fb5f
    HEAD_REF master
    PATCHES
        fix-static-build.patch
)

file(COPY
    "${CMAKE_CURRENT_LIST_DIR}/mysql-connector-cpp-config.cmake.in"
    "${CMAKE_CURRENT_LIST_DIR}/FindMySQL.cmake"
    DESTINATION "${SOURCE_PATH}"
)

set(CONFIGURE_OPTS)
set(OPTIONS)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" STATIC_ONLY)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" DYNAMIC_ONLY)
if(VCPKG_TARGET_IS_WINDOWS)
    set(CONFIGURE_OPTS WINDOWS_USE_MSBUILD)
    string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" STATIC_CRT)
    list(APPEND OPTIONS -DSTATIC_CRT=${STATIC_CRT})
else()
    list(APPEND OPTIONS -DENABLE_BUILD_DYNAMIC=${DYNAMIC_ONLY})
    list(APPEND OPTIONS -DENABLE_BUILD_STATIC=${STATIC_ONLY})
endif()
list(APPEND OPTIONS -DSTATIC_ONLY=${STATIC_ONLY} -DDYNAMIC_ONLY=${DYNAMIC_ONLY})
list(APPEND OPTIONS -DMYSQLCLIENT_STATIC_LINKING=${STATIC_ONLY})

# Use mysql-connector-cpp's own build process, skipping examples and tests.
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    ${CONFIGURE_OPTS}
    OPTIONS
        -DMYSQLCPPCONN_BUILD_EXAMPLES:BOOL=OFF
        -DMYSQLCPPCONN_BUILD_TESTS:BOOL=OFF
        ${OPTIONS}
    MAYBE_UNUSED_VARIABLES
        STATIC_CRT
        MYSQLCLIENT_STATIC_LINKING
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-mysql-connector-cpp)
file(INSTALL "${CURRENT_PORT_DIR}/vcpkg-cmake-wrapper.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${CURRENT_PORT_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

file(REMOVE "${CURRENT_PACKAGES_DIR}/BUILDINFO"
    "${CURRENT_PACKAGES_DIR}/LICENSE"
    "${CURRENT_PACKAGES_DIR}/README"
    "${CURRENT_PACKAGES_DIR}/debug/BUILDINFO"
    "${CURRENT_PACKAGES_DIR}/debug/LICENSE"
    "${CURRENT_PACKAGES_DIR}/debug/README"
)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_copy_pdbs()

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
