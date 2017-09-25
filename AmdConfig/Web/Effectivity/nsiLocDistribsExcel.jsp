<%@ page errorPage="amdErrorPage.jsp" import="java.sql.*, retrofit.AdminBean, exceptions.*, Configuration.AmdDB, org.apache.poi.hssf.usermodel.*, java.util.*, java.io.*"%><%
//	SCCSID: %M% %I% Modified: %G% %U%
//	Date      By            History
//      05/28/02  kcs	    	Initial
//
//  "tags" must be on same line for JRun. bug?
%><jsp:useBean id="adm" class="retrofit.AdminBean" scope="session" /><% 	
	
 	response.setHeader("Cache-Control","no-cache"); //HTTP 1.1
//	response.setHeader("Pragma","no-cache"); //HTTP 1.0
//	response.setDateHeader ("Expires", 0); //prevents caching at the proxy server
	String username = (String) session.getAttribute("userid");
	String connStr  = (String) session.getAttribute("AMD_ConnectionString");
	if (connStr == null) 
	{
		response.sendRedirect("login.jsp");
	}
	Connection myConn;
	AmdDB      conObj;
		
	conObj = AmdDB.instance();
	myConn = conObj.getConnection(username);
	session.setAttribute("DBConn",myConn);
	try{
		adm.setIsHtml(false);
		adm.setConn(myConn);	
	
		HSSFWorkbook wb = adm.reportNsiLocDistribsPoiExcel();	
		response.setContentType("application/vnd.ms-excel");
		ServletOutputStream outN = (ServletOutputStream) response.getOutputStream();
		wb.write(outN);
		outN.flush();
/* 
	following should become obsolete with POI testing.
		if (adm.getIsHtml()){
			out.println("<html xmlns:x=\"urn:schemas-microsoft-com:office:excel\"><body>");
			out.println(adm.reportNsiLocDistribs());
			out.println("</body></html>");
		}else{
			out.println(adm.reportNsiLocDistribs());
		}
*/
	}catch (Exception e){
		throw e;
	}

%>
