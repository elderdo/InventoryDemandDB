:: copyWithTimeStamp.bat
:: Author: Douglas S. Elder
:: Date: 02/10/2015
:: Description: copy a file to a directory
:: and prefix it with a time stamp
:: if the file is empty just delete it
::
::
::
@echo off
if "%1"=="" goto missingSource
if not exist %1 goto sourceNotExist
if "%2"=="" goto missingDest
if not exist %2\NUL goto destNotExist

setlocal ENABLEDELAYEDEXPANSION 
For /f "tokens=2-4 delims=/ " %%a in ('date /t') do (set mydate=%%c_%%a_%%b)
For /f "tokens=1-2 delims=/:" %%a in ("%TIME%") do (set mytime=%%a_%%b)
set source=%1
set dest=%2
if %~z1 == 0 goto emptyFile
copy %source% %dest%\%mydate%_%mytime%_%source%
goto done

:emptyFile
@echo %1 is empty - deleted
del %1
goto done

:missingSource
@echo "Missing source file"
goto usage

:sourceNotExist
@echo "%1 does not exist"
goto usage

:destNotExist
@echo "%2 is not a directory"
goto usage

:missingDest
@echo "Missing destination directory"
goto usage

:usage
@echo.Usage: copyWithTimeStamp.bat sourceFile destinationDirectory

:done
endlocal
