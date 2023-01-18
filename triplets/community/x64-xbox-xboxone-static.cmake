set(VCPKG_TARGET_ARCHITECTURE x64)
set(VCPKG_CRT_LINKAGE dynamic)
set(VCPKG_LIBRARY_LINKAGE static)
set(VCPKG_ENV_PASSTHROUGH PATH)
set(VCPKG_CMAKE_SYSTEM_VERSION 10.0)
set(VCPKG_C_FLAGS "/DWINAPI_FAMILY=WINAPI_FAMILY_GAMES /D_WIN32_WINNT=0x0A00 /D_GAMING_XBOX /D_GAMING_XBOX_XBOXONE /favor:AMD64 /arch:AVX")
set(VCPKG_CXX_FLAGS ${VCPKG_C_FLAGS})
