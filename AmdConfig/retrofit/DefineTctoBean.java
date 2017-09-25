//	SCCSID: %M% %I% Modified: %G% %U%
//	Date      By            History
//      05/28/02  kcs	    	Initial
package retrofit;
import java.io.*;
import java.util.*;
import java.sql.*;
import javax.servlet.jsp.*;
import effectivity.AcDisplayCntl;
import org.apache.regexp.RE;

class ArsRec {
	public String tcto_number;
	public String tail_no;
	public String block_name;
	public String scheduled_complete_date;
	public String actual_complete_date;
}

public class DefineTctoBean {
	private static int hitCount = 0;
	private boolean isAcSelected;
	private static final int DEFAULTLENGTH = 40;
	private static final int DBMAXLENGTH = 512;
	private int descDisplayLength;
	private String hdnEvent;
	private String hdnOptFromTo;
	private String[] hdnFromNsn;
	private String[] hdnToNsn;
	private String txtTcto;
	private String txtTctoDesc;
	private String cboTcto;
	private String cboNsn;
	private String cboVpn;
	private String cboPlanner;
	private String cboPair;
	private String[] cboBlkAc;
	private String optSearchBy;
	private String optFromTo;
	private String txtNsnVpn;
	private String[] chkFromTo;
	private String nomen;
	private String fromTo;
	private String plannerSql;
	private String space;
	private StringBuffer errorMsg;
	private JspWriter out; 
	private StringBuffer debugMsg;
	private StringBuffer instrMsg;
	private StringBuffer warnMsg;
	private AcDisplayCntl acDisplay;
	private boolean searchOn;
	private String chkDescDisplay;
	private boolean debugOn;
	
	class ActualCompDateException extends Exception {
		ActualCompDateException(String msg){
			super(msg);
		}
		ActualCompDateException(){
		}
	}
	public DefineTctoBean(){
		searchOn = false;
		setCboNsn("-1");
		setCboVpn("default");
		setCboTcto("default");
		setCboPair("default");
		setCboPlanner("default");
		setHdnEvent("none");
		txtNsnVpn = "";
		setOptSearchBy("byNsn");
		setOptFromTo("byFrom");
		space = "&nbsp;&nbsp;";
		nomen = "";
		debugMsg = new StringBuffer("");
		warnMsg = new StringBuffer("");
		errorMsg = new StringBuffer("");
		instrMsg = new StringBuffer("");
		acDisplay = new AcDisplayCntl();
		acDisplay.setOnChange("processEvent(\'acDisplay\')");
		setFromTo("byFrom");
		descDisplayLength = DEFAULTLENGTH ;
		setChkDescDisplay("on");
	}
	public void setDebugOn(boolean in){
		debugOn = in;
	}
	public boolean getDebugOn(){
		return debugOn;
	}
	public void setIsAcSelected (boolean in){
		isAcSelected = in;
	}
	public boolean getIsAcSelected(){
		return isAcSelected;
	}
	public void setChkDescDisplay(String in){
		chkDescDisplay = in;
	}
	public String getChkDescDisplay(){
		return chkDescDisplay;
	}
	public void setDescDisplayLength(int dl){
		if (dl > DBMAXLENGTH){
			descDisplayLength = DBMAXLENGTH;
		}else{
			descDisplayLength = dl;
		}
	}
	public void setDescDisplayLength(String dl){
		try {
			setDescDisplayLength(Integer.parseInt(dl));
		}catch (NumberFormatException e) {
			setDescDisplayLength(DEFAULTLENGTH);
		}
	}
	public int getDescDisplayLength(){
		return descDisplayLength;
	}
	public int getLowest(int x, int y){
		if (x <= y){
			return x;
		}else{
			return y;
		}
	}
	public void setAcBy(String acBy){
		this.acDisplay.setBy(acBy);
	}
	public String getAcBy(){
		return this.acDisplay.getBy();
	}
	public void setHdnEvent(String hdnEvent){
		this.hdnEvent = hdnEvent;
	}
	public String getHdnEvent(){
		return hdnEvent;
	}
	public void setHdnOptFromTo(String hdnOptFromTo){
		this.hdnOptFromTo = hdnOptFromTo;
	}
	public String getHdnOptFromTo(){
		return hdnOptFromTo;
	}
	public void setHdnFromNsn(String[] hdnFromNsn){
		this.hdnFromNsn = hdnFromNsn;
	}
	public String[] getHdnFromNsn(){
		return hdnFromNsn;
	}
	public void setHdnToNsn(String[] hdnToNsn){
		this.hdnToNsn = hdnToNsn;
	}
	public String[] getHdnToNsn(){
		return hdnToNsn;
	}
	public void setTxtTcto(String txtTcto){
		this.txtTcto = txtTcto;
	}
	public String getTxtTcto(){
		return txtTcto;
	}
	public void setTxtTctoDesc(String txtTctoDesc){
		this.txtTctoDesc = txtTctoDesc;
	}
	public String getTxtTctoDesc(){
		return txtTctoDesc;
	}
	public void setCboTcto(String cboTcto){
		this.cboTcto = cboTcto;
	}
	public String getCboTcto(){
		return cboTcto;
	}
	public void setCboPlanner(String cboPlanner){
		this.cboPlanner= cboPlanner;
	}
	public String getCboPlanner(){
		return cboPlanner;
	}
	public void setCboNsn(String cboNsn){
		this.cboNsn = cboNsn;
	}
	public String getCboNsn(){
		return cboNsn;
	}
	public void setCboVpn(String cboVpn){
		this.cboVpn = cboVpn;
	}
	public String getCboVpn(){
		return cboVpn;
	}
	public void setCboPair(String cboPair){
		this.cboPair = cboPair;
	}
	public String getCboPair(){
		return cboPair;
	}
	public void setCboBlkAc(String[] cboBlkAc){
		this.cboBlkAc = cboBlkAc;
	}
	public String[] getCboBlkAc(){
		return cboBlkAc;
	}
	public void setFromTo(String in){
		if (in != null && in.equals("byTo")){
			fromTo = "replaced_by_nsi_sid";
		}else{
			fromTo = "replaced_nsi_sid";
		}
	}
	public String getFromTo(){
		return fromTo;
	}
	public void setOptFromTo(String optFromTo){
		this.optFromTo = optFromTo;
		setFromTo(optFromTo);
	}
	public String getOptFromTo(){
		return optFromTo;
	}
	public void setOptSearchBy(String optSearchBy){
		this.optSearchBy = optSearchBy;
	}
	public String getOptSearchBy(){
		return optSearchBy;
	}
	public void setTxtNsnVpn(String txtNsnVpn){
		this.txtNsnVpn = txtNsnVpn;
	}
	public String getTxtNsnVpn(){
		return txtNsnVpn;
	}
	public void setChkFromTo(String[] chkFromTo){
		this.chkFromTo = chkFromTo;
	}
	public String[] getChkFromTo(){
		return chkFromTo;
	}
	public void setNomen(String nomen){
		this.nomen = nomen;
	}
	public String getNomen(){
		return nomen;
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
	public JspWriter getOut(){
		return out;
	}
	public void setOut(JspWriter out){
		this.out = out;
		acDisplay.setOut(out);
	}
	public void setDebugMsg(String debugMsg){
		if (debugOn){
			if (debugMsg.equals("")){
				this.debugMsg.setLength(0);
			}else{
				this.debugMsg.append(debugMsg + "<br>"); 
			}
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
	public void setInstrMsg(String instrMsg){
		if (instrMsg.equals("")){
			this.instrMsg.setLength(0);
		}else{
			this.instrMsg.append(instrMsg + "<br>"); 
		}
	}
	public String getInstrMsg(){
		return instrMsg.toString();
	}
	public boolean isNull(String in){
		if (in == null || in.equals("")){
			return true;
		}else{
			return false;
		}
	}
// ##########################
	public void processEvents(Connection myConn) throws Exception{
	   try{
		hitCount++;
		setErrorMsg("");
		setWarnMsg("");
		setDebugMsg("");
		setInstrMsg("");
		setNomen("");
			// ####  add actions ####
		String action = getHdnEvent();
		boolean hasActualCompDate = false;
		if (!getCboTcto().equals("default")) {
			hasActualCompDate = existAcWithActualCompDate(myConn);
		}
		if (action.equals("addTcto")){
			updateTcto(myConn);
		}else if (action.equals("addFromTo")){
			if (hasActualCompDate){
				setErrorMsg("cannot add pair - tcto has actual complete date in schedule by aircraft screen"); 
				return;
			}
			if (getCboTcto().equals("default")) {
				setErrorMsg("need to choose a TCTO before adding pairs");
			}else if (getCboPair().equals("default")){
			//	setErrorMsg("need to choose a pair before adding");
			}else{
				updateNsnFromTo(myConn);
			}
		}else if (action.equals("addBlkAc")){ 
			if (getCboTcto().equals("default")) {
				setErrorMsg("need to choose a TCTO before updating effectivity");
			}else{
				updateBlkAc(myConn);
			}
			// #### del actions ####
		}else if (action.equals("delTcto")){
			if (hasActualCompDate){
				setErrorMsg("cannot delete tcto - tcto has actual complete date in schedule by aircraft screen"); 
				return;
			}
			if (getCboTcto().equals("default")) {
				setErrorMsg("need to choose a TCTO before deleteing a TCTO");
			}else{
				delTcto(myConn);
			}
			setTxtTcto(null);
			setTxtTctoDesc(null);
			setCboTcto("default");
		}else if (action.equals("delFromTo")){
			if (hasActualCompDate){
				setErrorMsg("cannot delete pair - tcto has actual complete date in schedule by aircraft screen"); 
				return;
			}
			delNsnFromTo(myConn);
		}else if (action.equals("chkPairListAll") || action.equals("search")){
			// #### reset values ####
			if (action.equals("chkPairListAll")){
				setTxtNsnVpn("");
			}
			setCboPair("default");
			setCboNsn("-1");
			//setCboVpn("default");
			setCboPlanner("default");
			searchOn = true;
		}
		plannerSql = "";
		if (!getCboPlanner().equals("default")){
			plannerSql = " and ansi.planner_code=\'" + getCboPlanner() + "\' ";
			searchOn = true;
		}
	 }catch (Exception e){
		setErrorMsg(e.toString());
	 }
	}
	public boolean existAcWithActualCompDate(Connection myConn) throws Exception{
		String sqlString = "select tail_no from " + 
				   "amd_retrofit_schedules where actual_complete_date is not null and " +
				   "tcto_number=\'" + getCboTcto() + "\'";
		setDebugMsg(sqlString);
		Statement stmt = null;
		String acd = null;
		boolean retBool = false;
		try{
			stmt = myConn.createStatement();
			ResultSet rs = stmt.executeQuery(sqlString);
			if (rs.next()){
				retBool = true;
			}
		}catch (Exception e){
			setErrorMsg("System problem trying to get actual_complete_date: " + e.toString());
			throw e;
		}finally{
			stmt.close();
		}
		return retBool;
	}
	public void updateTcto(Connection myConn) throws Exception{
		if (isNull(getTxtTcto()) || isNull(getTxtTctoDesc())){
			setErrorMsg("please enter valid tcto number and/or description");
			return;
		}
		String txtDesc = getTxtTctoDesc().substring(0, getLowest(getTxtTctoDesc().length(), DBMAXLENGTH)); 
		String sqlString = "insert into amd_retrofit_tctos (tcto_number, tcto_desc) values (upper(\'" + getTxtTcto() + "\'), upper(\'" + txtDesc + "\'))";
		setDebugMsg(sqlString);
		Statement stmt = null;
		try {
			stmt = myConn.createStatement();
			stmt.executeUpdate(sqlString);
			setCboTcto(getTxtTcto());
		} catch (SQLException e){
			stmt.close();
			if (e.getErrorCode() == exceptions.OracleErrorCode.DUP_VAL_ON_INDEX){
				sqlString = "update amd_retrofit_tctos set tcto_desc = upper(\'" + txtDesc + "\') where tcto_number=\'" + getTxtTcto() + "\'"; 
				setDebugMsg(sqlString);
				stmt = myConn.createStatement();
				try {
					stmt.executeUpdate(sqlString);
					setCboTcto(getTxtTcto());
				} catch (SQLException e2){
					setErrorMsg("System problem updating tcto: " + e2.toString());
				}
			}else{
				setErrorMsg("System problem updating tcto: " + e.toString());
			}
		}finally{
			stmt.close();
		}
	}
	public int deleteFromRetroScheds(Connection myConn, String tcto, String tailNo) throws Exception{
		String sqlString = "delete from amd_retrofit_schedules where tcto_number=\'" + tcto + "\' and tail_no=\'" + tailNo + "\' and actual_complete_date is null"; 
		setDebugMsg(sqlString);
		Statement stmt = null;
		int successNum = 0;
		try {
			stmt = myConn.createStatement();
			successNum = stmt.executeUpdate(sqlString);
		}catch (Exception e){
			setErrorMsg("System problem deleting from amd_retrofit_scheds (" + tcto + "," + tailNo + ")");
			throw e;
		}finally{
			stmt.close();
		}
		return successNum;
	}
	public void insertIntoRetroScheds(Connection myConn, String tcto, String tailNo, String scd, String blk) throws Exception{
		String scdSql = null;
		String blkSql = null;
		if (scd == null){
			scdSql = "null";
		}else{
			scdSql = " to_date(\'" + scd + "\', \'MM/DD/YY\') ";
		}
		if (blk == null){
			blkSql = "null";
		}else{
			blkSql = "\'" + blk + "\'";
		}
		String sqlString = "insert into amd_retrofit_schedules (tcto_number, tail_no, scheduled_complete_date, block_name) values (\'" +  tcto + "\',\'" + tailNo + "\'," + scdSql + "," + blkSql + ")";	
		setDebugMsg(sqlString);
		Statement stmt = null;
		try {
			stmt = myConn.createStatement();
			stmt.executeUpdate(sqlString);
		}catch (Exception e){
			setErrorMsg("System problem inserting into amd_retrofit_schedules: " + e.toString());
			throw e;
		}finally{
			stmt.close();
		}
	}

	public Hashtable getTailListForTcto(Connection myConn, String tcto) throws Exception{
			String sqlString = "select tail_no from amd_retrofit_schedules where tcto_number =\'" + getCboTcto() + "\'";
			setDebugMsg(sqlString);
			Statement stmt = null;
			Hashtable tailList = new Hashtable();
			try {
				stmt = myConn.createStatement();
				ResultSet rs = stmt.executeQuery(sqlString);
				while(rs.next()){
					tailList.put(rs.getString("tail_no"), "");
				}
			}catch (Exception e){
				setErrorMsg("System problem retrieving tail list: " + e.toString());
				throw e;
			}finally{
				stmt.close();
			}
			return tailList;
	}
	public ArsRec getArsRec(Connection myConn, String tcto, String tailNo) throws Exception{
			/* get all blocks where tcto defined, get ars rec for the particular tail_no  and blk.
			   in theory, all the recs should have same scd and acd per the tail_no,
			   just get first one. */
		String sqlString = "select tcto_number, tail_no, block_name, to_char(scheduled_complete_date, \'MM/DD/YY\') scd, to_char(actual_complete_date, \'MM/DD/YY\') acd " +
				   "from amd_retrofit_schedules where tail_no=\'" + tailNo + "\' " + 
				   "and block_name in " +
					"(select distinct block_name from " +
				   	"amd_retrofit_schedules where block_name is not null " + 
					"and tcto_number=\'" + tcto + "\')";	
		setDebugMsg(sqlString);
		Statement stmt = null;
		ArsRec ars = new ArsRec();
		try {
			stmt = myConn.createStatement();
			ResultSet rs = stmt.executeQuery(sqlString);
			if (rs.next()){
				ars.tail_no = rs.getString("tail_no");
				ars.block_name = rs.getString("block_name");
				ars.scheduled_complete_date = rs.getString("scd");
				ars.actual_complete_date = rs.getString("acd");
				ars.tcto_number = rs.getString("tcto_number");
			}
			if (ars.actual_complete_date != null){
				throw new ActualCompDateException();
			}
		}catch (ActualCompDateException ae){
			setWarnMsg("aircraft " + ars.tail_no + " is part of block " + ars.block_name + " which has an actual comp date of " + ars.actual_complete_date + " => did not add"); 
			throw ae;
		}catch (Exception e){
			setErrorMsg("System problem trying with getSchedCompDate: " + e.toString());
			throw e;
		}finally{
			stmt.close();
		}
		return ars;
	}
	public void updateBlkAc(Connection myConn) throws Exception{
		Statement stmt = null;
		try{
			String scd = null;
			String[] newBlkAc = getCboBlkAc(); 
			Hashtable currentBlkAc = getTailListForTcto(myConn, getCboTcto());
			for (int i=0; i < newBlkAc.length; i++){
				if (!currentBlkAc.containsKey(newBlkAc[i])){
					try {
						ArsRec ars = getArsRec(myConn, getCboTcto(), newBlkAc[i]);
						insertIntoRetroScheds(myConn, getCboTcto(), newBlkAc[i], ars.scheduled_complete_date, ars.block_name);
					}catch (ActualCompDateException ae){
					}
				}else {
					currentBlkAc.remove(newBlkAc[i]);
				}
			}
			StringBuffer delIn = new StringBuffer("");
				/* currentBlkAc now contains those that have been "deleted" */
			for (java.util.Enumeration e = currentBlkAc.keys(); e.hasMoreElements();){	
				String tailNo = (String) e.nextElement();
				int successNum = deleteFromRetroScheds(myConn, getCboTcto(), tailNo);
				if (successNum ==0) {
					setWarnMsg("aircraft " + tailNo + " - actual comp date exists, cannot undefine");
				}
			}
		}catch (SQLException e){
			setErrorMsg("System problem updating blk ac: " + e.toString());
		}finally{
			if (stmt != null)
				stmt.close();
		}
	}
	public void applyDefaultEffectivity(Connection myConn) throws Exception{
		String replacedNsiSid = Helper.split(":", getCboPair(), 1);
		String sqlString = "select tail_no from amd_nsi_effects where effect_type =\'B\' and user_defined in (\'S\',\'Y\') and nsi_sid=" + replacedNsiSid;
		setDebugMsg(sqlString);
		Statement stmt = null;
		try {
			stmt = myConn.createStatement();
			ResultSet rs = stmt.executeQuery(sqlString);
			Statement stmtInsert = null;
			while (rs.next()){
				String tailNo = rs.getString("tail_no");
				try {
					stmtInsert = myConn.createStatement();
					sqlString = "insert into amd_retrofit_schedules (tcto_number, tail_no) values (\'" + getCboTcto() + "\',\'" + tailNo + "\')";
					setDebugMsg(sqlString);
					stmtInsert.executeUpdate(sqlString);
				}catch (SQLException e) {
					if (e.getErrorCode() == exceptions.OracleErrorCode.DUP_VAL_ON_INDEX){
						//record exists do nothing
					}else{
						setErrorMsg("System problem inserting default effectivity (" + getCboTcto() + ":" + tailNo + ") " + e.toString());
					}
				}finally {
					stmtInsert.close();
				}
			}
		}catch (SQLException e){
			setErrorMsg("System problem extracting from amd_nsi_effects: " + e.toString());
		}finally{
			stmt.close();
		}
	}

	public void updateNsnFromTo(Connection myConn) throws Exception{
		String replacedNsiSid = Helper.split(":", getCboPair(), 1);
		String replacedByNsiSid = Helper.split(":", getCboPair(), 2);
		String sqlString = null;
		Statement stmt = null;
		try {
			sqlString = "select tcto_number from amd_related_nsi_pairs where replaced_nsi_sid = " + Integer.parseInt(replacedNsiSid) + " and replaced_by_nsi_sid=" + Integer.parseInt(replacedByNsiSid);
			setDebugMsg(sqlString);
			stmt = myConn.createStatement();	
			ResultSet rs = stmt.executeQuery(sqlString);
			String tctonumber = null;
			while (rs.next()){
				tctonumber = rs.getString("tcto_number");	
			}
			if (tctonumber == null){ 
				sqlString = "update amd_related_nsi_pairs set tcto_number =\'" + getCboTcto() + "\' where replaced_nsi_sid=" + Integer.parseInt(replacedNsiSid) + " and replaced_by_nsi_sid=" + Integer.parseInt(replacedByNsiSid);
				setDebugMsg(sqlString);
				stmt = myConn.createStatement();	
				stmt.executeUpdate(sqlString);
				stmt.close();
				applyDefaultEffectivity(myConn);
			}else if (!tctonumber.equals(getCboTcto())){
				setErrorMsg(tctonumber + " currently has the same pair, please delete that occurrence first");
			}
		}catch (SQLException e){
			setErrorMsg("System problem updating nsn from to: " + e.toString());
		}finally{
			stmt.close();
		}
	}
	public void delTcto(Connection myConn) throws Exception{
		Statement stmt = null;
		try {
			String sqlString = "delete from amd_retrofit_schedules where tcto_number =\'" + getCboTcto() + "\'";
			setDebugMsg(sqlString);
		        stmt = myConn.createStatement();
			stmt.executeUpdate(sqlString);
			stmt.close();
			sqlString = "update amd_related_nsi_pairs set tcto_number=null where tcto_number=\'" + getCboTcto() + "\'";
			setDebugMsg(sqlString);
			stmt = myConn.createStatement();	
			stmt.executeUpdate(sqlString);
			stmt.close();
			sqlString = "delete from amd_retrofit_tctos where tcto_number =\'" + getCboTcto() + "\'";	
			setDebugMsg(sqlString);
			stmt = myConn.createStatement();	
			stmt.executeUpdate(sqlString);
			stmt.close();
		}catch (SQLException e){
			setErrorMsg("System problem deleting tcto: " + e.toString());
		}finally{
			stmt.close();
		}
	}
		//-- todo
	public void delNsnFromTo(Connection myConn) throws Exception{
		String[] delList = getChkFromTo();
		if (delList == null){
			setErrorMsg("need to choose a pair before trying to remove");
			return;
		}
		String sqlString = "";
		String[] fromList = getHdnFromNsn();
		String[] toList = getHdnToNsn();
		Statement stmt = null;
		try {
			for (int i=0; i < delList.length; i++){
				stmt = myConn.createStatement();
				sqlString = "update amd_related_nsi_pairs set tcto_number=null where replaced_nsi_sid=" + fromList[Integer.parseInt(delList[i])] + " and replaced_by_nsi_sid=" + toList[Integer.parseInt(delList[i])];
				setDebugMsg(sqlString);
				stmt.executeUpdate(sqlString);
				stmt.close();
			}
		}catch (SQLException e){
			setErrorMsg("System problem deleting nsn from to: " + e.toString());
		}finally {
			stmt.close();
		}
	}

	public String reportPlanner(Connection myConn) throws Exception{
		StringBuffer retStr = new StringBuffer("");
		String sqlString = null;
		if (getOptSearchBy().equals("byNsn")){
			sqlString = "select distinct planner_code from amd_national_stock_items ansi, amd_related_nsi_pairs where  ansi.nsi_sid =" + getFromTo() + " and nsn like \'" + getTxtNsnVpn() + "%\'";
		}else {
			sqlString = "select distinct planner_code from amd_national_stock_items ansi, amd_related_nsi_pairs, amd_spare_parts asp where  ansi.nsi_sid =" + getFromTo() + " and asp.nsn = ansi.nsn and asp.part_no like \'" + getTxtNsnVpn() + "%\'";
		}
		setDebugMsg(sqlString);
		Statement stmt = null;
		String selected = "";
		String pcSelected = getCboPlanner();
		boolean selectedFound = false;
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
			stmt.close();
		}
		return retStr.toString();
	}

	public String reportFromTo(Connection myConn) throws Exception{
		if (getCboTcto().equals("default")){
			return "";
		}
		StringBuffer retStr = new StringBuffer("");
		String sqlString = "select ansiF.prime_part_no as fromPart, ansiT.prime_part_no as toPart, ansiF.nsi_sid as fromNsiSid, ansiF.nsn as fromNsn, ansiT.nsi_sid as toNsiSid, ansiT.nsn as toNsn from amd_national_stock_items ansiF, amd_national_stock_items ansiT, amd_related_nsi_pairs arnp where ansiT.nsi_sid = replaced_by_nsi_sid and ansiF.nsi_sid = replaced_nsi_sid and arnp.tcto_number = \'" + getCboTcto() + "\'";
		Statement stmt = null;
		setDebugMsg(sqlString);
		boolean found = false;
		try {
			int i = 0;
			stmt = myConn.createStatement();
			ResultSet rs = stmt.executeQuery(sqlString);
			while(rs.next()){
				String fromPart = rs.getString("fromPart");
				String toPart = rs.getString("toPart");
				String fromNsiSid = rs.getString("fromNsiSid");
				String toNsiSid= rs.getString("toNsiSid");
				String fromNsn = rs.getString("fromNsn");
				String toNsn= rs.getString("toNsn");
				retStr = retStr.append("<tr>" + Helper.tCol(Helper.input("checkbox", "chkFromTo", String.valueOf(i))) + Helper.tCol(Helper.input("hidden", "hdnFromNsn", fromNsiSid) + fromNsn) + Helper.tCol(fromPart) + Helper.tCol(Helper.input("hidden", "hdnToNsn", toNsiSid) + toNsn) + Helper.tCol(toPart) + "</tr>");
				found = true;
				i++;
			}
		}catch (SQLException e){
			setErrorMsg("System problem reporting from to: " + e.toString());
		}finally {
			stmt.close();
		}
		if (!found){
			setInstrMsg("Please associate nsn pair to TCTO");
		}
		return retStr.toString();
	}
	public String reportPair(Connection myConn) throws Exception{
		if (!searchOn){
			return "<option selected value=\"default\">-- none --</option>";
		}
		StringBuffer retStr = new StringBuffer("");
		String ansiFTnsn = getOptFromTo();
		String ansiFTnsiSid = "ansiF.nsi_sid";
		String plannerPairSql = "";
		if (ansiFTnsn.equals("byTo")){
			ansiFTnsn = "ansiT.nsn";
			ansiFTnsiSid = "ansiT.nsi_sid";
			if (!getCboPlanner().equals("default")){
				plannerPairSql = " and ansiT.planner_code=\'" + getCboPlanner() + "\' ";
			}
			
		}else{
			ansiFTnsn = "ansiF.nsn";
			if (!getCboPlanner().equals("default")){
				plannerPairSql = " and ansiF.planner_code=\'" + getCboPlanner() + "\' ";
			}
		}
		String sqlString = null; 
		String orderBy =  " order by ansiF.nsn, ansiT.nsn";
		if (getHdnEvent().equals("cboByNsn")){
			sqlString = "select distinct ansiF.prime_part_no ppFrom, ansiT.prime_part_no ppTo, replaced_nsi_sid, ansiF.nsn as fromNsn, replaced_by_nsi_sid, ansiT.nsn as toNsn from amd_related_nsi_pairs, amd_national_stock_items ansiF, amd_national_stock_items ansiT where replaced_nsi_sid = ansiF.nsi_sid and replaced_by_nsi_sid = ansiT.nsi_sid and " + ansiFTnsiSid + "=" + Integer.parseInt(getCboNsn());
		}else if (getHdnEvent().equals("chkPairListAll")){ 
			sqlString = "select distinct ansiF.prime_part_no ppFrom, ansiT.prime_part_no ppTo, replaced_nsi_sid, ansiF.nsn as fromNsn, replaced_by_nsi_sid, ansiT.nsn as toNsn from amd_related_nsi_pairs, amd_national_stock_items ansiF, amd_national_stock_items ansiT where replaced_nsi_sid = ansiF.nsi_sid and replaced_by_nsi_sid = ansiT.nsi_sid"; 
		}else {
			if (getOptSearchBy().equals("byNsn")){
				sqlString = "select distinct ansiF.prime_part_no ppFrom, ansiT.prime_part_no ppTo, replaced_nsi_sid, ansiF.nsn as fromNsn, replaced_by_nsi_sid, ansiT.nsn as toNsn from amd_related_nsi_pairs, amd_national_stock_items ansiF, amd_national_stock_items ansiT where replaced_nsi_sid = ansiF.nsi_sid and replaced_by_nsi_sid = ansiT.nsi_sid and " + ansiFTnsn + " like \'" + getTxtNsnVpn() + "%\'" + plannerPairSql; 
			}else {
				sqlString = "select distinct ansiF.prime_part_no ppFrom, ansiT.prime_part_no ppTo, replaced_nsi_sid, ansiF.nsn as fromNsn, replaced_by_nsi_sid, ansiT.nsn as toNsn from amd_related_nsi_pairs, amd_national_stock_items ansiF, amd_national_stock_items ansiT, amd_spare_parts asp where replaced_nsi_sid = ansiF.nsi_sid and replaced_by_nsi_sid = ansiT.nsi_sid and asp.nsn =" + ansiFTnsn + " and asp.part_no like \'" + getTxtNsnVpn() + "%\'" + plannerPairSql; 
			}
		}
		setDebugMsg("pair: " + sqlString);
		String sqlCount = "select count(*) as myCount from (" + sqlString + ")";
		Statement stmt = null;
		try {
			stmt = myConn.createStatement();
			ResultSet rs = stmt.executeQuery(sqlCount);
			String myCount = "-1";
			if (rs != null){
				while(rs.next()){
					myCount = rs.getString("myCount");	
				}
			}
			rs.close();
			stmt.close();
			sqlString = sqlString + orderBy;
			stmt = myConn.createStatement();
			rs = stmt.executeQuery(sqlString);
			boolean selectedFound = false;
			while(rs.next()){
				String fromNsiSid = rs.getString("replaced_nsi_sid");
				String toNsiSid = rs.getString("replaced_by_nsi_sid");
				String fromPrime = rs.getString("ppFrom");
				String toPrime = rs.getString("ppTo");
				String fromNsn = rs.getString("fromNsn");
				String toNsn = rs.getString("toNsn");
				String selected = "";
				if (getCboPair().equals(fromNsiSid + ":" + toNsiSid) || myCount.equals("1")){
					selected = " selected";
					selectedFound = true;
				}
				retStr.append("<option" + selected + " value=\"" + fromNsiSid + ":" + toNsiSid + "\"> From: " + fromNsn + space + "[" + fromPrime + "]" + space + "To: " + toNsn + space + "[" + toPrime + "]</option>");
			}
			rs.close();
			stmt.close();
			if (!selectedFound){
				String choice = "";
				if  (myCount.equals("0")){
					choice = "-- none --";
				}else{
					choice = "-- choose pair --";
				}
				retStr.append("<option selected value=\"default\">" + choice + "</option>");
			}	
		}catch (SQLException e){
			setErrorMsg("System problem reporting pairs: " + e.toString());
		}finally{
			stmt.close();
		}
		return retStr.toString();
	}
	public String reportCboTcto(Connection myConn) throws Exception{
		StringBuffer retStr = new StringBuffer("");
		String sqlString = "select tcto_number, tcto_desc from amd_retrofit_tctos order by tcto_number";
		setDebugMsg(sqlString);
		Statement stmt = null;
		try {
			stmt = myConn.createStatement();
			ResultSet rs = stmt.executeQuery(sqlString);
			boolean found = false;
			while(rs.next()){
				String tctoNumber = rs.getString("tcto_number");
				String tctoDesc = rs.getString("tcto_desc");
				String selected = "";
				if (Helper.nvl(getCboTcto(), "default").equals(tctoNumber)){
					found = true;
					selected = " selected";
					setTxtTcto(tctoNumber);
					setTxtTctoDesc(tctoDesc);
				}
				String tctoInfo = tctoNumber + " [" + tctoDesc;
				retStr.append("<option" + selected + " value=\"" + tctoNumber + "\">" + 
						tctoInfo.substring(0, getLowest(tctoInfo.length(), getDescDisplayLength())) + "]" + "</option>");
			}
			if (!found){
				retStr.append("<option selected value=\"default\">-- choose tcto --</option>");
			}
		}catch (SQLException e){
			setErrorMsg("System problem reporting tcto: " + e.toString());
		}finally{
			if (stmt != null)
				stmt.close();
		}
		return retStr.toString();
	}

	public String reportCboBlkAc(Connection myConn) throws Exception{
		if (getCboTcto().equals("default")){
			return "";
		}
		StringBuffer retStr = new StringBuffer("");
		String acFieldSql = getAcBy();
		String acField = null;	
		if (acFieldSql.equals("tail_no")){
			acFieldSql = "aa.tail_no";
			acField = "tail_no";
		}else{
			acField = acFieldSql;
		}
		String tctoNumber = "";
		String sqlString = "select aa.tail_no as tailNo, " + acFieldSql + ", tcto_number from amd_retrofit_schedules ars, amd_aircrafts aa where tcto_number(+)=\'" + getCboTcto() + "\' and p_no not like \'%DUM%\' and aa.tail_no = ars.tail_no(+) order by " + acFieldSql;
		Statement stmt = null;
		setDebugMsg(sqlString);
		boolean found = false;
		try {
			stmt = myConn.createStatement();
			ResultSet rs = stmt.executeQuery(sqlString);
			while(rs.next()){
				String ac = rs.getString(acField);
				String tailNo = rs.getString("tailNo");
				tctoNumber = rs.getString("tcto_number");
				String selected = "";
				if (tctoNumber != null){
					selected = " selected";
					found = true;
				}
				retStr.append("<option" + selected + " value=\"" + tailNo + "\">" + ac + "</option>");
			}
		}catch (SQLException e) {
			setErrorMsg("System problem reporting blk ac: " + e.toString());
		}finally {
			stmt.close();
		}
		if (!found){
			setInstrMsg("Please associate effective aircraft with this TCTO");
			setIsAcSelected(false);
		}else{
			setIsAcSelected(true);
		}
		return retStr.toString();
	}
		// for testing
	public String reportBlkAc() throws Exception{
		String[] blkAc = getCboBlkAc();
		StringBuffer retStr = new StringBuffer("");
		if (blkAc != null){
			for (int i = 0; i < blkAc.length; i++){
				retStr.append(" " + blkAc[i]);
			}
		}
		return retStr.toString();
	}
	public String reportNsn(Connection myConn) throws Exception {
		if (!searchOn){
			return ("<option selected value=\"-1\">-- none --</option>");
		}
		StringBuffer retStr = new StringBuffer("");
		String sqlString = "";
			// searching and  byNsn
			// if byNsn and search button hit or 
		if (getOptSearchBy().equals("byNsn")){
			sqlString = "select distinct ansi.nsn, nsi_sid, prime_part_no, amd_preferred_pkg.getNomenclature(nsi_sid) nomenclature from amd_spare_parts asp, amd_related_nsi_pairs arnp, amd_national_stock_items ansi where ansi.nsi_sid =" + getFromTo() + " and ansi.nsn = asp.nsn and ansi.nsn like \'" + getTxtNsnVpn() + "%\'" + plannerSql + " order by nsn";
		}else{
			sqlString = "select distinct asp.nsn, nsi_sid, prime_part_no, amd_preferred_pkg.getNomenclature(nsi_sid) nomenclature from amd_related_nsi_pairs arnp, amd_national_stock_items ansi, amd_spare_parts asp where ansi.nsi_sid =" + getFromTo() + " and ansi.nsn = asp.nsn and asp.part_no like \'" + getTxtNsnVpn() + "%\'" + plannerSql + " order by prime_part_no";
		}
		setDebugMsg(sqlString);
		String myCount = "-1";
		String sqlCount = "select count(*) as myCount from (" + sqlString + ")";
		Statement stmt = null;
		try {
			stmt = myConn.createStatement();
			ResultSet rs = stmt.executeQuery(sqlCount);	
			while(rs.next()){
				myCount = rs.getString("myCount");
			}
			stmt.close();
			boolean selectedFound = false;
			stmt = myConn.createStatement();
			rs = stmt.executeQuery(sqlString);	
			while(rs.next()){
				String nsn = rs.getString("nsn");
				String nsiSid = rs.getString("nsi_sid");
				String primePart = rs.getString("prime_part_no");
				String nomenclature = rs.getString("nomenclature");
				String selected = "";
				if (getCboNsn().equals(String.valueOf(nsiSid)) || myCount.equals("1")){
					selected = " selected";
					selectedFound = true;
					setCboNsn(nsiSid);
				}
				retStr.append("<option" + selected + " value=\"" + nsiSid + "\">" + nsn + space + primePart +
				space + "[" + nomenclature + "]</option>");
			}	
			stmt.close();
			if (!selectedFound){
				String choice = "";
				if  (myCount.equals("0")){
					choice = "-- none --";
				}else{
					choice = "-- choose nsn --";
					setCboNsn("-1");
				}
				retStr.append("<option selected value=\"-1\">" + choice + "</option>");
			}
		}catch (SQLException e){
			setErrorMsg("System problem reporting nsn: " + e.toString());
		}finally {
			stmt.close();
		}
		return retStr.toString();
	}
	public String reportVpn(Connection myConn) throws Exception {
		String sqlString = "";
		if (!getCboNsn().equals("-1")){
			sqlString = "select part_no from amd_spare_parts asp, amd_national_stock_items ansi where asp.nsn = ansi.nsn and ansi.nsi_sid =" + getCboNsn(); 
		}else {
			return ("<option selected value=\"default\">-- none --</option>");
		}
		StringBuffer retStr = new StringBuffer("");
		setDebugMsg("vpn: " + sqlString);
		String myCount = "-1";
		String sqlCount = "select count(*) as myCount from (" + sqlString + ")"; 
		Statement stmt = null;
		try {
			stmt = myConn.createStatement();
			ResultSet rs = stmt.executeQuery(sqlCount);	
			while(rs.next()){
				myCount = rs.getString("myCount");
			}
			rs.close();
			stmt.close();
			String nomen = "";
			boolean selectedFound = false;
			stmt = myConn.createStatement();
			rs = stmt.executeQuery(sqlString);	
			while(rs.next()){
				String vpn = rs.getString("part_no");
				String selected = "";
				if (getCboVpn().equals(vpn) || myCount.equals("1")){
					selected = " selected";
					setNomen(nomen);
					selectedFound = true;
					setCboVpn(vpn);
				}
				retStr.append("<option" + selected + " value=\"" + vpn + "\">" + vpn + "</option>");
			}	
			rs.close();
			stmt.close();
			if (!selectedFound){
				String choice = "";
				if  (myCount.equals("0")){
					choice = "-- none --";
				}else{
					choice = "-- prime and alternate parts --";
				}
				retStr.append("<option selected value=\"default\">" + choice + "</option>");
			}
		}catch (SQLException e){
			setErrorMsg("System problem reporting vpn: " + e.toString());
		}finally{
			stmt.close();
		}
		return retStr.toString();
	}

	public void reportAcDisplay(){
		try {
			this.acDisplay.genHtml();
		}catch (Exception e){
			setErrorMsg("System problem trying to report aircraft: " + e.toString());
		}
	}
	public String isChecked(String ctl){
		String retStr = "";
		if (ctl.equals("chkDescDisplay")){
			if ((getChkDescDisplay() != null && !getChkDescDisplay().equals("")) || hitCount == 1){
				retStr = " checked=\"ON\" ";
			}
		}
		return retStr;
	}
	public String isChecked(String ctl, String inString){
		if (ctl.equals("optSearchBy")){
			if (getOptSearchBy().equals(inString)){
				return " checked=\"yes\"";
			}else{
				return "";
			}
		}else if (ctl.equals("optFromTo")){
			if (getOptFromTo().equals(inString)){
				return " checked=\"yes\"";
			}else{
				return "";
			}
		}else {
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
}
