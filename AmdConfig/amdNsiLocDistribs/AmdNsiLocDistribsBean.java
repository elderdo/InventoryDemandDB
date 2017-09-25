package amdNsiLocDistribs;
//	SCCSID: %M% %I% Modified: %G% %U%
//	Date      By            History
//      05/28/02  kcs	    	Initial
//	09/30/02  kcs		change excel to Jakarta poi
//		PVCS
//	$Revision:   1.2  $
//	$Author:   c378632  $
//	$Workfile:   AmdNsiLocDistribsBean.java  $


/*	
	mixture of methods for getting excel version, left in till POI version full tested:
	1st attempt: 	put tabs in between column values for excel to import. isHtml(false) in
			nsiLocDistribsExcel.jsp determines use.
			problem:  nsn treated as exponential # as opposed to literal string. ' did 
				  not work well.
	2nd attempt:	2000 version of excel can read and interpret html.  isHtml(true) in
			nsiLocDistribsExcel.jsp determines use.
			use x=str in xml to indicate nsn is literal (not large numeric).
			problem:  not everyone has 2000 version at time of testing, including Gino.
	3rd attempt:	use jakarta POI, preferred method.  Have control over colors, fonts, etc.
			utilizes HSSFWorkbook. working well, further testing required.
*/
import java.io.*;
import java.util.*;
import java.sql.*;
import oracle.jdbc.driver.OracleTypes;
import javax.servlet.jsp.*;
import org.apache.poi.hssf.usermodel.*;
import org.apache.poi.hssf.util.HSSFColor;
import retrofit.Helper;
import exceptions.*;

public class AmdNsiLocDistribsBean{
	private JspWriter out; 
	private StringBuffer errorMsg = new StringBuffer("");
	private StringBuffer debugMsg = new StringBuffer("");
	private StringBuffer warnMsg = new StringBuffer("");
	private final String tab = "\t";
	private boolean isHtml = true;
	private int maxTimePeriods = 0;
 	private	int gTpsHeadCount = 0;
	Connection myConn = null;

	public void setConn(Connection pConn){
		myConn = pConn;
	}
	public Connection getConn(){
		return myConn;
	}
	
	public int getMaxTimePeriods(){
		return maxTimePeriods;
	}	
	public void setIsHtml(boolean isHtml){
		this.isHtml = isHtml;
	}
	public boolean getIsHtml(){
		return isHtml;
	}
	
	public AmdNsiLocDistribsBean(){
		errorMsg = new StringBuffer("");
		debugMsg = new StringBuffer("");
		warnMsg = new StringBuffer("");
	}
	public JspWriter getOut(){
		return out;
	}
	public void setOut(JspWriter out){
		this.out = out;
	}
	public void setErrorMsg(String errorMsg){
		if (errorMsg.equals("")){
			this.errorMsg.setLength(0);
		}else{
			this.errorMsg.append(errorMsg + "<br>"); 
		}
	}
	public String getErrorMsg(){
		return errorMsg.toString();
	}
	public void setDebugMsg(String debugMsg){
		if (debugMsg.equals("")){
			this.debugMsg.setLength(0);
		}else{
			this.debugMsg.append(debugMsg + "<br>"); 
		}
	}
	public String getDebugMsg(){
		return debugMsg.toString();
	}
	public void setWarnMsg(String warnMsg){
		if (warnMsg.equals("")){
			this.warnMsg.setLength(0);
		}else{
			this.warnMsg.append(warnMsg + "<br>"); 
		}
	}
	public String getWarnMsg(){
		return warnMsg.toString();
	}

	public String wrap(String in, String atts, boolean isLargeNumber){
		String tick = "";
		if (isLargeNumber)
			tick = "\'";		
		return wrapIt(in, atts, tick);
	}
	public String wrap(String in, String atts){
		String tick = "";
		return wrapIt(in, atts, tick);
	}
	public String wrap(String in){
		String atts = "";
		String tick = "";
		return wrapIt(in, atts, tick);
	}
	
	public String wrapIt(String in, String atts, String tick){
		if (in == null || in.equals("")){
			in = "&nbsp;";
		}
		if (isHtml){
			return ("<td" + atts + ">" + in + "</td>");
		}else{
			return (tab + tick + in);
		}
	}
	public String endRow(){
		if (isHtml){
			return "</tr>\n";
		}else{
			return "\n";
		}
	}
	public String newRow(){
		if (isHtml){
			return "<tr>";
		}else{
			return "";
		}
	}

	public String nvl(String in, String defaultStr){
		if (in == null || in.equals("")){
			return defaultStr;
		}
		return in;
	}
	public String blankCol(int x){
		StringBuffer bc = new StringBuffer("");
		if (isHtml){
			for (int i=0; i < x; i++){
				bc.append("<td>&nbsp;</td>");
			}
		}else{
			for (int i=0; i < x; i++){
				bc.append(tab);
			}
		}
		return bc.toString();
	}
	public String genNsiSidPerLocation(java.util.ArrayList inList) throws Exception{
		StringBuffer retStr = new StringBuffer("");
		String nsn = ((AmdNsiLocDistribsRec) inList.get(0)).getNsn();
		nsn = wrap(nsn, " x:str=\"\'" + nsn + "\"", true);
		String pn = wrap( ((AmdNsiLocDistribsRec) inList.get(0)).getPn() ); 
		String locName = wrap( ((AmdNsiLocDistribsRec) inList.get(0)).getLocName() );

		retStr.append(newRow() + nsn + pn + locName);
		retStr.append(wrap("As Flying Count"));
		for (int i =0 ; i < inList.size(); i++){
			String afc = nvl( ((AmdNsiLocDistribsRec) inList.get(i)).getAsFlyingCount(), "n/a");
			retStr.append(wrap(afc, " align=\"right\""));	
		}
		retStr.append(endRow());
		retStr.append(newRow() + nsn + pn + locName);
		retStr.append(wrap("As Flying Percent"));
		for (int i =0 ; i < inList.size(); i++){
			String afp = nvl( ((AmdNsiLocDistribsRec) inList.get(i)).getAsFlyingPercent(), "n/a");
			retStr.append(wrap(afp, " align=\"right\""));	
		}
		retStr.append(endRow());
		retStr.append(newRow() + nsn + pn + locName);
		retStr.append(wrap("As Capable Count"));
		for (int i =0 ; i < inList.size(); i++){
			String acc = nvl( ((AmdNsiLocDistribsRec) inList.get(i)).getAsCapableCount(), "n/a");
			retStr.append(wrap(acc, " align=\"right\""));	
		}
		retStr.append(endRow());
		retStr.append(newRow() + nsn + pn + locName);
		retStr.append(wrap("As Capable Percent"));
		for (int i =0 ; i < inList.size(); i++){
			String acp = nvl( ((AmdNsiLocDistribsRec) inList.get(i)).getAsCapablePercent(), "n/a");
			retStr.append(wrap(acp, " align=\"right\""));	
		}
		retStr.append(endRow());
		if (inList.size() > maxTimePeriods){
			maxTimePeriods = inList.size();
		}
		return retStr.toString();
	}


	public String genLocDistribs(int pNsiSid) throws Exception{
		StringBuffer retStr = new StringBuffer("");
		retStr.append(getHeader("(" + Integer.toString(pNsiSid) + ")"));
		retStr.append(genPerNsiSid(pNsiSid));
		retStr.append(getEnd());
		return retStr.toString();
	}

	public void genLocDistribs(HSSFWorkbook pWb, int pNsiSid) throws Exception{
		setHeader(pWb, "(" + Integer.toString(pNsiSid) + ")");
		genPerNsiSid(pWb, pNsiSid);
	}

	public String genLocDistribs(java.util.ArrayList pNsiSidGroupList) throws Exception{
		int nsiSid = -99;
		StringBuffer retStr = new StringBuffer("");
		retStr.append(getHeader(pNsiSidGroupList));
		for (int i=0; i < pNsiSidGroupList.size(); i++){
			nsiSid = Integer.parseInt((String) pNsiSidGroupList.get(i));
			retStr.append(genPerNsiSid(nsiSid));
		}
		retStr.append(getEnd());
		return retStr.toString();
	}

	public void genLocDistribs(HSSFWorkbook pWb, java.util.ArrayList pNsiSidGroupList) throws Exception{
		int nsiSid = -99;
		setHeader(pWb, pNsiSidGroupList);
		for (int i=0; i < pNsiSidGroupList.size(); i++){
			nsiSid = Integer.parseInt((String) pNsiSidGroupList.get(i));
			genPerNsiSid(pWb, nsiSid);
		}
	}
	
	public void genPerNsiSid(HSSFWorkbook wb, int pNsiSid) throws Exception{
		CallableStatement stmt = null;
		StringBuffer retStr = new StringBuffer("");
		try {
			stmt = myConn.prepareCall("{call ?:= amd_effectivity_tcto_pkg.getNsiLocDistribs(?)}");	
			stmt.registerOutParameter(1, OracleTypes.CURSOR);
			stmt.setInt(2, pNsiSid);
			stmt.execute();
			ResultSet rs = (ResultSet) stmt.getObject(1);
			String lastLocId = "defaultLocId";
			String currentLocId = "";
			HSSFSheet sheet = wb.getSheetAt(0);
			HSSFRow row = sheet.getRow((short) 0);
			int lastCellNum = 0;
				// setHeader will create the header including all the time periods.
				// lastCellNum will relate to last time period, size of row.
			lastCellNum = row.getLastCellNum();
			row = null;
			short cellNum = 3;
			while (rs.next()){
				currentLocId = rs.getString("loc_id"); 
				if (!lastLocId.equals(currentLocId)){ 
						/*  4 rows for 4 fields -
							asCapableCount, asCapablePercent 
							asFlyingCount, asFlyingPercent
						*/
					sheet.createRow((short) (sheet.getLastRowNum()+1));
					sheet.createRow((short) (sheet.getLastRowNum()+1));
					sheet.createRow((short) (sheet.getLastRowNum()+1));
					sheet.createRow((short) (sheet.getLastRowNum()+1));
						// create all the cells for the 4 new rows 
					for (int j = 0; j < lastCellNum + 1; j++){
						(sheet.getRow(sheet.getLastRowNum()-3)).createCell((short) j);
						(sheet.getRow(sheet.getLastRowNum()-2)).createCell((short) j);
						(sheet.getRow(sheet.getLastRowNum()-1)).createCell((short) j);
						(sheet.getRow(sheet.getLastRowNum())).createCell((short) j);
					}
					if (!lastLocId.equals("defaultLocId") && lastCellNum != (int) cellNum){
						throw new exceptions.TimePeriodError("System problem - time periods not sequential or mismatched for loc id: " + currentLocId + "<" + lastCellNum + ":" + cellNum + ">");
					}
					cellNum = 3;
				}
				cellNum ++;
					// put cell values into the 4 rows
				for (int j = 3;  j >= 0; j--){
					row = sheet.getRow((short) (sheet.getLastRowNum() - j));
					row.getCell((short) 0).setCellValue(rs.getString("nsn"));
					row.getCell((short) 1).setCellValue(rs.getString("prime_part_no"));
					row.getCell((short) 2).setCellValue(rs.getString("location_name"));
					switch(j){
						case 3:
							row.getCell((short) 3).setCellValue("As Flying Count");
							row.getCell(cellNum).setCellValue(rs.getString("as_flying_count")) ;	
							break;
						case 2:
							row.getCell((short) 3).setCellValue("As Flying Percent");
								// round 2 decimal places
							row.getCell(cellNum).setCellValue(retrofit.Helper.roundTwo(rs.getString("as_flying_percent")));	
							break;
						case 1:
							row.getCell((short) 3).setCellValue("As Capable Count");
							row.getCell(cellNum).setCellValue(rs.getString("as_capable_count"));	
							break;
						case 0:
							row.getCell((short) 3).setCellValue("As Capable Percent");
								// round 2 decimal places
							row.getCell(cellNum).setCellValue(retrofit.Helper.roundTwo(rs.getString("as_capable_percent")));	
							break;
						default:
							break;
					}
				}
				lastLocId = currentLocId;
			}
			if (!lastLocId.equals("lastLocId") && lastCellNum != (int) cellNum){
				/* light check to see if time periods ok.  data should have sequential time periods.
				   check if same # of time periods for individual nsi as for all nsi in group
				   (determined by setHeader).  worst
				   case is that individual has a subset of values. throw error on occurrence */
				throw new exceptions.TimePeriodError("System problem - time periods not sequential or mismatched for loc id: " + currentLocId + "<" + lastCellNum + ":" + cellNum + ">");
			}
		}catch (Exception e){
			setErrorMsg("System problem with reporting nsn for excel: " + e.toString());
			throw e;
		}finally {
			if (stmt != null)
				stmt.close();
		}
	}
		
	public String genPerNsiSid(int pNsiSid) throws Exception{
		/* moved to oracle for performance --
		String sqlString = "select nsn, prime_part_no, location_name, loc_id, to_char(time_period_start, \'MM/DD/YY\') as time_period_start, to_char(time_period_end, \'MM/DD/YY\') as time_period_end, as_flying_count, as_flying_percent, as_capable_count, as_capable_percent from amd_nsi_loc_distribs anld, amd_national_stock_items ansi, amd_spare_networks asn where anld.nsi_sid=ansi.nsi_sid and anld.loc_sid=asn.loc_sid and anld.nsi_sid = " + pNsiSid + " order by loc_id, anld.time_period_start";  
		*/
		maxTimePeriods = 0;
		CallableStatement stmt = null;
		StringBuffer retStr = new StringBuffer("");
		try {
			stmt = myConn.prepareCall("{call ?:= amd_effectivity_tcto_pkg.getNsiLocDistribs(?)}");	
			stmt.registerOutParameter(1, OracleTypes.CURSOR);
			stmt.setInt(2, pNsiSid);
			stmt.execute();
			ResultSet rs = (ResultSet) stmt.getObject(1);
			java.util.ArrayList anldList = new ArrayList();
			String lastLocId = "lastLocId";
			String currentLocId = "";
			boolean firstOrFound = false;
			int tpsCount = 0;
			while (rs.next()){
				if (!firstOrFound)
					lastLocId = rs.getString("loc_id");
				firstOrFound = true;
				currentLocId = rs.getString("loc_id");
				AmdNsiLocDistribsRec aRec = new AmdNsiLocDistribsRec();
				aRec.setNsn(rs.getString("nsn"));
				aRec.setPn(rs.getString("prime_part_no"));
				aRec.setLocName(rs.getString("location_name"));
				aRec.setLocId(rs.getString("loc_id"));
				aRec.setTimePeriodStart(rs.getString("time_period_start"));
				aRec.setTimePeriodEnd(rs.getString("time_period_end"));
				aRec.setAsFlyingCount(rs.getString("as_flying_count"));
				aRec.setAsFlyingPercent(rs.getString("as_flying_percent"));
				aRec.setAsCapableCount(rs.getString("as_capable_count"));
				aRec.setAsCapablePercent(rs.getString("as_capable_percent"));
				if (!currentLocId.equals(lastLocId)){	
					try {
						retStr.append(genNsiSidPerLocation(anldList));
						anldList.clear();
					}catch (Exception e1){
						setErrorMsg("System problem with genNsiPerLocation (1): " + e1.toString());
						throw e1;
					}
					if (tpsCount != gTpsHeadCount && !lastLocId.equals("lastLocId")){
						setErrorMsg("System problem - time periods not sequential or mismatched for loc id: " + currentLocId + " (" + tpsCount + ":" + gTpsHeadCount + ")");
					} 
					tpsCount = 0;
				}
				tpsCount ++;
				anldList.add(aRec);
				lastLocId = currentLocId;
			}
			if (firstOrFound){
				try {
					retStr.append(genNsiSidPerLocation(anldList));
				}catch (Exception e2){
					setErrorMsg("System problem with genNsiPerLocation (2): " + e2.toString());
					throw e2;
				}
			}
		}catch (Exception e){
			setErrorMsg("System problem with reporting nsn: " + e.toString());
			throw e;
		}finally {
			if (stmt != null)
				stmt.close();
		}
		return retStr.toString();
	}


	public void setHeader(HSSFWorkbook pWb, String pInList) throws Exception{
		Statement stmt = null;
		String sqlString = getHeaderSql(pInList);
		setDebugMsg(sqlString);
		gTpsHeadCount = 0;
		try {
			HSSFSheet sheet = pWb.getSheetAt(0);
			HSSFCellStyle style = pWb.createCellStyle();
			HSSFRow row = sheet.createRow((short)0);
			HSSFCell cell = row.createCell((short) 0);
			style.setFillForegroundColor(HSSFColor.SKY_BLUE.index);
			style.setFillPattern(HSSFCellStyle.SOLID_FOREGROUND);

			HSSFFont font = pWb.createFont();
			font.setBoldweight(HSSFFont.BOLDWEIGHT_BOLD);
			style.setFont(font);
			cell.setCellValue("NSN");
			cell.setCellStyle(style);

			cell = row.createCell((short) 1);
			cell.setCellValue("Prime Part No.");
			cell.setCellStyle(style);

			cell = row.createCell((short) 2);
			cell.setCellValue("Location");
			cell.setCellStyle(style);

			cell = row.createCell((short) 3);
			cell.setCellValue("Data Type");
			cell.setCellStyle(style);

			HSSFCellStyle styleDate = pWb.createCellStyle();
			styleDate.setFillForegroundColor(HSSFColor.GOLD.index);
			styleDate.setFillPattern(HSSFCellStyle.SOLID_FOREGROUND);
			styleDate.setFont(font);
			styleDate.setAlignment(HSSFCellStyle.ALIGN_LEFT);

			stmt = myConn.createStatement();
			ResultSet rs = stmt.executeQuery(sqlString);
			int i = 4;
			while (rs.next()){
				row.createCell((short) i).setCellValue(rs.getString("tps"));
				row.getCell((short) i).setCellStyle(styleDate);
				i++;
				gTpsHeadCount ++;
			}
		}catch (Exception e){
			setErrorMsg("System problem with getting timePeriodStart header info (excel version): " + e.toString());
			throw e;
		}finally {
			stmt.close();
		}
	}

	public String getHeader(String pInList) throws Exception{
		StringBuffer retStr = new StringBuffer("");
		StringBuffer tp = new StringBuffer("");
		String sqlString = getHeaderSql(pInList);
		Statement stmt = null;
		setDebugMsg(sqlString);
		gTpsHeadCount = 0;
		try {
			stmt = myConn.createStatement();
			ResultSet rs = stmt.executeQuery(sqlString);
			while (rs.next()){
				tp.append(wrap(rs.getString("tps")));		
				gTpsHeadCount ++;
			}
		}catch (Exception e){
			setErrorMsg("System problem with getting timePeriodStart header info for nsiSid " +  pInList + ": " + e.toString());
			throw e;
		}finally {
			stmt.close();
		}
		if (!isHtml){
			retStr.append(tab + "NSN" + tab + "Prime Part No." + tab + "Location" + tab + "Data Type" + tp.toString() + "\n");
		}else{
			retStr.append("<table border=1><tr><td><b>NSN</b></td><td><b>Prime Part No.</b></td><td><b>Location</b></td><td><b>Data Type</b></td>" + tp.toString() + "</tr>\n");
		}
		return retStr.toString();
	}

	public String getHeader(java.util.ArrayList pNsiSidGroupList) throws Exception{
		return getHeader(getInList(pNsiSidGroupList));
	}

	public void setHeader(HSSFWorkbook pWb, java.util.ArrayList pNsiSidGroupList) throws Exception{
		setHeader(pWb, getInList(pNsiSidGroupList));
	}

	public String getEnd(){
		String tEnd = "</table>";
		if (!isHtml)
			tEnd = "";
		return tEnd;
	}

	public String getInList(java.util.ArrayList pAl) throws Exception {
		StringBuffer inList = new StringBuffer("(");
		for (int i=0; i < pAl.size(); i++){
			inList.append("\'" + (String) pAl.get(i) + "\',");
		}
		inList.setLength(inList.length() - 1);
		inList.append(")");
		return inList.toString();
	}
	public String getHeaderSql(String pInList) {
		return "select distinct time_period_start, to_char(time_period_start, 'MM/DD/YY') as tps " +
					" from amd_nsi_loc_distribs where nsi_sid in " + pInList + 
					" order by time_period_start"; 
	}
}
