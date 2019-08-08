function(vcpkg_check_linkage OUTPUT_LINK_LIST)

  get_property( _CMAKE_IN_TRY_COMPILE GLOBAL PROPERTY IN_TRY_COMPILE )
  if( _CMAKE_IN_TRY_COMPILE )
     set(${OUTPUT_LINK_LIST} ${ARGN} PARENT_SCOPE)
     return()
  endif()
  
  unset(${OUTPUT_LINK_LIST} PARENT_SCOPE)
  set(_tmp_list)
  set(_tmp_gen_list)
  set(_tmp_cur_list _tmp_list)
  set(_genexp_counter 0)
  foreach(_vcpkg_link_lib ${ARGN})
    vcpkg_msg(STATUS "vcpkg_check_linkage" "Link element to check ${_vcpkg_link_lib}")
    
    #Generator expressions list guard
    if(${_vcpkg_link_lib} MATCHES "^\\$<")
        vcpkg_msg(STATUS "vcpkg_check_linkage" "Detected opening generator expression!")
        math(EXPR _genexp_counter "${_genexp_counter} + 1")
        vcpkg_msg(STATUS "vcpkg_check_linkage" "Counter ${_genexp_counter}")
        set(_is_genex_list 1)
        
        string(REGEX MATCH "^\\$<[:]+:" "" _vcpkg_link_lib_genexp ${_vcpkg_link_lib})
        string(REGEX REPLACE "^\\$<[:]+:" "" _vcpkg_link_lib ${_vcpkg_link_lib})
        
        set(_tmp_cur_list _tmp_gen_list)
    endif()

    #Keyword check
    if(${_vcpkg_link_lib} MATCHES "(^debug$|^optimized$|^general$)")
      set(_vcpkg_link_lib_keyword ${_vcpkg_link_lib})
      vcpkg_msg(STATUS "vcpkg_check_linkage" "Setting keyword: ${_vcpkg_link_lib_keyword}!")
      continue()
    endif()

    #Linkage Check
    if(NOT TARGET ${_vcpkg_link_lib} AND "${_vcpkg_link_lib}" MATCHES "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}(/debug/(lib|bin)|/(lib|bin))(/manual-link)*") 
        # Library picked up from VCPKG -> check and correct linkage if necessary
        vcpkg_extract_library_name_from_path(_vcpkg_libtrack_name ${_vcpkg_link_lib})
        if(${_vcpkg_link_lib_keyword} MATCHES "debug" AND NOT "${_vcpkg_link_lib}" MATCHES "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug/(lib|bin)(/manual-link)*")
            if(DEFINED VCPKG_LIBTRACK_${_vcpkg_libtrack_name}_DEBUG)
                vcpkg_msg(WARNING "vcpkg_check_linkage" "Correcting debug linkage from ${_vcpkg_link_lib}!")
                set(${_vcpkg_link_lib} ${VCPKG_LIBTRACK_${_vcpkg_libtrack_name}_DEBUG})
                vcpkg_msg(WARNING "vcpkg_check_linkage" "to ${_vcpkg_link_lib}!")
            endif()
            vcpkg_msg(WARNING "vcpkg_check_linkage" "Wrong debug linkage: ${_vcpkg_link_lib}!") # should be correct if find_library did not screw up
        elseif(${_vcpkg_link_lib_keyword} MATCHES "optimized" AND NOT "${_vcpkg_link_lib}" MATCHES "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/(lib|bin)(/manual-link)*")
            if(DEFINED VCPKG_LIBTRACK_${_vcpkg_libtrack_name}_RELEASE)
                vcpkg_msg(WARNING "vcpkg_check_linkage" "Correcting optimized linkage from ${_vcpkg_link_lib}!")
                set(${_vcpkg_link_lib} ${VCPKG_LIBTRACK_${_vcpkg_libtrack_name}_RELEASE})
                vcpkg_msg(WARNING "vcpkg_check_linkage" "to ${_vcpkg_link_lib}!")
            endif()
            vcpkg_msg(WARNING "vcpkg_check_linkage" "Wrong optimized linkage: ${_vcpkg_link_lib}!") # should be correct if find_library did not screw up
        elseif(${_vcpkg_link_lib_keyword} MATCHES "general" OR NOT DEFINED _vcpkg_link_lib_keyword) # means general or no keyword!
            vcpkg_msg(STATUS "vcpkg_check_linkage" "Correcting general linkage option!")
            if(DEFINED VCPKG_LIBTRACK_${_vcpkg_libtrack_name}_DEBUG AND VCPKG_DEBUG_AVAILABLE)
                list(APPEND ${_tmp_cur_list} debug ${VCPKG_LIBTRACK_${_vcpkg_libtrack_name}_DEBUG}) # debug/optimized will not work in a generator expression!
            else()
                vcpkg_msg(WARNING "vcpkg_check_linkage" "VCPKG_LIBTRACK_${_vcpkg_libtrack_name}_DEBUG not available!")
            endif()
            if(DEFINED VCPKG_LIBTRACK_${_vcpkg_libtrack_name}_RELEASE)
                list(APPEND ${_tmp_cur_list} optimized ${VCPKG_LIBTRACK_${_vcpkg_libtrack_name}_RELEASE})
            else()
                vcpkg_msg(FATAL_ERROR "vcpkg_check_linkage" "VCPKG_LIBTRACK_${_vcpkg_libtrack_name}_RELEASE not available!")
            endif()
        else() #everything fine. Nothing to do 
            if(DEFINED _vcpkg_link_lib_keyword) # External LIB -> do nothing
              list(APPEND ${_tmp_cur_list} ${_vcpkg_link_lib_keyword} ${_vcpkg_link_lib})
            else()
              list(APPEND ${_tmp_cur_list} ${_vcpkg_link_lib})
            endif()
        endif()
    elseif(DEFINED _vcpkg_link_lib_keyword) # External LIB -> do nothing
      vcpkg_msg(STATUS "vcpkg_check_linkage" "External library with keyword!")
      list(APPEND _tmp_list ${_vcpkg_link_lib_keyword} ${_vcpkg_link_lib}) # keywords do not exist in genex so no guard needed
    else()
      list(APPEND ${_tmp_cur_list}  ${_vcpkg_link_lib})
    endif()
    
    #close generator expression guard!
    if(${_vcpkg_link_lib} MATCHES ">$")
        vcpkg_msg(STATUS "vcpkg_check_linkage" "Detected closing generator expression!")
        math(EXPR _genexp_counter "${_genexp_counter} - 1")
        vcpkg_msg(STATUS "vcpkg_check_linkage" "Counter ${_genexp_counter}")
        if(${_genexp_counter} EQUAL 0)
            vcpkg_msg(STATUS "vcpkg_check_linkage" "Closing generator expression List!")
            set(_is_genex_list 0)
            vcpkg_msg(STATUS "vcpkg_check_linkage" "Old List: ${_tmp_list}")
            list(JOIN _tmp_gen_list "\\\;" _tmp_glue_list)
            list(APPEND _tmp_list "${_vcpkg_link_lib_genexp}:${_tmp_glue_list}")
            vcpkg_msg(STATUS "vcpkg_check_linkage" "Gen List: ${_tmp_gen_list}")
            vcpkg_msg(STATUS "vcpkg_check_linkage" "New List: ${_tmp_list}")
            unset(_tmp_gen_list)
            unset(_vcpkg_link_lib_genexp)
            set(_tmp_cur_list _tmp_list)
        endif()
    endif()
    
    unset(_vcpkg_link_lib_keyword)
  endforeach()
  vcpkg_msg(STATUS "vcpkg_check_linkage" "Link List: ${ARGN}")
  vcpkg_msg(STATUS "vcpkg_check_linkage" "checked List: ${_tmp_list}")
  set(${OUTPUT_LINK_LIST} ${_tmp_list} PARENT_SCOPE)
endfunction()
