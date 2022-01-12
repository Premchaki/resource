# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/parameter_python
    REF boost-1.78.0
    SHA512 137929b7e257ace791e4b8a27ea481db986d7e47d1e105369bd44dacf6886c8b04cf7f95cb2cbe640e58e50fa33dd16df95034bf56a021ea8aad6a02e171db05
    HEAD_REF master
)

include(${CURRENT_INSTALLED_DIR}/share/boost-vcpkg-helpers/boost-modular-headers.cmake)
boost_modular_headers(SOURCE_PATH ${SOURCE_PATH})
