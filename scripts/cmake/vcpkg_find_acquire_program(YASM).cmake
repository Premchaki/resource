set(program_name yasm)
set(program_version 1.3.0.6.g1962)
set(brew_package_name "yasm")
set(apt_package_name "yasm")
if(CMAKE_HOST_WIN32)
    set(download_urls "https://www.tortall.net/projects/yasm/snapshots/v${program_version}/yasm-${program_version}.exe")
    set(download_filename "yasm-${program_version}.exe")
    set(download_sha512 c1945669d983b632a10c5ff31e86d6ecbff143c3d8b2c433c0d3d18f84356d2b351f71ac05fd44e5403651b00c31db0d14615d7f9a6ecce5750438d37105c55b)
    set(tool_subdirectory 1.3.0.6)
    set(raw_executable ON)
    set(rename_binary_to "yasm.exe")
endif()
