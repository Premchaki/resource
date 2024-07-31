vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

# Required to run build/generate_escape_tables.py et al.
vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_DIR "${PYTHON3}" DIRECTORY)
vcpkg_add_to_path("${PYTHON3_DIR}")

vcpkg_download_distfile(FMT11_RANGE_PATCH
    URLS https://github.com/facebook/folly/commit/21e8dcd464ee46b2144a1e4d4c0e452355ae15f0.patch?full_index=1
    FILENAME fmt11-range.patch
    SHA512 6a3afe361cd24b4f62b3aba625dfbbfb767c91f27fa45ed4604adc5ec3d574e571ece13eeda0d9d47b8a37166fc31b1ed7f58f120a35d35977085a08172de105
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO facebook/folly
    REF "v${VERSION}"
    SHA512 f129d4e530b5c8aaf4cbfb0c813e84ee911ec26e43fa01e6e1c9557501c605a8123d46d0c689b32eb5e5a57280968662a5fa370ede17af7526db59545e9a70db
    HEAD_REF main
    PATCHES
        disable-non-underscore-posix-names.patch
        fix-windows-minmax.patch
        fix-deps.patch
        disable-uninitialized-resize-on-new-stl.patch
        fix-unistd-include.patch
        fix-fmt11-cmake.patch
        ${FMT11_RANGE_PATCH}
)

file(REMOVE "${SOURCE_PATH}/CMake/FindFmt.cmake")
file(REMOVE "${SOURCE_PATH}/CMake/FindLibsodium.cmake")
file(REMOVE "${SOURCE_PATH}/CMake/FindZstd.cmake")
file(REMOVE "${SOURCE_PATH}/CMake/FindSnappy.cmake")
file(REMOVE "${SOURCE_PATH}/CMake/FindLZ4.cmake")
file(REMOVE "${SOURCE_PATH}/build/fbcode_builder/CMake/FindDoubleConversion.cmake")
file(REMOVE "${SOURCE_PATH}/build/fbcode_builder/CMake/FindGMock.cmake")
file(REMOVE "${SOURCE_PATH}/build/fbcode_builder/CMake/FindGflags.cmake")
file(REMOVE "${SOURCE_PATH}/build/fbcode_builder/CMake/FindGlog.cmake")
file(REMOVE "${SOURCE_PATH}/build/fbcode_builder/CMake/FindLibEvent.cmake")
file(REMOVE "${SOURCE_PATH}/build/fbcode_builder/CMake/FindLibUnwind.cmake")
file(REMOVE "${SOURCE_PATH}/build/fbcode_builder/CMake/FindSodium.cmake")
file(REMOVE "${SOURCE_PATH}/build/fbcode_builder/CMake/FindZstd.cmake")

if(VCPKG_CRT_LINKAGE STREQUAL static)
    set(MSVC_USE_STATIC_RUNTIME ON)
else()
    set(MSVC_USE_STATIC_RUNTIME OFF)
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        "zlib"       CMAKE_REQUIRE_FIND_PACKAGE_ZLIB
        "liburing"   WITH_liburing
        "libaio"     WITH_libaio
    INVERTED_FEATURES
        "bzip2"      CMAKE_DISABLE_FIND_PACKAGE_BZip2
        "lzma"       CMAKE_DISABLE_FIND_PACKAGE_LibLZMA
        "lz4"        CMAKE_DISABLE_FIND_PACKAGE_LZ4
        "zstd"       CMAKE_DISABLE_FIND_PACKAGE_Zstd
        "snappy"     CMAKE_DISABLE_FIND_PACKAGE_Snappy
        "libsodium"  CMAKE_DISABLE_FIND_PACKAGE_unofficial-sodium
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DMSVC_USE_STATIC_RUNTIME=${MSVC_USE_STATIC_RUNTIME}
        -DCMAKE_DISABLE_FIND_PACKAGE_LibDwarf=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_Libiberty=ON
        -DCMAKE_INSTALL_DIR=share/folly
        ${FEATURE_OPTIONS}
    MAYBE_UNUSED_VARIABLES
        MSVC_USE_STATIC_RUNTIME
)

vcpkg_cmake_install(ADD_BIN_TO_PATH)

vcpkg_copy_pdbs()

configure_file("${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake" "${CURRENT_PACKAGES_DIR}/share/${PORT}/vcpkg-cmake-wrapper.cmake" @ONLY)

vcpkg_cmake_config_fixup()

# Release folly-targets.cmake does not link to the right libraries in debug mode.
# We substitute with generator expressions so that the right libraries are linked for debug and release.
set(FOLLY_TARGETS_CMAKE "${CURRENT_PACKAGES_DIR}/share/folly/folly-targets.cmake")
FILE(READ ${FOLLY_TARGETS_CMAKE} _contents)
string(REPLACE "\${VCPKG_IMPORT_PREFIX}/lib/zlib.lib" "ZLIB::ZLIB" _contents "${_contents}")
STRING(REPLACE "\${VCPKG_IMPORT_PREFIX}/lib/" "\${VCPKG_IMPORT_PREFIX}/\$<\$<CONFIG:DEBUG>:debug/>lib/" _contents "${_contents}")
STRING(REPLACE "\${VCPKG_IMPORT_PREFIX}/debug/lib/" "\${VCPKG_IMPORT_PREFIX}/\$<\$<CONFIG:DEBUG>:debug/>lib/" _contents "${_contents}")
string(REPLACE "-vc140-mt.lib" "-vc140-mt\$<\$<CONFIG:DEBUG>:-gd>.lib" _contents "${_contents}")
FILE(WRITE ${FOLLY_TARGETS_CMAKE} "${_contents}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

vcpkg_fixup_pkgconfig()
