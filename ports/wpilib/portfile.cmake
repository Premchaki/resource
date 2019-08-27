include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO wpilibsuite/allwpilib
    REF 2bdb443255526015635f42b4152fefd17d0dc1ec
    SHA512 65fd2d9783993208c568d2618f288091173168af85a42c6a64287f91095160bf613a0b4592f628b21a82aff3337e38aa44dc710661a58b0b4d030209cb250d79
)

set(WITHOUT_JAVA ON)
set(WITHOUT_CSCORE ON)
set(WITHOUT_ALLWPILIB ON)

if ("cameraserver" IN_LIST FEATURES)
  set(WITHOUT_CSCORE OFF)
endif()

if ("allwpilib" IN_LIST FEATURES)
  set(WITHOUT_ALLWPILIB OFF)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA

    OPTIONS
      -DWITHOUT_JAVA=${WITHOUT_JAVA}
      -DWITHOUT_CSCORE=${WITHOUT_CSCORE}
      -DWITHOUT_ALLWPILIB=${WITHOUT_ALLWPILIB}
      -DUSE_VCPKG_LIBUV=ON
      -DUSE_VCPKG_EIGEN=ON
      -DFLAT_INSTALL_WPILIB=ON
)
vcpkg_install_cmake()

file(COPY ${CURRENT_PACKAGES_DIR}/wpilib/include/ntcore/ DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(COPY ${CURRENT_PACKAGES_DIR}/wpilib/include/wpiutil/ DESTINATION ${CURRENT_PACKAGES_DIR}/include)
if (NOT WITHOUT_ALLWPILIB)
file(COPY ${CURRENT_PACKAGES_DIR}/wpilib/include/wpilibc/ DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(COPY ${CURRENT_PACKAGES_DIR}/wpilib/include/hal/gen/ DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(COPY ${CURRENT_PACKAGES_DIR}/wpilib/include/hal/ DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/gen)
endif()
if (NOT WITHOUT_CSCORE)
file(COPY ${CURRENT_PACKAGES_DIR}/wpilib/include/cameraserver/ DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(COPY ${CURRENT_PACKAGES_DIR}/wpilib/include/cscore/ DESTINATION ${CURRENT_PACKAGES_DIR}/include)
endif()

if(NOT VCPKG_LIBRARY_LINKAGE STREQUAL "static")
  file(COPY ${CURRENT_PACKAGES_DIR}/wpilib/lib/ DESTINATION ${CURRENT_PACKAGES_DIR}/bin FILES_MATCHING PATTERN "*.dll")
  file(COPY ${CURRENT_PACKAGES_DIR}/debug/wpilib/lib/ DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin FILES_MATCHING PATTERN "*.dll")

  file(COPY ${CURRENT_PACKAGES_DIR}/wpilib/lib/ DESTINATION ${CURRENT_PACKAGES_DIR}/bin FILES_MATCHING PATTERN "*.so")
  file(COPY ${CURRENT_PACKAGES_DIR}/debug/wpilib/lib/ DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin FILES_MATCHING PATTERN "*.so")

  file(COPY ${CURRENT_PACKAGES_DIR}/wpilib/lib/ DESTINATION ${CURRENT_PACKAGES_DIR}/bin FILES_MATCHING PATTERN "*.dylib")
  file(COPY ${CURRENT_PACKAGES_DIR}/debug/wpilib/lib/ DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin FILES_MATCHING PATTERN "*.dylib")
endif()

file(COPY ${CURRENT_PACKAGES_DIR}/wpilib/lib/ DESTINATION ${CURRENT_PACKAGES_DIR}/lib FILES_MATCHING PATTERN "*.lib")
file(COPY ${CURRENT_PACKAGES_DIR}/debug/wpilib/lib/ DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib FILES_MATCHING PATTERN "*.lib")

file(COPY ${CURRENT_PACKAGES_DIR}/wpilib/lib/ DESTINATION ${CURRENT_PACKAGES_DIR}/lib FILES_MATCHING PATTERN "*.a")
file(COPY ${CURRENT_PACKAGES_DIR}/debug/wpilib/lib/ DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib FILES_MATCHING PATTERN "*.a")

vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/wpilib RENAME copyright)
