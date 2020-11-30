vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO sewenew/redis-plus-plus
    REF a9f9c301f8de1c181e6d45c573b5d1fe7b8200b1 # 1.2.1
    SHA512 038641a91a2d62f8b07b548fb16f03e87a014fc3a53e59d95e9d31d707e800de4922838bc1bc181d642bb6ac23eae877e0a8724548d9d8f113ebc8d744384abf
    HEAD_REF master
    PATCHES
        fix-ws2-linking-windows.patch
        fix-conversion.patch
)

if("cxx17" IN_LIST FEATURES)
    set(REDIS_PLUS_PLUS_CXX_STANDARD 17)
else()
    set(REDIS_PLUS_PLUS_CXX_STANDARD 11)
endif()


if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    set(REDIS_PLUS_PLUS_BUILD_STATIC ON)
    set(REDIS_PLUS_PLUS_BUILD_SHARED OFF)
else()
    set(REDIS_PLUS_PLUS_BUILD_STATIC OFF)
    set(REDIS_PLUS_PLUS_BUILD_SHARED ON)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS ${FEATURE_OPTIONS}
        -DREDIS_PLUS_PLUS_USE_TLS=OFF
        -DREDIS_PLUS_PLUS_BUILD_STATIC=${REDIS_PLUS_PLUS_BUILD_STATIC}
        -DREDIS_PLUS_PLUS_BUILD_SHARED=${REDIS_PLUS_PLUS_BUILD_SHARED}
        -DREDIS_PLUS_PLUS_BUILD_TEST=OFF
        -DREDIS_PLUS_PLUS_CXX_STANDARD=17
        -DREDIS_PLUS_PLUS_CXX_STANDARD=${REDIS_PLUS_PLUS_CXX_STANDARD}
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright )
