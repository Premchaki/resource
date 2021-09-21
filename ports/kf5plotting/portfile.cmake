vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/kplotting
    REF v5.84.0
    SHA512 4007e90bc2505cfcfb14d5b40d922cf72ffcc6898da3ffed5ce5493484fe36c1f0f697f2b8319a7fd95909aada489d57be7a8dceb66b2cbba2746ed4aa93e5a5
    HEAD_REF master
)

# Prevent KDEClangFormat from writing to source effectively blocking parallel configure
file(WRITE ${SOURCE_PATH}/.clang-format "DisableFormat: true\nSortIncludes: false\n")

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_TESTING=OFF
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/KF5Plotting)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
if (NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
  file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/plugins ${CURRENT_PACKAGES_DIR}/debug/plugins)
endif()
file(RENAME ${CURRENT_PACKAGES_DIR}/lib/plugins ${CURRENT_PACKAGES_DIR}/plugins)

file(INSTALL ${SOURCE_PATH}/LICENSES/ DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright)
