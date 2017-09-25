@echo off
SET EDITOR=winvi
SET OLDP=%PATH%
SET OLDCP=%CLASSPATH%
SET JRE=C:\Program Files\JavaSoft\JRE\1.4.2\
SET PATH=%JRE%bin;.;%PATH%
SET CLASSPATH=%JRE%lib;Amd2Xml.jar;classes12.zip;log4j-1.2.3.jar;log4j.properties;.
echo classpath=%CLASSPATH%

:menu
echo 1. Run DemandInfo 
echo 2. Run Demands 
echo 3. Run ExtForecast 
echo 4. Run FlightActy
echo 5. Run FlightActyForecast
echo 9. Exit
set choice=
set /p choice=Make selection
if %choice%==9 goto End
if %choice%==5 goto FlightActyForecast
if %choice%==4 goto FlightActy
if %choice%==3 goto ExtForecast
if %choice%==2 goto Demands
if %choice%==1 goto DemandInfo
goto menu

:DemandInfo
@echo on
echo %CLASSPATH%
java.exe DemandInfo Xml.ini > Xml\DemandInfo.xml -d
type Xml\DemandInfo.xml
@echo off
goto menu

:Demands
@echo on 
java.exe Demands  Xml.ini > Xml\Demands.xml
type Xml\Demands.xml
@echo off
goto menu

:ExtForecast
@echo on
java.exe ExtForecast Xml.ini > Xml\ExtForecast.xml
type Xml\ExtForecast.xml
@echo off
goto menu

:FlightActy
@echo on
java.exe FlightActy Xml.ini -d > Xml\FlightActy.xml
type Xml\FlightActy.xml
@echo off
goto menu

:FlightActyForecast
@echo on
java.exe FlightActyForecast Xml.ini > Xml\FlightActyForecast.xml
type Xml\FlightActyForecast.xml
@echo off
goto menu


:End
SET PATH=%OLDP%
SET CLASSPATH=%OLDCP%
