CREATE OR REPLACE TRIGGER "AMD_OWNER".amd_spare_networks_trig1
	BEFORE INSERT
	ON AMD_SPARE_NETWORKS
	FOR EACH ROW
DECLARE
BEGIN
	if (:new.loc_sid is null) then
		SELECT amd_spare_networks_seq.NEXTVAL INTO :new.loc_sid FROM DUAL;
	end if;
END;

/ 
