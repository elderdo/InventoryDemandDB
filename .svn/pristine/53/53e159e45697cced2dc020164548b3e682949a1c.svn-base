<html>
<%
//	SCCSID: %M% %I% Modified: %G% %U%
//	Date      By            History
//      05/28/02  kcs	    	Initial
//	10/23/02  kcs		add tcto.setHdnEvent("none") to not redo event when coming back to screen
%>
<title>Default Completion Rate</title>
<META NAME="title" Content="AMD Default Completion Rate">
<META NAME="subject" Content="AMD Effectivity Default Completion Rate">
<META NAME="creator" Content="338143-Ken Shew">
<META NAME="date" Content="2002-07-01">
<META NAME="validuntil" Content="2007-06-20">
<META NAME="owner" Content="293539-Gino Aedo">
<META NAME="robots" Content="all">
<script language=javascript>
function trim(strText) { 
    // this will get rid of leading spaces 
    while (strText.substring(0,1) == ' ') 
        strText = strText.substring(1, strText.length);

    // this will get rid of trailing spaces 
    while (strText.substring(strText.length-1,strText.length) == ' ')
        strText = strText.substring(0, strText.length-1);

   return strText;
} 

function isDigit (c)
{   return ((c >= "0") && (c <= "9"))
}

function isFloat (s)
{   var i;
    var seenDecimalPoint = false;
    var decimalPointDelimiter = '.';
    if (s== null || s==""){
   	return true;	 
    }
    if (s == decimalPointDelimiter) return false;

    // Search through string's characters one by one
    // until we find a non-numeric character.
    // When we do, return false; if we don't, return true.

    for (i = 0; i < s.length; i++)
    {   
        // Check that current character is number.
        var c = s.charAt(i);

        if ((c == decimalPointDelimiter) && !seenDecimalPoint){
		 seenDecimalPoint = true;
        }else if (!isDigit(c)){
		 return false;
	}
    }

    // All characters are numbers.
    return true;
}
function processEvent(whichone){
	isOk = true;
	if (whichone == 'update'){
		txtG = trim(document.dcrForm.txtGlobal.value);
		if (txtG == null  || txtG == ""){
			alert("Global default value cannot be empty");
			isOk = false;
		}
		if (!isFloat(txtG)){
			alert("Global default <" + txtG + "> not a positive number");
			isOk = false;
		}
		if (document.dcrForm.txtUserDefault != null){
			if (document.dcrForm.txtUserDefault.length == null){
				loopEnd = 1;
			}else{
				loopEnd = document.dcrForm.txtUserDefault.length;
			}
			for (i=0 ; i < loopEnd; i ++){
				if (loopEnd == 1){
					ud = document.dcrForm.txtUserDefault.value;
					tcto = document.dcrForm.hdnTcto.value;
				}else{
					ud = document.dcrForm.txtUserDefault[i].value;
					tcto = document.dcrForm.hdnTcto[i].value;
				}
				if ( !isFloat(trim(ud)) ){
					alert("TCTO " + tcto + " value <" + ud + "> is not a positive number");
					isOk = false;
				}
			}
		}
	}
	if (isOk){
		document.dcrForm.hdnEvent.value= whichone;
		document.dcrForm.submit();
	}
}
function clearAll(){
	if (document.dcrForm.txtUserDefault.length == null){
		document.dcrForm.txtUserDefault.value = "";
	}else{
		for (i=0 ; i < document.dcrForm.txtUserDefault.length; i ++){
			document.dcrForm.txtUserDefault[i].value = "";
		}
	}
}
</script>
<%@ page errorPage="amdErrorPage.jsp" import="java.sql.*, Configuration.AmdDB, retrofit.DefaultCompRateBean, Configuration.HtmlMenu" %>
<%!
	public String defaultStr(String inString, String inItem){
		if (inString == null || inString.equals("default")){
			return "<font color=\"brown\">-- no " + inItem + " chosen --</font>";
		}else{
			return inString;
		}
	}
	public String formatErrorMsg(String inString){
		return "<b><font color=\"red\">" + inString + "</font></b>";

	}
	public String nvl(String in, String replace){
		if (in == null){
			return replace;
		}else{
			return in;
		}
	}
	public String isChecked(String compareTo, String in){
		if (compareTo.equalsIgnoreCase(in)){
			return "checked ";
		}else{
			return "";
		}
	}
%>

<jsp:useBean id="dcr" class="retrofit.DefaultCompRateBean" scope="session" />
	<jsp:setProperty name="dcr" property="*" />
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
	//dcr.setDebugOn(true);
	dcr.setSessionUser(username);
	dcr.setHdnEvent("none");
	dcr.setDescDisplayLength(90);
	dcr.setOut(out);
	dcr.setChkAll(request.getParameter("chkAll"));
	dcr.setTxtUserDefault(request.getParameterValues("txtUserDefault"));
	dcr.processEvents(myConn);
%>
<body vLink=#3690dc link=#3690dc bgColor=#ffffff  topmargin=0 leftmargin=0
rightmargin=0 marginwidth=0 marginheight=0 <%= dcr.getOnLoad() %>>
<%
	HtmlMenu htmlMenu = new HtmlMenu() ;

	htmlMenu.setLabel2("define tcto") ;
	htmlMenu.setTitle2("Define TCTO") ;
	htmlMenu.setLink2("defineTcto.jsp") ;
	htmlMenu.setUrlData2("") ;

	htmlMenu.setLabel3("define block") ;
	htmlMenu.setTitle3("Define Block") ;
	htmlMenu.setLink3("defineBlock.jsp") ;
	htmlMenu.setUrlData3("") ;

	htmlMenu.setLabel4("schd ac") ;
	htmlMenu.setTitle4("Schedule By Aircraft") ;
	htmlMenu.setLink4("schedByAc.jsp") ;
	htmlMenu.setUrlData4("") ;


	out.println(htmlMenu.getHtml()) ;
%>
<table>
<tr>
<td width=1>&nbsp;</td>
<td>
<form name="dcrForm" action="defaultCompRate.jsp" method="post">
<input type="hidden" name="hdnEvent" value="none">
<hr>
<b>Default Completion Rate</b>
<hr>
<br>
<br>
<p><b>Set Global Default Value</b><br>
<table>
<tr><td>Global Default&nbsp;<input type="text" name="txtGlobal" size="4" value="<%= dcr.getGlobalDefault(myConn) %>">
</td></tr><tr><td>Update&nbsp;<b>ALL</b>&nbsp;TCTOs to use global default <input type="checkbox" name="chkAll"></tr>
</table>
<br>
<br>
<p><b>Select TCTO(s)</b></p>
<select name="cboTcto" size="8" multiple>
	<% dcr.reportTcto(myConn); %>;
</select>
<br>
<input type="button" name="btnView" value="View" onClick="processEvent('getTcto');">
<br>
<br>
<br>
<%
	String list = null;
	try {
		list = dcr.reportSelectedTcto(myConn);
	}catch (Exception e){
	}
	if (list != null && !list.equals("")){
		out.println("<table border=\"1\"><tr><td><b>TCTO</b></td><td><b>Description</b></td><td><b>User Defined Default</b></td><td><b>Uses Global Default</b></td></tr>");
		out.println(list);
		out.println("</table>");
		out.println("<br>");
		out.println("<a href=\"javascript:clearAll()\">Clear All Above User Defined</a>");
		out.println("<br>");
	}
%>

<%
	out.println(formatErrorMsg(dcr.getErrorMsg()));
	out.println("<input type=\"button\" name=\"update\" value=\"update\" onClick=\"processEvent(\'update\');\">");

	if (dcr.getDebugOn())
		out.println(dcr.getDebugMsg());
	myConn.commit();
%>
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
