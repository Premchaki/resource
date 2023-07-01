include_guard(GLOBAL)

function(boost_configure_and_install)
  cmake_parse_arguments(PARSE_ARGV 0 "arg" "" "SOURCE_PATH" "OPTIONS")

  string(REPLACE "-" "_" boost_lib_name "${PORT}")
  string(REPLACE "boost_" "" boost_lib_name "${boost_lib_name}")
  set(boost_lib_name_config "${boost_lib_name}")

  set(headers_only OFF)
  if(NOT EXISTS "${arg_SOURCE_PATH}/src"  OR "${PORT}" MATCHES "boost-(system|math|regex)")
    set(headers_only ON)
    set(VCPKG_BUILD_TYPE release)
  endif()

  set(boost_lib_path "libs/${boost_lib_name}")
  if(boost_lib_name MATCHES "numeric")
    string(REPLACE "numeric_" "numeric/" boost_lib_path "${boost_lib_path}")
    string(REPLACE "numeric_" "numeric/" boost_lib_name "${boost_lib_name}")
  endif()

  if(NOT EXISTS "${arg_SOURCE_PATH}/libs") # Check for --editable workflow
    set(target_path "${arg_SOURCE_PATH}/${boost_lib_path}")
    cmake_path(GET target_path PARENT_PATH parent_path)
    file(RENAME "${arg_SOURCE_PATH}/" "${arg_SOURCE_PATH}.tmp/")
    file(MAKE_DIRECTORY "${parent_path}")
    file(RENAME "${arg_SOURCE_PATH}.tmp/" "${target_path}")
  endif()

  file(WRITE "${arg_SOURCE_PATH}/CMakeLists.txt" " \
  cmake_minimum_required(VERSION 3.25) \n\
 \n\
  project(Boost VERSION ${VERSION} LANGUAGES CXX) \n\
 \n\
  set(BOOST_SUPERPROJECT_VERSION \${PROJECT_VERSION}) \n\
  set(BOOST_SUPERPROJECT_SOURCE_DIR \"\${PROJECT_SOURCE_DIR}\") \n\
 \n\
  list(APPEND CMAKE_MODULE_PATH \"${CURRENT_INSTALLED_DIR}/share/boost/cmake-build\") \n\
 \n\
  include(BoostRoot) \n\
  ")

  if("${PORT}" MATCHES "boost-(mpi|graph_parallel|property_map_parallel)")
    list(APPEND arg_OPTIONS -DBOOST_ENABLE_MPI=ON)
  endif()

  if("${PORT}" MATCHES "boost-(python|parameter_python)")
    list(APPEND arg_OPTIONS -DBOOST_ENABLE_PYTHON=ON)
  endif()

  vcpkg_cmake_configure(
    SOURCE_PATH "${arg_SOURCE_PATH}"
    OPTIONS
      -DBOOST_INCLUDE_LIBRARIES=${boost_lib_name}
      #-DBOOST_ENABLE_PYTHON=ON
      #"-DBOOST_INSTALL_CMAKEDIR=lib/cmake"
      -DBOOST_RUNTIME_LINK=${VCPKG_CRT_LINKAGE}
      "-DBOOST_INSTALL_INCLUDE_SUBDIR="
      ${arg_OPTIONS}
  )

  vcpkg_cmake_install()

  file(GLOB cmake_paths "${CURRENT_PACKAGES_DIR}/lib/cmake/*" LIST_DIRECTORIES true)
  file(GLOB cmake_files "${CURRENT_PACKAGES_DIR}/lib/cmake/*" LIST_DIRECTORIES false)
  list(REMOVE_ITEM cmake_paths "${cmake_files}" "${CURRENT_PACKAGES_DIR}/lib/cmake/boost_${boost_lib_name_config}-${VERSION}")
  foreach(config_path IN LISTS cmake_paths)
    string(REPLACE "-${VERSION}" "" config_path "${config_path}")
    string(REPLACE "${CURRENT_PACKAGES_DIR}/lib/cmake/" "" config_name "${config_path}")
    vcpkg_cmake_config_fixup(PACKAGE_NAME ${config_name} CONFIG_PATH lib/cmake/${config_name}-${VERSION} DO_NOT_DELETE_PARENT_CONFIG_PATH)
  endforeach()
  vcpkg_cmake_config_fixup(PACKAGE_NAME boost_${boost_lib_name_config} CONFIG_PATH lib/cmake/boost_${boost_lib_name_config}-${VERSION})

  if(headers_only) # TODO fix boost-system
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib" "${CURRENT_PACKAGES_DIR}/debug/lib")
  endif()
  file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share"
                      "${CURRENT_PACKAGES_DIR}/debug/include"
      )
  if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    #file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin" "${CURRENT_PACKAGES_DIR}/bin")
  endif()
  vcpkg_install_copyright(FILE_LIST "${CURRENT_INSTALLED_DIR}/share/boost-cmake/copyright")
  

endfunction()