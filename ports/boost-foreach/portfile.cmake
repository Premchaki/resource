# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/foreach
    REF boost-${VERSION}
    SHA512 af65753b4653f8f389aa305050b1aef102921985a138616b9ef90bb97b3bb6738ea5de9a70995b773b50dbca1f7299a377f6ac9fd2016b3542914d03b0d9ce57
    HEAD_REF master
)

set(FEATURE_OPTIONS "")
boost_configure_and_install(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
)
