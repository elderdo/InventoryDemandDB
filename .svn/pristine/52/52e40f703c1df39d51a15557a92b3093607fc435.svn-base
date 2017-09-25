@echo off
SET EDITOR=winvi
SET OLDP=%PATH%
SET OLDCP=%CLASSPATH%
SET JRE=C:\Program Files\JavaSoft\JRE\1.4.2\
SET PATH=%JRE%bin;.;%PATH%
SET CLASSPATH=%JRE%lib;Amd2Xml.jar;ojdbc14.jar;.
echo classpath=%CLASSPATH%
if NOT !%1==! goto processArgs

:menu
echo 1. Run CreateAddChange 
echo 2. Run CreateDeletes
echo 9. Exit
set choice=
set /p choice=Make selection
if %choice%==9 goto End
if %choice%==8 goto RepairInfo
if %choice%==7 goto DemandInfo
if %choice%==6 goto LocPartLeadTime
if %choice%==5 goto PartFactors
if %choice%==4 goto PartLeadTime
if %choice%==3 goto createAll
if %choice%==2 goto CreateDeletes
if %choice%==1 goto CreateAddChange
goto menu

:createAll
goto menu

:CreateAddChange
@echo on 
Call writeXml.bat SpoUser
Call writeXml.bat SiteAsset
Call writeXml.bat PartInfo
call writeXml.bat PartLeadTime
call writeXml.bat PartFactors
call writeXml.bat LocPartLeadTime
call writeXml.bat DemandInfo
call writeXml.bat RepairInfo
call writeXml.bat InvInfo
call writeXml.bat InTransit
call writeXml.bat BackOrder
call writeXml.bat BomDetail
call writeXml.bat OrderInfo
call writeXml.bat ExtForecast
call writeXml.bat LocPartOverride
call writeXml.bat FlightActy
call writeXml.bat FlightActyForecast
@echo off
goto menu

:CreateDeletes
@echo on 
Call writeXml.bat SpoUser_DEL
Call writeXml.bat SiteAsset_DEL
Call writeXml.bat PartInfo_DEL
call writeXml.bat PartLeadTime_DEL
call writeXml.bat PartFactors_DEL
call writeXml.bat LocPartLeadTime_DEL
call writeXml.bat DemandInfo_DEL
call writeXml.bat RepairInfo_DEL
call writeXml.bat InvInfo_DEL
call writeXml.bat InTransit_DEL
call writeXml.bat BackOrder_DEL
call writeXml.bat OrderInfo_DEL
call writeXml.bat ExtForecast_DEL
call writeXml.bat LocPartOverride_DEL
call writeXml.bat FlightActy_DEL
call writeXml.bat FlightActyForecast_DEL
@echo off
goto menu

:SiteAsset
@echo on
echo %CLASSPATH%
java.exe SiteAsset Xml.ini > Xml\SiteAsset.xml -d
wc -l Xml\SiteAsset.xml
@echo off
goto menu

:PartInfo
@echo on 
date /t
time /t
java.exe Table2Xml  Xml.ini PartInfo > Xml\PartInfo.xml
date /t
time /t
wc -l Xml\PartInfo.xml
@echo off
goto menu

:SiteAsset
@echo on
java.exe SiteAsset Xml.ini > Xml\SiteAsset.xml
type Xml\SiteAsset.xml
@echo off
goto menu

:PartLeadTime
@echo on
date /t
time /t
java.exe Table2Xml  Xml.ini PartLeadTime > Xml\PartLeadTime.xml
date /t
time /t
wc -l Xml\PartLeadTime.xml
@echo off
goto menu

:PartFactors
@echo on
date /t
time /t
java.exe Table2Xml  Xml.ini PartFactors > Xml\PartFactors.xml
date /t
time /t
wc -l Xml\PartFactors.xml
@echo off
goto menu

:LocPartLeadTime
@echo on
java.exe Table2Xml  Xml.ini LocPartLeadTime > Xml\LocPartLeadTime.xml
wc -l Xml\LocPartLeadTime.xml
@echo off
goto menu

:DemandInfo
@echo on
java.exe DemandInfo Xml.ini > Xml\DemandInfo.xml
type Xml\DemandInfo.xml
@echo off
goto menu

:RepairInfo
@echo on
date /t
time /t
java.exe Table2Xml  Xml.ini DemandInfo > Xml\DemandInfo.xml
date /t
time /t
wc -l Xml\DemandInfo.xml
@echo off
goto menu

:processArgs
if NOT EXIST %1.sql echo %1.sql does not exist
if NOT EXIST %1.sql goto end
call writeXml.bat %1
SHIFT
if NOT !%1==! goto processArgs

:End
SET PATH=%OLDP%
SET CLASSPATH=%OLDCP%
