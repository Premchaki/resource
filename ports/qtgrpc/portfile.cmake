set(SCRIPT_PATH "${CURRENT_INSTALLED_DIR}/share/qtbase")
include("${SCRIPT_PATH}/qt_install_submodule.cmake")

set(${PORT}_PATCHES)
set(TOOL_NAMES qtprotobufgen)
# native_grpc ->grpc WrapgRPC
# grp -> qt[network]
# qtprotobufgen -> protobuf WrapProtobuf
qt_install_submodule(PATCHES    ${${PORT}_PATCHES}
                     TOOL_NAMES ${TOOL_NAMES}
                     CONFIGURE_OPTIONS_MAYBE_UNUSED
                         QT_BUILD_EXAMPLES
                         QT_USE_DEFAULT_CMAKE_OPTIMIZATION_FLAGS
                    )
