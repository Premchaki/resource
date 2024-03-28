vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO AcademySoftwareFoundation/openfx
    REF OFX_Release_1_4_TAG
    SHA512 b20512ea38823167f191b72f1592548df85fbda6cefe47673972874c139641ee91277e78c1e0d57a457b9f864385e6fa0e4a7edcdbf0c7b2eda956c03a3e1e13
    HEAD_REF main
)

file(COPY_FILE ${CMAKE_CURRENT_LIST_DIR}/Openfx.cmake ${SOURCE_PATH}/CMakeLists.txt)
file(COPY_FILE ${CMAKE_CURRENT_LIST_DIR}/Support.cmake ${SOURCE_PATH}/Support/CMakeLists.txt)

vcpkg_cmake_configure(SOURCE_PATH ${SOURCE_PATH})
vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(
    PACKAGE_NAME openfx
    CONFIG_PATH lib/cmake/unofficial-openfx
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/DocSrc")

configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" COPYONLY)
file(INSTALL "${SOURCE_PATH}/Support/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/openfx" RENAME copyright)
