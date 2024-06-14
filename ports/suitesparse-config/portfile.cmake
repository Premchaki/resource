vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO DrTimothyAldenDavis/SuiteSparse
    REF v7.7.0
    SHA512 aa62dae81ae423ce7162ae83b46e5cf606d95482e6c6bb7ae6d61e15987761119d9418ef3a96648e6ba2327871a2847eef8ace197aa375279d71c80329d6f451
    HEAD_REF dev
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC_LIBS)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
  FEATURES
  openmp SUITESPARSE_USE_OPENMP
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/SuiteSparse_config"
    OPTIONS
        -DBUILD_STATIC_LIBS=${BUILD_STATIC_LIBS}
        -DSUITESPARSE_USE_CUDA=OFF  # not applicable here, skip check
        -DSUITESPARSE_USE_STRICT=ON  # don't allow implicit dependencies
        -DSUITESPARSE_USE_FORTRAN=OFF  # use Fortran sources translated to C instead
        -DSUITESPARSE_DEMOS=OFF
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

# Move SuiteSparseBLAS.cmake, SuiteSparsePolicy.cmake etc files
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/share/cmake")
file(RENAME "${CURRENT_PACKAGES_DIR}/lib/cmake/SuiteSparse" "${CURRENT_PACKAGES_DIR}/share/SuiteSparse")

vcpkg_cmake_config_fixup(
  PACKAGE_NAME SuiteSparse_config
  CONFIG_PATH lib/cmake/SuiteSparse_config
)
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
