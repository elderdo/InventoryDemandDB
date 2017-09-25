Option Explicit
' This Script will setup the environment variables that are needed to
' invoke gawk without an explicit path
' It also install the batch script which.bat to C:\Windows\System32 if
' it is not already there.  
'	which argument1 
' which will report the explicit path of the exe or bat file specified
' for argument1.  If it does not find it, it reports -None-

dim objFSO
const GNUWin32_HOME_ENVVAR = "GNUWin32_HOME"
const PROGRAM_FILES = "C:\PROGRA~1"
const GNUWIN32 = "GnuWin32"
dim GNUWin32_HOME
GNUWin32_HOME = PROGRAM_FILES & "\" & GNUWIN32

const DATA197 = "\\sw.nos.boeing.com\c17data\data197$"

Set objFSO = CreateObject("Scripting.FileSystemObject")
if not objFSO.FileExists("C:\Windows\System32\which.bat") then
	objFSO.copyFile DATA197 & "\which\which.bat","C:\Windows\System32\which.bat"	
	Wscript.Echo "Installed which.bat file to C:\Windows\System32\which.bat"
end if
If objFSO.FileExists(GNUWin32_HOME & "\bin\gawk.exe") Then
	Dim objShell
	Dim objEnv	
	Set objShell = WScript.CreateObject("WScript.Shell")
	Set objEnv = objShell.Environment("User")
	if objEnv(GNUWin32_HOME_ENVVAR) = "" then
		objEnv(GNUWin32_HOME_ENVVAR) = GNUWin32_HOME
	end if
	Wscript.Echo "User variable " & GNUWin32_HOME_ENVVAR & " = " & objEnv(GNUWin32_HOME_ENVVAR)
	if objEnv("Path") <> "" then
		if instr(objEnv("Path"),"%" & GNUWin32_HOME_ENVVAR &"%\bin") = 0 then
			objEnv("Path") = objEnv("Path") & ";%" & GNUWin32_HOME_ENVVAR & "%\bin"
			Wscript.Echo ";%" & GNUWin32_HOME_ENVVAR & "%\bin appended to User variable Path"
		end if
	else
		objEnv("Path") = "%" & GNUWin32_HOME_ENVVAR & "%\bin"
		Wscript.Echo "User Path Variable created"
	end if
	Wscript.Echo "User variable Path = " &  objEnv("Path")
	objShell.Run "which gawk > C:\which.txt"
	dim objReadFile
	Wscript.sleep(2000) ' give which a couple of seconds to execute
	set objReadFile = objFSO.openTextFile("C:\which.txt")
	dim strContents
	strContents = objReadFile.ReadAll
	objReadFile.close
	if instr(Ucase(strContents),Ucase(GNUWin32_HOME & "bin\gawk.exe")) <> 0 then
		Wscript.Echo GNUWin32_HOME & "\bin\gawk.exe was successfully found in your Path variable: setup complete."
	else
		Wscript.Echo "gawk.exe was not found in " & GNUWin32_HOME & "\bin"
		if instr(strContents,"-None-") = 0 then
			Wscript.Echo "Found " & strContents
		end if
	end if
	objFSO.deleteFile "C:\which.txt"
else
	Wscript.Echo GNUWin32_HOME_VALUE & "\bin\gawk.exe does not exist"
End If 




