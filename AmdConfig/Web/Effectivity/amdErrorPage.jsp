//	SCCSID: %M% %I% Modified: %G% %U%
//	Date      By            History
//      09/24/02  kcs	    	Initial
//	10/04/02  kcs		add printing of stack trace
//		PVCS
//	$Revision:   1.1  $
//	$Author:   c378632  $
//	$Workfile:   amdErrorPage.jsp  $
<html>
<script language=javascript>
</script>
<body>
<form>
<hr>
<b>The error caught has not been accounted for - <a href="mailto:gino.aedo@boeing.com">please report</a></b>
<hr>
<br>
<%@ page isErrorPage="true" session="false" %>
<%
	out.println("Error Message:");
	out.println(exception.toString());
	out.println("<br><b>stack trace:</b><br>");
	exception.printStackTrace(new java.io.PrintWriter(out));
%>
</form>
<br>
<br>
</body>
</html>

