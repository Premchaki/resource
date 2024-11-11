vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO winsoft666/zoe
    HEAD_REF master
    REF "v${VERSION}"
    SHA512 bb7c790223066092ddbd75d1dfcbec11819693065903c0bebc0bddefb64399c472491ee725006027fd6cb0c5a1f627c4275bbce197a7a92ec4c3421ff40f0191
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" ZOE_BUILD_SHARED_LIBS)
string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" ZOE_USE_STATIC_CRT)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DZOE_BUILD_SHARED_LIBS:BOOL=${ZOE_BUILD_SHARED_LIBS}
        -DZOE_USE_STATIC_CRT:BOOL=${ZOE_USE_STATIC_CRT}
        -DZOE_BUILD_TESTS:BOOL=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH share/zoe)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_copy_pdbs()
