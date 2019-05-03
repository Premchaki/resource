# Automatically generated by boost-vcpkg-helpers/generate-ports.ps1

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/format
    REF boost-1.69.0
    SHA512 094cdc1dee2020b20c78f10b1478f820948ca31c0edb258c8fc38b21b8fcdee3648eba50d536805ca19536b83e54516160e43895e44ba5403f7e7c4b5dc75d90
    HEAD_REF master
)

include(${CURRENT_INSTALLED_DIR}/share/boost-vcpkg-helpers/boost-modular-headers.cmake)
boost_modular_headers(SOURCE_PATH ${SOURCE_PATH})
