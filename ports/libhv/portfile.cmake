vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ithewei/libhv
    REF 8d14d1a6cd4accbda9e081716a59395b523303f6 #v1.2.6
    SHA512 d40063f2b2f8191965fd4434b80a17f505819a20fd63aefa63c08663d0acc82d086338f0382ab70289dff0417a8ec922f993d36c4007a1a13c7ce34d71018f83
    HEAD_REF master
    PATCHES
        fix-include_header.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        ssl WITH_OPENSSL
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DBUILD_EXAMPLES=OFF
        -DBUILD_UNITTEST=OFF
        -DBUILD_STATIC=${BUILD_STATIC}
        -DBUILD_SHARED=${BUILD_SHARED}
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/libhv)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

if(EXISTS "${CURRENT_PACKAGES_DIR}/lib/hv.dll")
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/bin")
    file(RENAME "${CURRENT_PACKAGES_DIR}/lib/hv.dll" "${CURRENT_PACKAGES_DIR}/bin/hv.dll")
endif()

if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/lib/hv.dll")
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/bin")
    file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/hv.dll" "${CURRENT_PACKAGES_DIR}/debug/bin/hv.dll")
endif()
