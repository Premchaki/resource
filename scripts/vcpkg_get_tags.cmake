macro(z_vcpkg_select_build_type)
    if(DEFINED ENV{VCPKG_BUILD_TYPE})
        if(NOT "$ENV{VCPKG_BUILD_TYPE}" STREQUAL "release")
            # Cf. https://github.com/microsoft/vcpkg/pull/16110
            message(FATAL_ERROR "The only supported value for VCPKG_BUILD_TYPE is 'release'.")
        endif()
        set(VCPKG_BUILD_TYPE "$ENV{VCPKG_BUILD_TYPE}")
        if(NOT "VCPKG_BUILD_TYPE" IN_LIST VCPKG_ENV_PASSTHROUGH)
            # This is for tracking, not for usage by ports.
            list(APPEND VCPKG_ENV_PASSTHROUGH "VCPKG_BUILD_TYPE")
        endif()
    endif()
endmacro()
function(vcpkg_get_tags PORT FEATURES VCPKG_TRIPLET_ID VCPKG_ABI_SETTINGS_FILE)
    z_vcpkg_select_build_type()
    message("d8187afd-ea4a-4fc3-9aa4-a6782e1ed9af")
    vcpkg_triplet_file(${VCPKG_TRIPLET_ID})

    # GUID used as a flag - "cut here line"
    message("c35112b6-d1ba-415b-aa5d-81de856ef8eb
VCPKG_TARGET_ARCHITECTURE=${VCPKG_TARGET_ARCHITECTURE}
VCPKG_CMAKE_SYSTEM_NAME=${VCPKG_CMAKE_SYSTEM_NAME}
VCPKG_CMAKE_SYSTEM_VERSION=${VCPKG_CMAKE_SYSTEM_VERSION}
VCPKG_PLATFORM_TOOLSET=${VCPKG_PLATFORM_TOOLSET}
VCPKG_VISUAL_STUDIO_PATH=${VCPKG_VISUAL_STUDIO_PATH}
VCPKG_CHAINLOAD_TOOLCHAIN_FILE=${VCPKG_CHAINLOAD_TOOLCHAIN_FILE}
VCPKG_BUILD_TYPE=${VCPKG_BUILD_TYPE}
VCPKG_LIBRARY_LINKAGE=${VCPKG_LIBRARY_LINKAGE}
e1e74b5c-18cb-4474-a6bd-5c1c8bc81f3f")

    # Just to enforce the user didn't set it in the triplet file
    if (DEFINED VCPKG_PUBLIC_ABI_OVERRIDE)
        set(VCPKG_PUBLIC_ABI_OVERRIDE)
        message(WARNING "VCPKG_PUBLIC_ABI_OVERRIDE set in the triplet will be ignored.")
    endif()
    include("${VCPKG_ABI_SETTINGS_FILE}" OPTIONAL)

    message("c35112b6-d1ba-415b-aa5d-81de856ef8eb
VCPKG_PUBLIC_ABI_OVERRIDE=${VCPKG_PUBLIC_ABI_OVERRIDE}
VCPKG_ENV_PASSTHROUGH=${VCPKG_ENV_PASSTHROUGH}
VCPKG_ENV_PASSTHROUGH_UNTRACKED=${VCPKG_ENV_PASSTHROUGH_UNTRACKED}
VCPKG_LOAD_VCVARS_ENV=${VCPKG_LOAD_VCVARS_ENV}
e1e74b5c-18cb-4474-a6bd-5c1c8bc81f3f
8c504940-be29-4cba-9f8f-6cd83e9d87b7")
endfunction()
