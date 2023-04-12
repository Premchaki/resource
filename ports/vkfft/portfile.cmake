# header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO DTolm/VkFFT
    REF e1c58868a9581725dd595975daf780da0a37dad1 #v1.2.31
    SHA512 b113f0117336ef2f6a285166cb4d68ea372e0dbb46025b7fcbae30f4f5147ad0fb1f7abfd91e1a73e2b4d72446c16ac0e90efc467785e035f176e81d95979706
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/vkFFT/" DESTINATION "${CURRENT_PACKAGES_DIR}/include/VkFFT")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
