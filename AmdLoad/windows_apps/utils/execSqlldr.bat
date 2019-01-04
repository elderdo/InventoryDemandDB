@echo off
:: vim: ts=2:sw=2:sts=2:et:syntax=dosbatch
:: execSqlldr.bat
:: Author: Douglas S. Elder
:: Date: 11/18/2014
:: Desc: Run sqlldr 
:: scripts 
:: An optional command line argument
:: specifying what opt file to use
:: Rev 1.0 11/10/2014
:: Rev 1.1 add slash between HOST_STRING and PWD env variables
:: Rev 1.2 Made ORACLE_HOME the same as the one used by
::         exeSqlplus.bat
:: Rev 1.3 09/05/2018 changed ORACLE_HOME because of new install of the 
::         Oracle client

setlocal enableextensions enabledelayedexpansion

set ORACLE_HOME=C:\Oracle\12cR2client64bit

set PWD=
set CTL_FILE=
if not EXIST %ORACLE_HOME%\NUL goto oraHomeErr

set BIN=%ORACLE_HOME%\bin
if not EXIST %BIN%\NUL goto oraBinErr

set TNS_ADMIN=%ORACLE_HOME%\network\admin
if not EXIST %TNS_ADMIN%\NUL goto oraTnsErr

set PATH=%BIN%\bin;%PATH%

:: set default connection
set HOST_STRING=AMDD
set UID=%USERNAME%

set OPT_FILE=dbConnect.txt

:loop
if "%1"=="-o" goto setOptFile
if "%1"=="-p" goto setPasswd
if "%1"=="-d" goto setDebug
if "%1"=="-c" goto setCtl

if EXIST "%OPT_FILE%" (
for /f "eol=;" %%A in (%OPT_FILE%) do (
	  set %%A
  )
)

if "%CTL_FILE%"=="" goto MissingCtl
if not EXIST "%CTL_FILE%" goto badCtl
if not EXIST "%DATA_FILE%" goto badData

set RC=
%BIN%\sqlldr %UID%@%HOST_STRING%/%PWD% control=%CTL_FILE% data=%DATA_FILE% ^
        rows=10000 readsize=10000000 bindsize=10000000 ^
        log=%APPNAME%.log ^
        bad=%APPNAME%.bad

set RC=%ERRORLEVEL%
if "%RC%"=="0" @echo.sqlldr has successfully executed
if "%RC%"=="2" @echo.sqlldr has executed with a warning
if "%RC%"=="3" @echo.sqlldr has failed
if "%RC%"=="4" @echo.sqlldr has had a fatal error
goto:done

:setDebug
shift
@echo on
goto loop

:setPwd
shift
if "%1"=="" goto Usage
set PWD=/%1
shift
goto loop

:setOptFile
shift
if "%1"=="" goto Usage
set OPT_FILE=%1
shift
goto loop

:setCtl
shift
if "%1"=="" goto Usage
set CTL_FILE=%1
shift
goto loop

:badData
@echo.
@echo %DATA_FILE% does not exist
goto:done

:badCtl
@echo.
@echo %CTL_FILE% does not exist
goto:done

:oraHomeErr
@echo.
@echo.Cannot find directory %ORACLE_HOME%
goto:done

:oraBinErr
@echo.
@echo.Cannot find directory %BIN%
goto:done

:MissingCtl
@echo.
@echo."You must supply a ctl file for SQL*Loader to run"
goto:Usage

:oraTnsErr
@echo.
@echo.Cannot find directory %TNS_ADMIN%
goto:done

:Usage
@echo.
@echo."execSqlldr.bat [ -c ctl_file -d -o opt_file -p pwd ]
@echo."where -c ctl_file is the control file for SQL*Loader to run"
@echo."      -d turns on debug"
@echo."      -o opt_file contains env overrides"
@echo."      -p pwd is the Oracle password for the account being ussed"


endlocal

:done
if "%PWD%"=="" pause
