//	SCCSID: %M% %I% Modified: %G% %U%
//	Date      By            History
//      05/28/02  kcs	    	Initial
//      08/20/02  kcs	    	add run batch
//	09/30/02  kcs		change excel to Jakarta poi
//		PVCS
//	$Revision:   1.2  $
//	$Author:   c378632  $
//	$Workfile:   AdminBean.java  $
package retrofit;
import java.io.*;
import java.util.*;
import java.sql.*;
import javax.servlet.jsp.*;
import amdNsiLocDistribs.*;
import exceptions.*;
import org.apache.regexp.RE;
import org.apache.poi.hssf.usermodel.*;

public class AdminBean{
	private JspWriter out; 
	private StringBuffer errorMsg = new StringBuffer("");
	private StringBuffer debugMsg = new StringBuffer("");
	private StringBuffer warnMsg = new StringBuffer("");
	private final String tab = "\t";
	private int maxTimePeriods = 0;
	private String txtNsnVpn;
	private String cboPlanner;
	private String hdnEvent;
	private String cboNsn;
	private String cboNsnGroup;
	private String optSearchBy;
	private AmdNsiLocDistribsBean anld;
	private boolean searchOn;
	private static final String space = "&nbsp;&nbsp;";
	private String chkAllNsns;
	private Connection myConn;
	private boolean debugOn;

	public AdminBean(){
		anld = new amdNsiLocDistribs.AmdNsiLocDistribsBean();
		errorMsg = new StringBuffer("");
		debugMsg = new StringBuffer("");
		warnMsg = new StringBuffer("");
		setCboNsn("-1");
		setCboPlanner("default");
		setTxtNsnVpn("");
		setHdnEvent("none");
		setOptSearchBy("byNsn");
		searchOn = false;
		setChkAllNsns("ON");
		setDebugOn(false);
	}
	public void setChkAllNsns(String in){
		chkAllNsns = in;
	}
	public String getChkAllNsns(){
		return chkAllNsns;
	}

	public void setConn(Connection pConn){
		this.myConn = pConn;
		anld.setConn(pConn);
	}
	public Connection getConn(){
		return this.myConn;
	}
	public void setHdnEvent(String hdnEvent){
		this.hdnEvent = hdnEvent;
	}
	public String getHdnEvent(){
		return this.hdnEvent;
	}
	public void setTxtNsnVpn(String txtNsnVpn){
		this.txtNsnVpn = txtNsnVpn;
	}
	public String getTxtNsnVpn(){
		return txtNsnVpn;
	}
	public void setCboPlanner(String cboPlanner){
		this.cboPlanner= cboPlanner;
	}
	public String getCboPlanner(){
		return cboPlanner;
	}
	public void setCboNsn(String cboNsn){
		this.cboNsn= cboNsn;
	}
	public String getCboNsn(){
		return cboNsn;
	}
	public void setOptSearchBy(String optSearchBy){
		this.optSearchBy= optSearchBy;
	}
	public String getOptSearchBy(){
		return optSearchBy;
	}
	public void setIsHtml(boolean isHtml){
		anld.setIsHtml(isHtml);
	}
	public boolean getIsHtml(){
		return anld.getIsHtml();
	}
	public JspWriter getOut(){
		return out;
	}
	public void setOut(JspWriter out){
		this.out = out;
		anld.setOut(out);
	}
	public void setErrorMsg(String errorMsg){
		if (errorMsg.equals("")){
			this.errorMsg.setLength(0);
			anld.setErrorMsg("");
		}else{
			this.errorMsg.append(errorMsg + "<br>"); 
		}
	}
	public String getErrorMsg(){
		String brk = "";
		if (!anld.getErrorMsg().equals(""))
			brk = "<br>"; 
		return anld.getErrorMsg() + brk +  errorMsg.toString();
	}
	public void setDebugMsg(String debugMsg){
		if (getDebugOn()){
			if (debugMsg.equals("")){
				this.debugMsg.setLength(0);
				anld.setDebugMsg("");
			}else{
				this.debugMsg.append(debugMsg + "<br>"); 
			}
		}
	}
	public String getDebugMsg(){
		String brk = "";
		if (!anld.getDebugMsg().equals(""))
			brk = "<br>"; 
		return anld.getDebugMsg() + brk + debugMsg.toString();
	}
	public void setWarnMsg(String warnMsg){
		if (warnMsg.equals("")){
			this.warnMsg.setLength(0);
			anld.setWarnMsg("");
		}else{
			this.warnMsg.append(warnMsg + "<br>"); 
		}
	}
	public String getWarnMsg(){
		String brk = "";
		if (!anld.getWarnMsg().equals(""))
			brk = "<br>"; 
		return anld.getWarnMsg() + brk + warnMsg.toString();
	}
	public boolean getDebugOn(){
		return debugOn;
	}
	public void setDebugOn(boolean in){
		debugOn = in;
	}
	public void processEvents() throws Exception{
		setDebugMsg("");
		setErrorMsg("");
		setWarnMsg("");
		if (getHdnEvent().equals("search")){
			searchOn = true;
			setCboPlanner("default");
			setCboNsn("-1");
		}else if (getHdnEvent().equals("cboPlanner")){
			searchOn = true;
		}else if (getHdnEvent().equals("runBatch")){
			try { 
				runBatch();
			}catch (Exception e){
				setErrorMsg("System problem running batch: " + e.toString());
			}
		}
	}

	public HSSFWorkbook reportNsiLocDistribsPoiExcel() throws Exception{
		if (getCboNsn().equals("-1")){
			return null;
		}
		HSSFWorkbook wb = new HSSFWorkbook();
		HSSFSheet sheet = wb.createSheet("new sheet");
		
		int nsiSid = 0;
		int nsiSidGrp = 0;
		try {
			nsiSid = Integer.parseInt(getCboNsn());
			setDebugMsg("wb checked:" + isChecked("chkAllNsns") + ";");
			if (isChecked("chkAllNsns")){
				java.util.ArrayList nsiSidGroupList = getNsiSidGroupList(getCboNsn());	
				if (nsiSidGroupList != null && !nsiSidGroupList.isEmpty()){
					anld.genLocDistribs(wb, nsiSidGroupList);
				}else{
					throw new exceptions.NoNsiGroupSid("no nsi group sid available");
				}
			}else{
				anld.genLocDistribs(wb, nsiSid);
			}
		}catch (NumberFormatException e){
			setErrorMsg("System Problem - wb number format exception (" + nsiSid + ") : " + e.toString());
			throw e;
		}catch (Exception e2){
			setErrorMsg("System Problem trying to report wb nsiLocDistribs: " + e2.toString());
			throw e2;
		}finally{
			setErrorMsg(anld.getErrorMsg());
			setDebugMsg(anld.getDebugMsg());
		}
		return wb;
	}

	public String reportNsiLocDistribs() throws Exception{
		if (getCboNsn().equals("-1")){
			return "";
		}
		HSSFWorkbook wb = null;
		StringBuffer retStr = new StringBuffer("");
		int nsiSid = 0;
		int nsiSidGrp = 0;
		try {
			nsiSid = Integer.parseInt(getCboNsn());
			setDebugMsg("normal checked:" + isChecked("chkAllNsns") + ";");
			if (isChecked("chkAllNsns")){
				java.util.ArrayList nsiSidGroupList = getNsiSidGroupList(getCboNsn());	
				if (nsiSidGroupList != null && !nsiSidGroupList.isEmpty()){
					retStr.append(anld.genLocDistribs(nsiSidGroupList));
				}else{
					throw new exceptions.NoNsiGroupSid("no nsi group sid available");
				}
			}else{
				retStr.append(anld.genLocDistribs(nsiSid));
			}
		}catch (NumberFormatException e){
			setErrorMsg("System Problem - number format exception (" + nsiSid + ") : " + e.toString());
		}catch (Exception e2){
			setErrorMsg("System Problem trying to report nsiLocDistribs: " + e2.toString());
		}
		return retStr.toString();
	}

	public String reportPlanner() throws Exception{
		StringBuffer retStr = new StringBuffer("");
		String sqlString = null;
		if (getTxtNsnVpn().equals("")){
			sqlString = "select distinct planner_code from amd_national_stock_items ansi, amd_nsi_loc_distribs anld where ansi.nsi_sid = anld.nsi_sid";
		}else if (getOptSearchBy().equals("byNsn")){
			sqlString = "select distinct planner_code from amd_national_stock_items ansi, amd_nsi_loc_distribs anld where ansi.nsi_sid = anld.nsi_sid and nsn like \'" + getTxtNsnVpn() + "%\'";
		}else {
			sqlString = "select distinct planner_code from amd_national_stock_items ansi, amd_nsi_loc_distribs anld, amd_spare_parts asp where ansi.nsi_sid = anld.nsi_sid and ansi.nsn = asp.nsn and asp.part_no like \'" + getTxtNsnVpn() + "%\'";
		}
		setDebugMsg(sqlString);
		String selected = "";
		String pcSelected = getCboPlanner();
		boolean selectedFound = false;
		Statement stmt = null;
		try {
			stmt = myConn.createStatement();
			ResultSet rs = stmt.executeQuery(sqlString);
			int i = 0;
			while(rs.next()){
				String plannerCode = rs.getString("planner_code");
				selected = "";
				if (plannerCode.equals(pcSelected)){
					selected = " selected ";
					selectedFound = true;
				}
				i++;
				retStr.append("<option" + selected + " value=\"" + plannerCode + "\">" + plannerCode + "</option>");
			}
			stmt.close();
			if (!selectedFound){
				String choice = "";
				if  (i == 0){
					choice = "-- none --";
				}else{
					choice = "-- choose planner --";
				}
				if (i != 1){	
					retStr.append("<option selected value=\"default\">" + choice + "</option>");
				}	
			}	
		}catch (Exception e){
			if (stmt != null)
				stmt.close();
		}
		return retStr.toString();
	}

	public String reportNsn() throws Exception {
		if (!searchOn){
			return("<option selected value=\"-1\">-- none --</option>");
		}
		StringBuffer retStr = new StringBuffer("");
		String sqlString = "";
			// searching and  byNsn
			// if byNsn and search button hit or 
		String plannerSql = "";
		if (!getCboPlanner().equals("default")){
			plannerSql = " and ansi.planner_code=\'" + getCboPlanner() + "\'";
		}
		String likeSqlNsn = "";
		String likeSqlPn = "";
		if (!getTxtNsnVpn().equals("")){
			likeSqlNsn = " and ansi.nsn like \'" + getTxtNsnVpn() + "%\'";
			likeSqlPn = " and asp.part_no like \'" + getTxtNsnVpn() + "%\'";
		}
		if (getOptSearchBy().equals("byNsn")){
			sqlString = "select distinct ansi.nsn, anld.nsi_sid, prime_part_no, amd_preferred_pkg.getNomenclature(anld.nsi_sid) nomenclature from amd_spare_parts asp, amd_nsi_loc_distribs anld, amd_national_stock_items ansi where ansi.nsi_sid =anld.nsi_sid and ansi.nsn = asp.nsn" + likeSqlNsn  + plannerSql + " order by nsn";
		}else{
			sqlString = "select distinct asp.nsn, anld.nsi_sid, prime_part_no, amd_preferred_pkg.getNomenclature(anld.nsi_sid) nomenclature from amd_nsi_loc_distribs anld, amd_national_stock_items ansi, amd_spare_parts asp where ansi.nsi_sid =anld.nsi_sid and ansi.nsn = asp.nsn"  + likeSqlPn + plannerSql + " order by prime_part_no";
		}
		setDebugMsg(sqlString);
		Statement stmt = null;
		try {
			boolean selectedFound = false;
			stmt = myConn.createStatement();
			ResultSet rs = stmt.executeQuery(sqlString);	
			String nsn = null;
			String nsiSid = null;
			String primePart = null;
			String nomenclature = null;
			int myCount = 0;
			while(rs.next()){
				nsn = rs.getString("nsn");
				nsiSid = rs.getString("nsi_sid");
				primePart = rs.getString("prime_part_no");
				nomenclature = rs.getString("nomenclature");
				String selected = "";
				if (getCboNsn().equals(String.valueOf(nsiSid))){
					selected = " selected";
					selectedFound = true;
					setCboNsn(nsiSid);
				}
				retStr.append("<option" + selected + " value=\"" + nsiSid + "\">" + nsn + space + primePart +
				space + "[" + nomenclature + "]</option>");
				myCount++;
			}	
			stmt.close();
			if (myCount == 1){
				retStr.setLength(0);
				retStr.append("<option selected value=\"" + nsiSid + "\">" + nsn + space + primePart +
				space + "[" + nomenclature + "]</option>");
			}
			if (!selectedFound){
				String choice = "";
				if  (myCount == 0){
					choice = "-- none --";
					retStr.append("<option selected value=\"-1\">" + choice + "</option>");
				}else if (myCount == 1){
					setCboNsn(nsiSid);
				}else{
					choice = "-- choose nsn --";
					setCboNsn("-1");
					retStr.append("<option selected value=\"-1\">" + choice + "</option>");
				}
			}
		}catch (SQLException e){
			setErrorMsg("System problem reporting nsn: " + e.toString());
		}finally {
			stmt.close();
		}
		return retStr.toString();
	}
	public java.util.ArrayList getNsiSidGroupList() throws Exception{
		if (getCboNsn().equals("-1")){
			return null;
		}
		return getNsiSidGroupList(getCboNsn());
	}
	public java.util.ArrayList getNsiSidGroupList(String nsiSid) throws Exception{
		java.util.ArrayList nsnGrpLst = new java.util.ArrayList();
		String sqlString = "select nsi_sid from amd_national_stock_items where nsi_group_sid = (select nsi_group_sid from amd_national_stock_items where nsi_sid=" + nsiSid + ") order by nsn";   
		
		setDebugMsg(sqlString);
		Statement stmt = null;
		try{
			stmt = myConn.createStatement();
			ResultSet rs = stmt.executeQuery(sqlString);	
			while(rs.next()){
				nsnGrpLst.add(rs.getString("nsi_sid"));
			}
		}catch (SQLException e){
			setErrorMsg("System problem loading nsn grouping: " + e.toString());
		}finally {
			stmt.close();
		}
		if (nsnGrpLst.isEmpty()){
			return null;
		}else{
			return nsnGrpLst;
		}
	}
	public boolean isChecked(String ctl){
		boolean retBool = false; 
		if (ctl.equals("chkAllNsns")){
			if (!Helper.nvl(getChkAllNsns(), "").equals("")){
				retBool = true;
			}
		}
		return retBool;
	}
	public String isCheckedInfo(String ctl){
		if (isChecked(ctl)){
			return " checked ";
		}else{
			return "";
		}
	}
	public boolean isChecked(String ctl, String value){
		boolean retBool = false; 
		if (ctl.equals("optSearchBy")){
			if (getOptSearchBy().equals(value)){
				retBool = true;
			}
		}
		return retBool;
	}

	public String isCheckedInfo(String ctl, String value){
		if (isChecked(ctl, value)){
			return " checked=\"yes\" ";
		}else{
			return "";
		}
	}
	public String getOnLoad() throws Exception{
		String retStr = "";
		if (!getErrorMsg().equals("")){
			retStr = "ERROR:<br>" + getErrorMsg();
		}
		/* warnings may be annoying, but errors important 
		if (!getWarnMsg().equals("")){
			retStr = retStr +  "WARNING:<br>" + getWarnMsg();
		}
		*/
		if (!retStr.equals("")){
			RE re = new RE("<br>");
			retStr = " onload=\"alert(\'" + re.subst(retStr, "\\n") + "\')\";";
				
		}
		return retStr;
	}

	public void runBatch() throws Exception{
		CallableStatement cStmt = myConn.prepareCall("{call amd_effectivity_pkg.batchProcess}");	
		cStmt.execute();
	} 
}

