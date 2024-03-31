vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

# Required to run build/generate_escape_tables.py et al.
vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_DIR "${PYTHON3}" DIRECTORY)
vcpkg_add_to_path("${PYTHON3_DIR}")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO facebook/folly
    REF "v${VERSION}"
    SHA512 c563aa64efa3098235db5f6354cdbc96d829f8bfc24e24464e0cae65279d00f1bba722c7060c2e76c89723ef66ef94225a02d6fb65e24fa6125adb619fc1d74b
    HEAD_REF main
    PATCHES
        reorder-glog-gflags.patch
        disable-non-underscore-posix-names.patch
        boost-1.70.patch
        fix-windows-minmax.patch
        fix-deps.patch
        openssl.patch # from https://github.com/facebook/folly/pull/2016
        disable-uninitialized-resize-on-new-stl.patch
        fix-unistd-include.patch
)

file(REMOVE "${SOURCE_PATH}/CMake/FindFmt.cmake")
file(REMOVE "${SOURCE_PATH}/CMake/FindLibsodium.cmake")
file(REMOVE "${SOURCE_PATH}/CMake/FindZstd.cmake")
file(REMOVE "${SOURCE_PATH}/CMake/FindSnappy.cmake")
file(REMOVE "${SOURCE_PATH}/CMake/FindLZ4.cmake")
file(REMOVE "${SOURCE_PATH}/CMake/FindLibUring.cmake")
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
        -DCMAKE_DISABLE_FIND_PACKAGE_LibAIO=ON
        -DPKG_CONFIG_USE_CMAKE_PREFIX_PATH=ON
        -DLIBAIO_FOUND=OFF
        -DCMAKE_INSTALL_DIR=share/folly
        ${FEATURE_OPTIONS}
    MAYBE_UNUSED_VARIABLES
        LIBAIO_FOUND
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
