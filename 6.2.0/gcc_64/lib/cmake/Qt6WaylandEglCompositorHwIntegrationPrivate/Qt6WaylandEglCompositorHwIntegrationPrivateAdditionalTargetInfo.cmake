# Additional target information for Qt6WaylandEglCompositorHwIntegrationPrivate
if(NOT DEFINED QT_DEFAULT_IMPORT_CONFIGURATION)
    set(QT_DEFAULT_IMPORT_CONFIGURATION RELWITHDEBINFO)
endif()
__qt_internal_promote_target_to_global_checked(Qt6::WaylandEglCompositorHwIntegrationPrivate)
get_target_property(_qt_imported_location Qt6::WaylandEglCompositorHwIntegrationPrivate IMPORTED_LOCATION_RELWITHDEBINFO)
get_target_property(_qt_imported_soname Qt6::WaylandEglCompositorHwIntegrationPrivate IMPORTED_SONAME_RELWITHDEBINFO)
get_target_property(_qt_imported_location_default Qt6::WaylandEglCompositorHwIntegrationPrivate IMPORTED_LOCATION_${QT_DEFAULT_IMPORT_CONFIGURATION})
get_target_property(_qt_imported_soname_default Qt6::WaylandEglCompositorHwIntegrationPrivate IMPORTED_SONAME_${QT_DEFAULT_IMPORT_CONFIGURATION})

# Import target "Qt6::WaylandEglCompositorHwIntegrationPrivate" for configuration "Release"
set_property(TARGET Qt6::WaylandEglCompositorHwIntegrationPrivate APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)

if(_qt_imported_location)
    set_property(TARGET Qt6::WaylandEglCompositorHwIntegrationPrivate PROPERTY IMPORTED_LOCATION_RELEASE "${_qt_imported_location}")
endif()
if(_qt_imported_soname)
    set_property(TARGET Qt6::WaylandEglCompositorHwIntegrationPrivate PROPERTY IMPORTED_SONAME_RELEASE "${_qt_imported_soname}")
endif()

# Import target "Qt6::WaylandEglCompositorHwIntegrationPrivate" for configuration "MinSizeRel"
set_property(TARGET Qt6::WaylandEglCompositorHwIntegrationPrivate APPEND PROPERTY IMPORTED_CONFIGURATIONS MINSIZEREL)

if(_qt_imported_location)
    set_property(TARGET Qt6::WaylandEglCompositorHwIntegrationPrivate PROPERTY IMPORTED_LOCATION_MINSIZEREL "${_qt_imported_location}")
endif()
if(_qt_imported_soname)
    set_property(TARGET Qt6::WaylandEglCompositorHwIntegrationPrivate PROPERTY IMPORTED_SONAME_MINSIZEREL "${_qt_imported_soname}")
endif()

# Default configuration
if(_qt_imported_location_default)
    set_property(TARGET Qt6::WaylandEglCompositorHwIntegrationPrivate PROPERTY IMPORTED_LOCATION "${_qt_imported_location_default}")
endif()
if(_qt_imported_soname_default)
    set_property(TARGET Qt6::WaylandEglCompositorHwIntegrationPrivate PROPERTY IMPORTED_SONAME "${_qt_imported_soname_default}")
endif()

unset(_qt_imported_location)
unset(_qt_imported_location_default)
unset(_qt_imported_soname)
unset(_qt_imported_soname_default)
unset(_qt_imported_configs)
