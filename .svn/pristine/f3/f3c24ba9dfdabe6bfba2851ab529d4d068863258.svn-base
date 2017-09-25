VERSION 5.00
Object = "{831FDD16-0C5C-11D2-A9FC-0000F8754DA1}#2.0#0"; "mscomctl.ocx"
Object = "{86CF1D34-0C5F-11D2-A9FC-0000F8754DA1}#2.0#0"; "mscomct2.ocx"
Begin VB.Form frmMain 
   BorderStyle     =   1  'Fixed Single
   Caption         =   "Main"
   ClientHeight    =   4965
   ClientLeft      =   2715
   ClientTop       =   1590
   ClientWidth     =   7140
   Icon            =   "frmMain.frx":0000
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   ScaleHeight     =   4965
   ScaleWidth      =   7140
   Begin VB.CommandButton cmdResetAlltoNulls 
      Caption         =   "Set all Params to N&ulls"
      Height          =   495
      Left            =   623
      TabIndex        =   22
      Top             =   3720
      Width           =   2055
   End
   Begin VB.CheckBox chkUseOrderCreateDate 
      Caption         =   "Use Order Create Date"
      Height          =   375
      Left            =   3240
      TabIndex        =   20
      Top             =   600
      Width           =   1935
   End
   Begin VB.ComboBox cboVoucherPrefixes 
      Height          =   315
      ItemData        =   "frmMain.frx":0442
      Left            =   1800
      List            =   "frmMain.frx":045B
      Sorted          =   -1  'True
      Style           =   2  'Dropdown List
      TabIndex        =   15
      Top             =   120
      Width           =   855
   End
   Begin VB.Frame Frame1 
      Caption         =   "Scheduled Receipt Date"
      Height          =   2175
      Left            =   360
      TabIndex        =   8
      Top             =   1440
      Width           =   6375
      Begin VB.OptionButton optSch 
         Caption         =   "Do not use Scheduled Receipt Date"
         Height          =   375
         Index           =   2
         Left            =   240
         TabIndex        =   21
         Top             =   1680
         Width           =   3135
      End
      Begin VB.TextBox txtCalendarDays 
         Height          =   375
         Left            =   3240
         TabIndex        =   18
         Top             =   1200
         Width           =   1080
      End
      Begin MSComCtl2.DTPicker dtpSchCalDay 
         Height          =   375
         Left            =   4680
         TabIndex        =   17
         Top             =   1200
         Width           =   1335
         _ExtentX        =   2355
         _ExtentY        =   661
         _Version        =   393216
         Format          =   20643841
         CurrentDate     =   38581
      End
      Begin VB.OptionButton optSch 
         Caption         =   "Use Current date + calendar days"
         Height          =   375
         Index           =   1
         Left            =   240
         TabIndex        =   16
         Top             =   1140
         Width           =   2775
      End
      Begin VB.OptionButton optSch 
         Caption         =   "Use Date Range"
         Height          =   375
         Index           =   0
         Left            =   240
         TabIndex        =   11
         Top             =   600
         Width           =   1575
      End
      Begin MSComCtl2.DTPicker dtpSchFrom 
         Height          =   375
         Left            =   3240
         TabIndex        =   12
         Top             =   600
         Width           =   1335
         _ExtentX        =   2355
         _ExtentY        =   661
         _Version        =   393216
         Format          =   20643841
         CurrentDate     =   38580
      End
      Begin MSComCtl2.DTPicker dtpSchTo 
         Height          =   375
         Left            =   4680
         TabIndex        =   13
         Top             =   600
         Width           =   1335
         _ExtentX        =   2355
         _ExtentY        =   661
         _Version        =   393216
         Format          =   20643841
         CurrentDate     =   38580
      End
      Begin MSComCtl2.UpDown updSch 
         Height          =   375
         Left            =   4320
         TabIndex        =   19
         Top             =   1200
         Width           =   255
         _ExtentX        =   450
         _ExtentY        =   661
         _Version        =   393216
         BuddyControl    =   "txtCalendarDays"
         BuddyDispid     =   196613
         OrigLeft        =   2881
         OrigTop         =   1200
         OrigRight       =   3136
         OrigBottom      =   1575
         Max             =   3650
         SyncBuddy       =   -1  'True
         BuddyProperty   =   0
         Enabled         =   -1  'True
      End
      Begin VB.Label Label5 
         Caption         =   "To"
         Height          =   255
         Left            =   5040
         TabIndex        =   10
         Top             =   240
         Width           =   375
      End
      Begin VB.Label Label4 
         Caption         =   "From "
         Height          =   255
         Left            =   3600
         TabIndex        =   9
         Top             =   240
         Width           =   375
      End
   End
   Begin VB.TextBox txtDelim 
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   13.5
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   375
      Left            =   6960
      MaxLength       =   1
      TabIndex        =   4
      Text            =   ","
      ToolTipText     =   "The character used to separate individual fields."
      Top             =   120
      Visible         =   0   'False
      Width           =   375
   End
   Begin VB.CommandButton cmdExit 
      Cancel          =   -1  'True
      Caption         =   "E&xit"
      Height          =   495
      Left            =   5543
      TabIndex        =   3
      Top             =   3720
      Width           =   975
   End
   Begin VB.CommandButton cmdSaveDates 
      Caption         =   "&Save Dates"
      Default         =   -1  'True
      Height          =   495
      Left            =   3143
      TabIndex        =   2
      Top             =   3720
      Width           =   1935
   End
   Begin MSComctlLib.ProgressBar ProgressBar1 
      Height          =   300
      Left            =   1680
      TabIndex        =   6
      Top             =   4560
      Width           =   3855
      _ExtentX        =   6800
      _ExtentY        =   529
      _Version        =   393216
      Appearance      =   1
   End
   Begin MSComctlLib.StatusBar StatusBar1 
      Align           =   2  'Align Bottom
      Height          =   495
      Left            =   0
      TabIndex        =   5
      Top             =   4470
      Width           =   7140
      _ExtentX        =   12594
      _ExtentY        =   873
      _Version        =   393216
      BeginProperty Panels {8E3867A5-8586-11D1-B16A-00C0F0283628} 
         NumPanels       =   3
         BeginProperty Panel1 {8E3867AB-8586-11D1-B16A-00C0F0283628} 
            Style           =   6
            Object.Width           =   2646
            MinWidth        =   2646
            TextSave        =   "9/13/2005"
         EndProperty
         BeginProperty Panel2 {8E3867AB-8586-11D1-B16A-00C0F0283628} 
            AutoSize        =   1
            Object.Width           =   7303
         EndProperty
         BeginProperty Panel3 {8E3867AB-8586-11D1-B16A-00C0F0283628} 
            Style           =   5
            TextSave        =   "4:02 PM"
         EndProperty
      EndProperty
   End
   Begin MSComCtl2.DTPicker dtpOrderCreateDate 
      Height          =   375
      Left            =   1800
      TabIndex        =   14
      Top             =   600
      Width           =   1335
      _ExtentX        =   2355
      _ExtentY        =   661
      _Version        =   393216
      Format          =   20643841
      CurrentDate     =   38580
   End
   Begin VB.Label lblDelim 
      Caption         =   "Field Separator"
      Height          =   375
      Left            =   6000
      TabIndex        =   7
      Top             =   120
      Visible         =   0   'False
      Width           =   855
   End
   Begin VB.Label Label2 
      Caption         =   "Order Create Date"
      Height          =   375
      Left            =   360
      TabIndex        =   1
      Top             =   720
      Width           =   1335
   End
   Begin VB.Label Label1 
      Caption         =   "Voucher Prefixes"
      Height          =   375
      Left            =   360
      TabIndex        =   0
      Top             =   120
      Width           =   1335
   End
End
Attribute VB_Name = "frmMain"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit
Private mblnLoading                     As Boolean
Private mintUseOrderCreateDate          As Integer
Private mstrVoucherPrefix               As String
Private mstrUseOrderCreateDate          As String
Private mintCalendarDays                As Integer
Private mblnSchCalDaysChanged           As Boolean
Private mblnCalendarDaysIsNull          As Boolean
Private mdtOrderCreateDate              As Date
Private mblnOrderCreateDateChanged      As Boolean
Private mblnOrderCreateDateIsNull       As Boolean
Private mblnSchedFromChanged            As Boolean
Private mdtSchedReceiptDateFrom         As Date
Private mblnSchedReceiptDateFromIsNull  As Boolean
Private mblnSchedToChanged              As Boolean
Private mdtSchedReceiptDateTo           As Date
Private mblnSchedReceiptDateToIsNull    As Boolean

Private mintTotRecs             As Integer
Private mvntFileArray           As Variant
Private mblnUseSchDateRange     As Boolean
Private mblnDoNotUseSchDate     As Boolean
Private Const MSG_PANEL             As Integer = 2
Private Const VOUCHER_PREFIX        As String = "vouncherPrefix"
Private Const CONFIG                As String = "Config"
Private Const USE_ORDER_CREATE_DATE As String = "useOrderCreateDate"
Private Const USE_SCH_DATE_RANGE    As String = "useSchDateRange"
Private Const DO_NOT_USE_SCH_DATE   As String = "doNotuseSchDate"
Private Const SCH_FROM              As String = "schFrom"
Private Const SCH_TO                As String = "schTo"
Private Const CALENDAR_DAYS         As String = "calDays"
Private Const ORDER_CREATE_DATE     As String = "orderCreateDate"


Private Enum SchDates
    dateRange
    currentPlusCalendar
    doNotUseSchdReceipt
End Enum
Public Enum Errors
    errBadOou = vbObjectError + 513
    errMaxOous
    errMaxOldNsns
    errNsnNeOou
End Enum
Private Enum fileExtensions
    flo = 2
    xls
End Enum

Private Sub cboVoucherPrefixes_Change()
    If Not mblnLoading Then
        mstrVoucherPrefix = cboVoucherPrefixes.Text
        getOracleData
        displayData
    End If
End Sub

Private Sub cboVoucherPrefixes_Click()
    If cboVoucherPrefixes.DataChanged Then
        cboVoucherPrefixes_Change
    End If
End Sub


Private Sub chkUseOrderCreateDate_Click()
    mblnOrderCreateDateChanged = True
    cmdSaveDates.Enabled = True
    If chkUseOrderCreateDate.Value = vbChecked Then
        dtpOrderCreateDate.Enabled = True
        If mblnOrderCreateDateIsNull Then
            dtpOrderCreateDate.Value = Now
        Else
            dtpOrderCreateDate.Value = mdtOrderCreateDate
        End If
    Else
        dtpOrderCreateDate.Enabled = False
    End If
End Sub

Private Sub cmdExit_Click()
    Unload Me
End Sub


Private Sub cmdTest_Click()
    Dim intFileNo As Integer
    intFileNo = FreeFile
    Open App.Path & "\test.txt" For Output Access Write As #intFileNo
    Dim txt As String
    txt = "This is some txt"
    Dim txt2 As String
    txt2 = "More of the same"
    Write #intFileNo, txt, txt2
    Close intFileNo
End Sub


Private Sub cmdResetAlltoNulls_Click()
    Dim cmd As ADODB.Command
    Set cmd = New ADODB.Command
    Set cmd.ActiveConnection = modDB.gobjConn
    cmd.CommandType = adCmdStoredProc
    cmd.CommandText = "amd_inventory.numberOfOnOrderParams"
    cmd.Parameters.Append cmd.CreateParameter("count", adDouble, adParamReturnValue)
    cmd.Execute
    Dim cnt As Integer
    cnt = cmd.Parameters("count").Value
    If MsgBox("Are you sure you want to do this?  It will reset all " & cnt & " params to nulls!", vbYesNo) = vbNo Then
        Exit Sub
    End If
    cmd.CommandText = "amd_inventory.clearOnOrderParams"
    cmd.Parameters.Delete ("count")
    cmd.Execute
    Set cmd = Nothing
    getOracleData
    displayData
End Sub

Private Sub cmdSaveDates_Click()
    Dim cmd As ADODB.Command
    Dim wrkDate As Date
    Dim wkrDate2 As Date
    
    If Not mblnOrderCreateDateChanged _
    And chkUseOrderCreateDate.Value = mintUseOrderCreateDate _
    And optSch(SchDates.dateRange) = mblnUseSchDateRange _
    And Not mblnSchedFromChanged _
    And Not mblnSchedToChanged _
    And Not mblnSchCalDaysChanged Then
        StatusBar1.Panels(MSG_PANEL).Text = "Nothing has changed."
        Exit Sub
    End If
    
        
    If cboVoucherPrefixes.Text = "" Then
        cboVoucherPrefixes.SetFocus
        MsgBox "You must select a voucher."
        Exit Sub
    End If
    If optSch(SchDates.dateRange) And (mblnSchedFromChanged Or mblnSchedToChanged) Then
        If dtpSchFrom.Value = "" Or dtpSchTo.Value = "" Then
            MsgBox ("You must select a range of dates")
            If dtpSchFrom.Value = "" Then
                dtpSchFrom.SetFocus
            Else
                dtpSchTo.SetFocus
            End If
            Exit Sub
        Else
            If CDate(dtpSchFrom.Value) > CDate(dtpSchTo.Value) Then
                MsgBox ("From date must precede to date.")
                dtpSchFrom.SetFocus
                Exit Sub
            End If
        End If
    End If
    If optSch(SchDates.currentPlusCalendar) And mblnSchCalDaysChanged Then
        If txtCalendarDays.Text = "" Then
            MsgBox ("You must enter the number of days from.")
            txtCalendarDays.SetFocus
            Exit Sub
        End If
    End If
    Set cmd = New ADODB.Command
    Set cmd.ActiveConnection = modDB.gobjConn
'    cmd.CommandType = adCmdText
'    Const PARAM_KEY As String = "on_order_date_"
'    Dim rs As Recordset
'    cmd.CommandText = "select * from amd_param_changes where param_key = '" & PARAM_KEY & LCase(cboVoucherPrefixes.Text) & "'"
'    Set rs = cmd.Execute
'    If rs.EOF Then
'        MsgBox cboVoucherPrefixes.Text & " is not a valid param"
'        Exit Sub
'    End If
    cmd.CommandType = adCmdStoredProc
    cmd.CommandText = "amd_inventory.setOnOrderParams"
    cmd.Parameters.Append cmd.CreateParameter("voucher", adVarChar, adParamInput, 2, cboVoucherPrefixes.Text)
    If chkUseOrderCreateDate.Value = vbChecked Then
        cmd.Parameters.Append cmd.CreateParameter("orderCreateDate", adDate, adParamInput, , CDate(dtpOrderCreateDate.Value))
    Else
        cmd.Parameters.Append cmd.CreateParameter("orderCreateDate", adDate, adParamInput, , Null)
    End If
    If optSch(SchDates.dateRange) Then
        cmd.Parameters.Append cmd.CreateParameter("schedReceiptDateFrom", adDate, adParamInput, , CDate(dtpSchFrom.Value))
        cmd.Parameters.Append cmd.CreateParameter("schedReceiptDateTo", adDate, adParamInput, , CDate(dtpSchTo.Value))
        cmd.Parameters.Append cmd.CreateParameter("schedReceiptCalDays", adDouble, adParamInput, , Null)
    ElseIf optSch(SchDates.currentPlusCalendar) Then
        cmd.Parameters.Append cmd.CreateParameter("schedReceiptDateFrom", adDate, adParamInput, , Null)
        cmd.Parameters.Append cmd.CreateParameter("schedReceiptDateTo", adDate, adParamInput, , Null)
        cmd.Parameters.Append cmd.CreateParameter("schedReceiptCalDays", adDouble, adParamInput, , CDbl(txtCalendarDays.Text))
    Else
        cmd.Parameters.Append cmd.CreateParameter("schedReceiptDateFrom", adDate, adParamInput, , Null)
        cmd.Parameters.Append cmd.CreateParameter("schedReceiptDateTo", adDate, adParamInput, , Null)
        cmd.Parameters.Append cmd.CreateParameter("schedReceiptCalDays", adDouble, adParamInput, , Null)
    End If
    cmd.Execute
    StatusBar1.Panels(MSG_PANEL).Text = "Data saved."
    Set cmd = Nothing
    ' make it look like nothing has changed
    mblnOrderCreateDateChanged = False
    mintUseOrderCreateDate = chkUseOrderCreateDate.Value
    mblnUseSchDateRange = optSch(SchDates.dateRange)
    mblnSchedFromChanged = False
    mblnSchedToChanged = False
    mblnSchCalDaysChanged = False
    cmdSaveDates.Enabled = False
    mdtOrderCreateDate = dtpOrderCreateDate.Value
    If txtCalendarDays.Text <> "" And IsNumeric(txtCalendarDays.Text) Then
        mintCalendarDays = CInt(txtCalendarDays.Text)
    End If
    
End Sub


Private Sub dtpOrderCreateDate_Change()
    If Not mblnLoading Then
        mblnOrderCreateDateChanged = True
        cmdSaveDates.Enabled = True
        StatusBar1.Panels(MSG_PANEL).Text = ""
    End If
End Sub

Private Sub dtpOrderCreateDate_Click()
    dtpOrderCreateDate_Change
End Sub

Private Sub dtpSchCalDay_Change()
    If dtpSchCalDay.Value >= Date Then
        txtCalendarDays.Text = DateDiff("d", Date, dtpSchCalDay.Value)
    Else
        dtpSchCalDay.Value = Now
    End If
End Sub

Private Sub dtpSchCalDay_Click()
    dtpSchCalDay_Change
End Sub

Private Sub dtpSchFrom_Change()
    If Not mblnLoading Then
        mblnSchedFromChanged = True
        cmdSaveDates.Enabled = True
        StatusBar1.Panels(MSG_PANEL).Text = ""
    End If
End Sub


Private Sub dtpSchFrom_Click()
    dtpSchFrom_Change
End Sub

Private Sub dtpSchTo_Change()
    If Not mblnLoading Then
        mblnSchedToChanged = True
        cmdSaveDates.Enabled = True
        StatusBar1.Panels(MSG_PANEL).Text = ""
    End If
End Sub
Private Sub displayData()
    If mblnOrderCreateDateIsNull Then
        chkUseOrderCreateDate.Value = vbUnchecked
        mintUseOrderCreateDate = vbUnchecked
        dtpOrderCreateDate.Enabled = False
    Else
        chkUseOrderCreateDate.Value = vbChecked
        mintUseOrderCreateDate = vbChecked
        dtpOrderCreateDate.Value = mdtOrderCreateDate
        dtpOrderCreateDate.Enabled = True
    End If
    If mblnSchedReceiptDateFromIsNull Then
        dtpSchFrom.Enabled = False
    Else
        dtpSchFrom.Enabled = True
        dtpSchFrom.Value = mdtSchedReceiptDateFrom
    End If
    If mblnSchedReceiptDateToIsNull Then
        dtpSchTo.Enabled = False
    Else
        dtpSchTo.Enabled = True
        dtpSchTo.Value = mdtSchedReceiptDateTo
    End If
    If Not mblnSchedReceiptDateFromIsNull And Not mblnSchedReceiptDateToIsNull Then
        optSch(SchDates.dateRange) = True
    ElseIf Not mblnCalendarDaysIsNull Then
        optSch(SchDates.doNotUseSchdReceipt) = True
    Else
        optSch(SchDates.doNotUseSchdReceipt) = True
    End If
    If mblnCalendarDaysIsNull Then
        txtCalendarDays.Text = ""
        txtCalendarDays.Enabled = False
        dtpSchCalDay.Enabled = False
        optSch(SchDates.currentPlusCalendar).Value = False
        updSch.Enabled = False
    Else
        txtCalendarDays.Text = mintCalendarDays
        txtCalendarDays.Enabled = True
        dtpSchCalDay.Enabled = True
        optSch(SchDates.currentPlusCalendar).Value = True
        updSch.Enabled = True
    End If
    StatusBar1.Panels(MSG_PANEL).Text = ""
    cmdSaveDates.Enabled = False
End Sub

Private Sub dtpSchTo_Click()
    dtpSchTo_Change
End Sub

Private Sub Form_Activate()
    cboVoucherPrefixes.ListIndex = -1 ' Have nothing selected
    Dim i As Integer
    For i = 0 To cboVoucherPrefixes.ListCount - 1
        If cboVoucherPrefixes.List(i) = mstrVoucherPrefix Then
            cboVoucherPrefixes.ListIndex = i
        End If
    Next
    displayData
    mblnLoading = False
End Sub
Private Sub getValidVouchers()
    Dim cmd As ADODB.Command
    Dim rs As ADODB.Recordset
    Set cmd = New ADODB.Command
    With cmd
        Set .ActiveConnection = modDB.gobjConn
        .CommandType = adCmdText
        .CommandText = "select distinct substr(gold_order_number,1,2) voucher from amd_on_order order by voucher"
        Set rs = .Execute
    End With
    If Not rs.EOF Then
        cboVoucherPrefixes.Clear
    End If
    Do While Not rs.EOF
        cboVoucherPrefixes.AddItem rs(0)
        rs.MoveNext
    Loop
    Set rs = Nothing
    Set cmd = Nothing
End Sub
Private Sub getOracleData()
    Dim cmd As ADODB.Command
    Set cmd = New ADODB.Command
    With cmd
        Set .ActiveConnection = modDB.gobjConn
        .CommandType = adCmdStoredProc
        .CommandText = "amd_inventory.getOnOrderParams"
        
        .Parameters.Append cmd.CreateParameter("voucher", adVarChar, adParamInput, 2000, mstrVoucherPrefix)
        .Parameters.Append cmd.CreateParameter("orderCreateDate", adDate, adParamOutput)
        .Parameters.Append cmd.CreateParameter("schedReceiptFrom", adDate, adParamOutput)
        .Parameters.Append cmd.CreateParameter("schedReceiptTo", adDate, adParamOutput)
        .Parameters.Append cmd.CreateParameter("schedReceiptCalDays", adDouble, adParamOutput)
        .Execute
        If IsNull(.Parameters("orderCreateDate").Value) Then
            mblnOrderCreateDateIsNull = True
        Else
            mblnOrderCreateDateIsNull = False
            mdtOrderCreateDate = .Parameters("orderCreateDate").Value
        End If
        If IsNull(.Parameters("schedReceiptFrom").Value) Then
            mblnSchedReceiptDateFromIsNull = True
        Else
            mblnSchedReceiptDateFromIsNull = False
            mdtSchedReceiptDateFrom = .Parameters("schedReceiptFrom").Value
        End If
        If IsNull(.Parameters("schedReceiptTo").Value) Then
            mblnSchedReceiptDateToIsNull = True
        Else
            mblnSchedReceiptDateToIsNull = False
            mdtSchedReceiptDateTo = .Parameters("schedReceiptTo").Value
        End If
        If IsNull(.Parameters("schedReceiptCalDays").Value) Then
            mblnCalendarDaysIsNull = True
        Else
            mblnCalendarDaysIsNull = False
            mintCalendarDays = .Parameters("schedReceiptCalDays").Value
        End If
    End With
    Set cmd = Nothing
End Sub
Private Sub Form_Load()
    mblnLoading = True
    Me.Caption = App.EXEName & " Utility Version " & App.Major & "." & App.Minor & "." & App.Revision
    mstrVoucherPrefix = GetSetting(App.EXEName, CONFIG, VOUCHER_PREFIX, "")
    mintCalendarDays = GetSetting(App.EXEName, CONFIG, CALENDAR_DAYS, 180)
    getOracleData
    getValidVouchers
    mblnUseSchDateRange = GetSetting(App.EXEName, CONFIG, USE_SCH_DATE_RANGE, optSch(SchDates.dateRange))
    mblnDoNotUseSchDate = GetSetting(App.EXEName, CONFIG, DO_NOT_USE_SCH_DATE, optSch(SchDates.doNotUseSchdReceipt))
    mstrUseOrderCreateDate = GetSetting(App.EXEName, CONFIG, USE_ORDER_CREATE_DATE, "1")
    mdtOrderCreateDate = GetSetting(App.EXEName, CONFIG, gstrORDER_CREATE_DATE, Now)
    If Command$ <> "" Then
        mstrVoucherPrefix = Replace(Command$, """", "")
    End If
    ProgressBar1.Max = 100
    ProgressBar1.Visible = False

#If DebugVersion Then
    ' keep the log file small while developing
    If fileExists(App.Path & "\log.xml") Then
        Debug.Print "deleting log file."
        Kill App.Path & "\log.xml"
    End If
#End If

End Sub
Private Function calDaysChanged() As Boolean
    calDaysChanged = False
    If txtCalendarDays.Text <> "" Then
        If IsNumeric(txtCalendarDays.Text) Then
            If mintCalendarDays <> CInt(txtCalendarDays.Text) Then
                calDaysChanged = True
                cmdSaveDates.Enabled = True
                StatusBar1.Panels(MSG_PANEL).Text = ""
            End If
        End If
    End If
End Function
Private Sub Form_Unload(Cancel As Integer)
    If cboVoucherPrefixes.Text <> "" Then
        SaveSetting App.EXEName, CONFIG, VOUCHER_PREFIX, cboVoucherPrefixes.Text
    End If
    SaveSetting App.EXEName, CONFIG, USE_ORDER_CREATE_DATE, chkUseOrderCreateDate.Value
    SaveSetting App.EXEName, CONFIG, USE_SCH_DATE_RANGE, optSch(SchDates.dateRange).Value
    If txtCalendarDays.Text <> "" Then
        SaveSetting App.EXEName, CONFIG, CALENDAR_DAYS, txtCalendarDays.Text
    End If
    If dtpOrderCreateDate.Value <> "" Then
        SaveSetting App.EXEName, CONFIG, ORDER_CREATE_DATE, dtpOrderCreateDate.Value
    End If
    If dtpSchFrom.Value <> "" Then
        SaveSetting App.EXEName, CONFIG, SCH_FROM, dtpSchFrom.Value
    End If
    If dtpSchFrom.Value <> "" Then
        SaveSetting App.EXEName, CONFIG, SCH_TO, dtpSchTo.Value
    End If
    If calDaysChanged _
    Or (chkUseOrderCreateDate.Value <> mintUseOrderCreateDate) _
    Or (mdtOrderCreateDate <> dtpOrderCreateDate.Value And dtpOrderCreateDate.Value <> "") _
    Or mblnSchedFromChanged _
    Or mblnSchedToChanged Then
        If MsgBox("You have not saved your changes.  Quit anyway?", vbYesNo) = vbNo Then
            Cancel = True
            Exit Sub
        End If
    End If
End Sub


Private Sub mobjFedLog_errorOccured(msg As String)
    Utils.errLog msg, True
End Sub

Private Sub mobjFedLog_percentComlete(percent As Integer)
    ProgressBar1.Value = percent
End Sub

Private Sub mobjFedLog_processRecord(recCnt As Integer)
    StatusBar1.Panels(1).Text = "record # " & recCnt
End Sub

Private Sub mobjFedLog_status(msg As String)
    StatusBar1.Panels(1).Text = msg
End Sub


Private Function isFileOutOk(strFileOut As String) As Boolean
    isFileOutOk = False
    If strFileOut <> "" And Len(strFileOut) > 3 Then
        If LCase(Right$(strFileOut, 4)) = ".xls" Then
            isFileOutOk = True
        Else
            MsgBox "The output file must have an .xls file extension"
        End If
    End If
End Function
Private Function oou2Xml(strOrderOfUse As String) As String
    Dim strOouXml As String
    Dim vntOou As Variant
    Dim i As Integer
    vntOou = Split(strOrderOfUse, "|")
    For i = LBound(vntOou) To UBound(vntOou)
        If Not IsEmpty(vntOou(i)) Then
            If vntOou(i) <> "" Then
                strOouXml = strOouXml & "<oou>" & vntOou(i) & "</oou>"
            End If
        End If
    Next
    oou2Xml = strOouXml
End Function


Private Sub optSch_Click(Index As Integer)
    cmdSaveDates.Enabled = True
    Select Case (Index)
        Case SchDates.dateRange
            dtpSchFrom.Enabled = True
            If mblnSchedReceiptDateFromIsNull Then
                dtpSchFrom.Value = Now
            Else
                dtpSchFrom.Value = mdtSchedReceiptDateFrom
            End If
            dtpSchTo.Enabled = True
            If mblnSchedReceiptDateToIsNull Then
                dtpSchTo.Value = dtpSchFrom.Value
            Else
                If mdtSchedReceiptDateTo > dtpSchFrom.Value Then
                    dtpSchTo.Value = mdtSchedReceiptDateTo
                Else
                    dtpSchTo.Value = dtpSchFrom.Value
                End If
            End If
            txtCalendarDays.Enabled = False
            txtCalendarDays.Text = ""
            dtpSchCalDay.Enabled = False
            updSch.Enabled = False
        Case SchDates.currentPlusCalendar
            dtpSchFrom.Enabled = False
            dtpSchTo.Enabled = False
            txtCalendarDays.Enabled = True
            txtCalendarDays.Text = mintCalendarDays
            dtpSchCalDay.Enabled = True
            updSch.Enabled = True
        Case SchDates.doNotUseSchdReceipt
            dtpSchFrom.Enabled = False
            dtpSchTo.Enabled = False
            txtCalendarDays.Enabled = False
            txtCalendarDays.Text = ""
            dtpSchCalDay.Enabled = False
            updSch.Enabled = False
        End Select
End Sub

Private Sub txtCalendarDays_Change()
    Dim intDays As Integer
    If IsNumeric(txtCalendarDays.Text) Then
        intDays = CInt(txtCalendarDays.Text)
        If intDays > updSch.Max Then
            intDays = updSch.Max
        ElseIf intDays < updSch.Min Then
            intDays = updSch.Min
        End If
        dtpSchCalDay.Value = DateAdd("d", intDays, Now)
        If Not mblnLoading Then
            mblnSchCalDaysChanged = True
            cmdSaveDates.Enabled = True
            StatusBar1.Panels(MSG_PANEL).Text = ""
        End If
    End If
End Sub

Private Sub txtCalendarDays_KeyPress(KeyAscii As Integer)
'If a backspace (ASCII-8) or a tab (ASCII-9) was
    ' entered, allow it unconditionally.
    If (KeyAscii = 8) Or (KeyAscii = 9) Then Exit Sub

    'Block the keypress if it is not a digit (ASCII-48
    ' through 57).
    If (KeyAscii < 48) Or (KeyAscii > 57) Then KeyAscii = 0
End Sub
