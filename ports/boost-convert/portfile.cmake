# Automatically generated by boost-vcpkg-helpers/generate-ports.ps1

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/convert
    REF boost-1.69.0
    SHA512 2461fd507ddefbae59f2357cc5627d52826555913660a4c58910f8562815d0d0e41e7ad169075404ed72fe215d93850775c30f4a0335dc282868dd51f7e0b9be
    HEAD_REF master
)

include(${CURRENT_INSTALLED_DIR}/share/boost-vcpkg-helpers/boost-modular-headers.cmake)
boost_modular_headers(SOURCE_PATH ${SOURCE_PATH})
