VERSION 5.00
Begin VB.Form frmLogin 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "Oracle Login"
   ClientHeight    =   2835
   ClientLeft      =   4590
   ClientTop       =   2805
   ClientWidth     =   3750
   Icon            =   "frmLogin.frx":0000
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   1675.011
   ScaleMode       =   0  'User
   ScaleWidth      =   3521.047
   ShowInTaskbar   =   0   'False
   Begin VB.CheckBox chkRememPwd 
      Caption         =   "Auto Connect"
      Height          =   375
      Left            =   1320
      TabIndex        =   9
      ToolTipText     =   $"frmLogin.frx":0442
      Top             =   1800
      Width           =   1455
   End
   Begin VB.ComboBox cboOracleHost 
      Height          =   315
      ItemData        =   "frmLogin.frx":04D5
      Left            =   1320
      List            =   "frmLogin.frx":04E2
      Style           =   2  'Dropdown List
      TabIndex        =   2
      Top             =   1320
      Width           =   2325
   End
   Begin VB.TextBox txtUserName 
      Height          =   345
      Left            =   1290
      TabIndex        =   0
      Top             =   495
      Width           =   2325
   End
   Begin VB.CommandButton cmdOK 
      Caption         =   "OK"
      Default         =   -1  'True
      Height          =   390
      Left            =   480
      TabIndex        =   3
      Top             =   2220
      Width           =   1140
   End
   Begin VB.CommandButton cmdCancel 
      Cancel          =   -1  'True
      Caption         =   "Cancel"
      Height          =   390
      Left            =   2100
      TabIndex        =   4
      Top             =   2280
      Width           =   1140
   End
   Begin VB.TextBox txtPassword 
      Height          =   345
      IMEMode         =   3  'DISABLE
      Left            =   1290
      PasswordChar    =   "*"
      TabIndex        =   1
      Top             =   885
      Width           =   2325
   End
   Begin VB.Label lblRev 
      Alignment       =   2  'Center
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   270
      Left            =   128
      TabIndex        =   8
      Top             =   120
      Width           =   3495
   End
   Begin VB.Label lblLabels 
      Caption         =   "&Oracle Server"
      Height          =   270
      Index           =   2
      Left            =   0
      TabIndex        =   7
      Top             =   1320
      Width           =   1080
   End
   Begin VB.Label lblLabels 
      Alignment       =   2  'Center
      Caption         =   "&User Name:"
      Height          =   270
      Index           =   0
      Left            =   105
      TabIndex        =   5
      Top             =   510
      Width           =   1080
   End
   Begin VB.Label lblLabels 
      Caption         =   "&Password:"
      Height          =   270
      Index           =   1
      Left            =   105
      TabIndex        =   6
      Top             =   900
      Width           =   1080
   End
End
Attribute VB_Name = "frmLogin"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit
Private Declare Function GetKeyState Lib "user32" (ByVal nVirtKey As Long) As Integer
Const KEY_TOGGLED As Integer = &H1
Const KEY_PRESSED As Integer = &H1000

Private Declare Function GetUserName Lib "advapi32.dll" Alias "GetUserNameA" (ByVal lpbuffer As String, nSize As Long) As Long
Private mblnCancelAutoConnect As Boolean
Private mstrOracleHost As String
Public setPassword As Boolean

Public LoginSucceeded As Boolean

Private Sub cmdCancel_Click()
    'set the global var to false
    'to denote a failed login
    LoginSucceeded = False
    Set modDB.gobjConn = Nothing
    Me.Hide
End Sub

Private Sub cmdOK_Click()
    If txtUserName.Text = "" Then
        MsgBox "Enter your Oracle user id."
        txtUserName.SetFocus
        Exit Sub
    End If
    If txtPassword.Text = "" Then
        MsgBox "Enter your Oracle password."
        txtPassword.SetFocus
        Exit Sub
    End If
    If cboOracleHost.Text = "" Then
        MsgBox "Enter a host string: AMDD, AMDI, or AMDP"
        cboOracleHost.SetFocus
        Exit Sub
    End If
    Dim errMsg As String
    If modDB.isLoginOk(cboOracleHost.Text, txtUserName.Text, txtPassword.Text, errMsg) Then
        SaveSetting "OrderInfoParams", "Config", "UserId", txtUserName.Text
        SaveSetting "OrderInfoParams", "Config", "OracleHost", cboOracleHost.Text
        SaveSetting "OrderInfoParams", "Config", "rememPwd", chkRememPwd.Value
        If chkRememPwd.Value = vbChecked Or setPassword Then
            SaveSetting "OrderInfoParams", "Config", "pwd", Utils.Encrypt(txtPassword.Text, txtUserName)
        End If
        If setPassword Then
            LoginSucceeded = True
            Me.Hide
        Else
            Unload Me
        End If
    Else
        Utils.errLog "<userid>" & txtUserName.Text & "</userid>" _
            & "<datasource>" & cboOracleHost.Text & "</datasource>" _
            & "<oracleErrormsg>" & errMsg & "</oracleErrormsg>"
        MsgBox errMsg
    End If
End Sub

Private Sub Form_Activate()
    If mstrOracleHost <> "" Then
        Dim i As Integer
        cboOracleHost.ListIndex = -1
        For i = 0 To cboOracleHost.ListCount - 1
            If cboOracleHost.List(i) = mstrOracleHost Then
                cboOracleHost.ListIndex = i
                Exit For
            End If
        Next
        If cboOracleHost.ListIndex = -1 Then
            cboOracleHost.ListIndex = 0
        End If
    End If
    If txtUserName.Text <> "" Then
        txtPassword.SetFocus
    End If
    If setPassword Then
        Me.Caption = Me.Caption & " ...Save Password"
    Else
        If chkRememPwd.Value = vbChecked Then
            Dim pwd As String
            pwd = GetSetting("OrderInfoParams", "Config", "pwd", "")
            If pwd <> "" And mstrOracleHost <> "" Then
                txtPassword.Text = Utils.Decrypt(pwd, txtUserName.Text)
                cboOracleHost.Text = mstrOracleHost
                If Not mblnCancelAutoConnect Then
                    cmdOK_Click
                Else
                    cmdOK.SetFocus
                End If
            End If
        End If
    End If

End Sub


Private Sub Form_Load()
    Dim sBuffer As String
    Dim lSize As Long
    
    lblRev.Caption = " OrderInfoParams Utility Version " & App.Major & "." & App.Minor & "." & App.Revision

    sBuffer = Space$(255)
    lSize = Len(sBuffer)
    txtUserName.Text = GetSetting("OrderInfoParams", "Config", "UserId", "")
    ' The userid logged onto the PC may be different for Oracle, so use
    ' the registry setting
    If txtUserName.Text = "" Then
        Call GetUserName(sBuffer, lSize)
        If lSize > 0 Then
            txtUserName.Text = Left$(sBuffer, lSize)
        Else
            txtUserName.Text = vbNullString
        End If
    End If
    mstrOracleHost = GetSetting("OrderInfoParams", "Config", "OracleHost", "AMDP")
    chkRememPwd.Value = GetSetting("OrderInfoParams", "Config", "rememPwd", vbUnchecked)
    If GetKeyState(vbKeyShift) And KEY_PRESSED Then
        mblnCancelAutoConnect = True
    End If
End Sub

