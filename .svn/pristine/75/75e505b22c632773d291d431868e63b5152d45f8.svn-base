SET DEFINE OFF;
DROP PACKAGE AMD_OWNER.AMD_SPO_LP_OVERRIDE_PKG;

CREATE OR REPLACE PACKAGE AMD_OWNER.amd_spo_lp_override_pkg AS
/*
      $Author$
    $Revision$
        $Date$
    $Workfile$
         $Log$
         */

    TYPE ref_cursor IS REF CURSOR;
        
    --Generate flat data file to sql load to SPO.X_IMP_LP_OVERRIDE table from amd_owner.tmp_a2a_loc_part_override
    FUNCTION getLpOverrideDataFile RETURN ref_cursor;
                                  
                          
end;
/

SHOW ERRORS;



SET DEFINE OFF;
DROP PACKAGE BODY AMD_OWNER.AMD_SPO_LP_OVERRIDE_PKG;

CREATE OR REPLACE PACKAGE BODY AMD_OWNER.amd_spo_lp_override_pkg AS
/*
      $Author$
    $Revision$
        $Date$
    $Workfile$
         $Log$
         */
             
    FUNCTION getLpOverrideDataFile RETURN ref_cursor IS   
        refCursor ref_cursor;
        vBatchJobNumber NUMBER DEFAULT NULL;
        
    begin
        select spoc17v2.batch_sequence.nextval@stl_escm_link into vBatchJobNumber from dual;
        
        IF vBatchJobNumber IS NOT NULL THEN
            OPEN refCursor FOR
                SELECT 
                SITE_LOCATION || '|' || 
                PART_NO  || '|' ||
                amd_location_part_override_pkg.TSL_OVERRIDE_TYPE || '|' ||
                case when override_type = 'ROQ Fixed' and override_quantity = 0 then
                    1
                    else OVERRIDE_QUANTITY
                end || '|' ||
                OVERRIDE_REASON || '|' ||
                replace(OVERRIDE_USER, ';') || '|' ||
                TO_CHAR(BEGIN_DATE, 'MM/DD/RRRR') || '|' ||
                TO_CHAR(END_DATE, 'MM/DD/RRRR') || '|' ||
                DECODE(ACTION_CODE, 'A', 'INS', 'C', 'UPD', 'D', 'DEL')  || '|' ||
                vBatchJobNumber || '|' ||
                SPOc17v2.interface_sequence.nextval@stl_escm_link
                FROM amd_owner.tmp_a2a_loc_part_override
                WHERE action_code IN ('A', 'C', 'D');
        END IF;    
        
        RETURN refCursor;

    end ;
                                              
end;
/

SHOW ERRORS;


