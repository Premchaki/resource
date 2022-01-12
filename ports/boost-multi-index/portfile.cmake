# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/multi_index
    REF boost-1.78.0
    SHA512 ea183d2e87d5d8655f96085ace78e8ee12678ae4603077773c658f6aa4d7bd86e1c120e0e0b6fef3b4fb42bf9ecbb79c4819c508eae4f5bf71c0ac6b50ec712a
    HEAD_REF master
)

include(${CURRENT_INSTALLED_DIR}/share/boost-vcpkg-helpers/boost-modular-headers.cmake)
boost_modular_headers(SOURCE_PATH ${SOURCE_PATH})
