    /*   				
       $Author:   c970183  $
     $Revision:   1.0  $
         $Date:   May 23 2005 09:11:34  $
     $Workfile:   AMD_VALID_SMR.fnc  $
	  $Log:   \\www-amssc-01\pds\archives\SDS-AMD\Database\Functions\AMD_VALID_SMR.fnv  $
/*   
/*      Rev 1.0   May 23 2005 09:11:34   c970183
/*   Initial revision.
*/
CREATE OR REPLACE FUNCTION AMD_VALID_SMR(SMRCODE VARCHAR2)
     RETURN  VARCHAR2 IS
     VALIDFLAG   VARCHAR2(1) ;
--
--  As of 1/29/2000  SMR Code is valid only the 6th digit
--			   is 'T', 'P', 'N'.
--
   BEGIN
   IF    NVL(SUBSTR(SMRCODE,6,1),'!') = 'T' THEN
         VALIDFLAG := 'Y' ;
   ELSIF NVL(SUBSTR(SMRCODE,6,1),'!') = 'P' THEN
         VALIDFLAG := 'Y' ;
   ELSIF NVL(SUBSTR(SMRCODE,6,1),'!') = 'N' THEN
         VALIDFLAG := 'Y' ;
   ELSE
         VALIDFLAG := 'N' ;
   END IF;
         RETURN(VALIDFLAG) ;
   END AMD_VALID_SMR;
/

