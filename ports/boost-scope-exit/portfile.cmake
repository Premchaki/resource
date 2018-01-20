# Automatically generated by boost-vcpkg-helpers/generate-ports.ps1

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/scope_exit
    REF boost-1.66.0
    SHA512 cb46dee821cf9f873eac9d8e937773a44c9e77b7c9972d064e1cc7b9f95e8b06509da29e2357c479f70993aae25756de1dad5d6639690f4390d466deef75b8da
    HEAD_REF master
)

include(${CURRENT_INSTALLED_DIR}/share/boost-vcpkg-helpers/boost-modular-headers.cmake)
boost_modular_headers(SOURCE_PATH ${SOURCE_PATH})
