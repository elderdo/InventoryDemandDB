::	$Author:   zf297a  $
::    $Revision:   1.1  $
::        $Date:   04 Jun 2007 11:48:32  $
::    $Workfile:   xe4AllPartsLCD.bat  $

::	This script is used to produce an xe4 file.

@echo off

sqlplus bsrm_loader@amdd/fromnewyork @xe4AllPartsLCD_012307.sql

gawk -f awkReplaceBlanks.awk file1.txt > newFile1.txt
echo newFile1.txt created
