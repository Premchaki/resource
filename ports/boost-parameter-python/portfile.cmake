# Automatically generated by boost-vcpkg-helpers/generate-ports.ps1

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/parameter_python
    REF boost-1.72.0
    SHA512 3d230ca500169fffb6c18b491bf94bf8091b56458621149710157e0386c2c6e01571c52170e4226bf6e86f2c8bf7f587da51b7e79f69a7653e0846e8dfdcc2fe
    HEAD_REF master
)

include(${CURRENT_INSTALLED_DIR}/share/boost-vcpkg-helpers/boost-modular-headers.cmake)
boost_modular_headers(SOURCE_PATH ${SOURCE_PATH})
