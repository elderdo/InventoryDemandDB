--      $Author:   zf297a  $
--    $Revision:   1.0  $
--        $Date:   Dec 22 2005 13:27:34  $
--    $Workfile:   amd_mission_types.ctl  $
--
-- SCCSID: amd_mission_types.ctl  1.1  Modified: 01/24/02 16:18:08
--

options (errors=10000)
LOAD DATA
append INTO TABLE amd_mission_types
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
(
	MISSION_TYPE_CODE,
	MISSION_TYPE_DESC
)
