/*
 * 9/23/2015 Douglas Elder added program_id
**/
SET ECHO ON TERMOUT ON AUTOCOMMIT ON TIME ON

variable program_id varchar2(30);

begin
select amd_defaults.getProgramId into :program_id from dual;
end;
/

print :program_id



exec amd_owner.mta_truncate_table('w_cxfr','reuse storage');
exec amd_owner.mta_truncate_table('w_item','reuse storage');
exec amd_owner.mta_truncate_table('w_poi1','reuse storage');
exec amd_owner.mta_truncate_table('w_syat','reuse storage');
exec amd_owner.mta_truncate_table('w_orh3','reuse storage');
exec amd_owner.mta_truncate_table('w_venn','reuse storage');
exec amd_owner.mta_truncate_table('w_ordv','reuse storage');
exec amd_owner.mta_truncate_table('w_ord1','reuse storage');
exec amd_owner.mta_truncate_table('w_ordh1','reuse storage');
exec amd_owner.mta_truncate_table('w_sc01','reuse storage');
exec amd_owner.mta_truncate_table('w_sycd','reuse storage');
exec amd_owner.mta_truncate_table('w_whse','reuse storage');
exec amd_owner.mta_truncate_table('w_wip1','reuse storage');
exec amd_owner.mta_truncate_table('w_work_center','reuse storage');
exec amd_owner.mta_truncate_table('wip_cat1','reuse storage');
exec amd_owner.mta_truncate_table('wip_isgp','reuse storage');
exec amd_owner.mta_truncate_table('wip_item','reuse storage');
exec amd_owner.mta_truncate_table('wip_ord1_history','reuse storage');
exec amd_owner.mta_truncate_table('wip_ord1','reuse storage');
exec amd_owner.mta_truncate_table('wip_ramp','reuse storage');
exec amd_owner.mta_truncate_table('wip_whse','reuse storage');
exec amd_owner.mta_truncate_table('wip_wip1_history','reuse storage');


insert into amd_owner.w_cxfr(sc, other_sc)
select sc, other_sc from cxfr@amd_pgoldlb_link;


INSERT into amd_owner.w_item (item_id, part, sc, location, qty, receipt_um, condition, 
status_servicable,status_suspended, status_avail, reserve_action, status_in_transit, 
status_new_order, status_mai, status_accountable, status_active, status_1)
SELECT
item_id, part, sc, location, qty, receipt_um, condition, 
status_servicable,status_suspended, status_avail, reserve_action, status_in_transit, 
status_new_order, status_mai, status_accountable, status_active, status_1
FROM item@amd_pgoldlb_link
where status_new_order in ('N','F')
and status_mai in ('N','F')
and status_accountable in ('Y','T')
and status_active in ('Y','T')
and status_1 <> 'D'
and condition not in ('D','4H','LOST','LDD','UNAV');



INSERT INTO AMD_OWNER.W_POI1(ORDER_NO, SEQ, UNIT_PRICE, QTY, CREATED_DATETIME)
SELECT ORDER_NO, SEQ, UNIT_PRICE, QTY, CREATED_DATETIME 
FROM POI1@AMD_PGOLDLB_LINK
WHERE CREATED_DATETIME >  ADD_MONTHS(SYSDATE,-24);


INSERT INTO AMD_OWNER.W_SYAT(SHORT_DESCRIPTION, ACTION_TAKEN)
SELECT  short_description, action_taken 
FROM syat@amd_pgoldlb_link;


INSERT INTO amd_owner.W_ORH3
SELECT * FROM ORH3@AMD_PGOLDLB_LINK
WHERE SYSDATE BETWEEN BEGIN_DATE AND END_DATE;

INSERT INTO amd_owner.W_VENN
SELECT VENDOR_NAME, VENDOR_CODE 
FROM VENN@AMD_PGOLDLB_LINK;

INSERT INTO amd_owner.W_ORDV
SELECT * FROM ORDV@AMD_PGOLDLB_LINK;

INSERT INTO amd_owner.W_ORD1(ORDER_NO, NEED_DATE,PO,PO_LINE,NH_ORDER_NO, PART,SERIAL, QTY_ORDERED, CONDITION,
VENDOR_CODE, STATUS,SC, ORIGINAL_LOCATION, LOCATION, REPAIR_TYPE,ACTION_TAKEN, PO_PRICE,
CREATED_DOCDATE,COMPLETED_DOCDATE, WIP_DATETIME, DISCREPANCY, CORRECTIVE_ACTION, REMARKS,
AWO_ALT, ORDER_TYPE, ACCOUNTABLE_YN, CREATED_DATETIME, DEFAULT_ID,PO_SEQ)
SELECT ORDER_NO, NEED_DATE,PO,PO_LINE,NH_ORDER_NO, PART,SERIAL, QTY_ORDERED, CONDITION,
VENDOR_CODE, STATUS,SC, ORIGINAL_LOCATION, LOCATION, REPAIR_TYPE,ACTION_TAKEN, PO_PRICE,
CREATED_DOCDATE,COMPLETED_DOCDATE, WIP_DATETIME, DISCREPANCY, CORRECTIVE_ACTION, REMARKS,
AWO_ALT, ORDER_TYPE, ACCOUNTABLE_YN, CREATED_DATETIME, DEFAULT_ID, PO_SEQ
FROM ORD1@AMD_PGOLDLB_LINK 
WHERE 
ORDER_NO NOT LIKE 'RAM%' 
AND SC LIKE :program_id || '%'
AND ACCOUNTABLE_YN = 'Y'
AND ORDER_TYPE = 'J' 
AND ORD1.STATUS IN ('U','O','R')
AND ORD1.ACTION_TAKEN IS NULL
UNION 
SELECT ORDER_NO, NEED_DATE,PO,PO_LINE,NH_ORDER_NO, PART,SERIAL, QTY_ORDERED, CONDITION,
VENDOR_CODE, STATUS,SC, ORIGINAL_LOCATION, LOCATION, REPAIR_TYPE,ACTION_TAKEN, PO_PRICE,
CREATED_DOCDATE,COMPLETED_DOCDATE, WIP_DATETIME, DISCREPANCY, CORRECTIVE_ACTION, REMARKS,
AWO_ALT, ORDER_TYPE, ACCOUNTABLE_YN, CREATED_DATETIME, DEFAULT_ID, PO_SEQ
FROM ORD1@AMD_PGOLDLB_LINK 
WHERE ORDER_NO NOT LIKE 'RAM%' 
AND SC LIKE :program_id || '%'
AND ACCOUNTABLE_YN = 'Y'
AND ORDER_TYPE = 'J' 
AND ORD1.STATUS IN ('U','O','R')
AND ORD1.ACTION_TAKEN NOT IN ('J','K','Z')
UNION
SELECT ORDER_NO, NEED_DATE,PO,PO_LINE,NH_ORDER_NO, PART,SERIAL, QTY_ORDERED, CONDITION,
VENDOR_CODE, STATUS,SC, ORIGINAL_LOCATION, LOCATION, REPAIR_TYPE,ACTION_TAKEN, PO_PRICE,
CREATED_DOCDATE,COMPLETED_DOCDATE, WIP_DATETIME, DISCREPANCY, CORRECTIVE_ACTION, REMARKS,
AWO_ALT, ORDER_TYPE, ACCOUNTABLE_YN, CREATED_DATETIME, DEFAULT_ID, PO_SEQ
FROM ORD1@AMD_PGOLDLB_LINK 
WHERE ORDER_NO NOT LIKE 'RAM%' 
AND SC LIKE :program_id || '%'
AND ACCOUNTABLE_YN = 'Y'
AND ORDER_TYPE = 'J' 
AND ORD1.STATUS = 'C'
AND ORD1.CREATED_DATETIME > ADD_MONTHS(SYSDATE,-24)
AND ORD1.ACTION_TAKEN IS NULL
UNION 
SELECT ORDER_NO, NEED_DATE,PO,PO_LINE,NH_ORDER_NO, PART,SERIAL, QTY_ORDERED, CONDITION,
VENDOR_CODE, STATUS,SC, ORIGINAL_LOCATION, LOCATION, REPAIR_TYPE,ACTION_TAKEN, PO_PRICE,
CREATED_DOCDATE,COMPLETED_DOCDATE, WIP_DATETIME, DISCREPANCY, CORRECTIVE_ACTION, REMARKS,
AWO_ALT, ORDER_TYPE, ACCOUNTABLE_YN, CREATED_DATETIME, DEFAULT_ID, PO_SEQ
FROM ORD1@AMD_PGOLDLB_LINK 
WHERE ORDER_NO NOT LIKE 'RAM%' 
AND SC LIKE :program_id || '%'
AND ACCOUNTABLE_YN = 'Y'
AND ORDER_TYPE = 'J' 
AND ORD1.STATUS = 'C'
AND ORD1.CREATED_DATETIME > ADD_MONTHS(SYSDATE,-24)
AND ORD1.ACTION_TAKEN NOT IN ('J','K','Z');

insert into amd_owner.w_ordh1(default_id, sc, part, vendor_code, po_heading, ship_via, status, wip_type)
select default_id, sc, part, vendor_code, po_heading, ship_via, status, wip_type
from ordh1@amd_pgoldlb_link;


insert into amd_owner.w_sc01
select * from sc01@amd_pgoldlb_link;


insert into amd_owner.w_sycd(condition, description)
select condition, description from sycd@amd_pgoldlb_link;


insert into amd_owner.w_whse(part, prime, sc, stock_level, reorder_point)
select part, prime, sc, stock_level, reorder_point
from whse@amd_pgoldlb_link
where stock_level > 0;


insert into amd_owner.w_wip1(item_id, created_doc_datetime, order_no, created_sys_datetime, created_userid, work_center, cday_span, remarks)
select item_id, created_doc_datetime, order_no, created_sys_datetime, created_userid, work_center, cday_span, remarks
from wip1@amd_pgoldlb_link;




insert into amd_owner.w_work_center(order_no, created_sys_datetime, work_center)
select distinct dts.*, work_center
from (select order_no, max(created_sys_datetime) cr_sys_dt from amd_owner.w_wip1 w_wip1 group by order_no order by order_no) dts,
amd_owner.w_wip1
where cr_sys_dt = created_sys_datetime
and dts.order_no = w_wip1.order_no;



INSERT INTO amd_owner.WIP_CAT1(PART, PRIME, MASTER, Group_no, OOU, NOUN, NSN, NIN, IMS_DESIGNATOR_CODE, IMS_DESIGNATOR_NAME, 
PLANNER_CODE, PLANNER_NAME, AAC, SOURCE_CODE, SMRC, USER_REF2, CRITICALITY)
SELECT  
CAT1.PART,
NVL(CATA."MASTER",CAT1.PRIME) "PRIME",
CATA."MASTER",
CAT1.ISGP_GROUP_NO,
ISGP.GROUP_PRIORITY "OOU",
CAT1.NOUN,
CAT1.NSN,
CAT1.NIN,
CAT2.IMS_DESIGNATOR_CODE IMS_DESIGNATOR_CODE,
NULL IMS_DESIGNATOR_NAME,
CAT2.PLANNER_CODE PLANNER_CODE, 
NULL PLANNER_NAME, 
CAT1.USER_REF7 "AAC",
CAT1.SOURCE_CODE,
CAT1.SMRC,
CAT1.USER_REF2,
AUXB.FIELD_VALUE Criticality
FROM GOLD__MASTER.CAT1@amd_pgoldlb_link, GOLD__MASTER.ISGP@amd_pgoldlb_link, GOLD__MASTER.CAT1@amd_pgoldlb_link CAT2,
(SELECT ISGP.GROUP_NO, MAX(ISGP.PART) "MASTER" FROM 
GOLD__MASTER.ISGP@amd_pgoldlb_link
WHERE 
NVL(ISGP.GROUP_PRIORITY,'XXX') || ISGP.SEQUENCE_NO = (SELECT MAX(NVL(T1.GROUP_PRIORITY,'XXX') || T1.SEQUENCE_NO) 
FROM GOLD__MASTER.ISGP@amd_pgoldlb_link T1, GOLD__MASTER.CAT1@amd_pgoldlb_link CAT1 WHERE 
T1.PART = CAT1.PART AND CAT1.NOUN NOT LIKE 'SEE PRIME%' AND T1.GROUP_NO = ISGP.GROUP_NO) GROUP BY ISGP.GROUP_NO) CATA,
(SELECT AUXB.KEY_VALUE1, AUXB.FIELD_VALUE FROM GOLD__MASTER.AUXB@amd_pgoldlb_link WHERE 
AUXB.ENTNAME = 'CAT1' AND AUXB.RECORD_TYPE = 'MDA' AND AUXB.FIELD_ID = 8 AND AUXB.KEY_VALUE2 = 'DEF') AUXB
WHERE
UPPER(cat1.noun) not like 'SEE PRIME%' AND
CAT1.ISGP_GROUP_NO = ISGP.GROUP_NO(+) AND
CAT1.PART = ISGP.PART(+) AND 
CAT1.PART = AUXB.KEY_VALUE1(+) AND 
CAT1.ISGP_GROUP_NO = CATA.GROUP_NO(+) AND
cat1.prime in 
(SELECT DISTINCT CAT1.PRIME
FROM GOLD__MASTER.CAT1@amd_pgoldlb_link,
(select ITEM.part from GOLD__MASTER.item@amd_pgoldlb_link, 
(SELECT DISTINCT OTHER_SC FROM gold__master.CXFR@amd_pgoldlb_link CXFR WHERE  
  REGEXP_LIKE(OTHER_SC,:program_id || '....(HLD|OBS|CTL|DSO|ROR|COD|SUP|ICP|TIR)...G') AND
  REGEXP_LIKE(SC,'^' || :program_id || '....((HLD|OBS|CTL|DSO)(JNS|ATL|OKC)|(ICP|TIR|COD)...|RORPBL)G$') AND 
  OTHER_SC NOT LIKE :program_id || '%CODLGBG') T1, 
(select sc from GOLD__MASTER.sc01@amd_pgoldlb_link WHERE SITE_CODE in (:program_id || 'UKB',:program_id || 'CAN',:program_id || 'AUS',:program_id || 'NAT',:program_id || 'QAT',:program_id || 'IND',:program_id || 'UAE')) T2
where item.sc = T1.other_sc(+) and
item.sc = T2.SC(+) AND 
NVL(T1.OTHER_SC,T2.SC) IS NOT NULL) IT
WHERE
(CAT1.SOURCE_CODE = 'F77' or CAT1.NSN = 'NSL') AND 
LNNVL(CAT1.USER_REF7 = 'Y') AND 
REGEXP_LIKE(CAT1.SMRC,'.....T') AND 
cat1.part = it.part
UNION
SELECT DISTINCT CAT1.PRIME
FROM GOLD__MASTER.CAT1@amd_pgoldlb_link,
(select ITEM.part from GOLD__MASTER.item@amd_pgoldlb_link, 
(SELECT DISTINCT OTHER_SC FROM gold__master.CXFR@amd_pgoldlb_link CXFR WHERE  
  REGEXP_LIKE(OTHER_SC,:program_id || '....(HLD|OBS|CTL|DSO|ROR|COD|SUP|ICP|TIR)...G') AND
  REGEXP_LIKE(SC,'^' || :program_id || '....((HLD|OBS|CTL|DSO)(JNS|ATL|OKC)|(ICP|TIR|COD)...|RORPBL)G$') AND 
  OTHER_SC NOT LIKE :program_id || '%CODLGBG') T1, 
(select sc from GOLD__MASTER.sc01@amd_pgoldlb_link WHERE SITE_CODE in (:program_id || 'UKB',:program_id || 'CAN',:program_id || 'AUS',:program_id || 'NAT',:program_id || 'QAT',:program_id || 'IND',:program_id || 'UAE')) T2
where 
ITEM.STATUS_MAI IN ('Y','T') AND
item.sc = T1.other_sc(+) and
item.sc = T2.SC(+) AND 
NVL(T1.OTHER_SC,T2.SC) IS NOT NULL) IT
WHERE
(CAT1.SOURCE_CODE = 'F77' or CAT1.NSN = 'NSL') AND 
CAT1.USER_REF7 = 'Y' AND 
REGEXP_LIKE(CAT1.SMRC,'.....T') AND 
cat1.part = it.part
union
SELECT DISTINCT CAT1.PRIME
FROM GOLD__MASTER.CAT1@amd_pgoldlb_link,
(SELECT REQ1.SELECT_FROM_PART FROM GOLD__MASTER.REQ1@amd_pgoldlb_link WHERE REQ1.SELECT_FROM_SC LIKE :program_id || '%' AND (REQ1.MILS_SOURCE_DIC IS NOT NULL OR REQ1.PURPOSE_CODE = 'R') AND 
REQ1.STATUS IN ('U','H','O','R','S','Y') and req1.created_datetime > add_months(sysdate,-60)) T1
WHERE
(CAT1.SOURCE_CODE = 'F77' or CAT1.NSN = 'NSL') AND 
REGEXP_LIKE(CAT1.SMRC,'.....T') AND 
LNNVL(CAT1.USER_REF7 = 'Y') AND 
cat1.part = t1.select_from_part
union
SELECT DISTINCT CAT1.PRIME
FROM GOLD__MASTER.CAT1@amd_pgoldlb_link,
(SELECT RAMP.NIIN FROM GOLD__MASTER.RAMP@amd_pgoldlb_link WHERE DELETE_INDICATOR IS NULL AND 
(RAMP.REQUISITION_OBJECTIVE > 0 OR RAMP.SERVICEABLE_BALANCE > 0 OR RAMP.DIFM_BALANCE > 0 OR RAMP.UNSERVICEABLE_BALANCE > 0)) T2
WHERE
(CAT1.SOURCE_CODE = 'F77' or CAT1.NSN = 'NSL') AND 
REGEXP_LIKE(CAT1.SMRC,'.....T') AND 
LNNVL(CAT1.USER_REF7 = 'Y') AND 
cat1.nsn <> 'NSL' AND 
SUBSTR(CAT1.NSN,6) = T2.NIIN
union
SELECT DISTINCT CAT1.PRIME
FROM GOLD__MASTER.CAT1@amd_pgoldlb_link,
(SELECT WHSE.PART FROM GOLD__MASTER.WHSE@amd_pgoldlb_link, GOLD__MASTER.SC01@amd_pgoldlb_link WHERE SC01.SITE_CODE IN (:program_id || 'UKB',:program_id || 'CAN',:program_id || 'AUS',:program_id || 'NAT',:program_id || 'QAT',:program_id || 'IND',:program_id || 'UAE') AND 
SC01.SC LIKE :program_id || 'GISPICP%' AND SC01.SC = WHSE.SC AND WHSE.STOCK_LEVEL > 0) T3
WHERE
(CAT1.SOURCE_CODE = 'F77' or CAT1.NSN = 'NSL') AND 
REGEXP_LIKE(CAT1.SMRC,'.....T') AND  
LNNVL(CAT1.USER_REF7 = 'Y') AND 
CAT1.PART = T3.PART) AND
NVL(CATA."MASTER",CAT1.PRIME) = CAT2.PART
union
SELECT  
CAT1.PART,
NVL(CATA."MASTER",CAT1.PRIME) "PRIME",
CATA."MASTER",
CAT1.ISGP_GROUP_NO,
ISGP.GROUP_PRIORITY "OOU",
CAT1.NOUN,
CAT1.NSN,
CAT1.NIN,
CAT2.IMS_DESIGNATOR_CODE IMS_DESIGNATOR_CODE,
NULL IMS_DESIGNATOR_NAME,
CAT2.PLANNER_CODE PLANNER_CODE, 
NULL PLANNER_NAME, 
CAT1.USER_REF7 "AAC",
CAT1.SOURCE_CODE,
CAT1.SMRC,
CAT1.USER_REF2,
AUXB.FIELD_VALUE Criticality
FROM GOLD__MASTER.CAT1@amd_pgoldlb_link, GOLD__MASTER.ISGP@amd_pgoldlb_link, GOLD__MASTER.CAT1@amd_pgoldlb_link CAT2,
(SELECT ISGP.GROUP_NO, MAX(ISGP.PART) "MASTER" FROM 
GOLD__MASTER.ISGP@amd_pgoldlb_link 
WHERE 
NVL(ISGP.GROUP_PRIORITY,'XXX') || ISGP.SEQUENCE_NO = (SELECT MAX(NVL(T1.GROUP_PRIORITY,'XXX') || T1.SEQUENCE_NO) 
FROM GOLD__MASTER.ISGP@amd_pgoldlb_link T1, GOLD__MASTER.CAT1@amd_pgoldlb_link CAT1 WHERE 
T1.PART = CAT1.PART AND CAT1.NOUN NOT LIKE 'SEE PRIME%' AND T1.GROUP_NO = ISGP.GROUP_NO) GROUP BY ISGP.GROUP_NO) CATA,
(SELECT AUXB.KEY_VALUE1, AUXB.FIELD_VALUE FROM GOLD__MASTER.AUXB@amd_pgoldlb_link WHERE 
AUXB.ENTNAME = 'CAT1' AND AUXB.RECORD_TYPE = 'MDA' AND AUXB.FIELD_ID = 8 AND AUXB.KEY_VALUE2 = 'DEF') AUXB
WHERE
UPPER(cat1.noun) not like 'SEE PRIME%' AND
CAT1.ISGP_GROUP_NO = ISGP.GROUP_NO(+) AND
CAT1.PART = ISGP.PART(+) AND 
CAT1.PART = AUXB.KEY_VALUE1(+) AND 
CAT1.ISGP_GROUP_NO = CATA.GROUP_NO(+) AND 
cat1.isgp_group_no in
(SELECT CAT1.isgp_group_no
FROM GOLD__MASTER.CAT1@amd_pgoldlb_link, 
(select ITEM.part from GOLD__MASTER.item@amd_pgoldlb_link, 
(SELECT DISTINCT OTHER_SC FROM gold__master.CXFR@amd_pgoldlb_link CXFR WHERE  
  REGEXP_LIKE(OTHER_SC,:program_id || '....(HLD|OBS|CTL|DSO|ROR|COD|SUP|ICP|TIR)...G') AND
  REGEXP_LIKE(SC,'^' || :program_id || '....((HLD|OBS|CTL|DSO)(JNS|ATL|OKC)|(ICP|TIR|COD)...|RORPBL)G$') AND 
  OTHER_SC NOT LIKE :program_id || '%CODLGBG') T1, 
(select sc from GOLD__MASTER.sc01@amd_pgoldlb_link WHERE SITE_CODE in (:program_id || 'UKB',:program_id || 'CAN',:program_id || 'AUS',:program_id || 'NAT',:program_id || 'QAT',:program_id || 'IND',:program_id || 'UAE')) T2
where item.sc = T1.other_sc(+) and
item.sc = T2.SC(+) AND 
NVL(T1.OTHER_SC,T2.SC) IS NOT NULL) IT
WHERE
(CAT1.SOURCE_CODE = 'F77' or CAT1.NSN = 'NSL') AND 
LNNVL(CAT1.USER_REF7 = 'Y') AND 
REGEXP_LIKE(CAT1.SMRC,'.....T') AND 
cat1.part = it.part
UNION
SELECT CAT1.isgp_group_no
FROM GOLD__MASTER.CAT1@amd_pgoldlb_link, 
(select ITEM.part from GOLD__MASTER.item@amd_pgoldlb_link, 
(SELECT DISTINCT OTHER_SC FROM gold__master.CXFR@amd_pgoldlb_link CXFR WHERE  
  REGEXP_LIKE(OTHER_SC,:program_id || '....(HLD|OBS|CTL|DSO|ROR|COD|SUP|ICP|TIR)...G') AND
  REGEXP_LIKE(SC,'^' || :program_id || '....((HLD|OBS|CTL|DSO)(JNS|ATL|OKC)|(ICP|TIR|COD)...|RORPBL)G$') AND 
  OTHER_SC NOT LIKE :program_id || '%CODLGBG') T1, 
(select sc from GOLD__MASTER.sc01@amd_pgoldlb_link WHERE SITE_CODE in (:program_id || 'UKB',:program_id || 'CAN',:program_id || 'AUS',:program_id || 'NAT',:program_id || 'QAT',:program_id || 'IND',:program_id || 'UAE')) T2
where 
ITEM.STATUS_MAI IN ('T','Y') AND
item.sc = T1.other_sc(+) and
item.sc = T2.SC(+) AND 
NVL(T1.OTHER_SC,T2.SC) IS NOT NULL) IT
WHERE
(CAT1.SOURCE_CODE = 'F77' or CAT1.NSN = 'NSL') AND 
CAT1.USER_REF7 = 'Y' AND 
REGEXP_LIKE(CAT1.SMRC,'.....T') AND 
cat1.part = it.part
union
SELECT CAT1.isgp_group_no
FROM GOLD__MASTER.CAT1@amd_pgoldlb_link,
(SELECT REQ1.SELECT_FROM_PART FROM GOLD__MASTER.REQ1@amd_pgoldlb_link WHERE REQ1.SELECT_FROM_SC LIKE :program_id || '%' AND (REQ1.MILS_SOURCE_DIC IS NOT NULL OR REQ1.PURPOSE_CODE = 'R') AND 
REQ1.STATUS IN ('U','H','O','R','S','Y') and req1.created_datetime > add_months(sysdate,-60)) T1
WHERE
(CAT1.SOURCE_CODE = 'F77' or CAT1.NSN = 'NSL') AND 
REGEXP_LIKE(CAT1.SMRC,'.....T') AND 
LNNVL(CAT1.USER_REF7 = 'Y') AND 
cat1.part = t1.select_from_part
union
SELECT CAT1.isgp_group_no
FROM GOLD__MASTER.CAT1@amd_pgoldlb_link,
(SELECT RAMP.NIIN FROM GOLD__MASTER.RAMP@amd_pgoldlb_link WHERE DELETE_INDICATOR IS NULL AND 
(RAMP.REQUISITION_OBJECTIVE > 0 OR RAMP.SERVICEABLE_BALANCE > 0 OR RAMP.DIFM_BALANCE > 0 OR RAMP.UNSERVICEABLE_BALANCE > 0)) T2
WHERE
(CAT1.SOURCE_CODE = 'F77' or CAT1.NSN = 'NSL') AND 
REGEXP_LIKE(CAT1.SMRC,'.....T') AND 
LNNVL(CAT1.USER_REF7 = 'Y') AND 
cat1.nsn <> 'NSL' AND 
SUBSTR(CAT1.NSN,6) = T2.NIIN
union
SELECT CAT1.isgp_group_no
FROM GOLD__MASTER.CAT1@amd_pgoldlb_link,
(SELECT WHSE.PART FROM GOLD__MASTER.WHSE@amd_pgoldlb_link, GOLD__MASTER.SC01@amd_pgoldlb_link WHERE SC01.SITE_CODE IN (:program_id || 'UKB',:program_id || 'CAN',:program_id || 'AUS',:program_id || 'NAT',:program_id || 'QAT',:program_id || 'IND',:program_id || 'UAE') AND 
SC01.SC LIKE :program_id || 'GISPICP%' AND SC01.SC = WHSE.SC AND WHSE.STOCK_LEVEL > 0) T3
WHERE
(CAT1.SOURCE_CODE = 'F77' or CAT1.NSN = 'NSL') AND 
REGEXP_LIKE(CAT1.SMRC,'.....T') AND  
LNNVL(CAT1.USER_REF7 = 'Y') AND 
CAT1.PART = T3.PART)  AND
NVL(CATA."MASTER",CAT1.PRIME) = CAT2.PART;


-- BEGIN CAT UPDATES

UPDATE amd_owner.WIP_CAT1 SET planner_code = (SELECT SYIN_VALUE FROM GOLD__MASTER.SYIV@amd_pgoldlb_link where customer = 'MDA' and SYIN_NAME = 'SYIN_DEFAULT_PLANNER_CODE')
WHERE WIP_CAT1.PLANNER_CODE IS NULL;

UPDATE amd_owner.WIP_CAT1 SET PLANNER_NAME = (SELECT PLANNER_NAME FROM GOLD__MASTER.SYPL@amd_pgoldlb_link where wip_cat1.PLANNER_CODE = sypl.planner_code);

update amd_owner.wip_cat1 set IMS_DESIGNATOR_NAME = 
(select max(use1.user_name)  
from use1@amd_pgoldlb_link use1
where USE1.EMPLOYEE_STATUS IN ('A','X') AND 
use1.ims_designator_code = wip_cat1.ims_designator_code)
where 
amd_owner.wip_cat1.ims_designator_name is null and 
exists(select max(use1.user_name)  
from use1@amd_pgoldlb_link use1
where USE1.EMPLOYEE_STATUS IN ('A','X') AND 
use1.ims_designator_code = wip_cat1.ims_designator_code);

update amd_owner.wip_cat1 set IMS_DESIGNATOR_NAME = 
(select max(use1.user_name) 
from uims@amd_pgoldlb_link uims, use1@amd_pgoldlb_link use1
where USE1.EMPLOYEE_STATUS IN ('A','X') AND 
use1.userid = uims.userid and 
uims.ALT_IMS_DES_CODE_B = 'T' AND 
uims.designator_code = wip_cat1.ims_designator_code)
where 
wip_cat1.ims_designator_name is null and 
exists(select max(use1.user_name) 
from uims@amd_pgoldlb_link uims, use1@amd_pgoldlb_link use1
where USE1.EMPLOYEE_STATUS IN ('A','X') AND 
use1.userid = uims.userid and 
uims.ALT_IMS_DES_CODE_B = 'T' AND 
uims.designator_code = wip_cat1.ims_designator_code);

-------- END CAT UPDATES

insert into amd_owner.wip_isgp 
( part, nsn, group_no, oou)
SELECT 
CAT1.PART,
CAT1.NSN,
ISGP.GROUP_NO,
ISGP.GROUP_PRIORITY "OOU" 
FROM 
amd_owner.wip_cat1 CAT1, gold__master.ISGP@amd_pgoldlb_link ISGP
WHERE 
CAT1.NSN <> 'NSL' AND 
CAT1.GROUP_NO = ISGP.GROUP_NO AND 
CAT1.PART = ISGP.PART
ORDER BY ISGP.GROUP_NO, ISGP.GROUP_PRIORITY, ISGP.SEQUENCE_NO;


 
insert into amd_owner.wip_item 
( item_id, master, prime, part, sc, site_code, location, qty, um, condition, description, status_servicable,
  status_suspended, status_avail, reserve_action, status_in_transit)
  SELECT 
  ITEM.ITEM_ID,
  CAT1.PRIME,
  CAT1.PRIME,
  ITEM.PART,
  ITEM.SC,
  SC01.SITE_CODE,
  ITEM.LOCATION,
  ITEM.QTY,
  ITEM.RECEIPT_UM UM,
  ITEM.CONDITION,
  SYCD.DESCRIPTION,
  ITEM.STATUS_SERVICABLE,
  ITEM.STATUS_SUSPENDED,
  ITEM.STATUS_AVAIL,
  ITEM.RESERVE_ACTION,
  ITEM.STATUS_IN_TRANSIT
  FROM amd_owner.w_item ITEM, amd_owner.W_SC01 SC01, amd_owner.wip_cat1 CAT1, amd_owner.W_SYCD SYCD,
  (SELECT DISTINCT OTHER_SC FROM amd_owner.W_CXFR CXFR WHERE  
  REGEXP_LIKE(OTHER_SC,:program_id || '....(HLD|OBS|CTL|DSO|ROR|COD|SUP|ICP|TIR)...G') AND
  REGEXP_LIKE(SC,'^' || :program_id || '....((HLD|OBS|CTL|DSO)(JNS|ATL|OKC)|(ICP|TIR|COD)...|RORPBL)G$') AND 
  OTHER_SC NOT LIKE :program_id || '%CODLGBG') CXFR
    WHERE 
  ITEM.SC = CXFR.OTHER_SC AND 
  ITEM.SC = SC01.SC AND 
  ITEM.PART = CAT1.PART AND 
  ITEM.CONDITION = SYCD.CONDITION;


-------------------#### Added ord1.created_datetime to the wip_ord1_history  . TP
-------------------#### And changed the source tables to use the local ones insteads of using the dblink. TP

insert into amd_owner.wip_ord1_history
(ORDER_NO, NEED_DATE, PO, PO_LINE, NH_ORDER_NO, PO_HEADING,  PART, SERIAL, QTY_ORDERED,  AGREEMENT_NUMBER, CONDITION, 
VENDOR_CODE, STATUS, SC, ORIGINAL_LOCATION, LOCATION, 
    REPAIR_TYPE, ACTION_TAKEN, SHORT_DESCRIPTION, PO_PRICE, CREATED_DOCDATE, CREATED_DATETIME, COMPLETED_DOCDATE, WIP_DATETIME, 
      DISCREPANCY, CORRECTIVE_ACTION, REMARKS, AWO_ALT, SITE_CODE, VENDOR_PHONE, VENDOR_CONTR_OFFICER, 
                VENDOR_CONTACT, VENDOR_EST_COST, VENDOR_ACT_COST, VENDOR_EST_RET_DATE, VENDOR_ACT_RET_DATE, 
                  WILL_CALL_DATE, CARRIER, SHIPMENT_CTRL_NO, INV_PAYMENT_TERMS, VENDOR_NAME)
                  SELECT ORD1.ORDER_NO,
                  ORD1.NEED_DATE,
                  ORD1.PO,
                  ORD1.PO_LINE, 
                  ORD1.NH_ORDER_NO,
                  ORDH1.PO_HEADING,
                  ORD1.PART,
                  ORD1.SERIAL,
                  ORD1.QTY_ORDERED,
                  ORH3.AGREEMENT_NUMBER,
                  ORD1.CONDITION,
                  ORD1.VENDOR_CODE,
                  ORD1.STATUS,
                  ORD1.SC,
                  ORD1.ORIGINAL_LOCATION,
                  ORD1.LOCATION,
                  ORD1.REPAIR_TYPE,
                  ORD1.ACTION_TAKEN,
                  SYAT.SHORT_DESCRIPTION,
                  NVL(ORD1.PO_PRICE, POI1.UNIT_PRICE) PO_PRICE,
                  ORD1.CREATED_DOCDATE,
		  ORD1.CREATED_DATETIME,
                  ORD1.COMPLETED_DOCDATE,
                  ORD1.WIP_DATETIME,
                  ORD1.DISCREPANCY,
                  ORD1.CORRECTIVE_ACTION,
                  ORD1.REMARKS,
                  ORD1.AWO_ALT,
                  ORDV.SITE_CODE,
                  ORDV.VENDOR_PHONE,
                  ORDV.VENDOR_CONTR_OFFICER,
                  ORDV.VENDOR_CONTACT,
                  ORDV.VENDOR_EST_COST,
                  ORDV.VENDOR_ACT_COST,
                  ORDV.VENDOR_EST_RET_DATE,
                  ORDV.VENDOR_ACT_RET_DATE,
                  ORDV.WILL_CALL_DATE,
                  ORDV.CARRIER,
                  ORDV.SHIPMENT_CTRL_NO,
                  ORDV.INV_PAYMENT_TERMS,
                  VENN.VENDOR_NAME 
                  FROM amd_owner.W_ORD1 ORD1, amd_owner.W_ORDV ORDV, amd_owner.W_VENN VENN, 
                  amd_owner.W_SYAT SYAT, amd_owner.W_ORDH1 ORDH1, 
                  (SELECT * FROM amd_owner.W_ORH3  WHERE SYSDATE BETWEEN BEGIN_DATE AND  END_DATE) ORH3,
                  (SELECT ORDER_NO, SEQ, SUM(UNIT_PRICE) UNIT_PRICE FROM amd_owner.W_POI1 POI1 WHERE POI1.CREATED_DATETIME >  ADD_MONTHS(SYSDATE,-24) GROUP BY ORDER_NO, SEQ) POI1
                  WHERE ORD1.ORDER_TYPE = 'J' AND ORD1.ACCOUNTABLE_YN = 'Y' AND 
                  ORD1.ORDER_NO = ORDV.ORDER_NO AND 
                  ORD1.VENDOR_CODE = VENN.VENDOR_CODE AND 
                  ORD1.ORDER_NO = POI1.ORDER_NO(+) AND 
                  ORD1.PO_SEQ = POI1.SEQ(+) AND
                  ORD1.DEFAULT_ID = ORDH1.DEFAULT_ID(+) AND
                  ORD1.ACTION_TAKEN = SYAT.ACTION_TAKEN(+) AND
                  ORD1.DEFAULT_ID = ORH3.DEFAULT_ID(+); 



------------------------#### Changed the 2nd a.IMS_DESIGNATOR_NAME to b.IMS_DESIGNATOR_NAME. 

update
( select 
 a.prime as aprime,
a.noun as anoun,
a.SMRC as aSMRC,
a.IMS_DESIGNATOR_CODE as aIMS_DESIGNATOR_CODE,
a.PLANNER_CODE as aPLANNER_CODE,
a.PLANNER_NAME as aPLANNER_NAME,
a.IMS_DESIGNATOR_NAME as aIMS_DESIGNATOR_NAME,
b.prime as bprime,
b.noun as bnoun,
b.SMRC as bSMRC,
b.IMS_DESIGNATOR_CODE as bIMS_DESIGNATOR_CODE,
b.PLANNER_CODE as bPLANNER_CODE,
b.PLANNER_NAME as bPLANNER_NAME,
b.IMS_DESIGNATOR_NAME as bIMS_DESIGNATOR_NAME 
from amd_owner.wip_ord1_history a, amd_owner.wip_cat1 b
where a.part = b.part)
set aprime = bprime,
anoun = bnoun,
aSMRC = bSMRC,
aIMS_DESIGNATOR_CODE = bIMS_DESIGNATOR_CODE,
aPLANNER_CODE = bPLANNER_CODE,
aPLANNER_NAME = bPLANNER_NAME,
aIMS_DESIGNATOR_NAME = bIMS_DESIGNATOR_NAME;


delete from amd_owner.wip_ord1_history
where prime is null;


insert into amd_owner.wip_ord1
(ORDER_NO, NEED_DATE, PO, PO_LINE, NH_ORDER_NO, PO_HEADING, PRIME, NOUN, SMRC, CRITICALITY, PART, SERIAL, QTY_ORDERED, IMS_DESIGNATOR_CODE,PLANNER_CODE,
  PLANNER_NAME, AGREEMENT_NUMBER, CONDITION, VENDOR_CODE, STATUS, SC, ORIGINAL_LOCATION, LOCATION, 
  REPAIR_TYPE, ACTION_TAKEN, SHORT_DESCRIPTION, PO_PRICE, CREATED_DOCDATE,COMPLETED_DOCDATE, WIP_DATETIME, 
  DISCREPANCY, CORRECTIVE_ACTION, REMARKS, AWO_ALT, SITE_CODE, VENDOR_PHONE, VENDOR_CONTR_OFFICER, 
  VENDOR_CONTACT, VENDOR_EST_COST, VENDOR_ACT_COST, VENDOR_EST_RET_DATE, VENDOR_ACT_RET_DATE, 
  WILL_CALL_DATE, CARRIER, SHIPMENT_CTRL_NO, INV_PAYMENT_TERMS, VENDOR_NAME, IMS_DESIGNATOR_NAME, CREATED_DATETIME,
  ACCOUNTABLE_YN, ORDER_TYPE)
select ORDER_NO, NEED_DATE, PO, PO_LINE, NH_ORDER_NO, PO_HEADING, PRIME, NOUN, SMRC, CRITICALITY, PART, SERIAL, QTY_ORDERED, IMS_DESIGNATOR_CODE,PLANNER_CODE,
  PLANNER_NAME, AGREEMENT_NUMBER, CONDITION, VENDOR_CODE, STATUS, SC, ORIGINAL_LOCATION, LOCATION, 
  REPAIR_TYPE, ACTION_TAKEN, SHORT_DESCRIPTION, PO_PRICE, CREATED_DOCDATE,COMPLETED_DOCDATE, WIP_DATETIME, 
  DISCREPANCY, CORRECTIVE_ACTION, REMARKS, AWO_ALT, SITE_CODE, VENDOR_PHONE, VENDOR_CONTR_OFFICER, 
  VENDOR_CONTACT, VENDOR_EST_COST, VENDOR_ACT_COST, VENDOR_EST_RET_DATE, VENDOR_ACT_RET_DATE, 
  WILL_CALL_DATE, CARRIER, SHIPMENT_CTRL_NO, INV_PAYMENT_TERMS, VENDOR_NAME, IMS_DESIGNATOR_NAME, CREATED_DATETIME,
  ACCOUNTABLE_YN, ORDER_TYPE from amd_owner.wip_ord1_history where status in ('O','R','U');


insert into amd_owner.wip_ramp 
( SRAN, NIIN, PRIME, RO, DL, RSP_LVL, RSP_OH, SVC_BAL,DIFM_BAL,OH,UNSRV_BAL,SUS_BAL)
SELECT SUBSTR (RAMP.SC, 8, 6) "SRAN",
       RAMP.NIIN,CATN.PRIME,
       RAMP.REQUISITION_OBJECTIVE "RO", 
       RAMP.DEMAND_LEVEL "DL",
       RSP.RSP_LVL,
       RSP.RSP_OH,
       RAMP.SERVICEABLE_BALANCE "SVC_BAL", 
       RAMP.DIFM_BALANCE "DIFM_BAL",
       (RAMP.SERVICEABLE_BALANCE + RAMP.DIFM_BALANCE) "OH",
       RAMP.UNSERVICEABLE_BALANCE "UNSRV_BAL", 
       RAMP.SUSPENDED_IN_STOCK "SUS_BAL"
FROM gold__master.RAMP@amd_pgoldlb_link RAMP, 
    (SELECT DISTINCT NIN, PRIME
       FROM amd_owner.wip_cat1) CATN,
    (SELECT NIIN, SC, 
         (NVL(WRM_LEVEL,0) + NVL(SPRAM_LEVEL,0) + NVL(HPMSK_LEVEL_QTY,0)) "RSP_LVL",
         (NVL(WRM_BALANCE,0) + NVL(SPRAM_BALANCE,0) + NVL(HPMSK_BALANCE,0)) "RSP_OH"
    FROM gold__master.RAMP@amd_pgoldlb_link RAMP 
    WHERE 
       SUBSTR (RAMP.SC, 8, 6) IN ('FB2805','FB4401','FB4402',
    'FB4403','FB4405','FB4408','FB4411','FB4415','FB4480','FB4412','FB4454',
    'FB4455','FB4486','FB4491','FB4621','FB4804','FB5814','FB5820','FB5846',
    'FB5851','FB5860','FB5873','FB5874','FB5878','FB5879','FB5880','FB5881',
        'FB5884','FB6151','FB6181','FB6322','FB6606','FB4479','FB5612','FB5685',
        'FB5621','FB5260','FB5209','FB5270','FB5240','FB5000','FB4418')) RSP
WHERE 
    RAMP.SC LIKE :program_id || '0008FB%G' AND 
    RAMP.DELETE_INDICATOR IS NULL AND  
    RAMP.NIIN = CATN.NIN AND 
    RAMP.NIIN = RSP.NIIN(+) AND 
    RAMP.SC = RSP.SC(+)
ORDER BY SUBSTR (RAMP.SC, 8, 6), RAMP.NIIN;




insert into amd_owner.wip_whse 
( part, site_code, sc, stock_level, reorder_point)
SELECT 
CAT1.PRIME,
SC01.SITE_CODE,
WHSE.SC,
WHSE.STOCK_LEVEL,
WHSE.REORDER_POINT
FROM amd_owner.W_WHSE WHSE, amd_owner.W_SC01 SC01, amd_owner.wip_cat1 CAT1
WHERE 
CAT1.PART = WHSE.PART AND 
REGEXP_LIKE(WHSE.SC,'^' || :program_id || 'GISPICP(AUS|UKB|SAC|CAN|QAT|UAE|IND)G$') AND
WHSE.SC = SC01.SC AND
STOCK_LEVEL > 0;

--------------------------------#### Changed from wip1@amd_pgoldlb_link to W_WIP1. TP.

insert into amd_owner.wip_wip1_history 
( item_id, created_doc_datetime, order_no, created_sys_datetime, created_userid, work_center,
  cday_span, remarks)
  SELECT ITEM_ID,
  CREATED_DOC_DATETIME,
  WIP1.ORDER_NO,
  CREATED_SYS_DATETIME, 
  CREATED_USERID, 
  WORK_CENTER, 
  CDAY_SPAN, 
  WIP1.REMARKS 
  FROM amd_owner.W_WIP1 WIP1, amd_owner.wip_ord1_history ORD1
  WHERE 
  WIP1.ORDER_NO = ORD1.ORDER_NO;


-------------------------- ### CDAY_SPAN query runs here. Provided by Dee.





begin
for cday_upd in (select t1.*, t2.*
                  from 
                  (SELECT rownum "r", t.*
                     from (select order_no "order_no", work_center "work_center", created_doc_datetime "created_doc_datetime", cday_span "cday_span"
                          from amd_owner.wip_wip1_history
                          order by order_no, created_doc_datetime) t) t1,
                  (SELECT rownum "r1", t.*
                     from (select order_no "order_no1", work_center "work_center1", created_doc_datetime "created_doc_datetime1", cday_span cday_span1
                          from amd_owner.wip_wip1_history
                          order by order_no, created_doc_datetime) t) t2
                  where 
                  t1."r" = t2."r1" - 1 and 
                  t1."cday_span" = 0 and
                  t1."order_no" = t2."order_no1") loop
                  update amd_owner.wip_wip1_history tbl set tbl.cday_span = round(cday_upd."created_doc_datetime1" - cday_upd."created_doc_datetime",4)
                  where tbl.cday_span = 0 and tbl.order_no = cday_upd."order_no" and tbl.work_center = cday_upd."work_center" and 
     tbl.created_doc_datetime = cday_upd."created_doc_datetime";
                  commit;
                  end loop;
end;
/

commit;


exec amd_owner.mta_truncate_table('wip_wip1','reuse storage');
exec amd_owner.mta_truncate_table('wip_wip1_detail','reuse storage');



insert into amd_owner.wip_wip1
( item_id, created_doc_datetime, order_no, created_sys_datetime, created_userid, work_center,
  cday_span, remarks)
  SELECT h.ITEM_ID, 
  CREATED_DOC_DATETIME,
  h.ORDER_NO,
  CREATED_SYS_DATETIME,
  CREATED_USERID,
  WORK_CENTER,
  CDAY_SPAN, 
  h.REMARKS
  FROM amd_owner.wip_wip1_history h, amd_owner.wip_ord1 o
  where h.order_no = o.order_no;


INSERT INTO amd_owner.WIP_WIP1_DETAIL(ORDER_NO, PRIME, ORD_DT, R_DT, STATUS, WIP_GROUP, CURR_WIP, DAYS)
SELECT 
"ORDER_NO",
"PRIME",
"ORD_DT",
"R_DT",
STATUS,
"WIP_GROUP",
MAX("CURRENT_WIP") "CURR_WIP",
round(SUM("DAYS"),2) "DAYS"
FROM
(select 
ord1.order_no "ORDER_NO",
ord1.PRIME,
ord1.created_datetime "ORD_DT",
ORD1.COMPLETED_DOCDATE "R_DT",
WIP1.CREATED_DOC_DATETIME WIP_DATETIME,
case when ORD1.WIP_DATETIME = WIP1.CREATED_DOC_DATETIME then 1 else 0 END "CURRENT_WIP",
case 
WHEN ORD1.STATUS IN ('R','C') AND WIP1.CREATED_DOC_DATETIME >= ORD1.COMPLETED_DOCDATE THEN 'R-STAT'
WHEN ORD1.STATUS IN ('R','C') AND WIP1.WORK_CENTER IN (SELECT WORK_CENTER FROM gold__master.SYWC@amd_pgoldlb_link SYWC WHERE JOB_ORDER_STATUS in ('R','C')) 
THEN 'R-STAT'
when wip1.work_center like '%TURNIN%' or wip1.work_center = 'RDP' THEN 'TURNIN'
WHEN WIP1.WORk_CENTER IN ('LOST IN CENTRAL WHS','SHIPPING') then 'PC'
when wip1.work_center IN ('HELD BUYER','HELD FOR BUYER/PRICE','HELD POCA','HELD TECH EVAL') THEN 'HELD BUYER'
WHEN (wip1.work_center LIKE 'HELD%' OR wip1.work_center LIKE 'DEFERRED%') AND 
      wip1.work_center NOT IN ('HELD BUYER','HELD FOR BUYER/PRICE','HELD POCA','HELD TECH EVAL') THEN 'HELD OTHER'
WHEN WIP1.WORK_CENTER like '%GRIEF%' THEN 'GRIEF'
WHEN WIP1.WORK_CENTER IN ('SHIP TO SUPPLIER') OR WIP1.WORK_CENTER IN (SELECT WORK_CENTER FROM gold__master.SYWC@amd_pgoldlb_link SYWC WHERE SYWC.WIP_STATUS 
in ('IN TRANSIT>SUPPLIER')) THEN 'SHIPPING'
WHEN (ORD1.COMPLETED_DOCDATE IS NULL OR WIP1.CREATED_DOC_DATETIME < ORD1.COMPLETED_DOCDATE) AND
     WIP1.WORK_CENTER IN (SELECT WORK_CENTER FROM gold__master.SYWC@amd_pgoldlb_link SYWC WHERE SYWC.WIP_STATUS in ('AT REPAIR FACILITY','AT SUPPLIER','IN 
TRANSIT>MDC') or
     LOCATION_USE_VENDOR = 'T')
     THEN 'IN-WORK SUPPLIER'
when wip1.work_center IN ('SEND TO NWP','NWP DELETED') THEN 'PR'
when WIP1.WORK_CENTER IN (SELECT WORK_CENTER FROM gold__master.SYWC@amd_pgoldlb_link SYWC WHERE SYWC.WIP_STATUS in ('AT BASE')) AND 
(NOT EXISTS(SELECT * FROM amd_owner.wip_wip1_history W1 WHERE W1.ORDER_NO = ORD1.ORDER_NO AND W1.WORK_CENTER IN ('SHIPPING','SEND TO NWP','SUPPLIER')) OR 
WIP1.CREATED_DOC_DATETIME < (SELECT MIN(CREATED_DOC_DATETIME) FROM amd_owner.wip_wip1_history W1 WHERE W1.ORDER_NO = ORD1.ORDER_NO AND W1.WORK_CENTER IN 
('SHIPPING','SEND TO NWP','SUPPLIER')))
THEN 'TURNIN'
ELSE 'IN-WORK SUPPLIER'
END "WIP_GROUP",
WIP1.WORK_CENTER,
CASE WHEN ord1.status IN ('U','O','R') AND ORD1.WIP_DATETIME = WIP1.CREATED_DOC_DATETIME THEN ROUND((SYSDATE + INTERVAL '2' HOUR) - WIP1.CREATED_DOC_DATETIME ,5) 
ELSE WIP1.CDAY_SPAN END "DAYS",
ORD1.STATUS
FROM amd_owner.wip_ord1_history ORD1, amd_owner.wip_wip1_history WIP1
WHERE
ORD1.ORDER_NO = WIP1.ORDER_NO)
GROUP BY "ORDER_NO", "PRIME", "ORD_DT", "R_DT", STATUS, "WIP_GROUP";


exit;
