@echo on
:: loadBenchStock.bat
:: Author: Douglas S. Elder
:: Date: 08/22/2013
:: Description: Use sqlplus and sqlldr to load
:: a csv file into table amd_owner.xbench_stock
:: 3/7/2016 use double quotes when doing rename 
::          in case newest csv files contains spaces
:: 2/17/2015 find newest csv or txt file
::           and save log and bad files to a directory
::           for amdd, amdi, and amdp
:: 9/6/2013 changed file name to loadBenchStock
:: 9/6/2013 changed ctl file name
:: 9/6/2013 changed truncate script name
:: 8/22/2013 initial Rev
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
if "%newest%"=="benchstock.csv" goto noNewCsv
del /F benchstock.csv
if %ERRORLEVEL% neq 0 goto cannotDel
ren "%newest%" benchstock.csv
if %ERRORLEVEL% neq 0 goto cannotRen

@echo using %newest% as benchstock.csv

if "%DEV%"=="Y" (
  call execSqlldr.bat %DEBUGOPT% -o AMDD.txt
  if %ERRORLEVEL% leq 2 (
    if EXIST benchstock.bad call moveWithTimeStamp.bat benchstock.bad amdd
    if EXIST benchstock.log  call moveWithTimeStamp.bat benchstock.log amdd
    if EXIST benchstock.csv call copyWithTimeStamp.bat benchstock.csv amdd
  )
)

if "%INT%"=="Y" (
  call execSqlldr.bat %DEBUGOPT% -o AMDI.txt
  if %ERRORLEVEL% leq 2 (
    if exist benchstock.bad call moveWithTimeStamp.bat benchstock.bad amdi
    if exist benchstock.log call moveWithTimeStamp.bat benchstock.log amdi
    if exist benchstock.csv call copyWithTimeStamp.bat benchstock.csv amdi
  )
)

if "%PRD%"=="Y" (
  call execSqlldr.bat %DEBUGOPT% -o AMDP.txt
  if %ERRORLEVEL% leq 2 (
    if exist benchstock.bad call moveWithTimeStamp.bat benchstock.bad amdp
    if exist benchstock.log call moveWithTimeStamp.bat benchstock.log amdp
    if exist benchstock.csv call copyWithTimeStamp.bat benchstock.csv amdp
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
@echo.loadbenchstock.bat [ -p -i -d -w pwd -x ]
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
@echo.Unable to ren benchstock.csv to %newest%
goto:eof

:cannotDel
@echo.Unable to delete benchstock.csv
goto:eof

:inputNotFound
@echo.Could not find csv or txt file
goto:eof

endlocal
