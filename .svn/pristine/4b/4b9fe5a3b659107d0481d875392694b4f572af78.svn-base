whenever sqlerror exit FAILURE
whenever oserror exit FAILURE

-- only one header row 
set pagesize 0   
-- remove trailing blanks 
set trimspool on 
-- this may or may not be useful...depends on your headings. 
set headsep off  
set linesize 200 
set echo off
set term off
set heading off
set feedback off

spool ../data/amd_l67_source.csv

select 'DIC,RI,NSN,MMC,NOMENCLATURE,DOC_NO,ATC,TRIC,TTPC,DMD_CD,TRANS_DATE,TRANS_SER,MARKED_FOR,ACTION_QTY,REASON,SRAN,DOFD,DOLD,UI,SUPP_ADDRESS,ERC,MIC,FILENAME' from dual ;

select DIC || ',' ||RI || ',' ||NSN || ',' ||MMC || ',"' ||replace(NOMENCLATURE,'"','^') || '","' ||DOC_NO || '",' ||ATC || ',' ||TRIC || ',' ||TTPC || ',' ||DMD_CD || ',' ||to_char(TRANS_DATE,'DD-MON-YY') || ',' ||TRANS_SER || ',"' ||MARKED_FOR || '",' ||ACTION_QTY || ',' ||REASON || ',' ||SRAN || ',' ||to_char(DOFD,'DD-MON-YY') || ',' ||to_char(DOLD,'DD-MON-YY') || ',' ||UI || ',' ||SUPP_ADDRESS || ',' ||ERC || ',' ||MIC || ',' ||FILENAME
from amd_l67_source ;


spool off

exit
