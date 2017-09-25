<html>
<%
//	SCCSID: %M% %I% Modified: %G% %U%
//	Date      By            History
//      05/28/02  kcs	    	Initial
//	09/30/02  kcs		add js calendar
//	10/17/02  kcs		add another update button
//	10/23/02  kcs		add tcto.setHdnEvent("none") to not redo event when coming back to screen
//
//		PVCS
//	$Revision:   1.3  $
//	$Author:   c378632  $
//	$Workfile:   schedByAc.jsp  $
%>
<META NAME="title" Content="AMD Schedule By Aircraft">
<META NAME="subject" Content="AMD Effectivity Schedule By Aircraft">
<META NAME="creator" Content="338143-Ken Shew">
<META NAME="date" Content="2002-07-01">
<META NAME="validuntil" Content="2007-06-20">
<META NAME="owner" Content="293539-Gino Aedo">
<META NAME="robots" Content="all">
<script language=javascript src="date-picker.js"></script>
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

function checkIfInBlk(){
	isOkChk = true;
	strAlert = "";
	if (document.schedByAcForm.optSearchBy[0].checked){
		if (document.schedByAcForm.hdnBlk.length == null){
			loopEnd = 1;
		}else {
			loopEnd = document.schedByAcForm.hdnBlk.length;
		}
		for (i = 0; i < loopEnd; i++){
			if (loopEnd == 1){
				acd = document.schedByAcForm.txtAcAcd.value;
				scd = document.schedByAcForm.txtAcScd.value;
				acView = document.schedByAcForm.hdnAcViewList.value;
				blk = document.schedByAcForm.hdnBlk.value;
			}else{
				acd = document.schedByAcForm.txtAcAcd[i].value;
				scd = document.schedByAcForm.txtAcScd[i].value;
				acView = document.schedByAcForm.hdnAcViewList[i].value;
				blk = document.schedByAcForm.hdnBlk[i].value;
			}
			if (blk != ""){
				if (acd != "" || scd != ""){
					strAlert = strAlert + "For " + acView + ": need to update dates thru block " + blk + " schedule\n";
					isOkChk = false;
				}
			}
		}
	}
	if (!isOkChk){
		alert(strAlert);
	}
	return isOkChk;
}
function processEvent(whichone){
	isOk = true;
	if (whichone == 'update'){
		now = new Date;
		space = "  ";
		warn = "";
		currentDate = ((now.getFullYear() *  10000) + ((now.getMonth()+1) * 100) + now.getDate());
		if (document.schedByAcForm.txtAcAcd.length == null){
			loopEnd = 1;
		}else{
			loopEnd = document.schedByAcForm.txtAcAcd.length;
		}
		isOk = checkIfInBlk();
		for (i = 0; i < loopEnd ; i++){
			if (loopEnd == 1){
				acd = document.schedByAcForm.txtAcAcd.value;
				scd = document.schedByAcForm.txtAcScd.value;
				acView = document.schedByAcForm.hdnAcViewList.value;
				acdDb = document.schedByAcForm.hdnDbAcd.value;
			}else{
				acd = document.schedByAcForm.txtAcAcd[i].value;
				scd = document.schedByAcForm.txtAcScd[i].value;
				acView = document.schedByAcForm.hdnAcViewList[i].value;
				acdDb = document.schedByAcForm.hdnDbAcd[i].value;
			}
			acd = trim(acd);
			scd = trim(scd);
			ymd = getYearMonDayArray(scd);
			schedCompleteDate=0;
			if (scd == ""){
			}else if (ymd == null){
				alert("ERROR:\n" + acView + space + "<" + scd + ">" + " sched complete date not in acceptable date format "); 
				isOk = false;
			}else {
				year = stripLeadZero(ymd[2]);
				month = stripLeadZero(ymd[0]);
				day = stripLeadZero(ymd[1]);
				if (!isDate(year, month, day)){
					alert("ERROR:\n" + acView + space + scd + " sched complete date not a date ");
					isOk = false;
				}else{
					schedCompleteDate = ((year*10000) + (parseInt(month) * 100) + parseInt(day));
				}
				if (loopEnd == 1){
					document.schedByAcForm.txtAcScd.value= month + '/' + day + '/' + year;
				}else{
					document.schedByAcForm.txtAcScd[i].value= month + '/' + day + '/' + year;
				}
			}
			if (schedCompleteDate < currentDate && scd != ""){
				warn = warn + acView + space + scd + " sched comp date should not be in past\n";
				isOk = false;
			}
			ymd = getYearMonDayArray(acd);
			actualCompleteDate=0;
			if (acd == ""){
			}else if (ymd == null){
				alert("ERROR:\n" + acView + space + "<" + acd + ">" + " actual complete date not in acceptable date format ");
				isOk = false;
			}else{ 
				year = stripLeadZero(ymd[2]);
				month = stripLeadZero(ymd[0]);
				day = stripLeadZero(ymd[1]);
				if (!isDate(year, month, day)){
					alert("ERROR:\n" + acView + space + acd + " actual complete date not a date ") 
					isOk = false;

				}else{
					actualCompleteDate = ((year*10000) + (parseInt(month) * 100) + parseInt(day));
				}
				if (loopEnd == 1){
					document.schedByAcForm.txtAcAcd.value= month + '/' + day + '/' + year;
				}else{
					document.schedByAcForm.txtAcAcd[i].value= month + '/' + day + '/' + year;
				}
			}
			if (actualCompleteDate > currentDate){
				alert("ERROR:\n" + acView + space + acd + " actual complete date cannot be in future ");
				isOk = false;
			}
			// actual complete date cannot be changed
			if (acd != "" && acdDb != ""){
				alert("For " + acView + ": cannot change retrofit completion date - please see system owner to change");
				isOk = false;
			}
			// help out java side by presenting only one date format and not redupping RR logic
			if (isOk && ymd != null){
				if (loopEnd == 1){
					document.schedByAcForm.txtAcAcd.value = ymd[0] + "/" + ymd[1] + "/" + ymd[2];
				}else {
					document.schedByAcForm.txtAcAcd[i].value = ymd[0] + "/" + ymd[1] + "/" + ymd[2];
				}
			}
		}
		if (warn != ""){
			alert("WARNING:\n" + warn);
		}
	}
	if (isOk){
		document.schedByAcForm.hdnAction.value = whichone;
		document.schedByAcForm.submit();
	}
}
</script>
<%@ page errorPage="amdErrorPage.jsp" import="java.sql.*, retrofit.SchedByAcBean, Configuration.AmdDB, Configuration.HtmlMenu" %>
<%!
	public String defaultStr(String inString, String inItem){
		if (inString == null || inString.equals("default")){
			return "<font color=\"brown\">-- no " + inItem + " chosen --</font>";
		}else{
			return inString;
		}
	}
	public String formatWarnMsg(String inString){
		if (!(nvl(inString, "")).equals("")){
			return "<br><b><font color=\"brown\">WARNING: " + inString + "</font></b>";
		}else{
			return "";
		}

	}
	public String formatErrorMsg(String inString){
		if (inString != null){
			return "<br><b><font color=\"red\">" + inString + "</font></b>";
		}else{
			return "";
		}

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
<jsp:useBean id="sched" class="retrofit.SchedByAcBean" scope="session" />
<jsp:setProperty name="sched" property="*"/>
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
	String reportAcSched= null;
	String reportCboTctoBlk = null;
	try {
		sched.setDebugOn(false);
		sched.setOut(out);
		sched.setHdnAction("none");
		sched.setDescDisplayLength(80);
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
		sched.setAcBy(acType);
		session.setAttribute("acBy", acType);
		sched.setTxtAcAcd(request.getParameterValues("txtAcAcd"));
		sched.setTxtAcScd(request.getParameterValues("txtAcScd"));
		String radioAction = request.getParameter("radioAction");
		if (radioAction != null && radioAction.equals("1")){
			sched.setCbo(null);
		}
		sched.processDbActions(myConn);
		// reports generated here to get errors at top of page
		reportCboTctoBlk = sched.reportCboTctoBlk(myConn); 
	 	reportAcSched= sched.reportAcSched(myConn);  
	}catch (Exception e){
		sched.setErrorMsg(e.toString());
	}
%>
<body vLink=#3690dc link=#3690dc bgColor=#ffffff  topmargin=0 leftmargin=0
rightmargin=0 marginwidth=0 marginheight=0 <%= sched.getOnLoad() %>>
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
<form name="schedByAcForm" action="schedByAc.jsp" method="post">
<input type="hidden" name="hdnAction" value="none">
<b>Schedule By Aircraft</b>
<%
out.println(formatWarnMsg(sched.getWarnMsg()));
out.println(formatErrorMsg(sched.getErrorMsg()));
%>
<hr>
		<input type="radio" name="optSearchBy" value="tcto" <%=sched.isChecked("tcto")%> onclick="processEvent('radio');">&nbsp;TCTO&nbsp;
		<input type="radio" name="optSearchBy" value="block" <%=sched.isChecked("block")%> onclick="processEvent('radio');">&nbsp;Block&nbsp; 
		<select name="cbo" size="1" onChange="processEvent('cbo')"">
			<% out.println(reportCboTctoBlk); %>
		</select>		
<hr>
<br>

<%
	 if (!sched.getCbo().equals("default")){
		if (sched.getOptSearchBy().equals("block")){
			out.print("<b>Block:</b> ");
		}else{
			out.print("<b>TCTO:</b> ");
		}
		out.println(sched.getCbo());
		if (nvl(reportAcSched,"").equals("")){
			out.println("<br>Effectivity not defined");					
		}
	 }
%>
<br>
<br>
<%  
	if (!nvl(reportAcSched, "").equals("")){
		sched.reportAcDisplay();
		out.println("<input type=\"button\" name=\"btnSave\" value=\"update\" onclick=\"processEvent(\'update\');\">");
		out.println("<br><br><table border=1>");
		out.println(sched.getTHeadSched());
		out.println(reportAcSched);
		out.println("</table>");
		out.println("<b>*</b>&nbsp;note: date format MM/DD/YY (or MM/DD/YYYY)");
		out.println("<br><br>");
		out.println("<input type=\"button\" name=\"btnSave\" value=\"update\" onclick=\"processEvent(\'update\');\">");
	}
if (sched.getDebugOn())
	out.println(sched.getDebugMsg());
	myConn.commit();
%>
</form>
</td>
</tr>
</table>
<%
	out.println(htmlMenu.getHtml()) ;
%>
<p><small>Last Modified on: 10/17/02</small>
<br><small>
Author:<a href="http://ioe.stl.mo.boeing.com/tele/detail.asp?bemsid=338143"><font style="font-size: 11px;" color=000000 face="verdana,arial,helvetica">K. Shew</font></a>
</small>
</body>
</html>
