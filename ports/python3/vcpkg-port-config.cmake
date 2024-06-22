include_guard(GLOBAL)
set(PYTHON3_VERSION "@VERSION@")
set(PYTHON3_VERSION_MAJOR "@PYTHON_VERSION_MAJOR@")
set(PYTHON3_VERSION_MINOR "@PYTHON_VERSION_MINOR@")
set(PYTHON3_INCLUDE "include/python${PYTHON3_VERSION_MAJOR}.${PYTHON3_VERSION_MINOR}")
set(PYTHON3_HAS_EXTENSIONS "@PYTHON_HAS_EXTENSIONS@")
set(site_base "")
if(VCPKG_TARGET_IS_WINDOWS)
  set(site_base "tools/python${PYTHON3_VERSION_MAJOR}/Lib")
else()
  set(site_base "lib/python${PYTHON3_VERSION_MAJOR}.${PYTHON3_VERSION_MINOR}")
endif()
set(PYTHON3_SITE "${site_base}/site-packages")

include("${CURRENT_HOST_INSTALLED_DIR}/share/vcpkg-get-python/vcpkg-port-config.cmake")
include("${CURRENT_HOST_INSTALLED_DIR}/share/vcpkg-python-test-import/vcpkg-port-config.cmake")
