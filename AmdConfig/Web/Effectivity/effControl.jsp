<%@ page contentType="text/html;charset=WINDOWS-1252"%>
<%@ page import="java.util.*" %> 
<%@ page import="java.sql.*" %> 
<%@ page import="Configuration.*" %> 


<% 
	String     username;
	String     password;
	String     hostname;
	String     connStr;
	Connection conn;
	AmdDB      conObj;

	username = (String) session.getAttribute("userid");
	password = (String) session.getAttribute("passwd");
	hostname = (String) session.getAttribute("host");
	connStr  = (String) session.getAttribute("AMD_ConnectionString");

	if (request.getServerName().equals("localhost"))
	{
		System.out.println("This should print only if running on pcb026330, AKA "+
			request.getServerName() + ".");
		username = "amd_owner";
		password = "sdsproject";
	}

	if (username == null) 
	{
%>
		<jsp:forward page="login.jsp"/> 
<%
	}
	else
	{
		conObj = AmdDB.instance();
		conn = conObj.getConnection(username);
		session.putValue("DBConn",conn);
%> 
		<jsp:forward page="EffectiveAC.jsp"/> 
<%
	}
%>
