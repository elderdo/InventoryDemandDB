Attribute VB_Name = "Utils"
Option Explicit
' Put global const's here
Private Const xmlFile As String = "\log.xml"
' Log: create an xml log file that can be viewed with Internet Explorer
Public Sub Log(msg As String, Optional showLog As Boolean = False)
    On Error GoTo logErr
    If showLog Then
        MsgBox msg
    End If
    Dim fileNumber As Integer
    fileNumber = FreeFile
    
    Dim xml() As String
    
    xml = fileArray()
    
    Open App.Path & xmlFile For Output As #fileNumber
    Dim i As Long
    ' Write out all lines except the closing log tag </log> and
    ' the empty entry
    For i = LBound(xml) To UBound(xml) - 2
        Print #fileNumber, xml(i)
    Next
        
    ' Now append a new message to the log file
    
    Print #fileNumber, "<msg>" ' start of message
    Print #fileNumber, "<date>" ' start of date
    Print #fileNumber, Now
    Print #fileNumber, "</date>" ' end of date
    Print #fileNumber, "<text>" ' start of text
    Print #fileNumber, msg
    Print #fileNumber, "</text>" ' end of text
    Print #fileNumber, "</msg>" ' end of message
    
    ' Now output the closing xml log tag keeping the
    ' basic structure of <?xml version="1.0"?><log>.......</log>
    Print #fileNumber, "</log>"
    Close #fileNumber
    Exit Sub
logErr:
    MsgBox "utils.logErr: " & Err.Number & " " & Err.Description
End Sub
Private Function fileArray() As String()
    Dim ff As Integer
    Dim raw$
    ff = FreeFile
    If Dir$(App.Path & xmlFile) = "" Then
        ' the file does not exist, so create the template for an
        ' empty xml log file.
        Dim xmlDoc(1 To 4) As String
        xmlDoc(1) = "<?xml version=""1.0""?>"
        xmlDoc(2) = "<log>"
        xmlDoc(3) = "</log>"
        ' add an empty item to be consistent with the split function
        xmlDoc(4) = ""
        fileArray = xmlDoc
    Else
        Open App.Path & "\log.xml" For Binary As #ff
        raw$ = String$(LOF(ff), 32) ' initialize the buffer to ascii 32
        Get #ff, 1, raw$ ' read the entire file
        Close #ff
        ' split the input into lines.  An extra empty item is included
        ' because of the way the buffer was initialized
         fileArray = Split(raw$, vbCrLf)
                    
    End If
End Function

Public Sub errLog(location As String, Optional ByVal showLog As Boolean = False)
    On Error GoTo errLogError
    ' create an xml formatted error message
    '  that will be written to the log file
    Debug.Print location & " "; Err.Number & " " & Err.Description
    Utils.Log "<error>" & vbCrLf _
        & "<location>" & location & "</location>" & vbCrLf _
        & "<err.Number>" & Err.Number & "</err.Number>" & vbCrLf _
        & "<err.Description>" & Err.Description & "</err.Description>" & vbCrLf _
        & "</error>", showLog
    Exit Sub
errLogError:
    MsgBox "errLog: " & Err.Number & " " & Err.Description
End Sub

Public Function Encrypt(SourceData As String, Optional password As String = "mojo") As String

    Dim S$
    S$ = Space$(Len(SourceData))
    If Len(S$) = 0 Then Exit Function
    
    Dim PC As Long
    Dim LC As Long
    
    For LC = 1 To Len(S$)
       PC = PC + 1
       If PC > Len(password) Then
           PC = 1
       End If
       Mid$(S$, LC, 1) = Chr(Asc(Mid(SourceData, LC, 1)) Xor Asc(Mid$(password, PC, 1)))
    Next
    
    Encrypt = S$

End Function

Public Function Decrypt(EncryptedData As String, Optional password As String = "mojo") As String

    Decrypt = Encrypt(EncryptedData, password)


End Function

Public Function fileExists(filename As String) As Boolean
    Dim strFile As String
    strFile = Dir(filename)
    fileExists = (strFile <> "")
End Function

