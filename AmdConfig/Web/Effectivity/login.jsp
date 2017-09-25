<%@ page import="coreservlets.* , Configuration.*, org.apache.log4j.Logger" %>
<%

/*
    $Revision:   1.1  $
      $Author:   c970183  $
    $Workfile:   login.jsp  $
         $Log:   \\www-amssc-01\pds\archives\SDS-AMD\Web\Effectivity\login.jsp-arc  $
/*   
/*      Rev 1.1   06 Aug 2002 10:29:34   c970183
/*   Added latest release
*/         
Logger logger = Logger.getLogger("login.jsp") ;

String errMsg, AmdD, AmdI, AmdP, connStr ;
errMsg = "" ;
User theUser = new User() ;
theUser.setCurDirectory(pageContext.getServletContext().getRealPath("/") + "/WEB-INF/classes/") ;
theUser.getIniFileInfo() ;
String hostString = request.getParameter("HostString") ;
String user = request.getParameter("user") ;
String passwd = request.getParameter("passwd") ;
if (hostString == null) {
	hostString = "" ;
} else {
  theUser.setDataSource(hostString) ;
}
if (request.getContentLength() > 0 || (!hostString.equals("") && user != null && passwd != null)) {
   if (hostString.equals("u10damc")) {
	theUser.setConnectionString("jdbc:oracle:thin:@hs1188.lgb.cal.boeing.com:1521:") ;
   } else if (hostString.equals("u10iamc")) {
	theUser.setConnectionString("jdbc:oracle:thin:@hs1183.lgb.cal.boeing.com:1521:") ;
   } else if (hostString.equals("u10pamc")) {
	theUser.setConnectionString("jdbc:oracle:thin:@amssc-ora11.lgb.cal.boeing.com:1521:") ;
   }  	
   theUser.setUserid(request.getParameter("user")) ;
   theUser.setPassword(request.getParameter("passwd")) ;
   if (theUser.isValidUser()) {
		if (theUser.hasRole("AMD_WRITER_ROLE")
			|| theUser.hasRole("AMD_USER") 
			|| theUser.hasRole("AMD_MAINT") 
			|| theUser.hasRole("AMDD_ADMIN") 
			|| theUser.hasRole("AMD_DATALOAD")) {
			session.putValue("AMD_ConnectionString", theUser.getConnectionString()) ;
			session.putValue("userid", theUser.getUserid()) ;
			session.putValue("passwd",theUser.getPassword()) ;
			session.putValue("host", theUser.getDataSource()) ;
			//out.print(session.getValue("AMD_ConnectionString")) ;
			Cookie cookie = new Cookie("Amd_ConnectionString", theUser.getConnectionString()) ;
			response.addCookie(cookie) ;
			cookie = new Cookie("passwd", theUser.getPassword()) ;
			response.addCookie(cookie) ;
			LongLivedCookie userCookie = new LongLivedCookie("User", request.getParameter("user")) ;
			response.addCookie(userCookie) ;
			LongLivedCookie hostStringCookie = new LongLivedCookie("HostString", request.getParameter("HostString")) ;
			response.addCookie(hostStringCookie) ;
			Cookie[] cookies = request.getCookies() ;
			String defaultPage = ServletUtilities.getCookieValue(cookies, "DefaultHomePage", "index.jsp") ;
			AmdDB amd = AmdDB.instance() ;
			amd.setConnection(theUser.getConnection(), theUser.getUserid()) ;
			logger.info(theUser.getUserid() + " successfully logged in.") ;
			response.sendRedirect(defaultPage) ;
		} else {
			errMsg = "You do not have an AMD role in Oracle." ;
			logger.warn(theUser.getUserid() + " does not have the proper Oracle role.") ;
		}
	} else {
		if (theUser.getInvalidUseridPassword()) {
			errMsg = "Your username and password were not found." ;
			logger.warn(theUser.getUserid() + " attempted to login for ip " + request.getRemoteAddr() + ", but failed.") ;
		} else if (theUser.getAccountLocked()) {
			errMsg = "Your Oracle account is locked.<a href=http://amssc-oracle01.web.boeing.com:7105/dba_di/public/forgot_password.html>Submit an Oracle password reset request.</a>" ;
		} else if (theUser.getOracleIsDown()) {
			errMsg = "Oracle is down.  Try again later." ;
		} else if (theUser.getPasswordExpired()) {
			errMsg = "Your password has expired." ;
		} else if (theUser.getPasswordWillExpire()) {
			errMsg = "Your password will expire." ;
		} else {
			errMsg = theUser.getError() ;
		}
	}
}
// Accomodate whatever URL is used - lower case or upper case or Mixed
Cookie[] cookies = request.getCookies() ;
String curUser = ServletUtilities.getCookieValue(cookies, "User", "amd_owner") ;
String HostString = ServletUtilities.getCookieValue(cookies,"HostString", "u10damc") ;
AmdD = "" ; AmdI = "" ; AmdP = "" ;
if (theUser.getDataSource().equals("u10damc")) {
	AmdD = "SELECTED" ;
} else if (theUser.getDataSource().equals("u10iamc")) {
	AmdI = "SELECTED" ;
} else if  (theUser.getDataSource().equals("u10pamc")) {
	AmdP = "SELECTED" ;
} else {
	AmdD = "SELECTED" ;
}

response.setHeader("Cache-Control", "no-store, no-cache");
response.setHeader("Pragma", "no-cache");
response.setDateHeader("Expires", -1)  ; // Make the page expire immediately 
	// so it will not be cached by the browser
%>

<html>
<head>
<META NAME="GENERATOR" Content="Microsoft Visual Studio 6.0">
<META NAME="title" Content="AMD Oracle Login">
<META NAME="subject" Content="AMD Effectivity Login Oracle">
<META NAME="creator" Content="535547-Douglas S. Elder">
<META NAME="date" Content="2002-06-20">
<META NAME="validuntil" Content="2007-06-20">
<META NAME="owner" Content="293539-Gino Aedo">
<META NAME="robots" Content="all">
<META NAME="Revision" Content="$Revision:   1.1  $">
<META NAME="Author" Content="$Author:   c970183  $">
<META NAME="Workfile" Content="$Workfile:   login.jsp  $">
<META NAME="Log" Content="$Log$">
<script LANGUAGE="JavaScript">
function setfocus() {
	if (document.UserInfo.user.value != "")
		document.UserInfo.passwd.focus() ;
	else
		document.UserInfo.user.focus() ;
}
function VerifyInput(theForm) {
	if (theForm.user.value == "") {
		alert("Enter user.") ;
		return false ;
	}
	if (theForm.passwd.value == "") {
		alert("Enter password.") ;
		return false ;
	}
	return true ;	
}
</script>
<title>AMD Oracle Login</title>
</head>
<body vLink=#3690dc link=#3690dc bgColor=#ffffff background=images/AmdWithShadow.gif onLoad="setfocus();" topmargin=0 leftmargin=0
rightmargin=0 marginwidth=0 marginheight=0>
<%
	HtmlMenu htmlMenu = new HtmlMenu() ;
	htmlMenu.setLabel1("suggested browser settings") ;
	htmlMenu.setTitle1("Suggested Browser Settings") ;
	htmlMenu.setLink1("BrowserSettings.jsp") ;
	htmlMenu.setLabel2("change password") ;
	htmlMenu.setTitle1("Change Password") ;
	htmlMenu.setLink2("http://ams-socal01.web.boeing.com/ora_util/oracle_password_reset2.cfm") ;
	htmlMenu.setLink3("") ;
	htmlMenu.setLink4("") ;
	out.println(htmlMenu.getHtml()) ;
%>
<table>
<tr><td width=1>&nbsp;</td><td>
<font color=green face=arial><b>
You must sign in to use the AMD database.
</b>
</font>
<form NAME="UserInfo" METHOD="POST" ACTION=".<%=request.getServletPath()%>" OnSubmit="return VerifyInput(this);">
<table>
<tr><td>Username</td><td><input TYPE="TEXT" NAME="user" VALUE="<%=curUser%>"></td></tr>
<tr><td>Password</td><td><input TYPE="PASSWORD" NAME="passwd"></td></tr>
<tr><td colspan=2><b>
<% if (AmdD.equals("SELECTED")) {
	out.println("Development (Oracle 8i)") ;
   } else if (AmdI.equals("SELECTED")) {
	out.println("Integrated Test (Oracle 8i)") ;
   } else if (AmdP.equals("SELECTED")) {
	out.println("Production (Oracle 8i)") ;
   }
%>
</b>
</td>
</tr>
</table>
<input TYPE="HIDDEN" VALUE="<%=request.getParameter("GoTo")%>" name="GoTo">
<input TYPE="SUBMIT" VALUE="Sign In">
</form>
<%=errMsg%>
<br>
<br><br><br>
<br><br><br>
<br><br><br>
<p><small>Last Modified on: 7/30/02 13:08</small>
<br><small>
Author:<a href="http://ioe.stl.mo.boeing.com/tele/detail.asp?bemsid=535547">
<FONT 
style="FONT-SIZE: 11px" face=verdana,arial,helvetica color=#000000>
Douglas S. Elder
</font>
</a>
</small>
</td>
</table>
</body>
</html>