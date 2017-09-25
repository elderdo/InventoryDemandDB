Attribute VB_Name = "modDB"
Option Explicit

Public gstrConnectionString As String
Public gobjConn As ADODB.Connection
Public Const gstrORDER_CREATE_DATE As String = "orderCreateDate"
Public Const gstrSCHED_RECEIPT_DATE  As String = "schedReceiptDate"
Private mobjBatch As Batch
Public Sub Main()
    Dim cmd As String
    cmd = Command
    If cmd <> "" Then
        If InStr(cmd, "-b") Then
            Dim sc As MSScriptControl.ScriptControl
            Set sc = loadScript("batch.vbs")
            sc.Timeout = 60000 * 2
            sc.run "batchRun"
        ElseIf InStr(cmd, "-p") Then
            Set sc = loadScript("password.vbs")
            sc.run "newPassword"
        Else
            MsgBox "Usage: OrderInfoParams -b or OrderInfoParams -p or OrderInfoParams", vbCritical
        End If
    Else
        frmLogin.Show vbModal
        If Not (gobjConn Is Nothing) Then
            frmMain.Show vbModal
        End If
    End If
    End
End Sub

Private Function loadScript(scriptFile As String) As MSScriptControl.ScriptControl
    Dim intScriptFile As Integer
    Dim sc As MSScriptControl.ScriptControl
    Set sc = New MSScriptControl.ScriptControl
    sc.Language = "VBScript"
    intScriptFile = FreeFile
    Open App.Path & "\" & scriptFile For Input As #intScriptFile
    Dim strCode As String
    strCode = Input$(LOF(intScriptFile), 1)
    sc.AddCode strCode
    Set mobjBatch = New Batch
    sc.AddObject "batch", mobjBatch, True
    sc.AddObject "App", App
    Set loadScript = sc
End Function
Public Function isLoginOk(ByVal host As String, ByVal uid As String, ByVal pwd As String, ByRef errMsg As String) As Boolean
    Dim objUser As User.clsUser
    Set objUser = New User.clsUser
    objUser.DataSource = host
    objUser.UserId = uid
    objUser.password = pwd
    If objUser.IsValidUser Then
        Set gobjConn = objUser.Connection
        isLoginOk = True
    Else
        If objUser.AccountIsLocked Then
            errMsg = "Your Oracle account is locked."
        ElseIf objUser.OracleIsDown Then
            errMsg = "Oracle is down.  Try again later."
        ElseIf objUser.PasswordExpired Then
            errMsg = "Your Oracle password has expired."
        Else
            errMsg = objUser.OracleErrorMessage
        End If
    End If
End Function

Private Function doesParamExist() As Boolean
    Dim rs As Recordset
    Set rs = gobjConn.Execute("select * from amd_params where param_key = '" & paramKey(gstrORDER_CREATE_DATE) & "'")
    doesParamExist = Not rs.EOF
    rs.Close
    Set rs = Nothing
End Function
Private Function paramKey(keyType As String) As String
    'paramKey = keyType & "_" & frmMain.cboVoucherPre.Text
    'Private Const gstrSCHED_RECEIPT_DATE  As String = "schedReceiptDate"

End Function
Private Sub updateParam()
    Const updateDml As String = "update amd_params set"
End Sub
    
Private Sub insertParam()
    Const insertDml As String = "insert into amd_param (param_key, param_description) "
    Dim values As String
    On Error GoTo insertParamError
    values = "values ('" & paramKey(gstrORDER_CREATE_DATE) & "', 'Order Create Date for voucher " & frmMain.cboVoucherPrefixes.Text & ".')"
    gobjConn.Execute insertDml & values
    values = "values ('," & paramKey(gstrSCHED_RECEIPT_DATE) & "', 'Scheduled Receipt Data for voucher " & frmMain.cboVoucherPrefixes.Text & ".')"
    gobjConn.Execute insertDml & values
    Exit Sub
insertParamError:
    MsgBox "insertParam: " & Err.Number & " " & Err.Description
End Sub
