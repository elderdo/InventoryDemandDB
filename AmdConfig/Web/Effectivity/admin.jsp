<html>
<%
//	SCCSID: %M% %I% Modified: %G% %U%
//	Date      By            History
//      05/28/02  kcs	    	Initial
//	08/20/02  kcs		add batch to button
//	10/23/02  kcs		add tcto.setHdnEvent("none") to not redo event when coming back to screen
//
//	PVCS
//	$Revision:   1.2  $
//	$Author:   c378632  $
//	$Workfile:   admin.jsp  $
%>
<META NAME="title" Content="AMD Forecast">
<META NAME="subject" Content="AMD Effectivity Forecast">
<META NAME="creator" Content="338143-Ken Shew">
<META NAME="date" Content="2002-07-01">
<META NAME="validuntil" Content="2007-06-20">
<META NAME="owner" Content="293539-Gino Aedo">
<META NAME="robots" Content="all">
<script language=javascript>
function processEvent(whichone){
	document.adminForm.hdnEvent.value= whichone;
	isOk = true;
	if(whichone == 'getAllValues'){
		cboNsn = document.adminForm.cboNsn[document.adminForm.cboNsn.selectedIndex].value;
		if(document.adminForm.chkAllNsns.checked && cboNsn == '-1'){
			alert("select nsn first before trying to get all nsns in group");
			document.adminForm.chkAllNsns.checked = false;	
			isOk = false;
		}
	}
	if (isOk){
		document.adminForm.submit();
	}
}
</script>
<%@ page errorPage="amdErrorPage.jsp" import="java.sql.*, retrofit.*, exceptions.*, Configuration.AmdDB, Configuration.HtmlMenu"%>
<%!
	public String nvl(String in, String replace){
		if (in == null){
			return replace;
		}else{
			return in;
		}
	}
	public String defaultStr(String inString, String inItem){
		if (inString == null || inString.equals("default")){
			return "<font color=\"brown\">-- no " + inItem + " chosen --</font>";
		}else{
			return inString;
		}
	}
	public String formatErrorMsg(String inString){
		if (nvl(inString, "").equals("")){
			return("");
		}
		return "<br><b><font color=\"red\">ERROR:<br>" + inString + "</font></b>";
	}
	public String formatWarnMsg(String inString){
		if (nvl(inString, "").equals("")){
			return("");
		}
		return "<br><b><font color=\"brown\">WARNING:<br>" + inString + "</font></b>";
	}
%>
<jsp:useBean id="adm" class="retrofit.AdminBean" scope="session" />
<jsp:setProperty name="adm" property="*" />
<% 	
 	response.setHeader("Cache-Control","no-cache"); //HTTP 1.1
//	response.setHeader("Pragma","no-cache"); //HTTP 1.0
//	response.setDateHeader ("Expires", 0); //prevents caching at the proxy server
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
	String reportNsiLocDistribs = null;
	String reportPlanner = adm.reportPlanner();
	String reportNsn = adm.reportNsn();
	java.util.ArrayList nsiSidGroupList = null;
	try{
		String txtNsnVpn = request.getParameter("txtNsnVpn");
		if (txtNsnVpn == null || txtNsnVpn.equals("")){
			adm.setTxtNsnVpn("");	
		}
		if (request.getParameter("chkAllNsns")== null){
			adm.setChkAllNsns("");
		}
		adm.setDebugOn(false);
		adm.setHdnEvent("none");
		adm.setDebugMsg("");
		adm.setOut(out);
		adm.setIsHtml(true);
		adm.setConn(myConn);
		adm.processEvents();
		reportPlanner = adm.reportPlanner();
		reportNsn = adm.reportNsn();
		reportNsiLocDistribs = adm.reportNsiLocDistribs();
		nsiSidGroupList = adm.getNsiSidGroupList();
	}catch (Exception e){
		adm.setErrorMsg("System problem: " + e.toString());
	}
%>

<body vLink=#3690dc link=#3690dc bgColor=#ffffff  
	topmargin=0 leftmargin=0 <%=adm.getOnLoad()%>>
<%
	HtmlMenu htmlMenu = new HtmlMenu() ;

	htmlMenu.setLink2("") ;

	htmlMenu.setLink3("") ;
	
	out.println(htmlMenu.getHtml()) ;
%>
<table>
<tr>
<td width=1>&nbsp;
</td>
<td>
<form name="adminForm" action="admin.jsp" method="post">
<input type="hidden" name="hdnEvent" value="none">
<hr>
<b>FORECAST</b>
<%= formatWarnMsg(adm.getWarnMsg()) %>
<%= formatErrorMsg(adm.getErrorMsg()) %>
<hr>
<br>
<b>Run Scheduling Engine</b>&nbsp;<input type="button" value=" Batch Process " onclick="processEvent('runBatch')">
<br>
<br>
<hr>
<br>
<b>View As Flying and As Capable Values</b>
<br>
<br>
<table>
<tr>
	<td><input type="button" value="Search" onclick="processEvent('search')"></td>
	<td>NSN&nbsp;<input type="radio" value="byNsn" name="optSearchBy" <%= adm.isCheckedInfo("optSearchBy","byNsn") %>>&nbsp;PN&nbsp;&nbsp;<input type="radio" name="optSearchBy" value="byVpn" <%= adm.isCheckedInfo("optSearchBy", "byVpn") %>></td>
	<td><input type="text" name="txtNsnVpn" value="<%=adm.getTxtNsnVpn()%>" onBlur="javascript:{this.value=this.value.toUpperCase();}"></td>
</tr>
<tr>
	<td>&nbsp;</td>
	<td>Planner:</td><td><select name="cboPlanner" onchange="processEvent('cboPlanner')">
		<% out.println(reportPlanner); %>	
		     </select></td>
</tr>
<tr>
	<td>&nbsp;</td>
	<td>NSN:</td><td><select name="cboNsn" onchange="processEvent('cboNsn')">
		<% out.println(reportNsn); %>	
		     </select></td>
</tr>
<tr>
	<td>&nbsp;</td>
	<td>&nbsp;</td>
	<td>
<%
	if (nsiSidGroupList != null && nsiSidGroupList.size() > 1){
		out.println("<input type=\"checkbox\" " + adm.isCheckedInfo("chkAllNsns") + " name=\"chkAllNsns\" onclick=\"processEvent('chkAllNsns')\">&nbsp;Get&nbsp;All&nbsp;NSNs in Group</td>");
	}
%>

</tr>
</table>
<br>
<%
	if (!reportNsiLocDistribs.equals("")){
		out.println("<a href=\"nsiLocDistribsExcel.jsp\">To Excel</a>");
		out.println("<table border=1>");
		out.println(reportNsiLocDistribs);  
		out.println("</table>");
		out.println("&nbsp;&nbsp;&nbsp;&nbsp;<a href=\"nsiLocDistribsExcel.jsp\">To Excel</a>");
	}
%>
<br>
<% 
	if (adm.getDebugOn())
		out.println(adm.getDebugMsg()); 
%>
<br>
</form>
</td>
</tr>
</table>
<%
	out.println(htmlMenu.getHtml()) ;
%>
<p><small>Last Modified on: 8/19/02</small>
<br><small>
Author:<a href="http://ioe.stl.mo.boeing.com/tele/detail.asp?bemsid=338143"><font style="font-size: 11px;" color=000000 face="verdana,arial,helvetica">K. Shew</font></a>
</small>
</body>
</html>
