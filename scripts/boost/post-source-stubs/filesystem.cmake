file(READ "${SOURCE_PATH}/build/Jamfile.v2" _contents)
string(REPLACE "import config : requires" "import ../config/checks/config : requires" _contents "${_contents}")
file(WRITE "${SOURCE_PATH}/build/Jamfile.v2" "${_contents}")
file(COPY "${CURRENT_INSTALLED_DIR}/share/boost-config/checks" DESTINATION "${SOURCE_PATH}/config")