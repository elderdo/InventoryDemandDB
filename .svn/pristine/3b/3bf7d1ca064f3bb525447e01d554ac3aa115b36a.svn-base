@echo off
SET EDITOR=winvi
SET OLDP=%PATH%
SET OLDCP=%CLASSPATH%
SET JRE=C:\Program Files\JavaSoft\JRE\1.4.2\
SET PATH=%JRE%bin;.;%PATH%
SET CLASSPATH=%JRE%lib;Amd2Xml.jar;classes12.zip;.
echo classpath=%CLASSPATH%

:menu
echo 1. Run SiteAsset 
echo 2. Run PartInfo 
echo 3. Run PartLeadTime 
echo 4. Run PartPricing
echo 9. Exit
set choice=
set /p choice=Make selection
if %choice%==9 goto End
if %choice%==4 goto PartPricing
if %choice%==3 goto PartLeadTime
if %choice%==2 goto PartInfo
if %choice%==1 goto SiteAsset
goto menu

:SiteAsset
@echo on
echo %CLASSPATH%
java.exe SiteAsset Xml.ini > Xml\SiteAsset.xml -d
type Xml\SiteAsset.xml
@echo off
goto menu

:PartInfo
@echo on 
java.exe PartInfo  Xml.ini > Xml\PartInfo.xml
type Xml\PartInfo.xml
@echo off
goto menu

:PartLeadTime
@echo on
java.exe PartLeadTime Xml.ini > Xml\PartLeadTime.xml
type Xml\PartLeadTime.xml
@echo off
goto menu

:PartPricing
@echo on
java.exe PartPricing Xml.ini -d > Xml\PartPricing.xml
type Xml\PartPricing.xml
@echo off
goto menu

:End
SET PATH=%OLDP%
SET CLASSPATH=%OLDCP%
