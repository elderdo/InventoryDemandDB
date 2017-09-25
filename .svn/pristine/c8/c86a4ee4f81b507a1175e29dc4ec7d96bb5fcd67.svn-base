<%@ page import="java.text.*, java.util.*, java.lang.*, java.sql.*, coreservlets.*, Substitution.*, Configuration.AmdDB, Configuration.NavBar, Configuration.HtmlMenu, org.apache.log4j.Logger" %>
<%
	Logger logger = Logger.getLogger("Substitution.jsp") ;
	String userid = (String) session.getValue("userid") ;
	if (userid == null) {
		try {
			response.sendRedirect("login.jsp") ;
			logger.info("Session Ended: userid missing in the session object: the user did not login or the session has timed out.") ;
			return ;
		} catch (java.lang.IllegalStateException e) {
			out.println("<html><body>Session expired:<a href=login.jsp>Goto Login</a></body></html>") ;
			return;
		}
	}
	Connection conn = AmdDB.instance().getConnection(userid) ;
	if (conn == null) {
		try {
			response.sendRedirect("login.jsp") ;
			logger.warn("Session Ended: lost the Oracle connection for userid " + userid) ;
			return ;
		} catch (java.lang.IllegalStateException e ) {
			out.println("<html><body>Session expired:<a href=login.jsp>Goto Login</a></body></html>") ;
			return ;
		}
	}


	Cookie[] cookies = request.getCookies();
	String keepSearch = ServletUtilities.getCookieValue(cookies, "KeepSearch", "N");
	LongLivedCookie keepSearchCookie = new LongLivedCookie("KeepSearch", keepSearch);
	response.addCookie(keepSearchCookie);

	

	ControlerSub cntl = new ControlerSub() ;
	cntl.setResponse(response) ;
	cntl.setRequest(request) ;
	cntl.setConn(conn) ;
	cntl.execute() ;
	String strPartNo = cntl.getPartNo() ;
		
%>

<html>
<title>Product Structure</title>
<META NAME="title" Content="Product Structure">
<META NAME="subject" Content="AMD Product Structure Application Data Entry Form to capture AMD Effectivity information">
<META NAME="creator" Content="1013683-Phuong-Thuy Pham">
<META NAME="date" Content="2002-06-21">
<META NAME="validuntil" Content="2007-06-21">
<META NAME="owner" Content="293539-Gino Aedo">
<META NAME="robots" Content="all">
<META NAME="Revision" Content="$Revision:   1.0  $">
<META NAME="Author" Content="$Author:   c970183  $">
<META NAME="Workfile" Content="$Workfile:   Substitution.jsp  $">
<META NAME="Log" Content="$Log:   \\www-amssc-01\pds\archives\SDS-AMD\Web\Effectivity\Substitution.jsp-arc  $">
/*   
/*      Rev 1.0   16 Sep 2002 10:50:52   c970183
/*   Initial revision.
<meta name="keywords" content=" Product, Structure, AMD, SDS">
<meta name="revisit-after" content="7days">
<meta name="robots" content="index, follow"> 
<meta HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=iso-8859-1">

	<style type="text/css">
	<!--
	A:link {text-decoration: none;}
	A:visited {text-decoration: none;}
	A:hover {text-decoration: underline;}
	-->
	</style>

<script language=javascript>
function VerifyInput() {
	return true ;
}
function DoAction(TheAction) {
	document.TheForm.action.value = TheAction ;
	document.TheForm.submit() ;
}
function Search(WhichOne) {
	if (WhichOne == '<%=ControlerSub.SEARCH_WITH_TOP_NAVBAR%>') {
		document.<%=ControlerSub.FORM_NAME%>.cboPlanner.options[0].selected = true ;
		document.<%=ControlerSub.FORM_NAME%>.cboNsn.options[0].selected = true ;
		<% if (!cntl.getNsiSid().equals(NavBar.NO_SELECTION) && !cntl.getNsn().equals("")) { %>
			document.<%=ControlerSub.FORM_NAME%>.cboEquiPlanner.options[0].selected= true ;
			document.<%=ControlerSub.FORM_NAME%>.cboEquiNsn.options[0].selected = true ;
		<% } %>
	}
	document.<%=ControlerSub.FORM_NAME%>.search.value = WhichOne ;
	document.<%=ControlerSub.FORM_NAME%>.submit() ;

}
function cboACReset() {
	var i=0 ;
	for (i=0 ; i<document.TheForm.cboAC.length; i++) {
		document.TheForm.cboAC.options[i].selected = false ;
	}
}
function cboPlannerChanged() {
	<% if (keepSearch.equals("N")) { %>
	document.<%=ControlerSub.FORM_NAME%>.txtNsnVpn.value = "" ;
	<% } %>
	document.TheForm.cboNsn.options[0].selected = true;
	Search(<%=ControlerSub.SEARCH_BY_PLANNER%>);
	document.TheForm.submit();
	return true ;
}

function cboNsnChanged() {
	document.TheForm.submit();
	return true ;
}



function cboEquiPlannerChanged() {
	<% if (keepSearch.equals("N")) { %>
	document.<%=ControlerSub.FORM_NAME%>.txtEquiNsnVpn.value = "" ;
	<% } %>
	document.TheForm.cboEquiNsn.options[0].selected = true;
	Search(<%=ControlerSub.SEARCH_BY_PLANNER%>);
	document.TheForm.submit();
	return true ;
}

function cboEquiNsnChanged() {
	document.TheForm.submit();
	return true;
}

function lastField(fld) {
	var i ;
	for (i = 0; i < document.forms[0].elements.length; i++) {
		if (document.forms[0].elements[i] == fld) {
			document.forms[0].lastElement.value = i ;
			break ;
		}
	}
}
function goto(link) {
	document.location.href = link ;
}

function SetChecked(val) {
	dml=document.TheForm;
	len = dml.elements.length;
	var i=0;
	for( i=0 ; i<len ; i++) {
		if (dml.elements[i].name=='Remove') {
			dml.elements[i].checked=val;
		}
	}
}
</script>
<body bgcolor=#ffffff link=3690dc vlink=3690dc topmargin=0 leftmargin=0 rightmargin=0 marginwidth=0 marginheight=0
	onLoad='<%=cntl.getLastElement()%>'>
<%
	HtmlMenu htmlMenu = new HtmlMenu() ;
	htmlMenu.setNsn(cntl.getNsn()) ;
	htmlMenu.setNsiSid(cntl.getNsiSid()) ;
	htmlMenu.setPlannerCode(cntl.getPlannerCode()) ;
	htmlMenu.setLabel3("configuration") ;
	htmlMenu.setLink3("Config.jsp") ;
	htmlMenu.setTitle3("Configuration") ;

	out.println(htmlMenu.getHtml()) ;
%>
<b>Product Structure</b>
<font color="ff0000" size=+1><%=cntl.getMsg()%></font>
<form NAME="TheForm" METHOD="POST" ACTION=".<%=request.getServletPath()%>" OnSubmit="return VerifyInput(this);">
<%
	out.println(cntl.getTopNavBar()) ;
%>
<hr>
<%

if (!cntl.getNsiSid().equals(NavBar.NO_SELECTION)) {
	out.println(cntl.getSplitConfigurationTables()) ;
%>
<table width=100%><!- Start TableD-->
<tr>
<td>
<font color="ff0000" size=+1><%=cntl.getMsg()%></font>
</table><!- End TableD-->
<% }  %>
<input type=hidden name=search>
<input type=hidden name=txtNsn value=<%=cntl.getNsn()%>>
<input type=hidden name=action>
<input type=hidden name=lastElement value=0>
</form>
<%
	out.println(htmlMenu.getHtml()) ;
%>

<script>
var default_date = "6/20/02"
var lm = document.lastModified

if (Date.parse(lm) == 0) {
lm = default_date
}

document.write("<p><small>Last Modified on:6/28/02 13:55</small>")
</script>
<br><small>
Author:<a href="http://ioe.stl.mo.boeing.com/tele/detail.asp?bemsid=1013683">
<FONT 
style="FONT-SIZE: 11px" face=verdana,arial,helvetica color=#000000>
Thuy Pham
</font>
</a>
</small>
</body>
</html>