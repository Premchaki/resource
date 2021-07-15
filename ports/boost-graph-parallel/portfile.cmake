# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/graph_parallel
    REF boost-1.76.0
    SHA512 6328aa909cb611728e10cb23f666b68ce11d2a79130946e60da3ce664c5aa71da43e05269720455647f0b52f4b4d7e941ea1cfd1e203bf42a494a44f770185c2
    HEAD_REF master
)

include(${CURRENT_INSTALLED_DIR}/share/boost-vcpkg-helpers/boost-modular-headers.cmake)
boost_modular_headers(SOURCE_PATH ${SOURCE_PATH})
