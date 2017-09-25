--      $Author:   zf297a  $
--    $Revision:   1.0  $
--        $Date:   Dec 22 2005 13:27:34  $
--    $Workfile:   amd_mission_flights.ctl  $
--
--
-- SCCSID: amd_mission_flights.ctl  1.2  Modified: 01/24/02 16:18:41
--

options (errors=10000)
LOAD DATA
append INTO TABLE amd_mission_flights
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
(
	MISSION_LEG,
	SCHED_DEPART_TIME                        DATE "mm/dd/yyyy hh:mi:ss am",
	ACTUAL_DEPART_TIME                       DATE "mm/dd/yyyy hh:mi:ss am",
	ACTUAL_ARRIVE_TIME                       DATE "mm/dd/yyyy hh:mi:ss am",
	TAIL_NO,
	DEPARTURE_ICAO,
	ARRIVAL_ICAO,
	MISSION_TYPE_CODE,
	MISSION_ID
)
