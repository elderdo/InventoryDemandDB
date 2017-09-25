--      $Author:   zf297a  $
--    $Revision:   1.4  $
--        $Date:   06 Oct 2009 13:13  $
--    $Workfile:   tmp_amd_dmnd_frcst_consumables.ctl  $
--    Load Access Flat files to Oracle using sqlldr
--    An Oracle trigger will perform translation of NSL~part_no
--    to a valid NSN if one exists vi amd_spare_parts 
--    and amd_national_stock_items

options (errors=10000, skip=1)
LOAD DATA
APPEND INTO TABLE tmp_amd_dmnd_frcst_consumables
FIELDS TERMINATED BY WHITESPACE
OPTIONALLY ENCLOSED BY '"'
(
nsn             char "amd_utils.transformNsn(:nsn)",
        sran            char(7),
        period          char(4),
		  ddr					float external "round(:ddr,4)",
		  demand_forecast float external "round(:demand_forecast,4)"
)
