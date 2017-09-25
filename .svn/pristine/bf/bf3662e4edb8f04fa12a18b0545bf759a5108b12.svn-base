<%--
  $Revision:   1.5  $
    $Author:   c970408  $
  $Workfile:   Config.jsp  $
       $Log:   \\www-amssc-01\pds\archives\SDS-AMD\Web\Effectivity\Config.jsp-arc  $
/*   
/*      Rev 1.5   13 Nov 2002 11:58:24   c970408
/*   REALLY fixed the comment section of keywords.
--%>

<%@ page import="java.text.*, java.util.*, java.sql.*, coreservlets.*, Configuration.*, org.apache.log4j.Logger" %>
<%
	Logger logger = Logger.getLogger("Config.jsp") ;
	String userid = (String) session.getValue("userid") ;
	if (userid == null) {
		try {
			response.sendRedirect("login.jsp") ;
			logger.info("Session Ended: userid missing in the session object: the user did not login or the session has timed out.") ;
			return ;
		} catch (java.lang.IllegalStateException e) {
			out.println("<html><body>Session expired:<a href=login.jsp>Goto Login</a></body></html>") ;
			return ;
		}
	}
	Connection conn = AmdDB.instance().getConnection(userid) ;
	if (conn == null) {
		try {
			response.sendRedirect("login.jsp") ;
			logger.warn("Session Ended: lost the Oracle connection for userid " + userid) ;
			return ;
		} catch (java.lang.IllegalStateException e) {
			out.println("<html><body>Session expired:<a href=login.jsp>Goto Login</a></body></html>") ;
			return ;
		}
		
	}


	Cookie[] cookies = request.getCookies() ;
	String keepSearch = ServletUtilities.getCookieValue(cookies, "KeepSearch", "N") ;
	LongLivedCookie keepSearchCookie = new LongLivedCookie("KeepSearch", keepSearch) ;
	response.addCookie(keepSearchCookie) ;

	Controller cntl = new Controller() ;
	cntl.setDebug(false) ;
	cntl.setResponse(response) ;
	cntl.setRequest(request) ;
	cntl.setOut(out) ;
	cntl.setConn(conn) ;
	cntl.execute() ;
%>
<html>
<title>Configuration</title>
<META NAME="title" Content="Configuration">
<META NAME="subject" Content="AMD Configuration Application Data Entry Form to capture AMD Effectivity information">
<META NAME="creator" Content="535547-Douglas S. Elder">
<META NAME="date" Content="2002-06-21">
<META NAME="validuntil" Content="2007-06-21">
<META NAME="owner" Content="293539-Gino Aedo">
<META NAME="robots" Content="all">
<META NAME="Revision" Content="$Revision:   1.5  $">
<META NAME="Author" Content="$Author:   c970408  $">
<META NAME="Workfile" Content="$Workfile:   Config.jsp  $">
<meta name="keywords" content=" Configuration, AMD, SDS">
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
<script language="JavaScript" src="date-picker.js"></script>
<script language=javascript>
function makeArray(n){
	for (i = 1; i <= n; i++){
		this[i] = 0;
	}
	return this;
}
var daysInMonth = makeArray(12);
daysInMonth[1] = 31;
daysInMonth[2] = 29;   // must programmatically check this
daysInMonth[3] = 31;
daysInMonth[4] = 30;
daysInMonth[5] = 31;
daysInMonth[6] = 30;
daysInMonth[7] = 31;
daysInMonth[8] = 31;
daysInMonth[9] = 30;
daysInMonth[10] = 31;
daysInMonth[11] = 30;
daysInMonth[12] = 31;

function trim(strText) { 
    // this will get rid of leading spaces 
    while (strText.substring(0,1) == ' ') 
        strText = strText.substring(1, strText.length);

    // this will get rid of trailing spaces 
    while (strText.substring(strText.length-1,strText.length) == ' ')
        strText = strText.substring(0, strText.length-1);

   return strText;
} 
function daysInFebruary(year){
	return ( ((year % 4==0) && ((!(year%100==0)) || (year % 400 ==0)))?29:28);
}

function inRange (s, start, end){
	x = parseInt(s);
	intStart = parseInt(start);
	intEnd = parseInt(end);
	if (x >= intStart && x <= intEnd){
		return true;
	}else{
		return false;
	}
}
function stripLeadZero(inString){
	myString = inString.toString();
	if (myString.substring(0,1) == '0'){
		return myString.substring(1, myString.length);
	}else{
		return myString;
	}
}

function isDate (pYear, pMonth, pDay){   
	var intYear = parseInt(pYear);
	var intMonth = parseInt(pMonth);
	var intDay = parseInt(pDay);
	if (!( (intYear > 0) && inRange(intMonth, 1, 12) && inRange(intDay, 1, 31) )){
		return false;
	}
	if ((intMonth == 2) && (intDay > daysInFebruary(intYear))) return false;
	if (intDay > daysInMonth[intMonth]){
		 return false; 
	}
	return true;
}

function retFullYear(inYear){
	year = parseInt(inYear);		
	if (year < 100){
			// match oracle RR 
		if (year >= 0 && year <= 49){
			year = year + 2000;
		}else {
			year = year + 1900;
		}
	}
	return year;	
}


function getYearMonDayArray(inString){
	regDateSlash = /^(\d?\d)\/(\d?\d)\/(\d\d\d\d)$/;
	regDateSlash2 = /^(\d?\d)\/(\d?\d)\/(\d\d)$/;
	regDateDash = /^(\d?\d)\-(\d?\d)\-(\d\d\d\d)$/;
	regDateDash2 = /^(\d?\d)\-(\d?\d)\-(\d\d)$/;
	if (regDateSlash.test(inString) || regDateSlash2.test(inString)){
		pieces = inString.split('/');
	}else if (regDateDash.test(inString) || regDateDash2.test(inString)){
		pieces = inString.split('-');
	}else{
		return null;
	}
	pieces[2] = retFullYear(pieces[2]);
	return pieces;
}

function validDate(theDate) {
	var ymd = "" ;
	ymd = getYearMonDayArray(theDate) ;
	if (ymd == null) {
	    return false ;
	} else {
	    year = stripLeadZero(ymd[2]) ;
	    month = stripLeadZero(ymd[0]) ;
	    day = stripLeadZero(ymd[1]) ;
	    if (!isDate(year, month, day)) {
		return false ;
	    }
	}
	return true ;
}

function validData() {
	var year = "" ;
	var month = "" ;
	var day = "" ;
	if (document.<%=Controller.FORM_NAME%>.txtStartDate.value != "") {
		if (!validDate(document.<%=Controller.FORM_NAME%>.txtStartDate.value)) {
			alert("Bad start date.") ;
			document.<%=Controller.FORM_NAME%>.txtStartDate.focus() ;
			return false ;
		}
	}
	if (document.<%=Controller.FORM_NAME%>.txtNeverBuy.value != "") {
		if (!validDate(document.<%=Controller.FORM_NAME%>.txtNeverBuy.value)) {
			alert("Bad deplete by date.") ;
			document.<%=Controller.FORM_NAME%>.txtNeverBuy.focus() ;
			return false ;
		}
	}
	var i = 0 ;
	var fleetSelected = false ;
	for (i=1 ; i<document.<%=Controller.FORM_NAME%>.cboAC.length; i++) {
		if (document.<%=Controller.FORM_NAME%>.cboAC.options[i].selected) {
			fleetSelected = true ;
		}
	}
	for (i=1 ; i<document.<%=Controller.FORM_NAME%>.cboFleetSize.length; i++) {
		if (document.<%=Controller.FORM_NAME%>.cboFleetSize.options[i].selected) {
			fleetSelected = true ;
		}
	}
	if (!fleetSelected) {
		alert("You must select a fleet size.") ;
		document.<%=Controller.FORM_NAME%>.cboFleetSize.focus() ;
		return false ;
	}

	return true ;
}
function DoAction(TheAction) 
{
	if (TheAction == "A" && 
		document.<%=Controller.FORM_NAME%>.cboRelNsn.selectedIndex == 0)
	{
		alert("To 'Add', you must select an nsn first.");
		return;
	}

	if (!validData()) {
		return ;
	}
	if (document.<%=Controller.FORM_NAME%>.confirmMsg.value != "") {
		if (!confirm(document.<%=Controller.FORM_NAME%>.confirmMsg.value)) {
			return ;
		}
	}
	document.<%=Controller.FORM_NAME%>.action.value = TheAction ;
	document.<%=Controller.FORM_NAME%>.submit() ;
}
function Search(WhichOne) {
	if (WhichOne == '<%=Controller.SEARCH_WITH_TOP_NAVBAR%>') {
		document.<%=Controller.FORM_NAME%>.cboPlanner.options[0].selected = true ;
		document.<%=Controller.FORM_NAME%>.cboNsn.options[0].selected = true ;
		<% if (!cntl.getNsiSid().equals(NavBar.NO_SELECTION) && !cntl.getNsn().equals("")) { %>
			document.<%=Controller.FORM_NAME%>.cboRelPlanner.options[0].selected = true ;
			document.<%=Controller.FORM_NAME%>.cboRelNsn.options[0].selected = true ;
		<%  } %>
	} else if (WhichOne == '<%=Controller.SEARCH_WITH_REL_NAVBAR%>') {
		document.<%=Controller.FORM_NAME%>.cboRelPlanner.options[0].selected = true ;
		document.<%=Controller.FORM_NAME%>.cboRelNsn.options[0].selected = true ;
	}
	document.<%=Controller.FORM_NAME%>.search.value = WhichOne ;
	document.<%=Controller.FORM_NAME%>.submit() ;
}
function cboACReset() {
	var i=0 ;
	if (document.<%=Controller.FORM_NAME%>.cboFleetSize.options[0].selected != true) {
	    for (i=0 ; i<document.<%=Controller.FORM_NAME%>.cboAC.length; i++) {
		    document.<%=Controller.FORM_NAME%>.cboAC.options[i].selected = false ;
	    }
	}
}
function effTypeReset() {
	document.<%=Controller.FORM_NAME%>.SplitEffect[0].checked = true ;
	document.<%=Controller.FORM_NAME%>.SplitEffect[1].checked = false ;
}
function cboPlannerChanged() {
	<% if (keepSearch.equals("N")) { %>
	document.<%=Controller.FORM_NAME%>.txtNsnVpn.value = "" ;
	<% } %>
	document.<%=Controller.FORM_NAME%>.cboNsn.options[0].selected = true;
<% if (!cntl.getNsiSid().equals(NavBar.NO_SELECTION) && !cntl.getNsn().equals("")) { %>
	document.<%=Controller.FORM_NAME%>.cboFleetSize.options[0].selected = true;
	cboACReset() ;
	effTypeReset() ;
	document.<%=Controller.FORM_NAME%>.txtStartDate.value = "" ;
	document.<%=Controller.FORM_NAME%>.txtNeverBuy.value = "" ;
<% } %>
	Search(<%=Controller.SEARCH_BY_PLANNER%>) ;
	return true ;
}
function cboNsnChanged() {
<% if (!cntl.getNsiSid().equals(NavBar.NO_SELECTION) && !cntl.getNsn().equals("")) { %>
	document.<%=Controller.FORM_NAME%>.cboFleetSize.options[0].selected = true;
	cboACReset() ;
	effTypeReset() ;
	document.<%=Controller.FORM_NAME%>.txtStartDate.value = "" ;
	document.<%=Controller.FORM_NAME%>.txtNeverBuy.value = "" ;
<% } %>
	Search(<%=Controller.SEARCH_BY_NSN%>) ;
	return true ;
}
function cboRelPlannerChanged() {
	<% if (keepSearch.equals("N")) {%>
	document.<%=Controller.FORM_NAME%>.txtRelNsnVpn.value = "" ;
	<% } %>
	document.<%=Controller.FORM_NAME%>.cboRelNsn.options[0].selected = true;
	document.<%=Controller.FORM_NAME%>.action.value = "<%=Controller.ACTION_SELECT_RELATED_PLANNER%>" ;
	document.<%=Controller.FORM_NAME%>.submit();
	return true ;
}
function cboRelNsnChanged() {
	document.<%=Controller.FORM_NAME%>.action.value = "<%=Controller.ACTION_SELECT_RELATED_NSN%>" ;
	document.<%=Controller.FORM_NAME%>.submit();
	return true ;
}
function cboAcChanged() {
	document.<%=Controller.FORM_NAME%>.action.value = "<%=Controller.ACTION_AC_CHANGED%>" ;
	document.<%=Controller.FORM_NAME%>.submit();
	return true ;
}
function acByChanged() {
	document.<%=Controller.FORM_NAME%>.action.value = "<%=Controller.ACTION_ACSORT%>" ;
	document.<%=Controller.FORM_NAME%>.submit();
	return true ;
}
function ViewChanged() {
	document.<%=Controller.FORM_NAME%>.action.value = "<%=Controller.ACTION_CHANGED_VIEW%>" ;
	document.<%=Controller.FORM_NAME%>.submit();
	return true ;
}
function SetChecked(val) {
	dml=document.<%=Controller.FORM_NAME%>;
	len = dml.elements.length;
	var i=0;
	for( i=0 ; i<len ; i++) {
		if (dml.elements[i].name=='Remove') {
			dml.elements[i].checked=val;
		}
	}
}
function optNsnFilterClicked() {
	document.<%=Controller.FORM_NAME%>.action.value = "<%=Controller.ACTION_CHANGE_NSN_FILTER%>" ;
	document.<%=Controller.FORM_NAME%>.submit() ;
	return true ;
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
function gotoLink(link) {
	document.location.href = link ;
}
</script>
<body bgcolor="#ffffff" link=3690dc vlink=3690dc topmargin=0 leftmargin=0 marginwidth=0 marginheight=0
	onLoad='<%=cntl.getLastElement()%>'>
<%
	HtmlMenu htmlMenu = new HtmlMenu() ;
	htmlMenu.setNsn(cntl.getNsn()) ;
	htmlMenu.setNsiSid(cntl.getNsiSid()) ;
	htmlMenu.setPlannerCode(cntl.getPlannerCode()) ;
	out.println(htmlMenu.getHtml()) ;
%>
<b>Configuration</b>
<font color="ff0000" size=+1><%=cntl.getMsg()%></font>
<form NAME=<%=Controller.FORM_NAME%> METHOD="POST" ACTION=".<%=request.getServletPath()%>" >
<%
	out.println(cntl.getTopNavBar()) ;
%>
<hr>
<%
if (!cntl.getNsiSid().equals(NavBar.NO_SELECTION) && !cntl.getNsn().equals("")) {
	out.println(cntl.getPrimaryNsnHtml()) ;

	out.println(cntl.getSplitConfigurationTables()) ;
%>
<table width=100%><!- Start TableD-->
<tr>
<td>
<font color="ff0000" size=+1><%=cntl.getMsg()%></font>
<tr>
<td>
<input name=<%=Controller.LAST_SAVE_BUTTON%> type=button onClick="DoAction('S')" value=Save>
</table><!- End TableD-->
<% } else { %>
Select a planner, Nsn, and a vendor part to define a primary nsn for a configuration.
<% } %>
<input type=hidden name=search>
<input type=hidden name=txtNsn value=<%=cntl.getNsn()%>>
<input type=hidden name=action>
<input type=hidden name=lastElement value=0>
<input type=hidden name=confirmMsg value="<%=cntl.getConfirmMsg()%>">
</form>
<%
	out.println(htmlMenu.getHtml()) ;
%>
<p><small>Last Modified on: 6/28/02 13:55</small>
<br><small>
Author:<a href="http://ioe.stl.mo.boeing.com/tele/detail.asp?bemsid=535547"><font style="font-size: 11px;" color=000000 face="verdana,arial,helvetica">Douglas S. Elder</font></a>
</small>
</body>
</html>
