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

public class DefineBlockBean {
	private static int hitCount = 0;
	private static final int DEFAULTLENGTH = 80;
	private static final int DBMAXLENGTH = 100;
	private int descDisplayLength;
	private String[] cboBlkAc;
	private String[] hdnTcto;
	private String chkDescDisplay;
	private String cboBlk; 
	private String txtBlk;
	private String txtBlkDesc;
	private String[] chkTcto; 
	private String cboTcto; 
	private StringBuffer debugMsg;
	private StringBuffer warnMsg;
	private StringBuffer errorMsg;
	private String hdnEvent;
	private JspWriter out;
	private AcDisplayCntl acDisplay;
	private String htmlSpace = "&nbsp;&nbsp;&nbsp;&nbsp;";
	public boolean debugOn = false;
	
	
	public DefineBlockBean(){
		debugMsg = new StringBuffer("");
		cboBlkAc = null;
		setCboBlk("default");
		setCboTcto("default");
		setTxtBlk("");
		setTxtBlkDesc("");
		setHdnEvent("none");
		errorMsg = new StringBuffer("");
		warnMsg = new StringBuffer("");
		acDisplay = new AcDisplayCntl();
		acDisplay.setOnChange("processEvent(\'radioAcType\')");
		descDisplayLength = DEFAULTLENGTH;
	}

	public void setDebugOn(boolean in){
		debugOn = in;
	}
	public boolean getDebugOn(){
		return debugOn;
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
	public String getErrorMsg(){
		return errorMsg.toString();
	}
	public void setErrorMsg(String errorMsg){
		if (errorMsg == null || errorMsg.equals("")){
			this.errorMsg.setLength(0);
		}else{
			this.errorMsg.append(errorMsg + "<br>");
		}
	}
	public String getWarnMsg(){
		return warnMsg.toString();
	}
	public void setWarnMsg(String in){
		if (in.equals("")){
			warnMsg.setLength(0);
		}else{
			warnMsg.append(in + "<br>");
		}
	}
	public String getDebugMsg(){
		return debugMsg.toString();
	}
	public void setDebugMsg(String in){
		if (debugOn){
			if (in.equals("")){
				debugMsg.setLength(0);
			}else{
				debugMsg.append(in + "<br>");
			}
		}
	}
	public void setAcBy(String acBy){
		this.acDisplay.setBy(acBy);
	}
	public String getAcBy(){
		return this.acDisplay.getBy();
	}
	public String getTxtBlk(){
		return txtBlk;
	}
	public void setTxtBlk(String txtBlk){
		this.txtBlk = txtBlk;
	}
	public String getTxtBlkDesc(){
		return txtBlkDesc;
	}
	public void setTxtBlkDesc(String txtBlkDesc){
		this.txtBlkDesc = txtBlkDesc;
	}
	public String getCboTcto(){
		return cboTcto;
	}	
	public void setCboTcto(String cboTcto){
		this.cboTcto = cboTcto;
	}
	public String getCboBlk(){
		return cboBlk;
	}	
	public void setCboBlk(String cboBlk){
		this.cboBlk = cboBlk;
	}
	public String[] getCboBlkAc(){
		return cboBlkAc;
	}	
	public void setCboBlkAc(String[] cboBlkAc){
		this.cboBlkAc = cboBlkAc;
	}
	public String[] getHdnTcto(){
		return hdnTcto;
	}	
	public void setHdnTcto(String[] hdnTcto){
		this.hdnTcto= hdnTcto;
	}
	public int getLowest(int x, int y){
		if (x <= y){
			return x;
		}else{
			return y;
		}
	}
	public boolean isAcSelected(String inPno){
		boolean isSelected = false;
		for (int i=0; i < cboBlkAc.length; i++){
			if (cboBlkAc[i].equals(inPno)){
				isSelected = true;
				break;
			}
		}
		return isSelected;
	}
	public String listAcSelected(){
		String  acList = "";
		if (cboBlkAc == null){
			return "no ac list";
		}
		for (int i=0; i < cboBlkAc.length; i++){
			if (!cboBlkAc[i].equals("0")){
				acList = acList + " " + cboBlkAc[i];
			}
		}
		return acList;
	}
	public String[] getChkTcto(){
		return chkTcto;
	}	
	public void setChkTcto(String[] chkTcto){
		this.chkTcto = chkTcto;
	}
	public String getHdnEvent(){
		return hdnEvent;
	}	
	public void setHdnEvent(String hdnEvent){
		this.hdnEvent = hdnEvent;
	}

	public JspWriter getOut(){
		return out;
	}
	public void setOut(JspWriter out){
		this.out = out;
		this.acDisplay.setOut(out);
	}

	public boolean isNull(String in){
		if ((in == null) || in.equals("")){
			return true;
		}else{
			return false;
		}
	}
	public String genInSql(String[] inList){
		StringBuffer retStrBuf = new StringBuffer("");
		for (int i=0; i < inList.length; i++){
			retStrBuf.append("\'" + inList[i] + "\'" + ",");
		}
		retStrBuf.setLength(retStrBuf.length() - 1);
		return retStrBuf.toString();
	}
	public void processEvents(Connection myConn){
		hitCount++;
		setErrorMsg("");
		setWarnMsg("");
		setDebugMsg("");
		try {
			String event = getHdnEvent();
			if (event.equals("addBlk")){
				addBlk(myConn);
			}else if (event.equals("delBlk")){ 
				delBlk(myConn);
			}else if (event.equals("updateBlkAc")){
				updateBlkAc(myConn);
			}else if (event.equals("addTcto")){
					// update the other tctos with potential new ac listing
				updateBlkAc(myConn);
					// add the new tcto with new aircraft listing 
				addTcto(myConn);
			}else if (event.equals("delTcto")){
				delTcto(myConn);
			}
		}catch (Exception e){
			setErrorMsg(e.toString());
		}
	}
	public void addBlk(Connection myConn) throws Exception{
		String blk = getTxtBlk();
		if (isNull(blk) || isNull(getTxtBlkDesc())){
			setErrorMsg("please enter valid block name and/or description");
			return;
		}
		String txtDescSql = "upper(\'" +getTxtBlkDesc().substring(0, getLowest(getTxtBlkDesc().length(), DBMAXLENGTH)) + "\')"; 
		String sqlString = "insert into amd_retrofit_sched_blocks (block_name, block_desc) values (upper(\'" + blk + "\')," + txtDescSql + ")";  
		setDebugMsg(sqlString);
		Statement stmt = null;
		try {
			stmt = myConn.createStatement();
			stmt.executeUpdate(sqlString);
			setCboBlk(blk);
		}catch (SQLException e){
			stmt.close();
			if (e.getErrorCode() == exceptions.OracleErrorCode.DUP_VAL_ON_INDEX){
				sqlString = "update amd_retrofit_sched_blocks set block_desc=" + txtDescSql + " where block_name=\'" + getTxtBlk() + "\'";
				setDebugMsg(sqlString);
				try {
					stmt = myConn.createStatement();
					stmt.executeUpdate(sqlString);
				}catch (Exception e2){
					setErrorMsg("System problem trying to update blk " + blk + ":" + e2.toString());
				}
			}else{
				setErrorMsg("System problem trying to add blk " + blk + ":" + e.toString());
			}
		}finally{
			stmt.close();
		}
	}

	public void delFromRetroScheds(Connection myConn, String blk) throws Exception{
		delFromRetroScheds(myConn, blk, null); 
	}
	
	public void delFromRetroScheds(Connection myConn, String blk, String[] acList) throws Exception{
		String acSql = "";
		if (acList != null){
			acSql =  " and tail_no in (" + genInSql(acList) + ")";
		}
		String sqlString = "update amd_retrofit_schedules set block_name = null where block_name =\'" + blk + "\'" + acSql;
		setDebugMsg(sqlString);
		Statement stmt = null;
		try {
			stmt = myConn.createStatement();
			stmt.executeUpdate(sqlString);
		}catch (Exception e){	
			setErrorMsg("System problem deleting blks for block name " + blk + ":" + e.toString());
			throw e;
		}finally {
			stmt.close();
		}
	}

	public void delBlk(Connection myConn) throws Exception{
		String blk = getCboBlk();
		if (blk.equals("default")){
			return;
		}
		Statement stmt = null;
		try {
			delFromRetroScheds(myConn, blk);
			stmt = myConn.createStatement();
			String sqlString = "delete from amd_retrofit_sched_blocks where block_name =\'" + blk + "\'";
			setDebugMsg(sqlString);
			stmt.executeUpdate(sqlString);
		}catch (Exception e){	
			setErrorMsg("System problem deleting block: " + e.toString());
		}finally {
			stmt.close();
		}
	}

	public Hashtable filterAcChosenList(Connection myConn, String[] tctoList, String[] acChosen) throws Exception{
		/* 
			filter:
				-those aircraft per the tcto list 
				that have already been assigned to another block.
				-if already has actual_complete_date.
		*/
		if (acChosen == null){
			return null;
		}
		StringBuffer warnStr = new StringBuffer("");
		Hashtable acChosenHash = new Hashtable();
		for (int i=0; i < acChosen.length; i++){
			acChosenHash.put(acChosen[i], "");
		}
		String acLook = getAcBy();
		if (acLook.equals("tail_no"))
			acLook = "aa.tail_no";	
		String sqlString = "select block_name, to_char(actual_complete_date, \'MM/DD/YY\') acd," + 
					"tcto_number, " + acLook + " as ac, aa.tail_no " + 
				   "from amd_retrofit_schedules ars, amd_aircrafts aa " +  
				   "where ars.tail_no = aa.tail_no and " + 
				   "ars.tail_no in (" + genInSql(acChosen) + ") and " +
				   "tcto_number in (" + genInSql(tctoList) + ") and " + 
				   "nvl(block_name, \'NOBLOCKNAME\') !=\'" + getCboBlk() + "\' and " +
				   "(actual_complete_date is not null or block_name is not null) " + 
				   "order by ac, block_name, tcto_number";
		setDebugMsg(sqlString);
		Statement stmt = null;
		try {
			stmt = myConn.createStatement();
			ResultSet rs = stmt.executeQuery(sqlString);
			while (rs.next()){
				String acd = rs.getString("acd");	
				warnStr.append(htmlSpace + rs.getString("ac") +  " : " + rs.getString("tcto_number") + ": "); 
				if (acd != null){
					warnStr.append(rs.getString("acd"));
				}else{
					warnStr.append(rs.getString("block_name"));
				}
				warnStr.append("<br>");
				if (acChosenHash.containsKey(rs.getString("tail_no"))){
					acChosenHash.remove(rs.getString("tail_no"));
				}
			}
		}catch (Exception e){
			setErrorMsg("System problem trying to get other block names with tcto " + getCboTcto());
		}finally{
			if (stmt != null)
				stmt.close();
		}
		if (!warnStr.toString().equals("")){
			// -4 is <br> at end
			warnStr.setLength(warnStr.length() - 4);
			setWarnMsg("Following aircraft already associated with another block OR<br>tcto has an " +
			"actual complete date already assigned =&gt; not processed:<br>" + warnStr.toString() ); 
		}
		return acChosenHash;
	}

	public void delTcto(Connection myConn) throws Exception{
		String[] checkedTctos = getChkTcto();
		String blk = getCboBlk();
		if (checkedTctos == null || blk.equals("default")){
			return;
		}
		Statement stmt = null;
		for (int i = 0; i < checkedTctos.length; i++){
			String sqlString = "update amd_retrofit_schedules set block_name=null where block_name=\'" + blk + "\' and tcto_number=\'" + checkedTctos[i] + "\'"; 
			setDebugMsg(sqlString);
			try {
				stmt = myConn.createStatement();
				stmt.executeUpdate(sqlString);
				stmt.close();
			}catch (Exception e){
				setErrorMsg("System problem trying to delete tcto: " + e.toString());
				setDebugMsg("del tcto error: " + ":" + checkedTctos[i] + ":" + blk + "<br>");
			}finally{
				stmt.close();
			}
		}
	}

	public boolean blkHasActualCompDate(Connection myConn, String blk) throws Exception{
		String sqlString = "select actual_complete_date from amd_retrofit_schedules " +
				   "where block_name=\'" + blk + "\' and actual_complete_date is not null" ; 
		setDebugMsg(sqlString);
		Statement stmt = null;
		String actualDate = null;
		try {
			stmt = myConn.createStatement();
			ResultSet rs = stmt.executeQuery(sqlString);
			if (rs.next()){
				actualDate = rs.getString("actual_complete_date");
			}
		}catch (Exception e){
			setErrorMsg("System problem trying to get actual date for block  " + blk + "; " + e.toString());
			throw e;
		}finally{
			stmt.close();
		}
		return (actualDate != null);
	}

	public int updateRetroScheds(Connection myConn, String blkName, String[] acChosen, String tcto) throws Exception{
		if (acChosen == null){
			return 0;
		}
		Statement stmt = null;
		String ac = null;
		String scd = null;
		String sqlScd = null;
		int j=0;
		try {
			for (int i=0; i < acChosen.length; i++){
				ac = acChosen[i];
				sqlScd = null;
				scd = getSchedCompDate(myConn, blkName, ac);
				if (scd != null){
					sqlScd = " to_date(\'" + scd + "\', \'MM/DD/YY\') ";
				}
				String sqlString = "update amd_retrofit_schedules " +
						   "set block_name=\'" + blkName + "\'," +
						   "    scheduled_complete_date=" + sqlScd +
						   " where tail_no=\'" + ac + "\' and tcto_number=\'" + tcto + "\'"; 
				setDebugMsg(sqlString);
				stmt = myConn.createStatement();
				j = j + stmt.executeUpdate(sqlString);
				stmt.close();
			}
		}catch (Exception e){
			setErrorMsg("System problem trying to update retro scheds (" + tcto + "," + ac + "):" + e.toString());
			throw e;
		}finally{
			if (stmt != null)
				stmt.close();
		}
		return j;
	}
	
	public int updateRetroScheds(Connection myConn, String blkName, String[] acChosen, String[] tctoList) throws Exception{
		if (acChosen == null){
			return 0;
		}
			/* only deals with new aircraft to blk */
/*????*/
		String sqlString = "update amd_retrofit_schedules set scheduled_complete_date=null, block_name=\'" + blkName + "\' where tail_no in (" + genInSql(acChosen) + ") and tcto_number in (" + genInSql(tctoList) + ")";
		setDebugMsg(sqlString);
		Statement stmt = null;
		int totalUpdates = 0;
		try {
			stmt = myConn.createStatement();
			totalUpdates = stmt.executeUpdate(sqlString);
		}catch (Exception e){
			setErrorMsg("System problem trying to update retroScheds: " + e.toString());
			throw e;
		}finally{
			stmt.close();
		}
		return totalUpdates;
	}

	public String getSchedCompDate(Connection myConn, String blk, String tailNo) throws Exception{
		String sqlString = "select to_char(scheduled_complete_date, \'MM/DD/YY\') scd, to_char(actual_complete_date, \'MM/DD/YY\') acd " +
				   "from amd_retrofit_schedules where tail_no=\'" + tailNo + "\' " + 
				   "and block_name=\'" + blk + "\' and scheduled_complete_date is not null"; 
		setDebugMsg(sqlString);
		Statement stmt = null;
		String scd = null;
		String acd = null;
		try {
			stmt = myConn.createStatement();
			ResultSet rs = stmt.executeQuery(sqlString);
			if (rs.next()){
				scd = rs.getString("scd");
				acd = rs.getString("acd");
			}
		}catch (Exception e){
			setErrorMsg("System problem trying with getSchedCompDate: " + e.toString());
			throw e;
		}finally{
			stmt.close();
		}
		return scd;
	}

	public void addTcto(Connection myConn) throws Exception{
		String[] acChosen = getCboBlkAc();	
		String tcto = getCboTcto();
		if (acChosen == null){
			setErrorMsg("must also choose aircraft when adding tcto");
			return;
		}else if (tcto.equals("default")){
			setErrorMsg("must choose tcto before trying to add");
			return;
		}
		try {
			if (blkHasActualCompDate(myConn, getCboBlk())){
				setErrorMsg("block already has an assigned actual completion date - cannot add tcto");
				return;
			}
		}catch (Exception e){
			setErrorMsg("System problem trying to get actual_complete_date: " + e.toString());
			throw e;
		}
			
		Hashtable acChosenHash = filterAcChosenList(myConn, new String[]{tcto}, acChosen);
			/* updateBlkAc with new ac is run prior to this. */
		Hashtable acCurrent = getCurrentAc(myConn, getCboBlk()); 
			/* if all ac's in effectivity def cannot be aligned with other tctos in blk, 
			do not add tcto to block */
		if (!acCurrent.isEmpty() && !hashKeysEqual(acChosenHash, acCurrent)){
			setWarnMsg("=> could not add tcto");
		}else{
			int totalUpdates = updateRetroScheds(myConn, getCboBlk(), hashToStringArray(acChosenHash), tcto);
			if (totalUpdates == 0){
				setWarnMsg(tcto + " was not added - its effectivity definition from Define TCTO screen does not have at least one corresponding aircraft (not associated with another block) with the requested block effectivity definition"); 
			}
		}
	}
	
	public String[] hashToStringArray(Hashtable h) throws Exception{
		if (h.isEmpty()){
			return null;
		}
		String[] retList = new String[h.size()];
		int j = 0;
		for (Enumeration e = h.keys(); e.hasMoreElements();){
			retList[j] = (String) e.nextElement();
			j++;
		}
		return retList;
	}

	public void updateBlkAc(Connection myConn) throws Exception{
		if (getCboBlkAc() == null){
			return;
		}
		String[] tctoList = getHdnTcto();
		if (tctoList == null){
			/* handled in javascript.
			   now handled in jsp, button will not show up if no tctos.
			setErrorMsg("Cannot update selected aircraft w/o associated tctos in list");
			*/
			return;
		}
			/*
			 filter those in other blks that have actual comp date.
			 filter choice:
			 all or nothing for tctolist relation to tail_no to block.
			 if one ac is not acceptable, don't update block for all tctos
			 for the one ac.  otherwise, the reporting of effective
			 aircraft would be misleading.	
			*/
		try {
			Hashtable acChosen = filterAcChosenList(myConn, tctoList, getCboBlkAc());
			if (acChosen.isEmpty()){
				return;
			}
				// get current ac list from db for block
			Hashtable acCurrent = getCurrentAc(myConn, getCboBlk()); 
				// new ac relative to acCurrent
			Hashtable newAc = getDiff(acCurrent, acChosen);
				// deleted ac relative to acCurrent
			Hashtable delAc = getDiff(acChosen, acCurrent);
			if (!delAc.isEmpty())
				delFromRetroScheds(myConn, getCboBlk(), hashToStringArray(delAc));
			if (!newAc.isEmpty())
				updateRetroScheds(myConn, getCboBlk(), hashToStringArray(newAc), tctoList);
		}catch (Exception e){
			setErrorMsg("System problem updating blk: " + e.toString());
			throw e;
		}
	}

	public boolean hashKeysEqual(Hashtable aList, Hashtable bList) throws Exception{
		boolean retBool = false;
		Hashtable newAc = getDiff(aList, bList);
		Hashtable delAc = getDiff(bList, aList);
		if (delAc.isEmpty() && newAc.isEmpty()){
			retBool = true;
		}
		return retBool;
	}

	public Hashtable getDiff(Hashtable baseList, Hashtable newList) throws Exception{
		Hashtable retHash = new Hashtable();
		for (Enumeration e = newList.keys(); e.hasMoreElements();){
			String el = (String) e.nextElement();
			if (!baseList.containsKey(el)){
				retHash.put(el, "");
			}
		}
		return retHash;
	}
	public Hashtable getCurrentAc(Connection myConn, String blk) throws Exception{
		Hashtable ac = new Hashtable();
		String sqlString = "select distinct tail_no " +
				   "from amd_retrofit_schedules where block_name=\'" + blk + "\'";
		setDebugMsg(sqlString);
		Statement stmt = null;
		try{
			stmt = myConn.createStatement();
			ResultSet rs = stmt.executeQuery(sqlString);
			while (rs.next()){
				ac.put(rs.getString("tail_no"), "");
			}
		}catch (Exception e){
			setErrorMsg("System problem trying to retrieve current aircraft for block " + blk + ";" + e.toString());
			throw e;
		}finally{
			stmt.close();
		}
		return ac;
	}

	public String reportCboBlk(Connection myConn) throws Exception{
		StringBuffer retStr = new StringBuffer("");
		String blkSelected = getCboBlk();
		String sqlString = "select block_name, block_desc from amd_retrofit_sched_blocks order by block_name";
		setDebugMsg(sqlString);
		boolean selectedFound = false;
		Statement stmt = null;
		try {
			stmt = myConn.createStatement();
			String selected = "";
			ResultSet rs = stmt.executeQuery(sqlString);
			while (rs.next()) {
				String blockName = rs.getString("block_name");
				String blockDesc = rs.getString("block_desc");
				selected = "";
				if (blockName.equals(blkSelected)){
					selected = " selected";
					selectedFound = true;
					setTxtBlk(blockName);
					setTxtBlkDesc(blockDesc);
				}
				String blkInfo = blockName + " [" + blockDesc;
				retStr.append("<option" + selected + " value=\"" + blockName + "\">" + 
				blkInfo.substring(0, getLowest(blkInfo.length(), getDescDisplayLength())) + "]</option>");
			}
		}catch (Exception e){
			setErrorMsg("System problem reporting blk choices: " + e.toString());
		}finally{
			stmt.close();
		}
		if (!selectedFound){
			retStr.append("<option selected value=\"default\">" + "-- choose block --" + "</option>");	
		}
		return retStr.toString();
	}
	public void reportAcDisplay() throws Exception{
		acDisplay.genHtml();
	}
	public String reportCboBlkAc(Connection myConn) throws Exception{
		StringBuffer retStr = new StringBuffer("");
		String blk = getCboBlk();
		String acField = getAcBy();
		String acFieldSql = acField;
		if (acField.equals("tail_no")){
			acFieldSql = "aa.tail_no"; 
		}
		String sqlString = "select distinct " + acFieldSql + ", aa.tail_no as tailNo, block_name from amd_aircrafts aa, amd_retrofit_schedules ars where block_name (+) = \'" + blk + "\' and aa.tail_no = ars.tail_no (+) and p_no != \'DUM\' order by " + acFieldSql;
		setDebugMsg(sqlString);
		Statement stmt = null;
		try {
			stmt = myConn.createStatement();
			String selected = "";
			ResultSet rs = stmt.executeQuery(sqlString);
			while (rs.next()) {
				String tailNo = rs.getString("tailNo");
				String blockName = rs.getString("block_name");
				String ac = rs.getString(acField);
				selected = "";
				if (blockName != null){
					selected = " selected";
				}
				retStr.append("<option" + selected + " value=\"" + tailNo + "\">" + ac + "</option>");
			}
		}catch (Exception e){
			setErrorMsg("System problem when report blk ac: " + e.toString());
		}finally {
			stmt.close();
		}
		return retStr.toString();
	}
	public String reportCboTcto(Connection myConn) throws Exception{
		StringBuffer retStr = new StringBuffer("");
		String sqlString = "select distinct at.tcto_number, tcto_desc from amd_retrofit_tctos at, amd_retrofit_schedules ars where at.tcto_number=ars.tcto_number order by at.tcto_number";
		setDebugMsg(sqlString);
		boolean selectedFound = false;
		Statement stmt = null;
		try {
			stmt = myConn.createStatement();
			String tctoSelected = getCboTcto();
			String selected = "";
			ResultSet rs = stmt.executeQuery(sqlString);
			while (rs.next()){
				String tctoNumber = rs.getString("tcto_number");
				String tctoDesc = rs.getString("tcto_desc");
				selected = "";
				if (tctoSelected.equals(tctoNumber)){
					selectedFound = true;
					selected = " selected";
				}
				String tctoInfo = tctoNumber + " [" + tctoDesc;
				retStr.append("<option" + selected + " value=\"" + tctoNumber  + "\">" +  
				tctoInfo.substring(0, getLowest(tctoInfo.length(), getDescDisplayLength())) + "] </option>");
			}
		}catch (Exception e) {
			setErrorMsg("System problem when report cbo tcto: " + e.toString());
		}finally {
			stmt.close();
		}
		if (!selectedFound){
			retStr.append("<option selected value=\"default\">-- select tcto to add--</option>");
		}
		return retStr.toString();
	}
	public String reportTctoList(Connection myConn) throws Exception{
		StringBuffer ret = new StringBuffer("");
		String blk = getCboBlk();
		if (blk.equals("default")){
			return "";
		}
		String sqlString = "select distinct at.tcto_number, tcto_desc from amd_retrofit_schedules ars, amd_retrofit_tctos at where ars.tcto_number = at.tcto_number and ars.block_name =\'" + blk + "\'" ; 
		setDebugMsg(sqlString);
		try {
			Statement stmt = myConn.createStatement();
			ResultSet rs = stmt.executeQuery(sqlString);
			while (rs.next()){
				String tctoNumber = rs.getString("tcto_number");
				String tctoDesc = rs.getString("tcto_desc");
				ret.append("<tr><td valign=\"top\"><input type=\"checkbox\" name=\"chkTcto\" value=\"" + tctoNumber + "\"></td>");
				ret.append("<td valign=\"top\">" + Helper.input("hidden", "hdnTcto", tctoNumber) + tctoNumber + "</td>");
				ret.append("<td valign=\"top\">" + tctoDesc + "</td></tr>");
			}
			setChkTcto(null);
		}catch (Exception e){
			setErrorMsg("System error trying to report tcto table: " + e.toString()); 
		}finally{
			return ret.toString();	
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
