<%@ page import="java.text.*, java.util.*, java.sql.*, coreservlets.*, Configuration.*" %>
<%
	String userid = (String) session.getValue("userid") ;
	if (userid == null || userid.equals("")) {
		try {
			response.sendRedirect("login.jsp") ;
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
			return ;
		} catch (java.lang.IllegalStateException e) {
			out.println("<html><body>Session expired:<a href=login.jsp>Goto Login</a></body></html>") ;
			return ;
		}
		
	}
	String action = request.getParameter("action") ;
	if (action != null && action.equals("logoff")) {
		session.removeAttribute("userid") ;
		AmdDB.instance().remove(userid) ; // close connection & remove conn from pool
		response.sendRedirect("http://inside.boeing.com") ;
	}
%>
<html>
<head>
<META NAME="Revision" Content="$Revision:   1.1  $">
<META NAME="title" Content="AMD Effectivity Home Page">
<META NAME="subject" Content="AMD Effectivity Home Page">
<META NAME="creator" Content="535547-Douglas S. Elder">
<META NAME="date" Content="2002-06-21">
<META NAME="validuntil" Content="2007-06-21">
<META NAME="owner" Content="293539-Gino Aedo">
<META NAME="robots" Content="all">
<META NAME="Author" Content="$Author:   c970183  $">
<META NAME="Workfile" Content="$Workfile:   index.jsp  $">
<META NAME="Log" Content="$Log:   \\www-amssc-01\pds\archives\SDS-AMD\Web\Effectivity\index.jsp-arc  $">
/*   
/*      Rev 1.1   06 Aug 2002 10:29:32   c970183
/*   Added latest release
	<style type="text/css">
	<!--
	A:link {text-decoration: none;}
	A:visited {text-decoration: none;}
	A:hover {text-decoration: underline;}
	-->
	</style>
<title>AMD Effectivity Home Page</title>
<script language=JavaScript>

function makeYearExpDate(yr) {
     var expire = new Date ();
     expire.setTime (expire.getTime() + ((yr *365) *24 * 60 * 60 * 1000));
     //expire = expire.toGMTString()
     return expire
}
// "Internal" function to return the decoded value of a cookie
//
function getCookieVal (offset) {
  var endstr = document.cookie.indexOf (";", offset);
  if (endstr == -1)
    endstr = document.cookie.length;
  return unescape(document.cookie.substring(offset, endstr));
}

//
//  Function to return the value of the cookie specified by "name".
//    name - String object containing the cookie name.
//    returns - String object containing the cookie value, or null if
//      the cookie does not exist.
//
function GetCookie (name) {
  var arg = name + "=";
  var alen = arg.length;
  var clen = document.cookie.length;
  var i = 0;
  while (i < clen) {
    var j = i + alen;
	   if (document.cookie.substring(i, j) == arg)
     return getCookieVal (j);
    i = document.cookie.indexOf(" ", i) + 1;
    if (i == 0) break; 
  }
  return null;
}

//
//  Function to create or update a cookie.
//    name - String object object containing the cookie name.
//    value - String object containing the cookie value.  May contain
//      any valid string characters.
//    [expires] - Date object containing the expiration data of the cookie.  If
//      omitted or null, expires the cookie at the end of the current session.
//    [path] - String object indicating the path for which the cookie is valid.
//      If omitted or null, uses the path of the calling document.
//    [domain] - String object indicating the domain for which the cookie is
//      valid.  If omitted or null, uses the domain of the calling document.
//    [secure] - Boolean (true/false) value indicating whether cookie transmission
//      requires a secure channel (HTTPS).  
//
//  The first two parameters are required.  The others, if supplied, must
//  be passed in the order listed above.  To omit an unused optional field,
//  use null as a place holder.  For example, to call SetCookie using name,
//  value and path, you would code:
//
//      SetCookie ("myCookieName", "myCookieValue", null, "/");
//
//  Note that trailing omitted parameters do not require a placeholder.
//
//  To set a secure cookie for path "/myPath", that expires after the
//  current session, you might code:
//
//      SetCookie (myCookieVar, cookieValueVar, null, "/myPath", null, true);
//
function SetCookie (name, value) {  
    var argv = SetCookie.arguments;  
    var argc = SetCookie.arguments.length;  
    var expires = (argc > 2) ? argv[2] : null;  
    var path = (argc > 3) ? argv[3] : null;  
    var domain = (argc > 4) ? argv[4] : null;  
    var secure = (argc > 5) ? argv[5] : false;  

    document.cookie = name + "=" + escape (value) + 
	((expires == null) ? "" : ("; expires=" + expires.toGMTString())) + 
	((path == null) ? "" : ("; path=" + path)) +  
	((domain == null) ? "" : ("; domain=" + domain)) +    
	((secure == true) ? "; secure" : "");
}
//  Function to delete a cookie. (Sets expiration date to current date/time)
//    name - String object containing the cookie name
//
function DeleteCookie (name) {
  var exp = new Date();
  exp.setTime (exp.getTime() - 1);  // This cookie is history
  var cval = GetCookie (name);
  if (cval != null)
    document.cookie = name + "=" + cval + "; expires=" + exp.toGMTString();
}

var config = "Config.jsp" ;
var equiv = "Substitution.jsp" ;
var effect = "effControl.jsp" ;
var tcto = "defineTcto.jsp" ;
var block = "defineBlock.jsp" ;
var schac = "schedByAc.jsp" ;
var defcomprt = "defaultCompRate.jsp" ;
var admin = "admin.jsp" ;
var thisPage = "index.jsp" ;
var defaultCookieName = "DefaultHomePage" ;

var expDays = 1000 ;

function setDefault(link) {
    var exp = new Date(); 
    exp.setTime(exp.getTime() + (expDays*24*60*60*1000));
    SetCookie(defaultCookieName, link, exp ) ;
    //document.location.href = link ;
}


function getDefaults() {
	var link = GetCookie(defaultCookieName) ;
	if (link == config) {
		document.theForm.homePage[0].checked = true ;
	} else if (link == equiv) {
		document.theForm.homePage[1].checked = true ;
	} else if (link == effect) {
		document.theForm.homePage[2].checked = true ;
	} else if (link == tcto) {
		document.theForm.homePage[3].checked = true ;
	} else if (link == block) {
		document.theForm.homePage[4].checked = true ;
	} else if (link == schac) {
		document.theForm.homePage[5].checked = true ;
	} else if (link == defcomprt) {
		document.theForm.homePage[6].checked = true ;
	} else if (link == admin) {
		document.theForm.homePage[7].checked = true ;
	} else if (link == thisPage) {
		document.theForm.homePage[8].checked = true ;
	}
}
function logoff() {
	document.theForm.action.value = "logoff" ;
	document.theForm.submit() ;
}
</script>
</head>
<body vLink=#3690dc link=#3690dc bgColor=#ffffff  onLoad="getDefaults();" topmargin=0 leftmargin=0
rightmargin=0 marginwidth=0 marginheight=0>
<%
	HtmlMenu htmlMenu = new HtmlMenu() ;
	htmlMenu.setLabel1("config") ;
	htmlMenu.setTitle1("Configuration") ;
	htmlMenu.setLink1("Config.jsp") ;
	out.println(htmlMenu.getHtml()) ;
%>

<table width=100%>
<tr><td width=1>&nbsp;</td>
<td>
<h3>Welcome <%=userid%></h3>
<form name=theForm>
<table>
<tr>
<th>
<font style="FONT-SIZE: 11px" face="verdana, arial,helvetica" 
      color=#3000E2>
Effectivity
</font>
</th>
<th>
<font style="FONT-SIZE: 11px" face="verdana, arial,helvetica" 
      color=#3000E2>
Retrofit
</font>
</th>
<th>
<font style="FONT-SIZE: 11px" face="verdana, arial,helvetica" 
      color=#3000E2>
Report
</font>
</th>
</tr>
<tr>
<td valign=top>
<table>
<tr>
<th><font style="FONT-SIZE: 10px" face="verdana, arial,helvetica" 
      color=#3000E2>Page</font></th>
<th><font style="FONT-SIZE: 10px" face="verdana, arial,helvetica" 
      color=#3000E2>
Set As Default</font></th>
</tr>
<tr>
<td>
<a title="Configuration" href=Config.jsp 
	onMouseOver="window.status='Click here to enter effectivity configuration data.'; return true"
	onMouseOut="window.status=''; ">
<font style="FONT-SIZE: 11px" face="verdana, arial,helvetica" 
      color=#000000>
<b>Configuration</b>
</font>
</a>
</td>
<td align=center><input type=radio name=homePage onClick="setDefault(config);"></td>
</tr>
<tr>
<td>
<a title="Product Structure" href=Substitution.jsp title="Production Structure">
<font style="FONT-SIZE: 11px" face="verdana, arial,helvetica" 
      color=#000000>
<b>Product Structure</b>
</font>
</a>
</td>
<td align=center><input type=radio name=homePage onClick="setDefault(equiv);"></td>
</tr>
<tr>
<td>
<a title="Effective Aircraft" href=effControl.jsp
	onMouseOver="window.status='Click here to enter aircraft effectivity data.'; return true"
	onMouseOut="window.status=''; ">
<font style="FONT-SIZE: 11px" face="verdana, arial,helvetica" 
      color=#000000>
<b>Effective Aircraft</b>
</font>
</a>
</td>
<td align=center><input type=radio name=homePage onClick="setDefault(effect)"></td>
</tr>
</table>
</td>
<td valign=top>
<table>
<tr>
<th><font style="FONT-SIZE: 10px" face="verdana, arial,helvetica" 
      color=#3000E2>Page
</font>
</th>
<th><font style="FONT-SIZE: 10px" face="verdana, arial,helvetica" 
      color=#3000E2>
Set As Default
</font>
</th>
</tr>
<tr>
<td>
<a title="Define TCTO" href="defineTcto.jsp">
<font style="FONT-SIZE: 11px" face="verdana, arial,helvetica" 
      color=#000000>
<b>Define TCTO</b>
</font>
</a>
</a>
</td>
<td align=center><input type=radio name=homePage onClick="setDefault(tcto)"></td>
</tr>
<tr>
<td>
<a title="Define Block" href="defineBlock.jsp">
<font style="FONT-SIZE: 11px" face="verdana, arial,helvetica" 
      color=#000000>
<b>Define Block</b>
</font>
</a>
</a>
</td>
<td align=center><input type=radio name=homePage onClick="setDefault(block)"></td>
</tr>
<tr>
<td>
<a title="Schedule By Aircraft" href="schedByAc.jsp">
<font style="FONT-SIZE: 11px" face="verdana, arial,helvetica" 
      color=#000000>
<b>Schedule By Aircraft</b>
</font>
</a>
</a>
</td>
<td align=center><input type=radio name=homePage onClick="setDefault(schac)"></td>
</tr>
<tr>
<td>
<a title="Default Completion Rate" href="defaultCompRate.jsp">
<font style="FONT-SIZE: 11px" face="verdana, arial,helvetica" 
      color=#000000>
<b>Default Completion Rate</b>
</font>
</a>
</a>
</td>
<td align=center><input type=radio name=homePage onClick="setDefault(defcomprt)"></td>
</tr>
</table>
</td>
<td valign=top>
<table>
<tr>
<th><font style="FONT-SIZE: 10px" face="verdana, arial,helvetica" 
      color=#3000E2>
Page</font></th>
<th><font style="FONT-SIZE: 10px" face="verdana, arial,helvetica" 
      color=#3000E2>
Set As Default
</font>
</th>
</tr>
<tr>
<td>
<a title="Forecast" href="admin.jsp">
<font style="FONT-SIZE: 11px" face="verdana, arial,helvetica" 
      color=#000000>
<b>Forecast</b>
</font>
</a>
</a>
</td>
<td align=center><input type=radio name=homePage onClick="setDefault(admin)"></td>
</tr>
</table>
</td>
</tr>
</table>
<table>
<tr>
<th><font style="FONT-SIZE: 11px" face="verdana, arial,helvetica" 
      color=#3000E2>
System</font>
</th>
</tr>
<tr>
<td valign=top>
<table>
<tr>
<th><font style="FONT-SIZE: 10px" face="verdana, arial,helvetica" 
      color=#3000E2>Page
</font></th>
<th><font style="FONT-SIZE: 10px" face="verdana, arial,helvetica" 
      color=#3000E2>Set As Default</font></th>
</tr>
<tr>
<td>
<font style="FONT-SIZE: 11px" face="verdana, arial,helvetica" 
      color=#009150>
<b>This Page</b>
</font>
</a></td>
<td align=center><input type=radio name=homePage onClick="setDefault(thisPage)"></td>
</tr>
<tr>
<td>
<a title="Effectivity Application Settings " href="CookieMgr.jsp">
<font style="FONT-SIZE: 11px" face="verdana, arial,helvetica" 
      color=#000000>
<b>Settings</b>
</font>
</a>
</td>
<td align=center>&nbsp;</td>
</tr>
<tr>
<td>
<a title="Click here to logoff the application" href="javascript:logoff();" 
	onMouseOver="window.status='Click here to logoff the application'; return true" 
	onMouseOut="window.status=''; ">
<font style="FONT-SIZE: 11px" face="verdana, arial,helvetica" 
      color=#000000>
<b>Logoff</b>
</font>
</a>
</td>
<td align=center>&nbsp;</td>
</tr>
</table>
</td>
<td valign=top>
<img align=right src=images/AmdWithShadowSmall.gif width=160 height=140></img></table>
</table>
<input type=hidden name=action>
</form>
<table>
<small>Last Modified on: 7/02/02 13:58</small>
<br><small>
Author:<a href="http://ioe.stl.mo.boeing.com/tele/detail.asp?bemsid=535547">
<FONT 
style="FONT-SIZE: 11px" face=verdana,arial,helvetica color=#000000>Douglas S. Elder</font></a>
</small>
</td>
</tr>
</table>
</body>
</html>