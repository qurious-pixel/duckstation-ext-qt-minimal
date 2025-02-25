function(qt_ensure_perl)
    if(DEFINED HOST_PERL)
        return()
    endif()
    find_program(HOST_PERL "perl" DOC "Perl binary")
    if (NOT HOST_PERL)
        message(FATAL_ERROR "Perl needs to be available to build Qt.")
    endif()
endfunction()

function(qt_ensure_sync_qt)
    qt_ensure_perl()
    if(DEFINED QT_SYNCQT)
        return()
    endif()

    get_property(QT_SYNCQT GLOBAL PROPERTY _qt_syncqt)
    if(NOT "${QT_SYNCQT}" STREQUAL "")
        set(QT_SYNCQT "${QT_SYNCQT}" PARENT_SCOPE)
        return()
    endif()

    # When building qtbase, use the source syncqt, otherwise use the installed one.
    set(SYNCQT_FROM_SOURCE "${QtBase_SOURCE_DIR}/libexec/syncqt.pl")
    if(NOT ("${QtBase_SOURCE_DIR}" STREQUAL "") AND EXISTS "${SYNCQT_FROM_SOURCE}")
        set(syncqt_absolute_path "${SYNCQT_FROM_SOURCE}")
        message(STATUS "Using source syncqt found at: ${syncqt_absolute_path}")

        qt_path_join(syncqt_install_dir ${QT_INSTALL_DIR} ${INSTALL_LIBEXECDIR})
        qt_copy_or_install(PROGRAMS "${SYNCQT_FROM_SOURCE}"
                           DESTINATION "${syncqt_install_dir}")
    elseif(NOT "${QT_HOST_PATH}" STREQUAL "")
        get_filename_component(syncqt_absolute_path
                               "${QT_HOST_PATH}/${QT${PROJECT_VERSION_MAJOR}_HOST_INFO_LIBEXECDIR}/syncqt.pl"
                               ABSOLUTE)
        message(STATUS "Using host syncqt found at: ${syncqt_absolute_path}")
    else()
        get_filename_component(syncqt_absolute_path
                               "${QT_BUILD_INTERNALS_RELOCATABLE_INSTALL_PREFIX}/${INSTALL_LIBEXECDIR}/syncqt.pl"
                               ABSOLUTE)
        message(STATUS "Using installed syncqt found at: ${syncqt_absolute_path}")
    endif()

    set(QT_SYNCQT "${syncqt_absolute_path}" PARENT_SCOPE)
    set_property(GLOBAL PROPERTY _qt_syncqt "${syncqt_absolute_path}")
endfunction()

function(qt_install_injections target build_dir install_dir)
    set(injections ${ARGN})
    qt_internal_module_info(module ${target})
    get_target_property(target_type ${target} TYPE)
    if (target_type STREQUAL "INTERFACE_LIBRARY")
        set(is_framework FALSE)
    else()
        get_target_property(is_framework ${target} FRAMEWORK)
    endif()
    # examples:
    #  SYNCQT.INJECTIONS = src/corelib/global/qconfig.h:qconfig.h:QtConfig src/corelib/global/qconfig_p.h:5.12.0/QtCore/private/qconfig_p.h
    #  SYNCQT.INJECTIONS = src/gui/vulkan/qvulkanfunctions.h:^qvulkanfunctions.h:QVulkanFunctions:QVulkanDeviceFunctions src/gui/vulkan/qvulkanfunctions_p.h:^5.12.0/QtGui/private/qvulkanfunctions_p.h
    # The are 3 parts to the assignment, divded by colons ':'.
    # The first part contains a path to a generated file in a build folder.
    # The second part contains the file name that the forwarding header should have, which points
    # to the file in the first part.
    # The third part contains multiple UpperCaseFileNames that should be forwarding headers to the
    # header specified in the second part.
    separate_arguments(injections UNIX_COMMAND "${injections}")
    foreach(injection ${injections})
        string(REPLACE ":" ";" injection ${injection})
        # Part 1.
        list(GET injection 0 file)
        # Part 2.
        list(GET injection 1 destination)
        string(REGEX REPLACE "^\\^" "" destination "${destination}")
        list(REMOVE_AT injection 0 1)
        # Part 3.
        set(fwd_hdrs ${injection})
        get_filename_component(destinationdir ${destination} DIRECTORY)
        get_filename_component(destinationname ${destination} NAME)
        get_filename_component(original_file_name ${file} NAME)

        # This describes a concrete example for easier comprehension:
        # A file 'qtqml-config.h' is generated by qt_internal_feature_write_file into
        # ${qtdeclarative_build_dir}/src/{module}/qtqml-config.h (part 1).
        #
        # Generate a lower case forwarding header (part 2) 'qtqml-config.h' at the following
        # location:
        # ${some_prefix}/include/${module}/qtqml-config.h.
        #
        # Inside this file, we #include the originally generated file,
        # ${qtdeclarative_build_dir}/src/{module}/qtqml-config.h.
        #
        # ${some_prefix}'s value depends on the build type.
        # If doing a prefix build, it should point to
        # ${current_repo_build_dir} which is ${qtdeclarative_build_dir}.
        # If doing a non-prefix build, it should point to
        # ${qtbase_build_dir}.
        #
        # In the code below, ${some_prefix} == ${build_dir}.
        set(lower_case_forwarding_header_path "${build_dir}/include/${module}")
        if(destinationdir)
            string(APPEND lower_case_forwarding_header_path "/${destinationdir}")
        endif()
        set(current_repo_build_dir "${PROJECT_BINARY_DIR}")

        file(RELATIVE_PATH relpath
                           "${lower_case_forwarding_header_path}"
                           "${current_repo_build_dir}/${file}")
        set(main_contents "#include \"${relpath}\"")

        qt_configure_file(OUTPUT "${lower_case_forwarding_header_path}/${original_file_name}"
             CONTENT "${main_contents}")

        if(is_framework)
            if(file MATCHES "_p\\.h$")
                set(header_type PRIVATE)
            else()
                set(header_type PUBLIC)
            endif()
            qt_copy_framework_headers(${target} ${header_type}
                ${current_repo_build_dir}/${file})
        else()
            # Copy the actual injected (generated) header file (not the just created forwarding one)
            # to its install location when doing a prefix build. In an non-prefix build, the qt_install
            # will be a no-op.
            qt_path_join(install_destination
                        ${install_dir} ${INSTALL_INCLUDEDIR} ${module} ${destinationdir})
            qt_install(FILES ${current_repo_build_dir}/${file}
                    DESTINATION ${install_destination}
                    RENAME ${destinationname} OPTIONAL)
        endif()

        # Generate UpperCaseNamed forwarding headers (part 3).
        foreach(fwd_hdr ${fwd_hdrs})
            set(upper_case_forwarding_header_path "include/${module}")
            if(destinationdir)
                string(APPEND upper_case_forwarding_header_path "/${destinationdir}")
            endif()

            # Generate upper case forwarding header like QVulkanFunctions or QtConfig.
            qt_configure_file(OUTPUT "${build_dir}/${upper_case_forwarding_header_path}/${fwd_hdr}"
                 CONTENT "#include \"${destinationname}\"\n")

            if(is_framework)
                # Copy the forwarding header to the framework's Headers directory.
                qt_copy_framework_headers(${target} PUBLIC
                    "${build_dir}/${upper_case_forwarding_header_path}/${fwd_hdr}")
            else()
                # Install the forwarding header.
                qt_path_join(install_destination "${install_dir}" "${INSTALL_INCLUDEDIR}" ${module})
                qt_install(FILES "${build_dir}/${upper_case_forwarding_header_path}/${fwd_hdr}"
                        DESTINATION ${install_destination} OPTIONAL)
            endif()
        endforeach()
    endforeach()
endfunction()

function(qt_read_headers_pri module_include_dir resultVarPrefix)
    file(STRINGS "${module_include_dir}/headers.pri" headers_pri_contents)
    foreach(line ${headers_pri_contents})
        if("${line}" MATCHES "SYNCQT.HEADER_FILES = (.*)")
            set(public_module_headers "${CMAKE_MATCH_1}")
            separate_arguments(public_module_headers UNIX_COMMAND "${public_module_headers}")
        elseif("${line}" MATCHES "SYNCQT.PRIVATE_HEADER_FILES = (.*)")
            set(private_module_headers "${CMAKE_MATCH_1}")
            separate_arguments(private_module_headers UNIX_COMMAND "${private_module_headers}")
        elseif("${line}" MATCHES "SYNCQT.GENERATED_HEADER_FILES = (.*)")
            set(generated_module_headers "${CMAKE_MATCH_1}")
            separate_arguments(generated_module_headers UNIX_COMMAND "${generated_module_headers}")
            foreach(generated_header ${generated_module_headers})
                list(APPEND public_module_headers "${module_include_dir}/${generated_header}")
            endforeach()
        elseif("${line}" MATCHES "SYNCQT.INJECTIONS = (.*)")
            set(injections "${CMAKE_MATCH_1}")
        elseif("${line}" MATCHES "SYNCQT.([A-Z_]+)_HEADER_FILES = (.+)")
            set(prefix "${CMAKE_MATCH_1}")
            string(TOLOWER "${prefix}" prefix)
            set(entries "${CMAKE_MATCH_2}")
            separate_arguments(entries UNIX_COMMAND "${entries}")
            set("${resultVarPrefix}_${prefix}" "${entries}" PARENT_SCOPE)
        endif()
    endforeach()
    set(${resultVarPrefix}_public "${public_module_headers}" PARENT_SCOPE)
    set(${resultVarPrefix}_private "${private_module_headers}" PARENT_SCOPE)
    set(${resultVarPrefix}_injections "${injections}" PARENT_SCOPE)
endfunction()

function(qt_compute_injection_forwarding_header target)
    qt_parse_all_arguments(arg "qt_compute_injection_forwarding_header"
                           "PRIVATE" "SOURCE;OUT_VAR" "" ${ARGN})
    qt_internal_module_info(module "${target}")
    get_filename_component(file_name "${arg_SOURCE}" NAME)

    set(source_absolute_path "${CMAKE_CURRENT_BINARY_DIR}/${arg_SOURCE}")
    file(RELATIVE_PATH relpath "${PROJECT_BINARY_DIR}" "${source_absolute_path}")

    if (arg_PRIVATE)
        set(fwd "${PROJECT_VERSION}/${module}/private/${file_name}")
    else()
        set(fwd "${file_name}")
    endif()

    string(APPEND ${arg_OUT_VAR} " ${relpath}:${fwd}")
    set(${arg_OUT_VAR} ${${arg_OUT_VAR}} PARENT_SCOPE)
endfunction()
