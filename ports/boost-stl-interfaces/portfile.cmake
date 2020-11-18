# Automatically generated by boost-vcpkg-helpers/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/stl_interfaces
    REF boost-1.74.0
    SHA512 8d6b0f0fe0b16cc79d52dd899cf8973c8abeb9d1087110c3bade797021ff10420c2d0d959b9442bce7499f0f028d690ef5e5a70300607950d025df8e9ab637a4
    HEAD_REF master
)

include(${CURRENT_INSTALLED_DIR}/share/boost-vcpkg-helpers/boost-modular-headers.cmake)
boost_modular_headers(SOURCE_PATH ${SOURCE_PATH})
