@echo off
:: vim: ts=2:sw=2:sts=2:et:syntax=dosbatch
:: execSqlplus.bat
:: Author: Douglas S. Elder
:: Date: 10/16/2014
:: Desc: Run sqlplus 
:: scripts 
:: An optional command line argument
:: specifying what script to be executed
:: can be used
:: Rev 1.0 10/16/2014
:: Rev 1.1 12/12/2017 added command line args -o -p and -d
::                    used OPT_FILE for env var override file
::                    used UID, HOST_STRING, PWD and SCRIPT
::                    env var's to run sqlplus
:: Rev 1.2 04/09/2818 Changed ORACLE_HOME to C:\Oracle\11gRclient64

setlocal enableextensions enabledelayedexpansion

:: Tell sqlplus it can find
:: scripts in the current directory
:: this may be overridden
:: in the dbConnect.txt file
set ORACLE_PATH=%CD%
set PWD=
set UID=
set SCRIPT=

set ORACLE_HOME=c:\Oracle\11gR202Client64bit
if not EXIST %ORACLE_HOME%\NUL goto oraHomeErr
set BIN=c:\Oracle\11gR202Client64bit\bin
if not EXIST %BIN%\NUL goto oraBinErr
set TNS_ADMIN=%ORACLE_HOME%\network\admin
if not EXIST %TNS_ADMIN%\NUL goto oraTnsErr
set PATH=%BIN%\bin;%PATH%

:: set default connection
set HOST_STRING=RMADP
set UID=%USERNAME%
set OPT_FILE=dbConnect.txt

:loop
if "%1"=="-o" goto setOptFile
if "%1"=="-p" goto setPasswd
if "%1"=="-d" goto setDebug
if "%1:~0,1%"=="-" goto invalidSwitch

:: if there is a positional command line argument
:: use that for the script to execute
if not "%1"=="" (
  set SCRIPT=%1
)


if EXIST %OPT_FILE% (
for /f "eol=;" %%A in (%OPT_FILE%) do (
	  set %%A
  )
)


:: if there is a script to 
:: execute, make sure it exists
:: and add the @ at the beginning 
:: of the file name
if not "%SCRIPT%"=="" (

  if EXIST "%SCRIPT%" (
    set SCRIPT=@%SCRIPT%
  ) else (
    if EXIST "%ORACLE_PATH%\%SCRIPT%" (
       set SCRIPT=@%SCRIPT%
    ) else (
      goto oraScriptErr
    )
  )

) 

set RC=
set OPT=
:: if there is a password assume this is a pure
:: batch execution. Allow only one login attempt
:: and suppress all SQL*Plus informat and prompt messages
if not "%PWD%"=="" set OPT="-LOGON -SILENT"
set OPT=%OPT:"=%
%BIN%\sqlplus %OPT% %UID%@%HOST_STRING%/%PWD% %SCRIPT%
set RC=%ERRORLEVEL%
if "%RC%"=="0" (
  @echo.sqlplus has successfully executed
) else (  
  @echo.sqlplus did not run successfully
)
goto:done

:setDebug
shift
@echo on
goto loop

:setScript
shift
if "%1"=="" goto Usage
set SCRIPT=%1
shift
goto loop

:setPwd
shift
if "%1"=="" goto Usage
set PWD=%1
shift
goto loop

:setOptFile
shift
if "%1"=="" goto Usage
set OPT_FILE=%1
shift
goto loop



:oraHomeErr
@echo.
@echo.Cannot find directory %ORACLE_HOME%
goto:done

:oraBinErr
@echo.
@echo.Cannot find directory %BIN%
goto:done

:oraTnsErr
@echo.
@echo.Cannot find directory %TNS_ADMIN%
goto:done

:invalidSwitch
@echo.
@echo."%1 is an invalid switch"
goto:Usage

:oraScriptErr
@echo.
@echo.Cannot find sqlplus script %SCRIPT%
goto:Usage

:Usage
@echo.
@echo."execSqlplus.bat [ -d -o opt_file -p pwd script ]
@echo."where -d turns on debug"
@echo."      -o opt_file contains env overrides"
@echo."      -p pwd is the Oracle password for the account being ussed"
@echo."      script is a positional param after the command line arg switches"
@echo."      it contains the SQL*Plus command and DML to execute."


endlocal

:done
if "%PWD%"=="" pause
