VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "Batch"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit
Public Function setPassword() As Boolean
    frmLogin.setPassword = True
    frmLogin.Show vbModal
    setPassword = frmLogin.LoginSucceeded
End Function
Private Sub setUserId(ByVal uid As String)
    SaveSetting "FedLog2Rbl", "Config", "UserId", uid
End Sub
Public Function execBatch(ByVal host As String, ByVal uid As String, ByVal fileIn As String, ByVal fileOut As String)
    Dim strPwd As String
    strPwd = GetSetting("FedLog2Rbl", "Config", "pwd", "")
    Dim strErrMsg As String
    If modDB.isLoginOk(host, uid, Utils.Decrypt(strPwd, uid), strErrMsg) Then
        If Left$(fileIn, 2) = ".\" Then
            fileIn = App.Path & "\" & Right$(fileIn, Len(fileIn) - 2)
        End If
        If Left$(fileOut, 2) = ".\" Then
            fileOut = App.Path & "\" & Right$(fileOut, Len(fileOut) - 2)
        End If
        doBatchRun fileIn, fileOut
        execBatch = 0
    Else
        MsgBox strErrMsg, vbCritical
        execBatch = 4
    End If
End Function


Private Sub doBatchRun(ByRef fileIn As String, ByRef fileOut As String)
    Dim vntFileArray As Variant
    Dim intFileSize As Integer
    Dim strDelim As String
    Dim strErrMsg As String
    
    
End Sub

Public Sub run(batchFile As String)
    ChDir App.Path
    Shell batchFile, vbNormalFocus
End Sub





