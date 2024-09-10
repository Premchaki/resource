vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO JoshuaSledden/Jigson
  REF "v${VERSION}"
  SHA512 c2efa21603e3b9d06fe67a4dc5dabb43341baf3609022a03fba3178d2eef7407d2511987c98a91495c9671e42166c641f313d479be55a243dc474fc392d5411e
)

file(GLOB HEADER_FILES "${SOURCE_PATH}/*.hpp" "${SOURCE_PATH}/*.h")
file(INSTALL ${HEADER_FILES} DESTINATION "${CURRENT_PACKAGES_DIR}/include/jigson")

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" COPYONLY)
