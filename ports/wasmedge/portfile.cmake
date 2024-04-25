vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO WasmEdge/WasmEdge
    REF "${VERSION}"
    SHA512 fcd6b804876a5899ec8c21aa349b7ec3e8e0b87537e93d237cb14da2ecb162410ae9ad39212c5ab01e4408191768b806d84e55934616de094a696bf6f02fe1de
    HEAD_REF master
)

set(WASMEDGE_CMAKE_OPTIONS "-DFETCHCONTENT_FULLY_DISCONNECTED=ON")

list(APPEND WASMEDGE_CMAKE_OPTIONS "-DWASMEDGE_BUILD_AOT_RUNTIME=OFF")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    list(APPEND WASMEDGE_CMAKE_OPTIONS "-DWASMEDGE_BUILD_STATIC_LIB=OFF")
    list(APPEND WASMEDGE_CMAKE_OPTIONS "-DWASMEDGE_BUILD_SHARED_LIB=ON")
    list(APPEND WASMEDGE_CMAKE_OPTIONS "-DWASMEDGE_LINK_LLVM_STATIC=OFF")
    list(APPEND WASMEDGE_CMAKE_OPTIONS "-DWASMEDGE_LINK_TOOLS_STATIC=OFF")
else()
    list(APPEND WASMEDGE_CMAKE_OPTIONS "-DWASMEDGE_BUILD_STATIC_LIB=ON")
    list(APPEND WASMEDGE_CMAKE_OPTIONS "-DWASMEDGE_BUILD_SHARED_LIB=OFF")
    list(APPEND WASMEDGE_CMAKE_OPTIONS "-DWASMEDGE_LINK_LLVM_STATIC=ON")
    list(APPEND WASMEDGE_CMAKE_OPTIONS "-DWASMEDGE_LINK_TOOLS_STATIC=ON")
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
  FEATURES
    tools WASMEDGE_BUILD_TOOLS
    aot WASMEDGE_BUILD_AOT_RUNTIME
    plugins WASMEDGE_BUILD_PLUGINS
)

# disabled due to build failure
list(APPEND WASMEDGE_CMAKE_OPTIONS "-DWASMEDGE_BUILD_EXAMPLE=OFF")

set(WASMEDGE_PLUGIN_WASI_NN_BACKEND "")

if("plugin-wasi-nn-backend-openvino" IN_LIST FEATURES)
    list(APPEND WASMEDGE_PLUGIN_WASI_NN_BACKEND "OpenVINO")
endif()
if("plugin-wasi-nn-backend-pytorch" IN_LIST FEATURES)
    list(APPEND WASMEDGE_PLUGIN_WASI_NN_BACKEND "PyTorch")
endif()
if("plugin-wasi-nn-backend-tensorflow-lite" IN_LIST FEATURES)
    list(APPEND WASMEDGE_PLUGIN_WASI_NN_BACKEND "TensorflowLite")
endif()

if(NOT WASMEDGE_PLUGIN_WASI_NN_BACKEND STREQUAL "")
    list(JOIN WASMEDGE_PLUGIN_WASI_NN_BACKEND "," WASMEDGE_PLUGIN_WASI_NN_BACKEND)
    list(APPEND WASMEDGE_CMAKE_OPTIONS "-WASMEDGE_PLUGIN_WASI_NN_BACKEND=${WASMEDGE_PLUGIN_WASI_NN_BACKEND}")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${WASMEDGE_CMAKE_OPTIONS}
        ${FEATURE_OPTIONS}
    OPTIONS_RELEASE
        -DCMAKE_INSTALL_BINDIR=${CURRENT_PACKAGES_DIR}/tools
    OPTIONS_DEBUG
        -DCMAKE_INSTALL_BINDIR=${CURRENT_PACKAGES_DIR}/debug/tools
)

vcpkg_cmake_install()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
