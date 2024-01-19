vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO LunarG/VulkanTools
    REF "vulkan-sdk-${VERSION}"
    SHA512 fcaa25375caad32800dbf015672bb9cb23ad90469fc63a259e43789bbe82e460d94f0d8e87f8bc4b624974dc2511af19e04da763483aea1cf34e6f78818b2383
    HEAD_REF main
)

vcpkg_replace_string("${SOURCE_PATH}/via/CMakeLists.txt" "jsoncpp_static" "JsonCpp::JsonCpp")

x_vcpkg_get_python_packages(PYTHON_VERSION "3" PACKAGES jsonschema OUT_PYTHON_VAR PYTHON3)
get_filename_component(PYTHON3_DIR "${PYTHON3}" DIRECTORY)
vcpkg_add_to_path("${PYTHON3_DIR}")

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
    -DVULKAN_HEADERS_INSTALL_DIR=${CURRENT_INSTALLED_DIR}
    -DBUILD_TESTS:BOOL=OFF
  OPTIONS_RELEASE
    -DVULKAN_LOADER_INSTALL_DIR=${CURRENT_INSTALLED_DIR}
  OPTIONS_DEBUG
    -DVULKAN_LOADER_INSTALL_DIR=${CURRENT_INSTALLED_DIR}/debug

)
vcpkg_cmake_install()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")

vcpkg_copy_tools(TOOL_NAMES vkvia vkconfig AUTO_CLEAN )

if(VCPKG_TARGET_IS_WINDOWS)
  file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
endif()

set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

