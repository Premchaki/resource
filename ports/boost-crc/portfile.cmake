# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/crc
    REF boost-1.80.0
    SHA512 9365b348dba52436d717c329634b58a9731b22b289714a3618bad9a4ea6967b8170ec289c4528762cd3cf74ae768a3756ce3d876ea8297b65f941d5560080a1b
    HEAD_REF master
)

include(${CURRENT_INSTALLED_DIR}/share/boost-vcpkg-helpers/boost-modular-headers.cmake)
boost_modular_headers(SOURCE_PATH ${SOURCE_PATH})
