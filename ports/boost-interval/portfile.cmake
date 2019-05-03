# Automatically generated by boost-vcpkg-helpers/generate-ports.ps1

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/interval
    REF boost-1.69.0
    SHA512 203e19a3c87fa50b22fe0c194f7774fc7dcf7ed7cd21add4bad8cdd1251783a7b173e1100cf33397d69aa3636a4dc4f2341f4a7dd8ac8c7c7f0781e9d48e1001
    HEAD_REF master
)

include(${CURRENT_INSTALLED_DIR}/share/boost-vcpkg-helpers/boost-modular-headers.cmake)
boost_modular_headers(SOURCE_PATH ${SOURCE_PATH})
