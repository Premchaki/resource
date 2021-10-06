vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO fallahn/tmxlite
    REF v1.3.0
    HEAD_REF master
    SHA512 3D432152080F7FDDD14A150FF87C34932695C96D7F676399C7610FF373972223CE54C9483BD9A872FD53668C113E334FCBF8596AE21CFDAF83B6159C7287A4A3
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/tmxlite"
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(INSTALL "${SOURCE_PATH}/readme.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)