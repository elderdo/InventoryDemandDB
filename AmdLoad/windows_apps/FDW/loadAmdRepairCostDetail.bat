:: loadAmdReapirCostDetail.bat
:: Author: Douglas S. Elder
:: Date: 12/12/2011
:: Description: Use sqlplus and sqlldr to load
:: a csv file into table amd_owner.amd_repair_cost_detail
::
:: Rev 3/6/2013 by DSE - added error messages for missing data file and password
::                       added :mostRecent to look for the most recent csv file
::                       as input
:: Rev 8/15/2012 by DSE - checked for directories existing
::     and then create only if they don't exit
:: allow -f option not to have an arg by checking a dash
:: argument following it
:: abort if password not set
:: abort if uid/pwd dialog box is closed instead selecting the OK 
:: button
::
:: Rev 11/8/2012 by DSE - fixed if '%var:~0,1%'=='- goto listFiles
:: by using double quotes and exclamation if "!var:~0,1!"=="-" goto listFiles
:: fixed if not exist %yy%_%mm%_%dd%\nul (mkdir %yy%_%mm%_%dd%\%ENV%)
:: by adding %ENV% if not exist %yy%_%mm%_%dd%\%ENV%\nul (mkdir %yy%_%mm%_%dd%\%ENV%)
:: Added the Environment to the title of the password HTA dialog and used 
:: replace.vbs to set it to the correct value
::
@echo off
setlocal ENABLEDELAYEDEXPANSION 
:: set defaults
set SQLPLUS_SCRIPT=truncateAmdRepairCostDetail.sql
set CONTROL_FILE=amdRepairCostDetail.ctl
set ENV=AMDD
set ORACLE_HOME=c:\oracle\11gR2client64bit
set THIS_FILE=%0
set DATA_FILE=

:loop
if "%1"=="help" goto Usage
if "%1"=="/h" goto Usage
if "%1"=="/?" goto Usage
if "%1"=="?" goto Usage
if "%1"=="-c" goto setControlFile
if "%1"=="-d" goto setDebug
if "%1"=="-e" goto setEnv
if "%1"=="-f" goto setDataFile
if "%1"=="-h" goto Usage
if "%1"=="-o" goto setOracleHome
if "%1"=="-p" goto setPassword
if "%1"=="-s" goto setSqlplusScript
if "%1"=="-u" goto setUserid

if not exist %SQLPLUS_SCRIPT% goto badScript
if not exist %CONTROL_FILE% goto badControlFile
if not exist %ORACLE_HOME%\bin\sqlplus.exe goto badSqlplus
if not exist %ORACLE_HOME%\bin\sqlldr.exe goto badSqlldr
if "%UID%"=="" set UID=%USERNAME%
if "%PWD%"=="" goto getPWD
if "%PWD%"=="" (
  @echo.password not entered
  goto done
)
if not "%1"=="" goto getDataFile


:exec
if "%PWD%"=="" goto noPWD
if "%DATA_FILE%"=="" call :mostRecent
if "%DATA_FILE%"=="" goto done
@echo.%DATA_FILE%
%ORACLE_HOME%\bin\sqlplus %UID%@%ENV%/%PWD% @%SQLPLUS_SCRIPT%
if %ERRORLEVEL% neq 0 goto sqlplusFailed 
%ORACLE_HOME%\bin\sqlldr userid=%UID%@%ENV%/%PWD% control=%CONTROL_FILE% %DATA_FILE%
if %ERRORLEVEL% neq 0 goto sqlldrFailed 
set dt=%date:~4%
set yy=%dt:~6%
set mm=%dt:~0,2%
set dd=%dt:~3,2%
if not exist %yy%_%mm%_%dd%\nul (mkdir %yy%_%mm%_%dd%)
if not exist %yy%_%mm%_%dd%\%ENV%\nul (mkdir %yy%_%mm%_%dd%\%ENV%)
move /-Y *.log %yy%_%mm%_%dd%\%ENV%
goto done


:noDataFile
@echo Missing data file
goto done

:noPWD
@echo Missing password for %UID%
goto done

:badSqlldr
@echo %ORACLE_HOME%\bin\sqlldr.exe does not exist
goto done

:badSqlplus
@echo %ORACLE_HOME%\bin\sqlplus.exe does not exist
goto done

:badControlFile
@echo %CONTROL_FILE% does not exist
goto done

:badScript
@echo %SQLPLUS_SCRIPT% does not exist
goto done

:sqlplusFailed
@echo Sqlplus failed
goto done

:sqlldrFailed
for %%i in (%CONTROL_FILE%) set LOG_FILE=%%~ni..log
notepad  %LOG_FILE%
@echo Sqlldr failed
goto done

:setDebug
shift
@echo on
goto loop

:setDataFile
shift
if not "%1"=="" (
  set var=%1
  if "!var:~0,1!"=="-" goto listFiles
  if not '%1'=='' goto getDataFile
)
:listFiles
SET index=1

SETLOCAL ENABLEDELAYEDEXPANSION
FOR %%f IN (*.csv) DO (
   SET file!index!="%%f"
   ECHO !index! - %%f
   SET /A index=!index!+1
)

SETLOCAL DISABLEDELAYEDEXPANSION

SET /P selection="select file by number:"

SET file%selection% >nul 2>&1

IF ERRORLEVEL 1 (
   ECHO invalid number selected   
   EXIT /B 1
)

CALL :RESOLVE %%file%selection%%%
call :DeQuote file_name

set DATA_FILE=DATA='%file_name%'
goto endSetDataFile
:getDataFile
set DATA_FILE=DATA='%~s1'
shift
:endSetDataFile
goto loop


:RESOLVE
SET file_name=%1
GOTO :EOF

:DeQuote
for /f "delims=" %%A in ('echo %%%1%%') do set %1=%%~A
Goto :eof

:setOracleHome
shift
if "%1"=="" goto Usage
set ORACLE_HOME=%1
shift
goto loop
 
:setEnv
shift
if "%1"=="" goto Usage
set ENV=%1
shift
goto loop
 
:setUserid
shift
if "%1"=="" goto Usage
set UID=%1
shift
goto loop

:setControlFile
shift
if "%1"=="" goto Usage
set CONTROL_FILE=%1
shift
goto loop

:setSqlplusScript
shift
if "%1"=="" goto Usage
set SQLPLUS_SCRIPT=%1
shift
goto loop

:setPassword
shift
if "%1"=="" goto Usage
set PWD=%1
shift
goto loop


:Usage
@echo.Usage %THIS_FILE% [-d -e env -o orahome -u orauserid -c ctl_file -s sqplus_script -p oracle_password
@echo. -f [csv-file] ]
@echo.where the following are all optional parameters
@echo.      -c ctl_file where ctl_file is the sqlldr control file.  Default is amdRepairCostDetail.ctl
@echo.      -d turn on debug
@echo.      -e env where env is the Oracle environment of AMDD, AMDI or AMDP.  Default is AMDD
@echo.      -f [csv_file] the csv_file is optional if not specified you will be prompted with a list of the
@echo.         csv files for the current directory
@echo.      -h show this usage messsage
@echo.      -o orahome where orahome is the Oracle home directory.  Default is c:\oracle\11gR2client64bit
@echo.      -p oracle_password where oracle_password is the Oracle password for the specified Oracle user id. (there is no default)
@echo.      -s sqlplus_script where sqlplus_script is the sqlplus script.  Default is truncateAmdRepairCostDetail.sql 
@echo.      -u orauserid where orauserid is the Oracle user account.  Default is the Windows user id  
@echo.
@echo.If a password is not entered you will be prompted for an Oracle user id and password.
 

goto done

:getPWD
:: See if I can find myself
If not exist %THIS_FILE% goto ERROR
:: Make the web page
set PATH=C:\Windows\System32;%PATH%
type %THIS_FILE% | find "    " | find /v "::" | find /v "@echo." | cscript /nologo replace.vbs ENV %ENV% > %TEMP%\UserIn.hta
:: Run the vbs code
start /w %TEMP%\UserIn.hta
:: At this point a batch file "%TEMP%\UserIn.bat" exists and you should 
:: call it! If you don't call the batch file here and instead opt to
:: call it from another batch file, be sure NOT to delete it in the
:: "Clean up" code section below!
if not exist %TEMP%\UserIn.bat (
  @echo.
  @echo.load aborted for "%DATA_FILE%"
  @echo.
  goto done
)
call %TEMP%\UserIn.bat
set UID=%USERNAME%
set PWD=%PASSWORD%
:: Clean up
del %TEMP%\UserIn.hta
del %TEMP%\UserIn.bat
goto exec

:mostRecent
for /f "delims=" %%x in ('dir /od /b *.csv') do set recent=%%x
set DATA_FILE=DATA='%recent%'
goto :eof


:ERROR
::cls
@echo.%0 is not the full path and file name
@echo.for the batch file. You MUST call this
@echo.batch file with a full path and file name.
goto done

:HTA
:: All HTA code MUST be indented four or more spaces.
:: NOTHING else in this batch file may be indented four spaces.
    <html>
    <head>
    <title>ENV Password Entry</title>
    <hta:application>
    <script language="vbscript">
        window.resizeTo 250,200
        Sub SaveBatch()
            Set fs = CreateObject("Scripting.FileSystemObject")
            strFile = fs.GetAbsolutePathName(fs.BuildPath(fs.GetSpecialFolder(2), "UserIn.bat"))
            Set ts = fs.OpenTextFile(strFile, 2, True)
            ts.WriteLine "SET USERNAME=" & document.Forms(0).elements("username").value
            ts.WriteLine "SET PASSWORD=" & document.Forms(0).elements("password").value
            ts.Close
        End Sub
    </script>
    </head>
    <body>
    <form>
        Oracle User Name:
        <br><input type=text name=username tabindex=1>
        <br>Password:
        <br><input type=password name=password>
        <br><input type=button language="vbscript" value="OK"
        onclick="SaveBatch : Window.Close">
    </form>
    <script language=vbscript>
        document.Forms(0).elements("username").focus
    </script>
    </body>
    </html>

:done
endlocal
