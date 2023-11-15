string(REPLACE "." "_" VERSION_STR "V${VERSION}")
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Open-Cascade-SAS/OCCT
    REF "${VERSION_STR}"
    SHA512 d9e882d44bb65616f8cfce68ebdcd5765669b84e3d82cfb2d1bc22b71b0e878442c079bacc37e9d54f28ce98a7c23bf81f2a3e3e7bbeeec38927ca739f423dee
    HEAD_REF master
    PATCHES
        dont-install-scripts.patch
        drop-bin-letter-d.patch
        fix-pdb-find.patch
        fix-install-prefix-path.patch
        install-include-dir.patch
        fix-depend-freetype.patch
        fix-depend-vtk.patch
        fix-dependence.patch
        fix-find-tbb.patch
)

if (VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    set(BUILD_TYPE "Shared")
else()
    set(BUILD_TYPE "Static")
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        "freeimage"  USE_FREEIMAGE
        "tbb"        USE_TBB
        "rapidjson"  USE_RAPIDJSON
        "samples"    INSTALL_SAMPLES
        "vtk"        USE_VTK
)

# We turn off BUILD_MODULE_Draw as it requires TCL 8.6 and TK 8.6 specifically which conflicts with vcpkg only having TCL 9.0 
# And pre-built ActiveTCL binaries are behind a marketing wall :(
# We use the Unix install layout for Windows as it matches vcpkg
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DBUILD_LIBRARY_TYPE=${BUILD_TYPE}
        -DBUILD_MODULE_Draw=OFF
        -DINSTALL_DIR_LAYOUT=Unix
        -DBUILD_SAMPLES_MFC=OFF
        -DBUILD_SAMPLES_QT=OFF
        -DBUILD_DOC_Overview=OFF
        -DINSTALL_TEST_CASES=OFF
        -DBUILD_MODULE_DETools=OFF
    OPTIONS_DEBUG
        -DINSTALL_SAMPLES=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/opencascade)

#make occt includes relative to source_file
list(APPEND ADDITIONAL_HEADERS 
      "ExprIntrp.tab.h"
      "FlexLexer.h"
      "glext.h"
      "igesread.h"
      "NCollection_Haft.h"
      "OSD_PerfMeter.h"
      "Standard_values.h"
    )

file(GLOB files "${CURRENT_PACKAGES_DIR}/include/opencascade/[a-zA-Z0-9_]*\.[hgl]xx")
foreach(file_name IN LISTS files)
    file(READ "${file_name}" filedata)
    string(REGEX REPLACE "# *include \<([a-zA-Z0-9_]*\.[hgl]xx)\>" "#include \"\\1\"" filedata "${filedata}")
    foreach(extra_header IN LISTS ADDITIONAL_HEADERS)
        string(REGEX REPLACE "# *include \<${extra_header}\>" "#include \"${extra_header}\"" filedata "${filedata}")
    endforeach()
    file(WRITE "${file_name}" "${filedata}")
endforeach()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/opencascade/samples/qt")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/OCCT_LGPL_EXCEPTION.txt")
