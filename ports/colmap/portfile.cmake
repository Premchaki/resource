set(COLMAP_REF "1f1ea00533241f16a936f6bac014d16520568b8e") # Aug 18, 2023

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO colmap/colmap
    REF "${COLMAP_REF}"
    SHA512 437f82cde0697ea5748f0b944707458903c2ddd4620703d759d8d73d33b8eb09001bc1c50c0d2354607714dc4bfd0457223850ece973e74ebf612a80fd116c14
    HEAD_REF main
)

if (NOT TRIPLET_SYSTEM_ARCH STREQUAL "x64" AND ("cuda" IN_LIST FEATURES OR "cuda-redist" IN_LIST FEATURES))
    message(FATAL_ERROR "Feature cuda and cuda-redist require x64 triplet.")
endif()

# set GIT_COMMIT_ID and GIT_COMMIT_DATE
if(DEFINED VCPKG_HEAD_VERSION)
    set(GIT_COMMIT_ID "${VCPKG_HEAD_VERSION}")
else()
    set(GIT_COMMIT_ID "${COLMAP_REF}")
endif()

string(TIMESTAMP COLMAP_GIT_COMMIT_DATE "%Y-%m-%d")

set(CUDA_ENABLED OFF)
set(TESTS_ENABLED OFF)

if("cuda" IN_LIST FEATURES)
    set(CUDA_ENABLED ON)
    set(CUDA_ARCHITECTURES "native")
endif()

if("cuda-redist" IN_LIST FEATURES)
    set(CUDA_ENABLED ON)
    set(CUDA_ARCHITECTURES "all-major")
endif()

if("tests" IN_LIST FEATURES)
    set(TESTS_ENABLED ON)
endif()

set(OPENMP_ENABLED ON)
if (VCPKG_TARGET_IS_OSX AND VCPKG_TARGET_ARCHITECTURE MATCHES "arm")
    set(OPENMP_ENABLED Off)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DCUDA_ENABLED=${CUDA_ENABLED}
        -DCMAKE_CUDA_ARCHITECTURES=${CUDA_ARCHITECTURES}
        -DTESTS_ENABLED=${TESTS_ENABLED}
        -DGIT_COMMIT_ID=${GIT_COMMIT_ID}
        -DGIT_COMMIT_DATE=${COLMAP_GIT_COMMIT_DATE}
        -DOPENMP_ENABLED=${OPENMP_ENABLED}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup()

file(GLOB TOOL_FILENAMES "${CURRENT_PACKAGES_DIR}/bin/*")
foreach(TOOL_FILENAME ${TOOL_FILENAMES})
    get_filename_component(TEST_TOOL_NAME ${TOOL_FILENAME} NAME_WLE)
    list(APPEND COLMAP_TOOL_NAMES "${TEST_TOOL_NAME}")
endforeach()

vcpkg_copy_tools(TOOL_NAMES ${COLMAP_TOOL_NAMES} AUTO_CLEAN)

# remove empty folders and unused files
file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/include/colmap/exe"
    "${CURRENT_PACKAGES_DIR}/include/colmap/lib/Graclus/multilevelLib"
    "${CURRENT_PACKAGES_DIR}/include/colmap/tools"
    "${CURRENT_PACKAGES_DIR}/include/colmap/ui/media"
    "${CURRENT_PACKAGES_DIR}/include/colmap/ui/shaders"
    "${CURRENT_PACKAGES_DIR}/COLMAP.bat"
    "${CURRENT_PACKAGES_DIR}/RUN_TESTS.bat"
    "${CURRENT_PACKAGES_DIR}/debug/COLMAP.bat"
    "${CURRENT_PACKAGES_DIR}/debug/RUN_TESTS.bat"
    "${CURRENT_PACKAGES_DIR}/debug/bin"
)

vcpkg_copy_pdbs()

file(INSTALL "${SOURCE_PATH}/COPYING.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
