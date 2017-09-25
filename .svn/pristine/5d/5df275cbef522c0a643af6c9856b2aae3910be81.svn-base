@echo off
SET EDITOR=winvi
SET OLDP=%PATH%
SET OLDCP=%CLASSPATH%
SET JRE=C:\Program Files\JavaSoft\JRE\1.4.2\
SET PATH=%JRE%bin;.;%PATH%
SET CLASSPATH=%JRE%lib;Amd2Xml.jar;classes12.zip;.
echo classpath=%CLASSPATH%

:menu
echo 1. Run InvInfo 
echo 2. Run BackOrder 
echo 3. Run OrderInfo 
echo 4. Run OrderInfoLine
echo 5. Run Part Effectivity
echo 6. Run InTransit 
echo 7. Run RepairInfo 
echo 9. Exit
set choice=
set /p choice=Make selection
if %choice%==9 goto End
if %choice%==7 goto RepairInfo
if %choice%==6 goto InTransit
if %choice%==5 goto PartEff
if %choice%==4 goto OrderInfoLine
if %choice%==3 goto OrderInfo
if %choice%==2 goto BackOrder
if %choice%==1 goto InvInfo
goto menu


:InvInfo
@echo on
java.exe InvInfo Xml.ini > Xml\InvInfo.xml
type Xml\InvInfo.xml
@echo off
goto menu

:BackOrder
@echo on
java.exe BackOrder Xml.ini > Xml\BackOrder.xml
type Xml\BackOrder.xml
@echo off
goto menu

:OrderInfo
@echo on
java.exe OrderInfo Xml.ini > Xml\OrderInfo.xml
type Xml\OrderInfo.xml
@echo off
goto menu

:OrderInfoLine
@echo on
java.exe OrderInfoLine Xml.ini > Xml\OrderInfoLine.xml
type Xml\OrderInfoLine.xml
@echo off
goto menu

:PartEff
@echo on
java.exe PartEff Xml.ini > Xml\PartEff.xml
type Xml\PartEff.xml
@echo off
goto menu

:InTransit
@echo on
java.exe InTransit Xml.ini > Xml\InTransit.xml
type Xml\InTransit.xml
@echo off
goto menu

:RepairInfo
@echo on
java.exe RepairInfo Xml.ini > Xml\RepairInfo.xml
type Xml\RepairInfo.xml
@echo off
goto menu

:End
SET PATH=%OLDP%
SET CLASSPATH=%OLDCP%
