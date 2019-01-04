DROP PROCEDURE AMD_OWNER.DROP_TABLE;

CREATE OR REPLACE PROCEDURE AMD_OWNER.drop_table (
                            table_name   varchar2)
as
crsor integer;
rval  integer;
begin
 dbms_output.put_line('Dropping Table : '|| table_name);
 crsor := dbms_sql.open_cursor;
 dbms_sql.parse(crsor, 'drop table '|| table_name
                ,dbms_sql.v7);
 rval := dbms_sql.execute(crsor);
 dbms_sql.close_cursor(crsor);
end;

 
/


DROP PROCEDURE AMD_OWNER.MTA_DISABLE_CONSTRAINT;

CREATE OR REPLACE PROCEDURE AMD_OWNER.mta_disable_constraint (
                            table_name		varchar2,
                            constraint_name	varchar2)
as
 /*
      $Author:   zf297a  $
	$Revision:   1.1  $
        $Date:   Jun 09 2006 09:19:12  $
    $Workfile:   MTA_DISABLE_CONSTRAINT.prc  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Procedures\MTA_DISABLE_CONSTRAINT.prc-arc  $
/*
/*      Rev 1.1   Jun 09 2006 09:19:12   zf297a
/*   Added PVCS keywords and writeMsg to log the event to amd_load_details
*/
crsor integer;
rval  integer;
begin
 amd_utils.writeMsg(pSourceName => 'mta_disable_constraint',
   pTableName => table_name, pError_location => 1, pData => 'mta_disable_constraint',
     pKey1 => table_name, pKey2 => constraint_name, pKey3 => '$Revision:   1.1  $') ;
 dbms_output.put_line('Disabling Constraint: ' || constraint_name ||
	' Table: '|| table_name);
 crsor := dbms_sql.open_cursor;
 dbms_sql.parse(crsor, 'alter table '|| table_name ||
                ' disable constraint '|| constraint_name ,dbms_sql.v7);
 rval := dbms_sql.execute(crsor);
 dbms_sql.close_cursor(crsor);
end;
 
/


DROP PROCEDURE AMD_OWNER.MTA_DISABLE_TRIGGER;

CREATE OR REPLACE PROCEDURE AMD_OWNER.mta_disable_trigger (
   trigger_name    VARCHAR2)
AS
   /*
        $Author:   zf297a  $
      $Revision:   1.0
          $Date:   Jul 04 2016


  */
   crsor   INTEGER;
   rval    INTEGER;
BEGIN
   amd_utils.writeMsg (pSourceName       => 'mta_disable_trigger',
                       pTableName        => trigger_name,
                       pError_location   => 1,
                       pData             => 'mta_disable_trigger',
                       pKey1             => trigger_name,
                       pKey2             => '',
                       pKey3             => '$Revision:   1.0  $');
   DBMS_OUTPUT.put_line ('Disabling trigger: ' || trigger_name);
   crsor := DBMS_SQL.open_cursor;
   DBMS_SQL.parse (crsor,
                   'alter trigger ' || trigger_name || ' disable ',
                   DBMS_SQL.v7);
   rval := DBMS_SQL.execute (crsor);
   DBMS_SQL.close_cursor (crsor);
END;
/


DROP PROCEDURE AMD_OWNER.MTA_ENABLE_CONSTRAINT;

CREATE OR REPLACE PROCEDURE AMD_OWNER.mta_enable_constraint (
                            table_name		varchar2,
                            constraint_name	varchar2)
as
 /*
      $Author:   zf297a  $
	$Revision:   1.1  $
        $Date:   Jun 09 2006 09:19:12  $
    $Workfile:   MTA_ENABLE_CONSTRAINT.prc  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Procedures\MTA_ENABLE_CONSTRAINT.prc-arc  $
/*
/*      Rev 1.1   Jun 09 2006 09:19:12   zf297a
/*   Added PVCS keywords and writeMsg to log the event to amd_load_details
*/
crsor integer;
rval  integer;
begin
 amd_utils.writeMsg(pSourceName => 'mta_enable_constraint',
   pTableName => table_name, pError_location => 1, pData => 'mta_enable_constraint',
     pKey1 => table_name, pKey2 => constraint_name, pKey3 => '$Revision:   1.1  $') ;
 dbms_output.put_line('Enabling Constraint: ' || constraint_name ||
	' Table: '|| table_name);
 crsor := dbms_sql.open_cursor;
 dbms_sql.parse(crsor, 'alter table '|| table_name ||
                ' enable constraint '|| constraint_name ,dbms_sql.v7);
 rval := dbms_sql.execute(crsor);
 dbms_sql.close_cursor(crsor);
end;
 
/


DROP PROCEDURE AMD_OWNER.MTA_ENABLE_TRIGGER;

CREATE OR REPLACE PROCEDURE AMD_OWNER.mta_enable_trigger (
   trigger_name    VARCHAR2)
AS
   /*
        $Author:   zf297a  $
      $Revision:   1.0
          $Date:   Jul 04 2016


  */
   crsor   INTEGER;
   rval    INTEGER;
BEGIN
   amd_utils.writeMsg (pSourceName       => 'mta_enable_trigger',
                       pTableName        => trigger_name,
                       pError_location   => 1,
                       pData             => 'mta_enable_trigger',
                       pKey1             => trigger_name,
                       pKey2             => '',
                       pKey3             => '$Revision:   1.0  $');
   DBMS_OUTPUT.put_line ('Disabling trigger: ' || trigger_name);
   crsor := DBMS_SQL.open_cursor;
   DBMS_SQL.parse (crsor,
                   'alter trigger ' || trigger_name || ' enable ',
                   DBMS_SQL.v7);
   rval := DBMS_SQL.execute (crsor);
   DBMS_SQL.close_cursor (crsor);
END;
/


DROP PROCEDURE AMD_OWNER.MTA_TRUNCATE_TABLE;

CREATE OR REPLACE PROCEDURE AMD_OWNER.mta_truncate_table (
                            table_name   varchar2,
                            storage_type varchar2)
as
 /*
      $Author:   zf297a  $
	$Revision:   1.4  $
        $Date:   Jun 09 2006 09:18:32  $
    $Workfile:   MTA_TRUNCATE_TABLE.prc  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Procedures\MTA_TRUNCATE_TABLE.prc-arc  $
/*
/*      Rev 1.4   Jun 09 2006 09:18:32   zf297a
/*   Added pData to set data_line in amd_load_details
/*
/*      Rev 1.3   Jun 08 2006 13:00:16   zf297a
/*   Added mta_truncate_table to last "end" statement.
/*
/*      Rev 1.2   Jun 08 2006 12:57:24   zf297a
/*   Made sure that the table_name appears in key2 of amd_load_details
/*
/*      Rev 1.1   Jun 07 2006 19:20:54   zf297a
/*   Added writeMsg with $Revision:   1.4  $
*/
crsor integer;
rval  integer;
begin
 amd_utils.writeMsg(pSourceName => 'mta_truncate_table',
   pTableName => table_name, pError_location => 1, pData => 'mta_truncate_table',
     pKey1 => storage_type, pKey2 => table_name, pKey3 => '$Revision:   1.4  $') ;
    dbms_output.put_line('Truncating Table : '|| table_name ||
                     ' Storage : '|| storage_type);
 crsor := dbms_sql.open_cursor;
 dbms_sql.parse(crsor, 'truncate table '|| table_name ||
                ' '|| storage_type ,dbms_sql.v7);
 rval := dbms_sql.execute(crsor);
 dbms_sql.close_cursor(crsor);
end mta_truncate_table;
 
/


DROP PROCEDURE AMD_OWNER.NIIN_FROM_PART;

CREATE OR REPLACE PROCEDURE AMD_OWNER.NIIN_FROM_PART (

PARTNO   	IN	VARCHAR2,
FSC 		OUT	VARCHAR2,
NIIN 		OUT	VARCHAR2,
PRIME_Ind		OUT VARCHAR2,
PRIME_PART	OUT VARCHAR2,
NSN			OUT VARCHAR2)
as
/******************************************************************************
   NAME:       NIIN_FROM_PART
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        11/4/2004          1. Created this procedure.

   NOTES:

   Automatically available Auto Replace Keywords:
      Object Name:     NIIN_FROM_PART
      Sysdate:         11/4/2004
      Date and Time:   11/4/2004, 1:57:47 PM, and 11/4/2004 1:57:47 PM
      Username:         (set in TOAD Options, Procedure Editor)
      Table Name:       (set in the "New PL/SQL Object" dialog)

******************************************************************************/
v_nsn varchar2(50);
BEGIN

   begin
   select substr(a.nsn,1,4), substr(a.nsn,5,9), b.PRIME_IND, NSN
   into FSC, NIIN, PRIME_IND, v_nsn
   from  amd_spare_parts a, amd_nsi_parts b
   where a.part_no = b.part_no
   and b.unassignment_date is null
   and a.part_no = partno;

   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       NIIN := 'Not Found';
	   Prime_ind := 'X';
     WHEN OTHERS THEN
       NIIN := 'Not Found';
	   Prime_ind := 'X';

   end;
   nsn := v_nsn;
   If Prime_ind = 'N' then
   	  begin
	  select a.part_no
   	  into  PRIME_PART
      from  amd_owner.amd_spare_parts a, amd_owner.amd_nsi_parts b
      where a.part_no = b.part_no and
            b.unassignment_date is null and b.prime_ind = 'Y' and
			a.nsn = v_NSN;
	  EXCEPTION
     WHEN NO_DATA_FOUND THEN
       PRIME_PART := 'Not Found';
     WHEN OTHERS THEN
       PRIME_PART := 'Not Found';
	 end;
   else
   	   Prime_part := partno;
   end if;

END NIIN_FROM_PART;
 
/


DROP PROCEDURE AMD_OWNER.PART_MASTER_IN;

CREATE OR REPLACE PROCEDURE AMD_OWNER.part_master_in (
NIIN                       IN  VARCHAR2,
NSN                      IN  VARCHAR2,
Part                  IN  VARCHAR2,
Prime_Part              IN  VARCHAR2,
Alternate_Parts          OUT VARCHAR2,
AAC                      OUT VARCHAR2,
ISG                      OUT CHAR,
Nomenclature          OUT VARCHAR2,
smrc                  OUT VARCHAR2,
errc                  OUT VARCHAR2,
remarks                  OUT VARCHAR2,
manuf_cage            OUT VARCHAR2,
source_code              OUT VARCHAR2,
ims_designator_code   OUT VARCHAR2,
order_lead_time          OUT NUMBER,
cap_price              OUT VARCHAR2,
um_issue_code          OUT VARCHAR2,
user_name              OUT VARCHAR2,
phone                  OUT VARCHAR2,
rop                      OUT NUMBER,
roq                      OUT NUMBER,
part_type              OUT VARCHAR2,
ror_admin              OUT VARCHAR2,
ror_phone              OUT VARCHAR2,
mtbdr_cleaned          OUT NUMBER,
serd                   OUT VARCHAR2,
hazmt                    OUT VARCHAR2,
auto_process           OUT VARCHAR2)
as
/******************************************************************************
   NAME:       PrimePart_from_NIIN
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        11/3/2004          1. Created this function.


******************************************************************************/
v_part varchar2(50);
partchar char(50);
isgchar char(50);
primechar char(50);
alting integer;
vims_designator_code varchar2(20);
verrc char(3);
vnsn varchar2(15);

BEGIN
    If part is null
    Then
      v_part := prime_part;
    Else
      v_part := part;
    End if;
    If part is null
    Then
      partchar := prime_part;
    Else
      partchar := part;
    End if;


   begin

      select acquisition_advice_code, Nomenclature, order_lead_time
      into AAC, Nomenclature, order_lead_time
      from amd_owner.amd_spare_parts
      where part_no = trim(v_part);
      EXCEPTION
     WHEN NO_DATA_FOUND THEN
       AAC := null;
     WHEN OTHERS THEN
       begin
       AAC := null;
       end;
   end;

    begin

      select mtbdr
      into mtbdr_cleaned
      from amd_owner.amd_rmads_source_tmp
      where part_no = v_part;
      EXCEPTION
     WHEN NO_DATA_FOUND THEN
       mtbdr_cleaned := 99999;
     WHEN OTHERS THEN
       begin
       mtbdr_cleaned := 99999;
       end;
   end;

    begin

      select  distinct(to_char(cap_price))
      into cap_price
      from amd_owner.prc1
      where part = v_part;
      EXCEPTION
     WHEN NO_DATA_FOUND THEN
       Cap_price := 'Not Available';
     WHEN OTHERS THEN
       begin
       cap_price := 'Price Varies';
       end;
   end;

   begin

   select ISGP_GROUP_NO, smrc, errc, remarks, manuf_cage, source_code, ims_designator_code, um_issue_code,
             user_ref4, hazardous_material_code, mils_auto_process_b
   into ISG, smrc, verrc, remarks, manuf_cage, source_code, vims_designator_code, um_issue_code,
          serd, hazmt, auto_process
   from  amd_owner.CAT1
   where part = trim(partchar);
    EXCEPTION
     WHEN NO_DATA_FOUND THEN
       ISG := null;
     WHEN OTHERS THEN
       begin
       ISG := null;
       end;

   end;
   errc := verrc;
   If substr(smrc,6,1) in ('N','P')
   Then
          part_type := 'C';
   Else
          part_type := 'R';
   End if;

   primechar := prime_part;
   If trim(verrc) = 'T'
   Then
   begin
   select c.user_name, c.phone
   into ror_admin, ror_phone
   from VENC a, VENN b, amd_USE1 c
   where a.vendor_code = b.vendor_code
   and a.USER_REF1 = c.userid
   and a.part = trim(partchar);
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       ror_admin := 'Not Found';
     WHEN OTHERS THEN
       ror_admin := 'Not Found';
   end;
   Else
          ror_admin := 'N/A';
   End if;


   vnsn := trim(nsn);
   If trim(verrc) in ('N','P')
   Then
          begin

      select rop, roq
      into rop, roq
      from amd_owner.amd_acmii
      where nsn = vnsn and
            sran = 'CTLATL';
      EXCEPTION
     WHEN NO_DATA_FOUND THEN
       rop := null;
       roq := null;
     WHEN OTHERS THEN
       rop := null;
       roq := null;
   end;
   else
          rop := null;
       roq := null;
   End if;



   ims_designator_code := vims_designator_code;
   If vims_designator_code is not null
   Then
          begin

      select distinct user_name, phone
      into user_name, phone
      from amd_owner.amd_use1
      where ims_designator_code = trim(vims_designator_code);
      EXCEPTION
     WHEN NO_DATA_FOUND THEN
       user_name := 'Not Available';
     WHEN OTHERS THEN
       begin
       user_name := 'Not Available';
       end;
   end;
   else
         user_name := 'Not Available';
   End if;


--If ISG is null then
   begin
   select count(distinct(b.part_no)) - 1
   into Alternate_Parts
   from  amd_owner.amd_spare_parts a, amd_owner.amd_nsi_parts b
   where a.part_no = b.part_no and
   b.unassignment_date is null
   and substr(a.nsn,5,9) = NIIN;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       Alternate_Parts := '0';
     WHEN OTHERS THEN
       begin
       Alternate_Parts := '0';
       end;
   end;
/*Else
  isgchar := isg;
   begin
   select count(distinct(part)) - 1
   into alting
   from cat1
    where isgp_group_no = isgchar;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       Alternate_Parts := '0';
     WHEN OTHERS THEN
       begin
       Alternate_Parts:= '0';
       end;
   end;
   Alternate_parts := to_char(alting);
 End if; */

END part_master_in;
 
/


DROP PROCEDURE AMD_OWNER.PRIMEPART_FROM_NSN;

CREATE OR REPLACE PROCEDURE AMD_OWNER.PrimePart_from_NSN(
NSN	  		  IN  VARCHAR2,
PRIME_Part		  OUT VARCHAR2)
as
/******************************************************************************
   NAME:       PrimePart_from_NIIN
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        11/3/2004          1. Created this function.


******************************************************************************/
vNSN varchar2(50);

BEGIN
vNSN := NSN;
   select a.part_no
   into PRIME_PART
   from  amd_owner.amd_spare_parts a, amd_owner.amd_nsi_parts b
   where a.part_no = b.part_no and
   b.unassignment_date is null and b.prime_ind = 'Y'
   and a.nsn = vNSN;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       Prime_part := 'Not Found';
     WHEN OTHERS THEN
       Prime_part := 'Not Found';

END PrimePart_from_NSN;
 
/


DROP PROCEDURE AMD_OWNER.SLEEP;

CREATE OR REPLACE PROCEDURE AMD_OWNER.sleep( secs in number) is
/*
      $Author:   zf297a  $
    $Revision:   1.0  $
        $Date:   07 Aug 2009 10:07:58  $
    $Workfile:   SLEEP.prc  $
         $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\Procedures\SLEEP.prc.-arc  $
/*
/*      Rev 1.0   07 Aug 2009 10:07:58   zf297a
/*   Initial revision.
*/
        end_date_time date := sysdate + (1/(24*60*60) * secs) ;
    begin
        while sysdate < end_date_time
        loop
            null;
        end loop;
    end sleep ;
 
/


DROP PROCEDURE AMD_OWNER.TRUNCATE_TABLE;

CREATE OR REPLACE PROCEDURE AMD_OWNER.truncate_table (
                            table_name   varchar2,
                            storage_type varchar2)
as
crsor integer;
rval  integer;
begin
 dbms_output.put_line('Truncating Table : '|| table_name ||
                     ' Storage : '|| storage_type);
 crsor := dbms_sql.open_cursor;
 dbms_sql.parse(crsor, 'truncate table '|| table_name ||
                ' '|| storage_type ,dbms_sql.v7);
 rval := dbms_sql.execute(crsor);
 dbms_sql.close_cursor(crsor);
end;

 
/


DROP PUBLIC SYNONYM DROP_TABLE;

CREATE PUBLIC SYNONYM DROP_TABLE FOR AMD_OWNER.DROP_TABLE;


DROP PUBLIC SYNONYM MTA_DISABLE_TRIGGER;

CREATE PUBLIC SYNONYM MTA_DISABLE_TRIGGER FOR AMD_OWNER.MTA_DISABLE_TRIGGER;


DROP PUBLIC SYNONYM MTA_ENABLE_TRIGGER;

CREATE PUBLIC SYNONYM MTA_ENABLE_TRIGGER FOR AMD_OWNER.MTA_ENABLE_TRIGGER;


DROP PUBLIC SYNONYM NIIN_FROM_PART;

CREATE PUBLIC SYNONYM NIIN_FROM_PART FOR AMD_OWNER.NIIN_FROM_PART;


DROP PUBLIC SYNONYM PART_MASTER_IN;

CREATE PUBLIC SYNONYM PART_MASTER_IN FOR AMD_OWNER.PART_MASTER_IN;


DROP PUBLIC SYNONYM PRIMEPART_FROM_NSN;

CREATE PUBLIC SYNONYM PRIMEPART_FROM_NSN FOR AMD_OWNER.PRIMEPART_FROM_NSN;


DROP PUBLIC SYNONYM SLEEP;

CREATE PUBLIC SYNONYM SLEEP FOR AMD_OWNER.SLEEP;


DROP PUBLIC SYNONYM TRUNCATE_TABLE;

CREATE PUBLIC SYNONYM TRUNCATE_TABLE FOR AMD_OWNER.TRUNCATE_TABLE;


GRANT EXECUTE ON AMD_OWNER.DROP_TABLE TO AMD_READER_ROLE;

GRANT EXECUTE ON AMD_OWNER.MTA_DISABLE_CONSTRAINT TO AMD_READER_ROLE;

GRANT EXECUTE ON AMD_OWNER.MTA_DISABLE_TRIGGER TO AMD_READER_ROLE;

GRANT EXECUTE ON AMD_OWNER.MTA_ENABLE_CONSTRAINT TO AMD_READER_ROLE;

GRANT EXECUTE ON AMD_OWNER.MTA_ENABLE_TRIGGER TO AMD_READER_ROLE;

GRANT EXECUTE ON AMD_OWNER.MTA_TRUNCATE_TABLE TO AMD_READER_ROLE;

GRANT EXECUTE ON AMD_OWNER.NIIN_FROM_PART TO AMD_READER_ROLE;

GRANT EXECUTE ON AMD_OWNER.PART_MASTER_IN TO AMD_READER_ROLE;

GRANT EXECUTE ON AMD_OWNER.PRIMEPART_FROM_NSN TO AMD_READER_ROLE;

GRANT EXECUTE ON AMD_OWNER.TRUNCATE_TABLE TO AMD_READER_ROLE;

GRANT EXECUTE ON AMD_OWNER.DROP_TABLE TO AMD_WRITER_ROLE;

GRANT EXECUTE ON AMD_OWNER.MTA_DISABLE_CONSTRAINT TO AMD_WRITER_ROLE;

GRANT EXECUTE ON AMD_OWNER.MTA_DISABLE_TRIGGER TO AMD_WRITER_ROLE;

GRANT EXECUTE ON AMD_OWNER.MTA_ENABLE_CONSTRAINT TO AMD_WRITER_ROLE;

GRANT EXECUTE ON AMD_OWNER.MTA_ENABLE_TRIGGER TO AMD_WRITER_ROLE;

GRANT EXECUTE ON AMD_OWNER.MTA_TRUNCATE_TABLE TO AMD_WRITER_ROLE;

GRANT EXECUTE ON AMD_OWNER.NIIN_FROM_PART TO AMD_WRITER_ROLE;

GRANT EXECUTE ON AMD_OWNER.PRIMEPART_FROM_NSN TO AMD_WRITER_ROLE;

GRANT EXECUTE ON AMD_OWNER.SLEEP TO AMD_WRITER_ROLE;

GRANT EXECUTE ON AMD_OWNER.TRUNCATE_TABLE TO AMD_WRITER_ROLE;

GRANT EXECUTE ON AMD_OWNER.DROP_TABLE TO BSRM_LOADER;

GRANT EXECUTE ON AMD_OWNER.MTA_DISABLE_CONSTRAINT TO BSRM_LOADER;

GRANT EXECUTE ON AMD_OWNER.MTA_ENABLE_CONSTRAINT TO BSRM_LOADER;

GRANT EXECUTE ON AMD_OWNER.MTA_TRUNCATE_TABLE TO BSRM_LOADER;

GRANT EXECUTE ON AMD_OWNER.SLEEP TO BSRM_LOADER;

GRANT EXECUTE ON AMD_OWNER.TRUNCATE_TABLE TO BSRM_LOADER;

GRANT EXECUTE ON AMD_OWNER.MTA_TRUNCATE_TABLE TO IRVT_OWNER;
