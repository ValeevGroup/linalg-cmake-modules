set( LAPACK_UTILITY_CMAKE_FILE_DIR ${CMAKE_CURRENT_LIST_DIR} )

function( check_dgesvd_exists _libs _link_ok _uses_lower _uses_underscore )

include( ${LAPACK_UTILITY_CMAKE_FILE_DIR}/CommonFunctions.cmake )

set( ${_link_ok} FALSE )
set( ${_uses_lower} )
set( ${_uses_underscore} )

foreach( _uplo LOWER UPPER )

  set( _dgesvd_name_template "dgesvd" )
  string( TO${_uplo} ${_dgesvd_name_template} _dgesvd_name_uplo )
  
  foreach( _under UNDERSCORE NO_UNDERSCORE )

    set( _item LAPACK_${_uplo}_${_under} )
    if( _under EQUAL "UNDERSCORE" )
      set( _dgesvd_name "${_dgesvd_name_uplo}_" )
    else()
      set( _dgesvd_name "${_dgesvd_name_uplo}_" )
    endif()

    check_function_exists_w_results( 
      "${${_libs}}" ${_dgesvd_name} _compile_output _compile_result
    )

    message( STATUS "Performing Test ${_item}" )
    if( _compile_result )

      message( STATUS "Performing Test ${_item} -- found" )
      set( ${_link_ok} TRUE )
      string( COMPARE EQUAL "${_uplo}"  "LOWER"      ${_uses_lower}      )
      string( COMPARE EQUAL "${_under}" "UNDERSCORE" ${_uses_underscore} )
      break()

    else()

      append_possibly_missing_libs( LAPACK _compile_output ${_libs} _new_libs )
      list( APPEND ${_libs} ${_new_libs} )
      set( ${_libs} ${${_libs}} PARENT_SCOPE )


      # Recheck Compiliation
      check_function_exists_w_results( 
        "${${_libs}}" ${_dgesvd_name} _compile_output _compile_result
      )

      if( _compile_result )
        message( STATUS "Performing Test ${_item} -- found" )
        set( ${_link_ok} TRUE )
        string( COMPARE EQUAL "${_uplo}"  "LOWER"      ${_uses_lower}      )
        string( COMPARE EQUAL "${_under}" "UNDERSCORE" ${_uses_underscore} )
        break()
      else()
        message( STATUS "Performing Test ${_item} -- not found" )
      endif()

    endif()

  endforeach()

  if( ${${_link_ok}} )
    break()
  endif()

  unset( _dgesvd_name_template )
  unset( _dgesvd_name_uplo     )
endforeach() 

#cmake_pop_check_state()


set( ${_link_ok}         ${${_link_ok}}         PARENT_SCOPE )
set( ${_uses_lower}      ${${_uses_lower}}      PARENT_SCOPE )
set( ${_uses_underscore} ${${_uses_underscore}} PARENT_SCOPE )

endfunction()




function( check_lapack_int _libs _dsyev_name _libs_are_lp64 )

try_run( _run_result _compile_result ${CMAKE_CURRENT_BINARY_DIR}
  SOURCES        ${LAPACK_UTILITY_CMAKE_FILE_DIR}/lapack_ilp64_checker.c
  LINK_LIBRARIES ${${_libs}}
  COMPILE_DEFINITIONS "-DDSYEV_NAME=${_dsyev_name}"
  COMPILE_OUTPUT_VARIABLE _compile_output
  RUN_OUTPUT_VARIABLE     _run_output
)

if( _run_output MATCHES "LAPACK IS LP64" )
  set( ${_libs_are_lp64} TRUE PARENT_SCOPE )
else()
  set( ${_libs_are_lp64} FALSE PARENT_SCOPE )
endif()

endfunction() 
