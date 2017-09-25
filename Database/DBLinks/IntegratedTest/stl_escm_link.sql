/*
	$Author:   zf297a  $
      $Revision:   1.2  $
          $Date:   03 Dec 2008 12:54:10  $
      $Workfile:   stl_escm_link.sql  $
           $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Database\DBLinks\IntegratedTest\stl_escm_link.sql.-arc  $
/*   
/*      Rev 1.2   03 Dec 2008 12:54:10   zf297a
/*   Fixed userid and password
/*   
/*      Rev 1.1   02 May 2008 12:29:40   zf297a
/*   Added set define off and drop statements
/*   
/*      Rev 1.0   02 May 2008 12:20:20   zf297a
/*   Initial revision.
	
*/
SET DEFINE OFF;
DROP DATABASE LINK "STL_ESCM_LINK.BOEINGDB";

CREATE DATABASE LINK "STL_ESCM_LINK.BOEINGDB" 
  CONNECT TO c17pgm 
  IDENTIFIED BY C1e3dc1c 
  USING 'STL_TESCM';

