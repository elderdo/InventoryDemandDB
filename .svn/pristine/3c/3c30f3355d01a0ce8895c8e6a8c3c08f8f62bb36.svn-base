@echo off
SET EDITOR=winvi
SET OLDP=%PATH%
SET OLDCP=%CLASSPATH%
SET JRE=C:\Program Files\JavaSoft\JRE\1.4.2\
SET PATH=%JRE%bin;.;%PATH%
SET CLASSPATH=%JRE%lib;Amd2Xml.jar;classes12.zip;.
echo classpath=%CLASSPATH%

:menu
echo 1. Run LocPartLeadtime 
echo 2. Run PartFactors 
echo 3. Run LocPartOverride 
echo 9. Exit
set choice=
set /p choice=Make selection
if %choice%==9 goto End
if %choice%==3 goto LocPartOverride
if %choice%==2 goto PartFactors
if %choice%==1 goto LocPartLeadtime
goto menu

:LocPartLeadtime
@echo on
echo %CLASSPATH%
java.exe LocPartLeadtime Xml.ini > Xml\LocPartLeadtime.xml -d
type Xml\LocPartLeadtime.xml
@echo off
goto menu

:PartFactors
@echo on 
java.exe PartFactors  Xml.ini > Xml\PartFactors.xml
type Xml\PartFactors.xml
@echo off
goto menu

:LocPartOverride
@echo on
java.exe LocPartOverride Xml.ini > Xml\LocPartOverride.xml
type Xml\LocPartOverride.xml
@echo off
goto menu


:End
SET PATH=%OLDP%
SET CLASSPATH=%OLDCP%
