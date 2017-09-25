/*
	$Author:   zf297a  $
      $Revision:   1.2  $
          $Date:   03 Dec 2008 12:54:38  $
      $Workfile:   stl_escm_link.sql  $
           $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\DBLinks\Production\stl_escm_link.sql.-arc  $
/*   
/*      Rev 1.2   03 Dec 2008 12:54:38   zf297a
/*   Fixed userid and password
/*   
/*      Rev 1.1   09 May 2008 10:56:30   zf297a
/*   The production database will be converted to stl_pescm on the weekend of May 23rd, 2008
/*   
/*      Rev 1.0   02 May 2008 12:32:32   zf297a
/*   Initial revision.

*/
SET DEFINE OFF;
DROP DATABASE LINK "STL_ESCM_LINK.BOEINGDB";

CREATE DATABASE LINK "STL_ESCM_LINK.BOEINGDB"
 CONNECT TO c17devlpr
 IDENTIFIED BY bqza1vcz
 USING 'STL_PESCM';


