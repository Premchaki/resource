vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ubarsc/kealib
    REF  de6dabd414039dd36a1ff01243901cec3f45256e #1.4.11
    SHA512 34032dd27aee0714cbe6b76b2f731a05408fd5ff78080343bcfbc3aa7e6eeb06a341a423cee1e7f3624f4c1f661feaf4ea3a3d2e53172933e49982df0c438a6f
    HEAD_REF master
    PATCHES hdf5_include.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DLIBKEA_WITH_GDAL=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin" "${CURRENT_PACKAGES_DIR}/bin")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
