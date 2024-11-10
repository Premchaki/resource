vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tomwillow/tomsolver
    REF "${VERSION}"
    SHA512 520546a9d1c800551a84410e43b567803ede0c00ee96016d509834237b8a7300e1b2a2382af1f6a5e5f3c5c0d3bb04c61c7d547b78c1432b86444692c122908a
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_EXAMPLES=OFF
        -DBUILD_TESTS=OFF

)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${CURRENT_PORT_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
