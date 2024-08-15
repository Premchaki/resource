vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Exiv2/exiv2
    REF "v${VERSION}"
    SHA512 c8338a118feefa104d73932890c732247c884ab9ce1d170c43a22ab5884517a0e2a7fd1febde7705b8290fbbbc29e64738610404816e4db2b56a70fc444ca049
    HEAD_REF master
    PATCHES
        #fix-expat.patch
        #fix-inih.patch
        #fix-brotli.patch
        dependencies.diff
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        xmp     EXIV2_ENABLE_XMP
        png     EXIV2_ENABLE_PNG
        nls     EXIV2_ENABLE_NLS
        bmff    EXIV2_ENABLE_BMFF
)
if(VCPKG_TARGET_IS_UWP)
    list(APPEND FEATURE_OPTIONS -DEXIV2_ENABLE_FILESYSTEM_ACCESS=OFF)
endif()

string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "dynamic" EXIV2_CRT_DYNAMIC)

vcpkg_add_to_path(PREPEND "${CURRENT_HOST_INSTALLED_DIR}/tools/gettext/bin")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DEXIV2_BUILD_EXIV2_COMMAND=OFF
        -DEXIV2_BUILD_UNIT_TESTS=OFF
        -DEXIV2_BUILD_SAMPLES=OFF
        -DEXIV2_BUILD_DOC=OFF
        -DEXIV2_ENABLE_EXTERNAL_XMP=OFF
        -DEXIV2_ENABLE_LENSDATA=ON
        -DEXIV2_ENABLE_DYNAMIC_RUNTIME=${EXIV2_CRT_DYNAMIC}
        -DEXIV2_ENABLE_WEBREADY=OFF
        -DEXIV2_ENABLE_CURL=OFF
        -DEXIV2_ENABLE_VIDEO=OFF
        -DEXIV2_TEAM_EXTRA_WARNINGS=OFF
        -DEXIV2_TEAM_WARNINGS_AS_ERRORS=OFF
        -DEXIV2_TEAM_PACKAGING=OFF
        -DEXIV2_TEAM_USE_SANITIZERS=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_Python3=ON
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/exiv2)
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/share/man"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
