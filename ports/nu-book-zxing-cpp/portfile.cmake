vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nu-book/zxing-cpp
    REF 50f53ef73f610788feaebd4159f8e4b32e6d38d8  #v1.3.0
    SHA512 3d7b1d2839d78042a4d217e4184af39907afdce2546673e2c47b17f54b75f2f1e953c16b63a5bc29a7e6c3590366bed3cfae760c21bf315ab00f39ad2e046f2b
    HEAD_REF master
)

if (VCPKG_TARGET_IS_UWP)
   set(ENV{CL} "$ENV{CL} -wd4996")
endif()
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_BLACKBOX_TESTS=OFF
        -DBUILD_EXAMPLES=OFF
        -DBUILD_SYSTEM_DEPS=ALWAYS
    MAYBE_UNUSED_VARIABLES
        # Currently no dependencies, but this defends against future additions
        BUILD_SYSTEM_DEPS
)

vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(
    CONFIG_PATH lib/cmake/ZXing
    PACKAGE_NAME ZXing
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/nu-book-zxing-cpp" RENAME copyright)
