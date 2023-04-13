vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO blend2d/blend2d
  REF 7b420376ed32f3979f860d8c3be04128ab5c6690
  SHA512 88818bfe18b0638b02f84277a4584ddf2cee2158540c1794c3a96c12891274472dc896bef94408baf9ec398e30549c0b3feda58e4b7bf3014a0cf436f394a3ed
  HEAD_REF master
  PATCHES
    fix-depend-asmjit.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BLEND2D_STATIC)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
  INVERTED_FEATURES
    futex      BLEND2D_NO_FUTEX
    jit        BLEND2D_NO_JIT
    tls        BLEND2D_NO_TLS
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DBLEND2D_STATIC=${BLEND2D_STATIC}"
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")

if("jit" IN_LIST FEATURES)
  vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/${PORT}/blend2d-config.cmake"
"# Generated by CMake"
[[# Generated by CMake
include(CMakeFindDependencyMacro)
find_dependency(asmjit CONFIG)]])
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
if(BLEND2D_STATIC)
  file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")

if(BLEND2D_STATIC)
  file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage_static.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME usage)
else()
  file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
endif()
