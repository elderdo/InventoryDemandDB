/*
      Author:   Douglas Elder  
    Revision:   1.0  
        Date:   31 Oct 2014
    Workfile:   loadCat1.sql  

    Rev 1.0   31 Oct 2014  Initial Rev - Douglas Elder
*/

/* Formatted on 10/31/2014 12:41:50 PM (QP5 v5.252.13127.32867) */
WHENEVER SQLERROR EXIT FAILURE
WHENEVER OSERROR EXIT FAILURE

SET TIME ON
SET TIMING ON
SET ECHO ON

UPDATE ramp a
   SET a.current_stock_number =
          (SELECT DISTINCT b.NSN
             FROM cat1 b
            WHERE b.nin = a.nsn AND b.nsn <> 'NSL')
 WHERE a.SC IN ('C170008FB2065G', 'C170008FB2029G', 'C170008FB2039G');
/

QUIT
