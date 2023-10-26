vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO soasis/text
  REF 3ead0683985b48be123040592f85c13a4aec5044 
  SHA512 a72415f3c724a7e378634a85a5d4d2ec2d7c434312616acb9a319a160be705e51bf527a124e10d9a4bdf6c9a0ba7bfacae2af0710cd67be6b876cdcdcd1e3514
  HEAD_REF main
  PATCHES fix-cmake-install.patch
)

set(VCPKG_BUILD_TYPE release) # header-only

vcpkg_cmake_configure(
  SOURCE_PATH ${SOURCE_PATH}
)

vcpkg_cmake_install()

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
