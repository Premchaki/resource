# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/math
    REF boost-${VERSION}
    SHA512 760b9c45ccf79209505cb028dbd70ae78c5d46f1b8bc422c453035ef50b438a13cfc9352b6efeb9ca5fa0b10f305bfa59f8aecc93fed080ef47ffd124eff2a78
    HEAD_REF master
    PATCHES
        build-old-libs.patch
        opt-random.diff
)

set(FEATURE_OPTIONS "")
boost_configure_and_install(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
)
