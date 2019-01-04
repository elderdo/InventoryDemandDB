Option Explicit

' vim: ts=2:sw=2:sts=2:expandtab:
' getAmdWarnerRobinsDemands.vbs
' Author: Douglas S. Elder
' Date: 8/13/2017
' Desc: Extract the source_code, transaction_date, nsn, doc_no, and demand quantity
' from an Excel spreadsheet and send the output to stdout

sub Usage
  WScript.Echo "Usage: cscript /Nologo getAmdWarnerRobinsDemands.vbs name_of_excel_file > name_of_csv_file"
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
dim sourceCodeCol,tranDtCol,nsnCol, docNoCol, qtyCol
sourceCodeCol = 0
tranDtCol = 0
nsnCol = 0
docNoCol = 0
qtyCol = 0
' check if users put data in other columns
dim i
i = 1
do until trim(objExcel.Cells(1,i).Value) = ""

  do
    'WScript.Echo "A" & i & "=" & objExcel.Cells(1,i)
    re.Pattern = "SOS"
    if re.Test(objExcel.Cells(1,i)) = true then
      sourceCodeCol = i
      exit do
    end if

    re.Pattern = "TRAN_DT"  
    if re.Test(objExcel.Cells(1,i)) = true then
      tranDtCol = i
      exit do
    end if

    re.Pattern = "DOc_"
    if re.Test(objExcel.Cells(1,i)) = true then
      docNoCol = i
      exit do
    end if

    re.Pattern = "FRT ADJ"
    if re.Test(objExcel.Cells(1,i)) = true then
      qtyCol = i
      exit do
    end if

    re.Pattern = "NSN"
    if re.Test(objExcel.Cells(1,i)) = true then
       nsnCol = i
       exit do
    end if

  loop until true ' use this type of do loop to get the effect of a "continue" when exiting the do loop

  i = i + 1
loop
'WScript.Echo "end loop"
if err.Number <> 0 then
  WScript.Echo "Scan of Excel's first row failed"
  DisplayErrorInfo
  WScript.Quit 4
end if


'WScript.Echo "sourceCodeCol=" & sourceCodeCol 
'WScript.Echo "tranDtCol=" & tranDtCol 
'WScript.Echo "nsnCol=" & nsnCol
'WScript.Echo "docNoCol=" & docNoCol
'WScript.Echo "qtyCol=" & qtyCol
if sourceCodeCol = 0 or tranDtCol = 0 or nsnCol = 0 or docNoCol = 0 or qtyCol = 0  then
  WScript.Echo "Could not find headers in spreadsheet"
  WScript.Quit 4
end if

'WScript.Echo "start header"
dim intRow:intRow = 1
Wscript.Echo "Row," & objExcel.Cells(intRow, sourceCodeCol).value & "," _
 & objExcel.Cells(intRow, tranDtCol).Value & "," _
 & objExcel.Cells(intRow, nsnCol).Value & "," _
 & objExcel.Cells(intRow, docNoCol).Value & "," _
 & objExcel.Cells(intRow, qtyCol).Value & "," _
 & "Filename"
'WScript.Echo "end header"
intRow = intRow + 1

'WScript.Echo "start spreadsheet"
Do Until objExcel.Cells(intRow,sourceCodeCol).Value = ""
    Wscript.Echo intRow & "," & objExcel.Cells(intRow, sourceCodeCol).Value & "," _
     & objExcel.Cells(intRow, tranDtCol).Value & "," _
     & objExcel.Cells(intRow, nsnCol).Value & "," _
     & objExcel.Cells(intRow, docNoCol).Value & "," _
     & objExcel.Cells(intRow, qtyCol).Value & "," _
     & """" & WScript.Arguments.Item(0) & """"
  intRow = intRow + 1
Loop
'WScript.Echo "end spreadsheet"
if err.Number <> 0 then
  WScript.Echo "Scan of Excel failed"
  DisplayErrorInfo
  WScript.Quit 4
end if

objExcel.Quit
set objExcel = Nothing
set re = Nothing
set fso = Nothing

