<html>
<%
//	SCCSID: %M% %I% Modified: %G% %U%
//	Date      By            History
//      05/28/02  kcs	    	Initial
//	10/23/02  kcs		add tcto.setHdnEvent("none") to not redo event when coming back to screen
%>
<META NAME="title" Content="AMD Define Block">
<META NAME="subject" Content="AMD Effectivity Define Block">
<META NAME="creator" Content="338143-Ken Shew">
<META NAME="date" Content="2002-07-01">
<META NAME="validuntil" Content="2007-06-20">
<META NAME="owner" Content="293539-Gino Aedo">
<META NAME="robots" Content="all">
<script language=javascript>
function reduceToMax() {
	maxLength = 100;
	myString = document.defineBlockForm.txtBlkDesc.value; 
	if ( myString != null){
		if (document.defineBlockForm.txtBlkDesc.value.length > maxLength){	
			document.defineBlockForm.txtBlkDesc.value = myString.substring(0, maxLength); 
		}
	}	
}
function processEvent(whichone){
	document.defineBlockForm.hdnEvent.value= whichone;
	isOk = true;
	if (whichone == 'addBlk'){
		txtBlk = document.defineBlockForm.txtBlk.value;
		txtBlkDesc = document.defineBlockForm.txtBlkDesc.value;
		if (txtBlk == null || trim(txtBlk) == "" || txtBlkDesc == null || trim(txtBlkDesc) == ""){
			alert('Block Name or Description cannot be empty');
			isOk = false;
		}
	}else if (whichone == 'addTcto'){
		if (document.defineBlockForm.cboTcto.options[document.defineBlockForm.cboTcto.selectedIndex].value == 'default'){

			alert('Need to choose tcto before trying to add');
			isOk = false;
		}
	}
	if (isOk){
		document.defineBlockForm.submit();
	}
}
function SetChecked(val) {
	dml = document.defineBlockForm;
	len = dml.elements.length;
	var i=0;
	for (i=0 ; i < len ; i++){
		if (dml.elements[i].name == 'chkTcto'){
			dml.elements[i].checked=val;
		}
	}
}
function delSpaces(strText){
	retStr = "";
	for (i=0 ; i < strText.length ; i++){
		if (!strText.charAt(i) == ' '){
			
		}	
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
</script>
<%@ page errorPage="amdErrorPage.jsp" import="java.sql.*, retrofit.DefineBlockBean, Configuration.AmdDB, Configuration.HtmlMenu"%>
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
		return "<b><br><font color=\"brown\">WARNING:<br>" + inString + "</font></b>";
	}
	public String isChecked(String compareTo, String in){
		if (compareTo.equalsIgnoreCase(in)){
			return "checked ";
		}else{
			return "";
		}
	}
%>
	<jsp:useBean id="dbh" class="retrofit.DefineBlockBean" scope="session" />
	<jsp:setProperty name="dbh" property="*" />
<% 	
 	response.setHeader("Cache-Control","no-cache"); //HTTP 1.1
//	response.setHeader("Pragma","no-cache"); //HTTP 1.0
//	response.setDateHeader ("Expires", 0); //prevents caching at the proxy server
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
	String reportCboBlk = null;
	String reportCboBlkAc = null;
	String reportCboTcto = null;
	String reportTctoList = null;
	try{
		// dbh.setDebugOn(true);
		dbh.setOut(out);
		dbh.setHdnEvent("none");
		dbh.setDescDisplayLength(60);
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
		dbh.setAcBy(acType);
		if (request.getParameter("chkDescDisplay") == null){
			dbh.setChkDescDisplay("");
		}
		session.setAttribute("acBy", acType);
			// values don't get reset thru setProperty if user empties txt boxes 
		dbh.setTxtBlk(request.getParameter("txtBlk"));
		dbh.setTxtBlkDesc(request.getParameter("txtBlkDesc"));
		dbh.setCboBlkAc(request.getParameterValues("cboBlkAc"));
		dbh.setHdnTcto(request.getParameterValues("hdnTcto"));
		dbh.processEvents(myConn);
			// to get warning and error messages
		reportCboBlk = dbh.reportCboBlk(myConn); 
		reportCboBlkAc = dbh.reportCboBlkAc(myConn); 
		reportCboTcto = dbh.reportCboTcto(myConn); 
		reportTctoList = dbh.reportTctoList(myConn);	
		dbh.setHdnEvent("default");
	}catch (Exception e){
		dbh.setErrorMsg(e.toString());	
	}
%>

<body vLink=#3690dc link=#3690dc bgColor=#ffffff  topmargin=0 leftmargin=0
rightmargin=0 marginwidth=0 marginheight=0 <%= dbh.getOnLoad() %>>
<%
	HtmlMenu htmlMenu = new HtmlMenu() ;

	htmlMenu.setLabel2("define tcto") ;
	htmlMenu.setTitle2("Define TCTO") ;
	htmlMenu.setLink2("defineTcto.jsp") ;
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
<form name="defineBlockForm" action="defineBlock.jsp" method="post">
<input type="hidden" name="hdnEvent" value="none">
<b>Define Block</b>
<%= formatErrorMsg(dbh.getErrorMsg()) %>
<%= formatWarnMsg(dbh.getWarnMsg()) %>
<hr>
<select name="cboBlk" size="1" onChange="processEvent('cboBlk');">;
<% 
	out.println(reportCboBlk); 
%>
</select>		
<input type="button" name="btnDel" value="Delete" onclick="processEvent('delBlk')">&nbsp;
<br>
<br>
<input type="button" name="btnAddBlk" value="Add Block OR Change Description" onClick="processEvent('addBlk');">
<table>
<tr><td>Block Name:</td><td><input type="text" name="txtBlk" size="20" maxlength="20" value="<%= nvl(dbh.getTxtBlk(), "")%>" onBlur="javascript:{this.value=this.value.toUpperCase();}"></td></tr>
<tr><td valign="top">Block Desc (limit 100 chars):</td>
<%	
	if (dbh.isChecked("chkDescDisplay").equals("")){
		out.println("<td><input type=\"txt\" name=\"txtBlkDesc\" onBlur=\"javascript:{this.value=this.value.toUpperCase();}\" maxlength=\"100\" size=\"50\" value=\"" + nvl(dbh.getTxtBlkDesc(), "") + "\"></td>");
	}else{
		out.println("<td><textarea name=\"txtBlkDesc\" onBlur=\"javascript:{this.value=this.value.toUpperCase();reduceToMax();}\" rows=\"2\" cols=\"50\" wrap=\"physical\" >" + nvl(dbh.getTxtBlkDesc(), "") + "</textarea></td>");
	}
%>
  <td valign="top"><input type="checkbox" name="chkDescDisplay" <%= dbh.isChecked("chkDescDisplay") %> onclick="processEvent('chkDescDisplay')" >display description as multiline</td></tr>
</table>
<hr>
<br>
<%
	if (!nvl(dbh.getCboBlk(), "default").equals("default")){
		out.println("Define Effectivity For <b>" + defaultStr(dbh.getCboBlk(), "block") + "</b><br>Populate Retrofit Effectivity By Selected Aircraft<br>");
		dbh.reportAcDisplay();
		out.println("<select name=\"cboBlkAc\" size=\"5\" multiple>");
		out.println(reportCboBlkAc); 
		out.println("</select>");
		if (! nvl(reportTctoList, "").equals("")){
			out.println("<img src=\"images/red_arrow_down.gif\" alt=\"aircraft have been selected\"><br>");
			out.println("<input type=\"button\" value=\"update selected ac\" onClick=\"processEvent(\'updateBlkAc\');\">");
		}
		out.println("<br><br>");
		out.println("<input name=\"btnAddTcto\" type=\"button\" value=\"Add\" onClick=\"processEvent(\'addTcto\');\">");
		out.println("<select name=\"cboTcto\" size=\"1\" >");
		out.println(reportCboTcto); 
		out.println("</select>");
	}
%>
	<br><br>
<% 
	if (!nvl(reportTctoList, "").equals("")){
		out.println("<table border=1><tr>");
		out.println("<td><input name=\"btnDelTcto\" type=\"button\" value=\"Delete\" onClick=\"processEvent(\'delTcto\');\"></td>");
		out.println("<td width=\"20%\" valign=\"top\"><b>TCTO #</b></td>");
		out.println("<td valign=\"top\"><b>Description</b></td></tr>");
		out.println(reportTctoList);
		out.println("</table>");
		out.println("<a href=\"javascript:SetChecked(1)\">Check&nbsp;All</a>");
		out.println("-");
		out.println("<a href=\"javascript:SetChecked(0)\">Clear&nbsp;All</a>");
	}
%>
<br>
<br>
<%  
	if(dbh.getDebugOn()){
		out.println(dbh.getDebugMsg());
 	}
	myConn.commit();
%>
<br>
</form>
</td>
</tr>
</table>
<%
	out.println(htmlMenu.getHtml()) ;
%>
<p><small>Last Modified on: 7/01/02 15:15</small>
<br><small>
Author:<a href="http://ioe.stl.mo.boeing.com/tele/detail.asp?bemsid=338143"><font style="font-size: 11px;" color=000000 face="verdana,arial,helvetica">K. Shew</font></a>
</small>
</body>
</html>
