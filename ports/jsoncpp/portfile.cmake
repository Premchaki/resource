vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO open-source-parsers/jsoncpp
    REF 9059f5cad030ba11d37818847443a53918c327b1 # 1.9.4
    SHA512 8062c83cad9dc453f1eb4886e63e054570e0f29dcd6594330d3b3628ba994915e26e08690cd28118805a766be200ac99ad4fbc131db3af895122a8d1bd87ef31
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" JSONCPP_STATIC)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS 
        -DJSONCPP_WITH_CMAKE_PACKAGE=ON
        -DBUILD_STATIC_LIBS=${JSONCPP_STATIC}
        -DJSONCPP_WITH_PKGCONFIG_SUPPORT=OFF
        -DJSONCPP_WITH_POST_BUILD_UNITTEST=OFF
        -DJSONCPP_WITH_TESTS=OFF
        -DJSONCPP_WITH_EXAMPLE=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/jsoncpp)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
