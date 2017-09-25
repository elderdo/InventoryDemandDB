--      $Author:   zf297a  $
--    $Revision:   1.0  $
--        $Date:   Dec 22 2005 13:27:34  $
--    $Workfile:   amd_rmads_source_tmp.ctl  $
--
-- SCCSID: amd_rmads_source_tmp.ctl 1.2 Modified:04/04/03 10:33:15
Load Data
INFILE  '/apps/CRON/AMD/data/mtbrpn.dat'
REPLACE
INTO TABLE AMD_RMADS_SOURCE_TMP
(
  PART_NO          POSITION(1:20)             CHAR, 
  QPEI_WEIGHTED    POSITION(30:33)            DECIMAL EXTERNAL,
  MTBDR            POSITION(35:44)            DECIMAL EXTERNAL)
