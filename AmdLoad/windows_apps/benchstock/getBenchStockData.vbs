' vim: ts=2:sw=2:sts=2:expandtab:
' getBenchStockData.vbs
' Author: Douglas S. Elder
' Date: 10/22/2015
' Desc: Extract the sran, stock number and authorized quantity
' from an Excel spreadsheet and send the output to stdout
Option Explicit

sub Usage
  WScript.Echo "Usage: cscript /Nologo getBenchStockData.vbs name_of_excel_file > name_of_csv_file"
end sub

on error resume next
if WScript.Arguments.Count = 0 then
  Usage
  WScript.Quit 4
end if


' make sure this script is executed using cscript
if not LCase( Right( WScript.FullName, 12 ) ) = "\cscript.exe" then
  Usage
  WScript.Quit 4
end if

Sub DisplayErrorInfo

    WScript.Echo "Error:      : " & Err
    WScript.Echo "Error (hex) : &H" & Hex(Err)
    WScript.Echo "Source      : " & Err.Source
    WScript.Echo "Description : " & Err.Description
    ' clean up after any error by getting rid of objects
    if IsObject(objExcel) then
      objExcel.Quit
      set objExcel = Nothing
    end if
    set fso = Nothing
    set re = Nothing
   
    Err.Clear

End Sub


dim objExcel:Set objExcel = CreateObject("Excel.Application")
if err.Number <> 0 then
  WScript.Echo "Unable to start Excel"
  DisplayErrorInfo
  WScript.Quit 4
end if

dim fso: set fso = CreateObject("Scripting.FileSystemObject")
if err.Number <> 0 then
  WScript.Echo "Unable to create the File System Object"
  DisplayErrorInfo
  WScript.Quit 4
end if

dim CurrentDirectory
CurrentDirectory = fso.GetAbsolutePathName(".")
if err.Number <> 0 then
  WScript.Echo "Unable to get the current directory"
  DisplayErrorInfo
  WScript.Quit 4
end if

'WScript.Echo WScrit.Arguments.Item(0)
dim objWorkbook:Set objWorkbook = objExcel.Workbooks.Open(CurrentDirectory & "\" & WScript.Arguments.Item(0))
if err.Number <> 0 then
  WScript.Echo "Unable to Open workbook " & CurrentDirectory & "\" & WScript.Arguments.Item(0)
  DisplayErrorInfo
  WScript.Quit 4
end if

dim re:Set re = new regexp  'Create the RegExp object
if err.Number <> 0 then
  WScript.Echo "Unable to create a regular expression object ( regex ) "
  DisplayErrorInfo
  WScript.Quit 4
end if

re.IgnoreCase = True
dim col:col=1
dim sranCol,stockNumberCol,authQtyCol
' default columns
sranCol = 1
stockNumberCol = 4
authQtyCol = 5
' check if users put data in other columns
dim i
i = 1
do until objExcel.Cells(1,i).Value = ""
  re.Pattern = "SRAN"
  if re.Test(objExcel.Cells(1,i)) = true then
    sranCol = i
  else
    re.Pattern = "STOCK *NUMBER"  
    if re.Test(objExcel.Cells(1,i)) = true then
      stockNumberCol = i
    else
      re.Pattern = "AUTH *QTY"
      if re.Test(objExcel.Cells(1,i)) = true then
        authQtyCol = i
      end if
    end if
  end if 
  i = i + 1
loop
if err.Number <> 0 then
  WScript.Echo "Scan of Excel's first row failed"
  DisplayErrorInfo
  WScript.Quit 4
end if


if not sranCol <> stockNumberCol and stockNumberCol <> authQtyCol then
  WScript.Echo "Could not find headers in spreadsheet"
  WScript.Quit 4
end if
dim intRow:intRow = 1
Do Until objExcel.Cells(intRow,sranCol).Value = ""
    Wscript.Echo objExcel.Cells(intRow, sranCol).Value & "," _
     & objExcel.Cells(intRow, stockNumberCol).Value & "," _
     & objExcel.Cells(intRow, authQtyCol).Value 
  intRow = intRow + 1
Loop
if err.Number <> 0 then
  WScript.Echo "Scan of Excel failed"
  DisplayErrorInfo
  WScript.Quit 4
end if

objExcel.Quit
set objExcel = Nothing
set re = Nothing
set fso = Nothing

