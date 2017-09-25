//	SCCSID: %M% %I% Modified: %G% %U%
//	Date      By            History
//      05/28/02  kcs	    	Initial
package retrofit;
import java.io.*;
import java.util.*;
import java.sql.*;
import javax.servlet.jsp.*;
import org.apache.regexp.RE;

public class DefaultCompRateBean {
	private int descDisplayLength;
	private static final int DEFAULTLENGTH = 80;
	private static final int DBMAXLENGTH = 512;
	private String hdnEvent;
	private String[] cboTcto;
	private String[] hdnTcto;
	private String[] txtUserDefault;
	private String txtGlobal;
	private StringBuffer errorMsg;
	private StringBuffer debugMsg;
	private StringBuffer warnMsg;
	private String sessionUser;
	private String chkAll;
	private JspWriter out; 
	private String space;
	public boolean debugOn = false;
	
	public DefaultCompRateBean(){
		setHdnEvent("none");
		space = "  ";
		debugMsg = new StringBuffer("");
		warnMsg = new StringBuffer("");
		errorMsg = new StringBuffer("");
		descDisplayLength = DEFAULTLENGTH;
	}
	public void setSessionUser(String sessionUser){
		this.sessionUser = sessionUser;
	}
	public void setHdnEvent(String hdnEvent){
		this.hdnEvent = hdnEvent;
	}
	public String getHdnEvent(){
		return hdnEvent;
	}
	public void setTxtUserDefault(String[] txtUserDefault){
		this.txtUserDefault = txtUserDefault;
	}
	public String[] getTxtUserDefault(){
		return txtUserDefault;
	}
	public void setChkAll(String chkAll){
		this.chkAll= chkAll;
	}
	public String getChkAll(){
		return chkAll;
	}
	public void setTxtGlobal(String txtGlobal){
		this.txtGlobal= txtGlobal;
	}
	public String getTxtGlobal(){
		return txtGlobal;
	}
	public void setCboTcto(String[] cboTcto){
		this.cboTcto= cboTcto;
	}
	public String[] getCboTcto(){
		return cboTcto;
	}
	public void setHdnTcto(String[] hdnTcto){
		this.hdnTcto= hdnTcto;
	}
	public String[] getHdnTcto(){
		return hdnTcto;
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
	public void setDebugOn(boolean in){
		debugOn = in;
	}
	public boolean getDebugOn(){
		return debugOn;
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
	public JspWriter getOut(){
		return out;
	}
	public void setOut(JspWriter out){
		this.out = out;
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
		if (x < y){
			return x;
		}else {
			return y;
		}
	}
// ##########################
	public void processEvents(Connection myConn) throws Exception{
		setErrorMsg("");
		setWarnMsg("");
		setDebugMsg("");
		if (getHdnEvent().equals("update")){
			setGlobalDefault(myConn);
			update(myConn);
		}
		if (chkAll != null && chkAll.equals("on")){
			updateAll(myConn);
		}
	}
	public void reportTcto(Connection myConn) throws Exception{
		String sqlString = "select tcto_number, tcto_desc from amd_retrofit_tctos order by tcto_number";
		Statement stmt = null;
		setDebugMsg(sqlString);
		try {
			stmt = myConn.createStatement();
			ResultSet rs = stmt.executeQuery(sqlString);
			while(rs.next()){
				String tctoNum = rs.getString("tcto_number");
				String tctoDesc = rs.getString("tcto_desc");
				String tctoInfo = tctoNum + space + tctoDesc;				
				out.println("<option value=\"" + tctoNum  + "\">" + 
				tctoInfo.substring(0, getLowest(tctoInfo.length(), getDescDisplayLength())) + "</option>");
			}
			stmt.close();
		}catch (Exception e){
			stmt.close();
			setErrorMsg("System problem reporting tcto: " + e.toString());
		}
	}

	public void setGlobalDefault(Connection myConn) throws Exception{
		String amuGlobal = getTxtGlobal();
		String sqlString = "update amd_param_changes set param_value=to_number(" + amuGlobal + "), effective_date = sysdate, user_id=\'" + sessionUser + "\' where param_key=\'avg_monthly_upgrade\'";
		Statement stmt = null;
		try {
			stmt = myConn.createStatement();
			stmt.executeUpdate(sqlString);
		}catch (Exception e){
			setErrorMsg("System problem setting global default");
		}finally{
			stmt.close();
		}
	}

	public String getGlobalDefault(Connection myConn) throws Exception{
		String sqlDefault = "select param_value from amd_param_changes where param_key=\'avg_monthly_upgrade\'";
		Statement stmt = null;
		String amuGlobal = null;
		try {
			stmt = myConn.createStatement();
			ResultSet rs = stmt.executeQuery(sqlDefault);
			while(rs.next()){
				amuGlobal = rs.getString("param_value"); 
			}
			java.lang.Float.valueOf(amuGlobal);
		}catch (NumberFormatException n){
			setErrorMsg("System problem: default from amd_param_changes, value avg_monthly_upgrade, not a number"); 
			throw n;
		}catch (NullPointerException b){
			setErrorMsg("System problem: default from amd_param_changes, value avg_monthly_upgrade, is null");
			throw b; 
		}catch (Exception e){
			setErrorMsg("System problem getting default value for burn rate");
			throw e;
		}finally {
			if (stmt != null)
				stmt.close();
		}
		return amuGlobal;
	}

	public String reportSelectedTcto(Connection myConn) throws Exception{
		String amuGlobal = null;
		try {
			amuGlobal = getGlobalDefault(myConn);
		}catch (Exception e){
			throw e;
		}
		StringBuffer sqlString = new StringBuffer("select tcto_number, tcto_desc, avg_monthly_upgrade from amd_retrofit_tctos");
		Statement stmt = null;
		StringBuffer retString = new StringBuffer("");
		String[] tctoList =  getCboTcto();
		if (tctoList == null){
			return "";
		}
		sqlString.append(" where tcto_number in ("); 
		for (int i=0; i < tctoList.length; i++){
			sqlString.append("\'" + tctoList[i] + "\',");  
		}
		sqlString.setLength(sqlString.length() - 1);
		sqlString.append(")");
		setDebugMsg(sqlString.toString());
		try {
			stmt = myConn.createStatement();
			ResultSet rs = stmt.executeQuery(sqlString.toString());
			while(rs.next()){
				String tctoNum = rs.getString("tcto_number");
				String tctoDesc = rs.getString("tcto_desc");
				String amu = rs.getString("avg_monthly_upgrade");
				String yesOrNo = "";
				if (amu == null){
					yesOrNo = "yes - " + amuGlobal;
				}else {
					yesOrNo = "no";
				}
				retString.append("<tr><td valign=\"top\">" + tctoNum + "</td><td valign=\"top\">" + tctoDesc + "</td><td valign=\"top\">" + 
				Helper.input("hidden", "hdnTcto", tctoNum) +
				Helper.input("text", "txtUserDefault", amu) + "</td><td valign=\"top\">" + yesOrNo +  
				"&nbsp;</td></tr>\n");
			}
			stmt.close();
		}catch (Exception e){
			stmt.close();
			setErrorMsg("System problem reporting selected tcto: " + e.toString());
			throw e;
		}
		return retString.toString();
	}
	public void updateAll(Connection myConn) throws Exception{
		String sqlString = "update amd_retrofit_tctos set avg_monthly_upgrade=null";
		Statement stmt = null;
		try{
			stmt = myConn.createStatement();
			stmt.executeUpdate(sqlString);
		}catch (Exception e){
			setErrorMsg("System problem trying to update ALL defaults");
		}finally{
			stmt.close();
		}
	}
	public void update(Connection myConn) throws Exception{
		String[] tcto = getHdnTcto();
		String[] txtUser= getTxtUserDefault();
		if (tcto == null){
			return;
		}
		if (txtUser == null){
			setErrorMsg("System problem: user info is null");
			return;
		}
		Statement stmt = null;
		for (int i=0; i < tcto.length; i++){
			try {
				String userInfo = "";
				if (txtUser[i] == null || txtUser[i].equals("")){
					userInfo = null;
				}else{
					Float.valueOf(txtUser[i]);
					userInfo = "to_number(" + txtUser[i] + ")";
				}
				String sqlString = "update amd_retrofit_tctos set avg_monthly_upgrade=" + userInfo + " where tcto_number=\'" + tcto[i] + "\'";	
				stmt = myConn.createStatement();
				stmt.executeUpdate(sqlString);
			}catch (Exception e) {
				setErrorMsg("System problem updating for tcto &lt;" + tcto[i] + "&gt; value &lt;" + txtUser[i] + "&gt; " + " message " + e.toString());
			}finally{
				if (stmt != null)
					stmt.close();	
			}
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






