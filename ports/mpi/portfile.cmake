set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

if (VCPKG_TARGET_IS_WINDOWS)
    file(INSTALL "${CURRENT_INSTALLED_DIR}/share/msmpi/vcpkg-cmake-wrapper.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
endif()
