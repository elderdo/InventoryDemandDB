@echo on
:: loadamdWarnerRobinsDemands.bat
:: Author: Douglas S. Elder
:: Date: 08/13/2017
:: Description: Use sqlldr to load
:: a csv file into table amd_owner.amd_warner_robins_demands
::
::
::
@echo off
setlocal ENABLEDELAYEDEXPANSION 
:: set defaults
set DEV=
set DEBUGOPT=
set INT=
set PRD=
set ALL=Y

:loop
if "%1"=="-d" goto setDev
if "%1"=="-i" goto setIntegrated
if "%1"=="-p" goto setProd
if "%1"=="-w" goto setPwd
if "%1"=="-x" goto setDebug
if not "%1"=="" goto usage

if "%ALL%"=="Y" (
  set DEV=Y
  set INT=Y
  set PRD=Y
)

:: get most recent csv or txt file
for /f "tokens=*" %%a in ('dir /b /od *.csv') do set newest=%%a
:: use the most recent file as input
if "%newest%"=="" goto inputNotFound
if "%newest%"=="amdWarnerRobinsDemands.csv" goto noNewCsv
del /F amdWarnerRobinsDemands.csv
if %ERRORLEVEL% neq 0 goto cannotDel
ren "%newest%" amdWarnerRobinsDemands.csv
if %ERRORLEVEL% neq 0 goto cannotRen

@echo using %newest% as amdWarnerRobinsDemands.csv

if "%DEV%"=="Y" (
  call execSqlldr.bat %DEBUGOPT% -o AMDD.txt
  if %ERRORLEVEL% leq 2 (
    if EXIST amdWarnerRobinsDemands.bad call moveWithTimeStamp.bat amdWarnerRobinsDemands.bad amdd
    if EXIST amdWarnerRobinsDemands.log  call moveWithTimeStamp.bat amdWarnerRobinsDemands.log amdd
    if EXIST amdWarnerRobinsDemands.csv call copyWithTimeStamp.bat amdWarnerRobinsDemands.csv amdd
  )
)

if "%INT%"=="Y" (
  call execSqlldr.bat %DEBUGOPT% -o AMDI.txt
  if %ERRORLEVEL% leq 2 (
    if exist amdWarnerRobinsDemands.bad call moveWithTimeStamp.bat amdWarnerRobinsDemands.bad amdi
    if exist amdWarnerRobinsDemands.log call moveWithTimeStamp.bat amdWarnerRobinsDemands.log amdi
    if exist amdWarnerRobinsDemands.csv call copyWithTimeStamp.bat amdWarnerRobinsDemands.csv amdi
  )
)

if "%PRD%"=="Y" (
  call execSqlldr.bat %DEBUGOPT% -o AMDP.txt
  if %ERRORLEVEL% leq 2 (
    if exist amdWarnerRobinsDemands.bad call moveWithTimeStamp.bat amdWarnerRobinsDemands.bad amdp
    if exist amdWarnerRobinsDemands.log call moveWithTimeStamp.bat amdWarnerRobinsDemands.log amdp
    if exist amdWarnerRobinsDemands.csv call copyWithTimeStamp.bat amdWarnerRobinsDemands.csv amdp
  )
)
goto:eof

:setPwd
shift
if "%1"== goto usage
set PWD="-p %1"
goto loop

:setDev
shift
set DEV=Y 
set ALL=N
goto loop

:setIntegrated
shift
set INT=Y
set ALL=N
goto loop

:setProd
shift
set PRD=Y
set ALL=N
goto loop

:setDebug
shift
set DEBUGOPT=-d
@echo on
goto loop

:usage
@echo.loadamdWarnerRobinsDemands.bat [ -p -i -d -w pwd -x ]
@echo.where  -d is for dev
@echo.       -i is for integrated
@echo.       -p is for prod
@echo.       -w sets the Oracle password for %USERNAME%
@echo.       -x turns on debug
goto:eof

:noNewCsv
@echo.No new csv file found
goto:eof

:cannotRen
@echo.Unable to ren amdWarnerRobinsDemands.csv to %newest%
goto:eof

:cannotDel
@echo.Unable to delete amdWarnerRobinsDemands.csv
goto:eof

:inputNotFound
@echo.Could not find csv or txt file
goto:eof

endlocal
