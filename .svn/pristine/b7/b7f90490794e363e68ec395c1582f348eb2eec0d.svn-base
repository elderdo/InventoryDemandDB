spool install.log

prompt EXECUTING GoldTables.sql
@../ddl/GoldTables.sql

prompt EXECUTING AMDTmpTables.sql
@../ddl/AMDTmpTables.sql

prompt EXECUTING AMD.sql
@../ddl/AMD.sql

prompt APPLYING GRANTS TO ROLES
@../ddl/AMD.gra

prompt COMPILING AMD_UTILS PACKAGE
@amd_utils.sql

prompt COMPILING AMD_DEFAULTS PACKAGE
@amd_defaults.sql

prompt COMPILING AMD_FROM_BSSM_PKG PACKAGE
@amd_from_bssm_pkg.sql

prompt COMPILING AMD_CLEANED_FROM_BSSM_PKG PACKAGE
@amd_cleaned_from_bssm_pkg.sql

prompt COMPILING AMD_CLEAN_DATA PACKAGE
@amd_clean_data.sql

prompt COMPILING AMD_NSL_SEQUENCE_PKG PACKAGE
@amd_nsl_sequence_pkg.sql

prompt COMPILING AMD_PREFERRED_PKG PACKAGE
@amd_preferred_pkg.sql

prompt COMPILING AMD_VALIDATION_PKG PACKAGE
@amd_validation_pkg.sql

prompt COMPILING AMD_SPARE_PARTS_PKG PACKAGE
@amd_spare_parts_pkg.sql

prompt COMPILING AMD_TEST_DATA PACKAGE
@amd_test_data.sql

prompt COMPILING AMD_RMADS_SOURCE_TMP_PKG PACKAGE
@amd_rmads_source_tmp_pkg.sql

prompt COMPILING AMD_PART_LOCS_LOAD_PKG PACKAGE
@amd_part_locs_load_pkg.sql

prompt COMPILING AMD_MAINT_TASK_DISTRIBS_PKG PACKAGE
@amd_maint_task_distribs_pkg.sql

prompt COMPILING AMD_LOAD PACKAGE
@amd_load.sql

prompt COMPILING AMD_INVENTORY PACKAGE
@amd_inventory.sql

prompt COMPILING AMD_DEMAND PACKAGE
@amd_demand.sql

prompt COMPILING AMDDPPKG PACKAGE
@amddppkg.sql

create sequence AMD_ORDER_SID_SEQ;

spool off

quit
