# -- Mumps COMMMON
set(COMM_SRC
ana_omp_m.F ana_orderings_wrappers_m.F double_linked_list.F
fac_asm_build_sort_index_ELT_m.F fac_asm_build_sort_index_m.F fac_descband_data_m.F
fac_future_niv2_mod.F fac_ibct_data_m.F fac_maprow_data_m.F front_data_mgt_m.F lr_common.F
mumps_comm_ibcast.F mumps_l0_omp_m.F mumps_memory_mod.F mumps_mpitoomp_m.F mumps_ooc_common.F mumps_static_mapping.F omp_tps_common_m.F
)

set(COMM_OTHER_SRC
ana_orderings.F ana_set_ordering.F ana_AMDMF.F bcast_errors.F estim_flops.F
mumps_type_size.F mumps_type2_blocking.F mumps_version.F mumps_print_defined.F
mumps_pord.c
mumps_common.c mumps_size.c mumps_io.c mumps_io_basic.c mumps_io_thread.c mumps_io_err.c
mumps_numa.c mumps_thread.c mumps_save_restore_C.c mumps_config_file_C.c mumps_thread_affinity.c
tools_common.F sol_common.F
)

set(ORDERING_INCDIRS)
set(ORDERING_LIBS)
set(ORDERING_FLAGS -Dpord)
if(scotch)
  find_package(Scotch COMPONENTS ESMUMPS REQUIRED)
  list(APPEND ORDERING_FLAGS -Dscotch)
  list(APPEND COMM_OTHER_SRC mumps_scotch.c mumps_scotch64.c mumps_scotch_int.c)
  list(APPEND ORDERING_INCDIRS ${Scotch_INCLUDE_DIRS})
  list(APPEND ORDERING_LIBS ${Scotch_LIBRARIES})
endif()
if(metis)
  find_package(METIS REQUIRED)
  list(APPEND ORDERING_FLAGS -Dmetis)
  list(APPEND COMM_OTHER_SRC mumps_metis.c mumps_metis64.c mumps_metis_int.c)
  list(APPEND ORDERING_INCDIRS ${METIS_INCLUDE_DIRS})
  list(APPEND ORDERING_LIBS ${METIS_LIBRARIES})
endif()
list(APPEND ORDERING_LIBS mumps::pord)

# manually create directory to avoid race condition for FetchContent
# else can get INTERFACE_INCLUDE_DIRECTORIES not found error
file(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/include)

add_library(mumps_common ${COMM_SRC} ${COMM_OTHER_SRC})
target_link_libraries(mumps_common PRIVATE ${ORDERING_LIBS} ${NUMERIC_LIBS})
target_include_directories(mumps_common PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/../include ${NUMERIC_INCDIRS} ${ORDERING_INCDIRS}
  INTERFACE
  $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/include>
  $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/../include>
  $<INSTALL_INTERFACE:include>)
target_compile_definitions(mumps_common PRIVATE ${CDEFS} ${ORDERING_FLAGS})
# if(WIN32)
#   target_compile_definitions(mumps_common PRIVATE MUMPS_WIN32)
# endif()
set_target_properties(mumps_common PROPERTIES
  Fortran_MODULE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/include)
add_library(mumps::common ALIAS mumps_common)

install(TARGETS mumps_common
  EXPORT MUMPSTargets
  ARCHIVE DESTINATION lib
  LIBRARY DESTINATION lib
  RUNTIME DESTINATION bin
  INCLUDES DESTINATION include)

# -- Mumps
set(_ifc_libs)

foreach(a ${arith})

list(APPEND _ifc_libs mumps::${a}mumps)

set(SRC
${a}ana_aux.F ${a}ana_aux_par.F ${a}ana_lr.F ${a}fac_asm_master_ELT_m.F ${a}fac_asm_master_m.F
${a}fac_front_aux.F ${a}fac_front_LU_type1.F ${a}fac_front_LU_type2.F
${a}fac_front_LDLT_type1.F ${a}fac_front_LDLT_type2.F ${a}fac_front_type2_aux.F
${a}fac_lr.F ${a}fac_mem_dynamic.F ${a}fac_omp_m.F ${a}fac_par_m.F
${a}lr_core.F ${a}lr_stats.F ${a}lr_type.F
${a}mumps_comm_buffer.F ${a}mumps_config_file.F ${a}mumps_load.F ${a}mumps_lr_data_m.F
${a}mumps_ooc_buffer.F ${a}mumps_ooc.F ${a}mumps_sol_es.F
${a}mumps_save_restore.F ${a}mumps_save_restore_files.F
${a}mumps_struc_def.F ${a}omp_tps_m.F ${a}sol_lr.F ${a}static_ptr_m.F
)

set(SRC_OTHER
${a}ini_driver.F ${a}ana_driver.F ${a}fac_driver.F ${a}sol_driver.F ${a}sol_distrhs.F
${a}end_driver.F ${a}ana_aux_ELT.F ${a}ana_dist_m.F ${a}ana_LDLT_preprocess.F
${a}ana_reordertree.F ${a}arrowheads.F ${a}bcast_int.F ${a}fac_asm_ELT.F
${a}fac_asm.F ${a}fac_b.F ${a}fac_distrib_distentry.F ${a}fac_distrib_ELT.F ${a}fac_lastrtnelind.F
${a}fac_mem_alloc_cb.F ${a}fac_mem_compress_cb.F ${a}fac_mem_free_block_cb.F
${a}fac_mem_stack_aux.F ${a}fac_mem_stack.F
${a}fac_process_band.F ${a}fac_process_blfac_slave.F ${a}fac_process_blocfacto_LDLT.F ${a}fac_process_blocfacto.F
${a}fac_process_bf.F ${a}fac_process_end_facto_slave.F
${a}fac_process_contrib_type1.F ${a}fac_process_contrib_type2.F ${a}fac_process_contrib_type3.F
${a}fac_process_maprow.F ${a}fac_process_master2.F ${a}fac_process_message.F
${a}fac_process_root2slave.F ${a}fac_process_root2son.F ${a}fac_process_rtnelind.F ${a}fac_root_parallel.F
${a}fac_scalings.F ${a}fac_determinant.F ${a}fac_scalings_simScaleAbs.F ${a}fac_scalings_simScale_util.F
${a}fac_sol_pool.F ${a}fac_type3_symmetrize.F ${a}ini_defaults.F
${a}mumps_driver.F ${a}mumps_f77.F ${a}mumps_gpu.c ${a}mumps_iXamax.F
${a}ana_mtrans.F ${a}ooc_panel_piv.F ${a}rank_revealing.F
${a}sol_aux.F ${a}sol_bwd_aux.F ${a}sol_bwd.F ${a}sol_c.F ${a}sol_fwd_aux.F ${a}sol_fwd.F ${a}sol_matvec.F
${a}sol_root_parallel.F ${a}tools.F ${a}type3_root.F
)

set(CINT_SRC mumps_c.c)

add_library(${a}mumps ${CINT_SRC} ${SRC} ${SRC_OTHER})
target_compile_definitions(${a}mumps PRIVATE MUMPS_ARITH=MUMPS_ARITH_${a} ${CDEFS} ${ORDERING_FLAGS})
# if(WIN32)
#   target_compile_definitions(${a}mumps PRIVATE MUMPS_WIN32)
# endif()
target_include_directories(${a}mumps PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/../include ${NUMERIC_INCDIRS}
  INTERFACE
  $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/include>
  $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/../include>
  $<INSTALL_INTERFACE:include>)
target_link_libraries(${a}mumps PRIVATE mumps_common ${NUMERIC_LIBS})
set_target_properties(${a}mumps PROPERTIES
  Fortran_MODULE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/include)
add_library(mumps::${a}mumps ALIAS ${a}mumps)

install(TARGETS ${a}mumps
  EXPORT MUMPSTargets
  ARCHIVE DESTINATION lib
  LIBRARY DESTINATION lib
  RUNTIME DESTINATION bin
  INCLUDES DESTINATION include)

install(FILES
  ${CMAKE_CURRENT_SOURCE_DIR}/../include/${a}mumps_c.h
  ${CMAKE_CURRENT_SOURCE_DIR}/../include/${a}mumps_root.h
  ${CMAKE_CURRENT_SOURCE_DIR}/../include/${a}mumps_struc.h
  DESTINATION include)

endforeach()

install(FILES
  ${CMAKE_CURRENT_SOURCE_DIR}/../include/mumps_c_types.h
  ${CMAKE_CURRENT_SOURCE_DIR}/../include/mumps_compat.h
  DESTINATION include)

install(DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/include/ DESTINATION include)

# mumps::mumps is the target most users will link to.
# It knows all the include directories.
add_library(mumps::mumps INTERFACE IMPORTED GLOBAL)
set_property(TARGET mumps::mumps PROPERTY
  INTERFACE_LINK_LIBRARIES ${_ifc_libs} mumps::common mumps::pord)
