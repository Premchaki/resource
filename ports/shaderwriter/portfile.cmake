
vcpkg_from_github(OUT_SOURCE_PATH SOURCE_PATH
    REPO DragonJoker/ShaderWriter
    REF e978c96c959e8aa41eedaef322dcc6a0ec00ad49
    HEAD_REF master
    SHA512 4f1ea1fd97392edc2b3dd9b6453fa395772e75a52f28d7bbd5a63d2fe8eca40c8a0d4016e2017e126f22fc03acf28ab29db6de037d64c7687f95884b8435b7c7
)

vcpkg_from_github(OUT_SOURCE_PATH CMAKE_SOURCE_PATH
    REPO DragonJoker/CMakeUtils
    REF 6b76e6873afe33baeb59c233d3a70bd391f01769
    HEAD_REF master
    SHA512 d7834cf8eeff12575acc526d9dc39471ededad1ff25bec0b85e27a36381157f797c1eb168983410a40b60c001b52b787baea498aef80ffa08c9b7d9a9f5eb7ae
)

get_filename_component(SRC_PATH ${CMAKE_SOURCE_PATH} DIRECTORY)
if (EXISTS ${SRC_PATH}/CMake)
    file(REMOVE_RECURSE ${SRC_PATH}/CMake)
endif()
file(RENAME ${CMAKE_SOURCE_PATH} ${SRC_PATH}/CMake)
set(CMAKE_SOURCE_PATH ${SRC_PATH}/CMake)
file(COPY ${CMAKE_SOURCE_PATH} DESTINATION ${SOURCE_PATH})

if (VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    vcpkg_configure_cmake(
        SOURCE_PATH ${SOURCE_PATH}
        PREFER_NINJA
        OPTIONS
            -DCMAKE_INSTALL_PREFIX=${CURRENT_INSTALLED_DIR}
            -DPROJECTS_USE_PRECOMPILED_HEADERS=OFF
            -DSDW_GENERATE_SOURCE=OFF
            -DSDW_BUILD_TESTS=OFF
            -DSDW_BUILD_STATIC_SDW=OFF
            -DSDW_BUILD_EXPORTER_GLSL_STATIC=OFF
            -DSDW_BUILD_EXPORTER_HLSL_STATIC=OFF
            -DSDW_BUILD_EXPORTER_SPIRV_STATIC=OFF
    )
else ()
    vcpkg_configure_cmake(
        SOURCE_PATH ${SOURCE_PATH}
        PREFER_NINJA
        OPTIONS
            -DCMAKE_INSTALL_PREFIX=${CURRENT_INSTALLED_DIR}
            -DPROJECTS_USE_PRECOMPILED_HEADERS=OFF
            -DSDW_GENERATE_SOURCE=OFF
            -DSDW_BUILD_TESTS=OFF
            -DSDW_BUILD_STATIC_SDW=ON
            -DSDW_BUILD_EXPORTER_GLSL_STATIC=ON
            -DSDW_BUILD_EXPORTER_HLSL_STATIC=ON
            -DSDW_BUILD_EXPORTER_SPIRV_STATIC=ON
    )
endif ()
vcpkg_install_cmake()
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/shaderwriter RENAME copyright)
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/shaderwriter)
