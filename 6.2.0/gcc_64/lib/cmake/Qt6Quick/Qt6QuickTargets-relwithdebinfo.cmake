#----------------------------------------------------------------
# Generated CMake target import file for configuration "RelWithDebInfo".
#----------------------------------------------------------------

# Commands may need to know the format version.
set(CMAKE_IMPORT_FILE_VERSION 1)

# Import target "Qt6::Quick" for configuration "RelWithDebInfo"
set_property(TARGET Qt6::Quick APPEND PROPERTY IMPORTED_CONFIGURATIONS RELWITHDEBINFO)
set_target_properties(Qt6::Quick PROPERTIES
  IMPORTED_LOCATION_RELWITHDEBINFO "${_IMPORT_PREFIX}/lib/libQt6Quick.so.6.2.0"
  IMPORTED_SONAME_RELWITHDEBINFO "libQt6Quick.so.6"
  )

list(APPEND _IMPORT_CHECK_TARGETS Qt6::Quick )
list(APPEND _IMPORT_CHECK_FILES_FOR_Qt6::Quick "${_IMPORT_PREFIX}/lib/libQt6Quick.so.6.2.0" )

# Commands beyond this point should not need to know the version.
set(CMAKE_IMPORT_FILE_VERSION)
