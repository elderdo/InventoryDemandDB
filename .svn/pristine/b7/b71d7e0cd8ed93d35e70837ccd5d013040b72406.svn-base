rem   $Author:   zf297a  $
rem $Revision:   1.0  $
rem     $Date:   Mar 30 2006 11:35:38  $
rem $Workfile:   fixXml.bat  $
rem This batch file can be used to convert an A2A xml file into standard xml
rem WARNING: This batch file does not check the input file to see if it is an
rem A2A file.
rem
rem
@echo off
if (%1) == () goto usage
echo ^<?xml version="1.0"?^> > %temp%\fixXml.xml
echo ^<xml^> >> %temp%\fixXml.xml
type %1 >> %temp%\fixXml.xml
echo ^</xml^> >> %temp%\fixXml.xml
copy %temp%\fixXml.xml %1
echo %1 converted to regular xml
goto end

:usage
echo Usage: %0 file 
echo where file is the name of the A2A xml file you want to convert to standard xml
:end
