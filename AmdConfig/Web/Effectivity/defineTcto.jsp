<html>
<%
//	SCCSID: %M% %I% Modified: %G% %U%
//	Date      By            History
//      05/28/02  kcs	    	Initial
//	09/24/02  kcs		change appearance of page, not content
//	09/30/02  kcs		change appearance of page, not content
//	10/10/02  kcs		change appearance of page, not content
//	10/23/02  kcs		add tcto.setHdnEvent("none") to not redo event when coming back to screen
//		PVCS
//	$Revision:   1.4  $
//	$Author:   c378632  $
//	$Workfile:   defineTcto.jsp  $
%>
<META NAME="title" Content="AMD Define TCTO">
<META NAME="subject" Content="AMD Effectivity Define TCTO">
<META NAME="creator" Content="338143-Ken Shew">
<META NAME="date" Content="2002-07-01">
<META NAME="validuntil" Content="2007-06-20">
<META NAME="owner" Content="293539-Gino Aedo">
<META NAME="robots" Content="all">
<script language=javascript>
function reduceToMax() {
	maxLength = 512;
	myString = document.tctoForm.txtTctoDesc.value; 
	if ( myString != null){
		if (document.tctoForm.txtTctoDesc.value.length > maxLength){	
			document.tctoForm.txtTctoDesc.value = myString.substring(0, maxLength); 
		}
	}	
}
function processEvent(whichone){
	document.tctoForm.hdnEvent.value = whichone;
	isOk = true;
	if (whichone == 'addTcto'){
		txt = document.tctoForm.txtTcto.value;
		txtDesc = document.tctoForm.txtTctoDesc.value;
		if (txt == null || trim(txt) == "" || txtDesc == null || trim(txtDesc) == ""){
			alert("TCTO Number or Description cannot be empty");
			isOk = false;
		}
	}else if (whichone == 'addBlkAc'){
		isOk = false;
		for (i=0; i < document.tctoForm.cboBlkAc.length; i++){
			if (document.tctoForm.cboBlkAc[i].selected){
				isOk = true;			
			}
		}
		if (isOk == false){
			alert("Must choose aircraft before updating effectivity");
		}
	}
	if (isOk == true){
		document.tctoForm.submit();
	}
}

function trim(strText) { 
    // this will get rid of leading spaces 
    while (strText.substring(0,1) == ' ') 
        strText = strText.substring(1, strText.length);

    // this will get rid of trailing spaces 
    while (strText.substring(strText.length-1,strText.length) == ' ')
        strText = strText.substring(0, strText.length-1);

   return strText;
} 
function chk(whichone){
	document.tctoForm.hdnChkAction.value = whichone;
	document.tctoForm.submit();
}
function SetChecked(val) {
	dml=document.tctoForm;
	len = dml.elements.length;
	var i=0;
	for( i=0 ; i<len ; i++) {
		if (dml.elements[i].name=='chkFromTo') {
			dml.elements[i].checked=val;
		}
	}
}
function update(){
	document.tctoForm.submit();
}
</script>
<%@ page errorPage="amdErrorPage.jsp" import="java.sql.*, retrofit.DefineTctoBean, Configuration.AmdDB, Configuration.HtmlMenu" %>
<%!
	public String defaultStr(String inString, String inItem){
		if (inString == null || inString.equals("default")){
			return "<font color=\"brown\">-- no " + inItem + " chosen --</font>";
		}else{
			return inString;
		}
	}
	public String formatErrorMsg(String inString){
		if (whenNull(inString).equals("")){
			return "";
		}else{
			return "<br><b><font color=\"red\">ERROR: " + inString + "</font></b>";
		}
	}
	public String formatInstrMsg(String inString){
		if (whenNull(inString).equals("")){
			return "";
		}else{
			return "<br><b><font color=\"blue\">" + inString + "</font></b>";
		}
	}
	public String formatWarnMsg(String inString){
		if (whenNull(inString).equals("")){
			return "";
		}else{
			return "<br><b><font color=\"brown\">WARNING:<br>" + inString + "</font></b>";
		}
	}
	public String whenNull(String in){
		if (in == null){
			return "";
		}else{
			return in;
		}
	}
	
%>
	<jsp:useBean id="tcto" class="retrofit.DefineTctoBean" scope="session" />
	<jsp:setProperty name="tcto" property="*" />
<%
 	response.setHeader("Cache-Control","no-cache"); //HTTP 1.1
 // 	response.setHeader("Pragma","no-cache"); //HTTP 1.0
//  	response.setDateHeader ("Expires", 0); //prevents caching at the proxy server
  	String username = (String) session.getAttribute("userid");
	String userid = (String) session.getValue("userid") ;
	if (userid == null) {
		try {
			response.sendRedirect("login.jsp") ;
			return ;
		} catch (java.lang.IllegalStateException e) {
			out.println("<html><body>Session expired:<a href=login.jsp>Goto Login</a></body></html>") ;
			return ;
		}
	}
	Connection myConn = AmdDB.instance().getConnection(userid) ;
	if (myConn == null) {
		try {
			response.sendRedirect("login.jsp") ;
			return ;
		} catch (java.lang.IllegalStateException e) {
			out.println("<html><body>Session expired:<a href=login.jsp>Goto Login</a></body></html>") ;
			return ;
		}
		
	}

	session.setAttribute("DBConn",myConn);	
	String reportCboTcto = "";
	String reportPlanner = "";
	String reportNsn = "";
	String reportPair = "";
	String reportFromTo = "";
	String reportCboBlkAc = "";
	try {
		tcto.setDebugOn(false);
		tcto.setOut(out);
		tcto.setHdnEvent("none");
		tcto.setDescDisplayLength(60);
		if (request.getParameter("chkDescDisplay") == null){
			tcto.setChkDescDisplay("");
		}
		String acTypeRequest = request.getParameter("acBy");
		String acTypeSession = (String) session.getAttribute("acBy");
		String acType = null;
		if (acTypeRequest != null){
			acType = acTypeRequest;
		}else if (acTypeSession != null){
			acType = acTypeSession;
		}else{
			acType = "p_no";
		}
		tcto.setAcBy(acType);
		session.setAttribute("acBy", acType);
		tcto.processEvents(myConn);
		// to be able to put warning and error messages at top of page,
		// run reports first.
		reportCboTcto = tcto.reportCboTcto(myConn);
		reportPlanner = tcto.reportPlanner(myConn); 
		reportNsn = tcto.reportNsn(myConn); 
		reportPair = tcto.reportPair(myConn); 
		reportFromTo = tcto.reportFromTo(myConn);
		reportCboBlkAc = tcto.reportCboBlkAc(myConn);
		if (request.getParameter("cboBlkAc") == null){
			tcto.setCboBlkAc(null);
		}
		if (request.getParameter("chkFromTo") == null){
			tcto.setChkFromTo(null);
		}
		String txtNsnVpn = request.getParameter("txtNsnVpn");
		if (txtNsnVpn == null || txtNsnVpn.equals("")){
			tcto.setTxtNsnVpn("");	
		}
	}catch (Exception e){
		tcto.setErrorMsg("Error from main");
	}
%>
<body vLink=#3690dc link=#3690dc bgColor=#ffffff  topmargin=0 leftmargin=0
rightmargin=0 marginwidth=0 marginheight=0 <%=tcto.getOnLoad()%>>
<%
	HtmlMenu htmlMenu = new HtmlMenu() ;

	htmlMenu.setLabel2("define block") ;
	htmlMenu.setTitle2("Define Block") ;
	htmlMenu.setLink2("defineBlock.jsp") ;
	htmlMenu.setUrlData2("") ;

	htmlMenu.setLabel3("schd ac") ;
	htmlMenu.setTitle3("Schedule By Aircraft") ;
	htmlMenu.setLink3("schedByAc.jsp") ;
	htmlMenu.setUrlData3("") ;

	htmlMenu.setLabel4("deflt compl rt") ;
	htmlMenu.setTitle4("Default Completion Rate") ;
	htmlMenu.setLink4("defaultCompRate.jsp") ;
	htmlMenu.setUrlData4("") ;


	out.println(htmlMenu.getHtml()) ;
%>
<table>
<tr>
<td width=1>&nbsp;</td>
<td>
<form name="tctoForm" action="defineTcto.jsp" method="post">
<input type="hidden" name="hdnEvent" value="none">
<b>Define TCTO</b>
<%= formatErrorMsg(tcto.getErrorMsg()) %>
<%= formatWarnMsg(tcto.getWarnMsg()) %>
<%= formatInstrMsg(tcto.getInstrMsg()) %>
<hr>
	&nbsp;
	<select name="cboTcto" size="1" onChange="processEvent('cboTcto');" size="25">
		<% out.println(reportCboTcto); %>
	</select>&nbsp;<input type="button" name="btnDelTcto" value="Delete" onclick="processEvent('delTcto');">
	<br>
	<br>
	<input type="button" name="btnAddChgTcto" value="Add TCTO OR Change Description" onclick="processEvent('addTcto');">
<table>
  <tr>
	<td>TCTO Number:</td>
	<td><input type="txt" name="txtTcto" onBlur="javascript:{this.value=this.value.toUpperCase();}" size="13" maxlength="13" value="<%= whenNull(tcto.getTxtTcto()) %>"></td>
  </tr>
  <tr>
	<td valign="top">TCTO Desc (limit&nbsp;512&nbsp;chars):</td>
<%	
	if (tcto.isChecked("chkDescDisplay").equals("")){
		out.println("<td><input type=\"txt\" name=\"txtTctoDesc\" onBlur=\"javascript:{this.value=this.value.toUpperCase();}\" maxlength=\"512\" size=\"50\" value=\"" + whenNull(tcto.getTxtTctoDesc()) + "\"></td>");
	}else{
		out.println("<td><textarea name=\"txtTctoDesc\" onBlur=\"javascript:{this.value=this.value.toUpperCase();reduceToMax();}\" rows=\"8\" cols=\"64\" wrap=\"physical\" >" + whenNull(tcto.getTxtTctoDesc()) + "</textarea></td>");
	}
%>
  <td valign="top"><input type="checkbox" name="chkDescDisplay" <%= tcto.isChecked("chkDescDisplay") %> onclick="processEvent('chkDescDisplay')" >display description as multiline</td></tr>
</table>
<%
	out.println("<br><hr><br>");
if (!tcto.getCboTcto().equals("default")){
	out.println("	<b>TCTO Parts List<br>Add Parts By Selecting NSN/Part Number Pairs To Associate With TCTO " +  defaultStr(tcto.getCboTcto(), "tcto")  + "</b><br><br><br>");
	out.println("List/Search Items:");
	out.println("<table>");
	out.println("<tr><td>&nbsp;&nbsp;&nbsp;</td><td><input type=\"button\" value=\"List All Pairs\" onclick=\"processEvent(\'chkPairListAll\');\"></td></tr>");
	out.println("<tr><td>&nbsp;&nbsp;&nbsp;</td><td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color=\"blue\"><b>OR</b></font></td><td>&nbsp;</td></tr>");
	out.println("<tr><td>&nbsp;&nbsp;&nbsp;</td><td><b>Choose Planner:&nbsp;</b>");
	out.println("			<select name=\"cboPlanner\" size=\"1\" onChange=\"processEvent(\'cboByPlanner\');\">    ");
					out.println(reportPlanner);
	out.println("			</select></td></tr>");
	out.println("<tr><td>&nbsp;&nbsp;&nbsp;</td><td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color=\"blue\"><b>OR</b></font></td><td>&nbsp;</td></tr>");
	out.println("	<tr>    ");
	out.println("		<td>&nbsp;&nbsp;&nbsp;</td><td><b>From</b>&nbsp;<input type=\"Radio\" name=\"optFromTo\" value=\"byFrom\"" + tcto.isChecked("optFromTo", "byFrom") + ">&nbsp;&nbsp;<b><font color=\"blue\">or</font></b>&nbsp;&nbsp;&nbsp;&nbsp;<b>To</b>&nbsp;&nbsp;<input type=\"Radio\" name=\"optFromTo\" value=\"byTo\"" +  tcto.isChecked("optFromTo", "byTo") + "></td></tr>  ");
	out.println("		<tr><td>&nbsp;&nbsp;&nbsp;</td><td><b>NSN</b>&nbsp;<input type=\"Radio\" name=\"optSearchBy\" value=\"byNsn\" " + tcto.isChecked("optSearchBy", "byNsn") + ">");
	out.println("&nbsp;&nbsp;<b><font color=\"blue\">or</font></b>&nbsp;&nbsp;&nbsp;<b>PN</b>&nbsp;<input type=\"RADIO\" name=\"optSearchBy\" value=\"byVpn\" " +  tcto.isChecked("optSearchBy", "byVpn") + 	">");
	out.println("</td></tr><tr><td>&nbsp;&nbsp;&nbsp;</td><td><input size=\"25\" type=\"text\" onBlur=\"javascript:{this.value=this.value.toUpperCase();}\" name=\"txtNsnVpn\" value=\"" +  tcto.getTxtNsnVpn() + "\" 	></td></tr>    ");
	out.println("<tr><td>&nbsp;&nbsp;&nbsp;</td><td><input type=\"button\" value=\"Search For Pairs\" align=\"BOTTOM\" 	onclick=\"processEvent(\'search\');\"></td>");
	out.println("</table><br>");
	out.println("Select From List/Search Results:");
	out.println("<table>");
	out.println("	<tr>");
	out.println("<td>&nbsp;&nbsp;&nbsp;</td><td><b>NSN:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</b>    ");
	out.println("			<select name=\"cboNsn\" size=\"1\" onChange=\"processEvent(\'cboByNsn\');\">    ");
				 	out.println(reportNsn);
	out.println("			</select></td></tr>");
	out.println("	<tr>    ");
	out.println("		<td>&nbsp;&nbsp;&nbsp;</td><td><b>From To Pair:</b>&nbsp;&nbsp;<select name=\"cboPair\" size=\"1\">    ");
				out.println(reportPair); 
	out.println("		    </select></td></tr>");
	out.println("<tr><td>&nbsp;&nbsp;&nbsp;</td><td><input type=\"button\" name=\"addFromTo\" value=\"Add Nsn Pair     \" 	onclick=\"processEvent(\'addFromTo\');\"></td></tr></table>    ");	
	out.println("	<br>    ");
	if (!reportFromTo.equals("")){
		out.println("	<table border=1>    ");
		out.println("	<th style=\"font-weight: bold;\">    ");
		out.println("	<tr>    ");
		out.println("		<td><input type=\"button\" name=\"removeFromTo\" value=\"Remove\" 	onclick=\"processEvent(\'delFromTo\');\"></td>    ");
		out.println("		<td valign=\"TOP\" colspan=\"2\"><b>From:&nbsp;&nbsp;Nsn / Part No.</b>&nbsp;</td>    ");
		out.println("		<td valign=\"TOP\" colspan=\"2\"><b>To:&nbsp;&nbsp;Nsn / Part No.</b>&nbsp;</td>    ");
		out.println("	</tr>    ");
		out.println("	</th>    ");
		out.println(reportFromTo); 
		out.println("	</table>    ");
		out.println("	<a href=\"javascript:SetChecked(1)\">Check&nbsp;All</a>    ");
		out.println("	-    ");
		out.println("	<a href=\"javascript:SetChecked(0)\">Clear&nbsp;All</a><br>    ");
	}
	out.println("<br><hr><br>");
	out.println("<b>Define Effectivity For " + defaultStr(tcto.getCboTcto(), "tcto")  + "</b>");
	out.println("<br>Populate Retrofit Effectivity By Selected Aircraft<br>");
	tcto.reportAcDisplay();
	out.println("<select name=\"cboBlkAc\" size=\"5\" multiple>");
		out.println(reportCboBlkAc);
	out.println("</select>");
	if (tcto.getIsAcSelected()){
		out.println("<img src=\"images/red_arrow_down.gif\" alt=\"aircraft have been selected\">");	
	}
	out.println("<br><input type=\"button\" value=\"Update Effectivity\" onclick=\"processEvent(\'addBlkAc\');\">    ");
}
%>
<br>
<% 
	if (tcto.getDebugOn())
		out.println("debug:" + tcto.getDebugMsg());
	myConn.commit();
%>
</form>
</td>
</tr>
</table>
<%
	out.println(htmlMenu.getHtml()) ;
%>
<p><small>Last Modified on: 9/24/02 15:15</small>
<br><small>
Author:<a href="http://ioe.stl.mo.boeing.com/tele/detail.asp?bemsid=338143"><font style="font-size: 11px;" color=000000 face="verdana,arial,helvetica">K. Shew</font></a>
</small>
</body>
</html>
