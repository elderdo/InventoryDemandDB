//	SCCSID: %M% %I% Modified: %G% %U%
//	Date      By            History
//      05/28/02  kcs	    	Initial
//	09/30/02  kcs		add js calendar and change to order by tcto number for tcto
//		PVCS
//	10/17/02  kcs		resolve "array" problem with javascript
//	$Revision:   1.2  $
//	$Author:   c378632  $
//	$Workfile:   SchedByAcBean.java  $
package retrofit;
import java.io.*;
import java.util.*;
import java.sql.*;
import javax.servlet.jsp.*;
import effectivity.*;
import org.apache.regexp.RE;
public class SchedByAcBean {
	private static final int DEFAULTLENGTH = 80;	
	private static final String calImage = "<img src=\"images/show-calendar.gif\">";
	private int descDisplayLength;
	private String optSearchBy;
	private String cbo;		
	private String[] txtAcScd;
	private String[] txtAcAcd;
	private String[] hdnAcList;
	private String[] hdnAcViewList;
	private String hdnAction;
	private JspWriter out;
	private StringBuffer errorMsg;	
	private String warnMsg;	
	private StringBuffer debugMsg;
	private effectivity.AcDisplayCntl acDisplay;
	private boolean debugOn;
	public SchedByAcBean(){
		setHdnAction("none");
		setCbo("default");
		setOptSearchBy("tcto");
		debugMsg = new StringBuffer("");
		errorMsg = new StringBuffer("");
		acDisplay = new effectivity.AcDisplayCntl();
		acDisplay.setOnChange("processEvent(\'acDisplay\')");
		setDescDisplayLength(DEFAULTLENGTH);
		debugOn = false;
	}
	public boolean getDebugOn(){
		return debugOn;
	}
	public void setDebugOn(boolean in){
		debugOn = in;
	}
	public void setWarnMsg(String warnMsg){
		this.warnMsg = warnMsg;
	}
	public String getWarnMsg(){
		return warnMsg;
	}
	public void setDebugMsg(String debugMsg){
		if (getDebugOn()){
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
	public void setAcBy(String acBy){
		setErrorMsg("setAcBy:" + acBy);
		this.acDisplay.setBy(acBy);	
	}
	public String getAcBy(){
		return acDisplay.getBy();
	}
	public void setOut (JspWriter out){
		this.out = out;
		acDisplay.setOut(out);
	}
	public JspWriter getOut(){
		return out;
	}
	public void setHdnAction(String hdnAction){
		this.hdnAction = hdnAction;
	}
	public String getHdnAction(){
		return hdnAction;
	}
	public void setOptSearchBy(String optSearchBy){
		this.optSearchBy = optSearchBy;
	}
	public String getOptSearchBy(){
		return optSearchBy;
	}
	public void setCbo(String cbo){
		this.cbo = cbo;
	}
	public String getCbo(){
		return cbo;
	}
	public void setHdnAcViewList(String[] hdnAcViewList){
		this.hdnAcViewList = hdnAcViewList;
	}
	public String[] getHdnAcViewList(){
		return hdnAcViewList;
	}
	public void setHdnAcList(String[] hdnAcList){
		this.hdnAcList = hdnAcList;
	}
	public String[] getHdnAcList(){
		return hdnAcList;
	}
	public void setTxtAcScd(String[] txtAcScd){
		this.txtAcScd = txtAcScd;
	}
	public String[] getTxtAcScd(){
		return txtAcScd;
	}
	public void setTxtAcAcd(String[] txtAcAcd){
		this.txtAcAcd = txtAcAcd;
	}
	public String[] getTxtAcAcd(){
		return txtAcAcd;
	}
	public String isChecked(String inString){
		if (getOptSearchBy().equals(inString)){
			return " checked=\"yes\"";
		}else{
			return "";
		}
	}
	public String getErrorMsg(){
		return errorMsg.toString();
	}
	public void setErrorMsg(String errorMsg){
		if (errorMsg.equals("")){
			this.errorMsg.setLength(0);
		}else{
			this.errorMsg.append(errorMsg + "<br>");
		}
	}
	public int getLowest(int x, int y){
		if (x <= y){
			return x;
		}else{
			return y;
		}
	}
	public String nvl(String inString, String defaultStr){
		if (inString == null){
			return defaultStr;
		}else{
			return inString;
		}
	}
	public void setDescDisplayLength(int dl){
		descDisplayLength = dl;
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

	public void reportAcDisplay(){
		try {
			acDisplay.genHtml();
		}catch (Exception e){
			setErrorMsg("System problem reporting acDisplay: " + e.getMessage());
		}
	}

	public String getTHeadSched(){
		StringBuffer baseHead = new StringBuffer("<tr><td width=\"20%\" valign=\"TOP\"><b>Aircraft</b></td><td valign=\"TOP\"><b>Scheduled&nbsp;Comp&nbsp;Date&nbsp;*</b></td><td valign=\"TOP\"><b>Actual&nbsp;Comp&nbsp;Date&nbsp;*</b></td>");
		if (getOptSearchBy().equals("tcto")){
			baseHead.append("<td valign=\"TOP\"><b>Block Association</b></td>");
		}
		return (baseHead.toString() + "</tr>");
	}
	public String reportAcSched(Connection myConn) throws Exception{
		if (getCbo().equals("default")){
			return null;
		}
		String blockOrTcto = "";
		if (getOptSearchBy().equals("block")){
			blockOrTcto = "block_name";	
		}else{
			blockOrTcto = "tcto_number";	
		}
		StringBuffer dateList = new StringBuffer("");
		String acFieldSql = getAcBy();
		String acField = null;
		if (acFieldSql.equals("tail_no")){
			acFieldSql = "aa.tail_no";
			acField = "tail_no";
		}else{
			acField = acFieldSql;
		}
		String sqlString = "select distinct block_name," + acFieldSql + ", ars.tail_no as tailNo, to_char(scheduled_complete_date, \'MM/DD/YY\') as scheduled_complete_date, to_char(actual_complete_date, \'MM/DD/YY\') as actual_complete_date " + " from amd_retrofit_schedules ars, amd_aircrafts aa where " + blockOrTcto + "=\'" + getCbo() + "\' and aa.tail_no = ars.tail_no order by " + acFieldSql;	
		setDebugMsg(sqlString);
		Statement stmt = null;
		boolean conflictingDates = false;
		int i = 0;
		try {
			stmt = myConn.createStatement(); 
			ResultSet rs = stmt.executeQuery(sqlString);
			String previousAc = "";
			while (rs.next()) {
				String blockName = rs.getString("block_name");
				String ac = rs.getString(acField);
				String tailNo = rs.getString("tailNo");
				String scd = rs.getString("scheduled_complete_date");
				String acd = rs.getString("actual_complete_date");
				if (!ac.equals(previousAc)){
					dateList.append("<tr>" + Helper.tCol(Helper.input("hidden", "hdnAcList", tailNo) + Helper.input("hidden", "hdnAcViewList", ac) + ac) + Helper.tCol(Helper.input("text", "txtAcScd", "", "10") + "<a href=\"javascript:show_calendar('schedByAcForm.txtAcScd[" + i + "]')\">" + calImage + "</a>" + "&nbsp;&nbsp;&nbsp;" + nvl(scd, "n/a") + "&nbsp;&nbsp;&nbsp;" + Helper.input("hidden", "hdnDbScd", scd)) + Helper.tCol(Helper.input("text", "txtAcAcd", "", "10") + Helper.input("hidden", "hdnDbAcd", nvl(acd, "")) + "<a href=\"javascript:show_calendar('schedByAcForm.txtAcAcd[" + i + "]')\">" + calImage + "</a>" + "&nbsp;&nbsp;&nbsp;" + nvl(acd, "n/a") + "&nbsp;&nbsp;&nbsp;" )); 
					if (blockOrTcto.equals("tcto_number")){
						dateList.append(Helper.tCol(Helper.input("hidden", "hdnBlk", nvl(blockName, "")) + "&nbsp;&nbsp;&nbsp;" + nvl(blockName, "n/a")));
					}
				}else{
					//distinct in query will not rule out same a/c different dates
					//should not happen anymore thru front door
					conflictingDates = true;
				}
				dateList.append("\n");
				previousAc = ac;
				i++;
			}
			rs.close();
		}catch (SQLException e){
			setErrorMsg("System problem reporting ac sched: " + e.getMessage());
		}finally {
			stmt.close();
		}
		if (conflictingDates){
			setErrorMsg("Problem with conflicting dates - please contact system owner"); 
		}
			// variable is array and can be subscripted if multi.  if just one record
			// browser will not like subscript [0] 
			// instead of generating an extra query to count, just string substitute index use
			// after the fact
		String retStr = null;
		setDebugMsg("i: " + i);
		if (i == 1) {
			setDebugMsg("inside regular expression");
			RE re = new RE("txtAcScd\\[0\\]");
			retStr = dateList.toString();
			retStr = re.subst(retStr, "txtAcScd");
			re = new RE("txtAcAcd\\[0\\]");
			retStr = re.subst(retStr, "txtAcAcd");
			return retStr;
		}else {
			return dateList.toString();
		}
	}
	public String reportCboTctoBlk(Connection myConn) throws Exception{
		StringBuffer retStr = new StringBuffer("");
		String sqlString = "";
		String fieldName = "";
		String fieldDesc = "";
		if (getOptSearchBy().equals("block")){
			sqlString = "select block_name, block_desc from amd_retrofit_sched_blocks order by block_name";
			fieldName = "block_name";
			fieldDesc = "block_desc";
		}else{
			sqlString = "select tcto_number, tcto_desc from amd_retrofit_tctos order by tcto_number"; 
			fieldName = "tcto_number";
			fieldDesc = "tcto_desc";
		}
		Statement stmt = null;
		setDebugMsg(sqlString);
		try {
			stmt = myConn.createStatement(); 
			ResultSet rs = stmt.executeQuery(sqlString);
			if (getCbo().equals("default")){
				retStr.append("<option selected value=\"default\">-- choose " +  getOptSearchBy() + "--</option>");
			}
			while (rs.next()) {
				String name = rs.getString(fieldName);
				String desc = rs.getString(fieldDesc);
				String selected = "";
				if (getCbo().equals(name)){
					selected = " selected";
				}
				String info = name + " [" + desc;
				retStr.append("<option" + selected + " value=\"" + name + "\">" + 
				info.substring(0, getLowest(info.length(), getDescDisplayLength())) + "] </option>");

			}
			rs.close();
		}catch (SQLException e){
			setErrorMsg("System problem reporting ac sched: " + e.getMessage());
		}finally {
			stmt.close();
		}
		return retStr.toString();
	}
	public void processDbActions(Connection myConn) throws Exception{
			//mostly updating db
		try {
			setDebugMsg("");
			setWarnMsg("");
			setErrorMsg("");
			if (getHdnAction().equals("radio")){
				setCbo("default");
				setTxtAcAcd(null);
				setTxtAcScd(null);
				setHdnAcList(null);
			}else if (getHdnAction().equals("update")){
				updateDates(myConn);
			}
		}catch (Exception e){
			//setErrorMsg(e.getMessage());
		}
	}

	public boolean assignedLocForTailAndDate(Connection myConn, String tail, String inDate) throws Exception{
		CallableStatement cStmt = null;
		boolean retBool = true;
		try {		
			cStmt = myConn.prepareCall("{? = call amd_effectivity_tcto_pkg.getAcAssignLocSid(?,?)}");
			java.text.SimpleDateFormat f = new java.text.SimpleDateFormat("MM/dd/yyyy");
			java.sql.Date sqlDate = new java.sql.Date(f.parse(inDate).getTime());
			cStmt.registerOutParameter(1, java.sql.Types.INTEGER);
			cStmt.setString(2, tail);
			cStmt.setDate(3, sqlDate);
			setDebugMsg("tailAssign " + inDate + " : " +  sqlDate.toString() );
			cStmt.execute();
		}catch (SQLException e){
			setDebugMsg("tailAssign error caught: " + e.getErrorCode() + ":" + e.toString()); 
			if (e.getErrorCode() == exceptions.OracleErrorCode.NO_DATA_FOUND){
				retBool = false;
			}else{
				setErrorMsg("System problem getting location: " + e.toString());
				throw e;
			}
		}finally{
			cStmt.close();
		}
		return retBool;
	}

	public ArrayList getNsiGroupSidsForTctoParts(Connection myConn, String pFieldName, String pFieldValue) throws Exception{
		String sqlString = "";
		if ((pFieldName.toLowerCase()).equals("block_name")){
			sqlString = 	"select distinct nsi_group_sid " +
					"from amd_national_stock_items ansi, amd_related_nsi_pairs arnp " +
					"where ansi.nsi_sid = arnp.replaced_by_nsi_sid and " +
					"tcto_number in (select distinct tcto_number from amd_retrofit_schedules " +
					"		where block_name=\'" + pFieldValue + "\')"; 	 
		}else{
			sqlString = 	"select distinct nsi_group_sid " +
					"from amd_national_stock_items ansi, amd_related_nsi_pairs arnp " +
					"where ansi.nsi_sid = arnp.replaced_by_nsi_sid and tcto_number=\'" + pFieldValue + "\'";

		}
		ArrayList retList = null;
		setDebugMsg(sqlString);
		Statement stmt = null;
		try {
			stmt = myConn.createStatement(); 
			ResultSet rs = stmt.executeQuery(sqlString);
			retList = new ArrayList();
			while (rs.next()) {
				retList.add(rs.getString("nsi_group_sid"));
			}
		}catch (Exception e){
			throw e;
		}finally{
			stmt.close();
		}
		return retList;
	}

	public void updateDates(Connection myConn) throws Exception{
			//skip null dates for update
		String[] ac = getHdnAcList();
		String[] acView = getHdnAcViewList();
		if (ac == null){
			return;
		}
		String sqlString = "";
		String fieldName = "";
		String[] scd = getTxtAcScd();
		String[] acd = getTxtAcAcd();
		String scdSql= null;
		String acdSql= null;
		if (getOptSearchBy().equals("block")){
			fieldName = "block_name";
		}else{
			fieldName = "tcto_number";
		}
		Statement stmt = null;
		CallableStatement cStmt = null;
		/* commit put here for procedure call which will rollback on failure */
		myConn.commit();
		boolean prevAutoCommit = myConn.getAutoCommit();
		myConn.setAutoCommit(false);
		for (int i=0; i < ac.length; i++){
			String comma = "";
			if (scd[i] == null || scd[i].equals("")){
				scdSql = "";
			}else{
				if (assignedLocForTailAndDate(myConn, ac[i], scd[i])){
					scdSql =  " scheduled_complete_date=TO_DATE(\'" + scd[i] + "\', 'MM/DD/RR\') ";
				}else{
					setWarnMsg("ac " + acView[i] + " sched date " + scd[i] + " not processed - aircraft not assigned a location for that date");
				}
			}
			if (acd[i] == null || acd[i].equals("")) {
				acdSql = "";
			}else{
				if (assignedLocForTailAndDate(myConn, ac[i], acd[i])){
					acdSql = " actual_complete_date=TO_DATE(\'" + acd[i] + "\', 'MM/DD/RR\') ";
				}else{
					setWarnMsg("ac " + acView[i] + " actual date " + acd[i] + " not processed - aircraft not assigned a location for that date");
				}
			}
			if ( !(scdSql.equals("") && acdSql.equals("")) ){
				if (!scdSql.equals("") && !acdSql.equals(""))
					comma = ",";  
				try {
					sqlString = "update amd_retrofit_schedules set " + scdSql + comma + acdSql 
					+ " where " + fieldName + "=\'" + getCbo() + "\' and tail_no=\'" + ac[i] + "\'";		
					setDebugMsg(sqlString);
					try {
						stmt = myConn.createStatement(); 
						stmt.executeUpdate(sqlString);
					}catch (Exception eARS){
						setErrorMsg("System problem updating retrofit schedules: " + eARS.toString());
						throw eARS;
					}
				/* chose to put procedure here as opposed to trigger to catch error, and be 
				   able to rollback above on failure */
					if (!acdSql.equals("")){
						cStmt = myConn.prepareCall("{call amd_effectivity_tcto_pkg.updateAsFlyAsCapable(?,?,?,?)}");
						cStmt.setString(1, fieldName);
						cStmt.setString(2, getCbo());
						cStmt.setString(3, ac[i]);
						// javascript passes 4 digit year
						// for 2 digit years, "RR" logic for oracle different than java.
						// javascript handles RR logic too. 
						java.text.SimpleDateFormat f = new java.text.SimpleDateFormat("MM/dd/yyyy");
						java.sql.Date sqlDate = new java.sql.Date(f.parse(acd[i]).getTime());
						cStmt.setDate(4, sqlDate);
						setDebugMsg( sqlDate.toString() );
						cStmt.executeUpdate();
						ArrayList nsiGroupSidList = getNsiGroupSidsForTctoParts(myConn, fieldName, getCbo());
						// 	
						//	pruneAsCapable will handle as capable 
						//	taking into account all parts in the group.
						//	
						try {
							effectivity.AmdUtils.setConnection(myConn);
							for (int j=0; j < nsiGroupSidList.size(); j++){
								effectivity.AmdUtils.pruneAsCapable( Integer.parseInt((String) nsiGroupSidList.get(j)));
								setDebugMsg("nsiGroupSid:" + sqlString);
							}
						}catch (Exception eP){
							setErrorMsg("System problem pruning: " + eP.toString());
							throw eP;
						}
					}
				}catch (SQLException e){
					if (e.getErrorCode() == exceptions.OracleErrorCode.NO_DATA_FOUND){
						setErrorMsg("TCTO (or TCTO in block) missing nsn pair definition, not appropriate to set an actual complete date - please correct appropriate TCTO(s)");
					}else{
						setErrorMsg("System problem updating dates: (" + fieldName + "," + getCbo() + "," + ac[i] + ") " + e.toString());
					}
					myConn.rollback();
				}finally{
					if (stmt != null)
						stmt.close();
					if (cStmt != null)
						cStmt.close();
					myConn.commit();
				}
			}
		} 			
		myConn.setAutoCommit(prevAutoCommit);
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
