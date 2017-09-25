package Substitution;
/*
 *  $Revision:   1.6  $
 *  $Author:   c402417  $
 *  $Workfile:   ControlerSub.java  $
 *  $Log:   \\www-amssc-01\pds\archives\SDS-AMD\Components-ClientServer\AmdConfig\Substitution\ControlerSub.java-arc  $
/*
/*   Rev 1.6   24 Sep 2002 16:28:36   c402417
/*check the file back in, no change
/*
/*   Rev 1.5   04 Sep 2002 14:06:20   c970183
/*Fixed typo
/*
/*   Rev 1.4   04 Sep 2002 13:58:52   c970183
/*Removed System.out and replaced with logger.........
/*
/*   Rev 1.3   04 Sep 2002 13:30:46   c970183
/*Added get methods for PVCS revision variables.
 *  *
 *  *   Rev 1.2   04 Sep 2002 12:17:16   c970183
 *  *Fixed Keywords at top of class
 *
 *  Rev 1.1   04 Sep 2002 12:06:04   c970183
 *  Moved check for adding a part as a component of itself.
 */
import Configuration.AmdDB;
import Configuration.NavBar;
import coreservlets.*;
import java.sql.*;
import java.text.*;
import java.util.*;
import javax.servlet.http.*;
import javax.servlet.jsp.*;
import org.apache.log4j.Logger;
import org.apache.regexp.RE;

/**
 *  Description of the Class
 *
 *@author     c970183
 *@created    June 26, 2002
 */
public class ControlerSub {
	private String aircraft[];
	private String aircraftHtml;
	private String chkEquivalentNsns;
	private Connection conn;
	private String equiNomenclature;
	private String equiNsiSid;
	private String equiNsn;
	private String equiNsnVpn;
	private String equiPartNo;
	private String equiPlannerCode;
	private String equiSearchBy;
	private EquivalentNsn equivalentNsn;
	private NavBar equivalentNsnSearch;
	private boolean errorOccured = false;

	private String gotoBottom;

	private String lastElement;
	private String latestConfig;

	private Msg msg = new Msg();
	private WorkingSet myWorkingSet;
	private String nsiSid;
	private String nsn;
	private String nsnVpn;
	private JspWriter out;
	private PageContext pageContext;
	private String partNo;
	private String plannerCode;
	private String predefinedFleetSizeHtml;
	private HttpServletRequest request;
	private HttpServletResponse response;
	private String search;
	private String searchBy;
	private HttpSession session;
	private String startDate;
	private String strNsnSidAndNsn;
	private String theAction;
	private NavBar topNavBar;
	private EquivalentNsn topNsn;
	private boolean usePredefinedFleetSize;
	private String userid;
	private String views[];
	private static String author = "$Author:   c402417  $";
	private static Logger logger = Logger.getLogger(ControlerSub.class.getName());

	private static String revision = "$Revision:   1.6  $";
	private static String workfile = "$Workfile:   ControlerSub.java  $";
	/**
	 *  Description of the Field
	 */
	public final static String ACTION_ADD = "A";
	/**
	 *  Description of the Field
	 */
	public final static String ACTION_REMOVE = "R";
	/**
	 *  Description of the Field
	 */
	public final static String ACTION_SELECT_EQUI_NSN = "D";
	/**
	 *  Description of the Field
	 */
	public final static String ACTION_SELECT_EQUI_PLANNER = "SELEQUIPLANNER";
	/**
	 *  Description of the Field
	 */
	public final static String ACTION_SELECT_RELATED_NSN = "D";
	private final static String BOTTOM_OF_PAGE = "#Bottom";
	/**
	 *  Description of the Field
	 */
	public final static String BY_NSN = "byNsn";
	/**
	 *  Description of the Field
	 */
	public final static String BY_VPN = "byVpn";
	private final static String EQUIVALENT_NSN_COMBO_BOX = "cboEquiNsn";

	/**
	 *  Description of the Field
	 */
	public final static String FORM_NAME = "TheForm";
	/**
	 *  Description of the Field
	 */
	public final static String NO_SELECTION = "-None-";
	/**
	 *  Description of the Field
	 */
	public final static String SEARCH_BY_NSN = "4";
	/**
	 *  Description of the Field
	 */
	public final static String SEARCH_BY_PLANNER = "3";
	/**
	 *  Description of the Field
	 */
	public final static String SEARCH_WITH_EQUI_NAVBAR = "2";
	/**
	 *  Description of the Field
	 */
	public final static String SEARCH_WITH_TOP_NAVBAR = "1";
	private final static String START_EQUIVALENT_NSNS = "#EquivalentNsns";


	/**
	 *  Sets the conn attribute of the ControlerSub object
	 *
	 *@param  conn                       The new conn value
	 *@exception  java.io.IOException    Description of the Exception
	 *@exception  java.sql.SQLException  Description of the Exception
	 */
	public void setConn(Connection conn) throws java.io.IOException, java.sql.SQLException {
		this.conn = conn;
		if (this.conn.isClosed()) {
			if (out != null) {
				out.println("Database connection is closed: notify application support.");
			}
			System.err.println("Database connection is closed: notify application support.");
		}
	}


	/**
	 *  Sets the cookie attribute of the ControlerSub object
	 *
	 *@param  cookieName  The new cookie value
	 *@param  value       The new cookie value
	 */
	private void setCookie(String cookieName, String value) {
		LongLivedCookie userCookie = new LongLivedCookie(cookieName, value);
		response.addCookie(userCookie);
	}


	/**
	 *  Sets the lastElement attribute of the ControlerSub object
	 *
	 *@param  lastElement  The new lastElement value
	 */
	public void setLastElement(String lastElement) {
		this.lastElement = lastElement;
	}


	/**
	 *  Sets the nsn attribute of the ControlerSub object
	 *
	 *@param  nsn  The new nsn value
	 */
	public void setNsn(String nsn) {
		this.nsn = nsn;
	}


	/**
	 *  Sets the pageContext attribute of the ControlerSub object
	 *
	 *@param  pageContext  The new pageContext value
	 */
	public void setPageContext(PageContext pageContext) {
		this.pageContext = pageContext;
		this.response = (HttpServletResponse) pageContext.getResponse();
	}


	/**
	 *  Sets the partNo attribute of the ControlerSub object
	 *
	 *@param  partNo  The new partNo value
	 */
	public void setPartNo(String partNo) {
		this.partNo = partNo;
	}


	/**
	 *  Sets the request attribute of the ControlerSub object
	 *
	 *@param  request  The new request value
	 */
	public void setRequest(HttpServletRequest request) {
		this.request = request;
	}


	/**
	 *  Sets the response attribute of the ControlerSub object
	 *
	 *@param  response  The new response value
	 */
	public void setResponse(HttpServletResponse response) {
		this.response = response;
	}


	/**
	 *  Sets the topNavBar attribute of the ControlerSub object
	 *
	 *@param  userid                     The new topNavBar value
	 *@exception  java.sql.SQLException  Description of the Exception
	 *@exception  java.io.IOException    Description of the Exception
	 */
	private void setTopNavBar(String userid)
			 throws java.sql.SQLException, java.io.IOException {
		logger.debug("setting top NavBar.");

		topNavBar = new NavBar();
		// since the out property is not set html will be available in the
		// html property
		String cbnNsn = request.getParameter("cboNsn");
		topNavBar.setUseNsnFilter(false);
		topNavBar.setSearchBy(searchBy);
		topNavBar.setSearchFieldValue(nsnVpn);
		topNavBar.setShowAllNsns(true);
		topNavBar.setAllowPartNoSelect(true);
		// if there is only one part_no select it
		if (logger.isDebugEnabled()) {
			logger.debug("searchBy=" + searchBy
					 + " nsnVpn=" + nsnVpn
					 + " plannerCode=" + plannerCode
					 + " nsiSid=" + nsiSid
					 + " partNo=" + partNo);
		}

		String psPreviousSearch = getCookie("PsPreviousSearch", "");
		if (logger.isDebugEnabled()) {
			logger.debug("search=" + search + " psPreviousSearch=" + psPreviousSearch);
		}
		if (search.equals(SEARCH_BY_NSN)) {
			if (psPreviousSearch.equals(SEARCH_BY_PLANNER) || psPreviousSearch.equals(ControlerSub.SEARCH_BY_NSN)) {
				nsnVpn = "";
			}
			setCookie("PsPreviousSearch", search);
		} else if (search.equals(SEARCH_BY_PLANNER)) {
			nsnVpn = "";
			setCookie("PsPreviousSearch", search);
		} else if (search.equals(ControlerSub.SEARCH_WITH_TOP_NAVBAR)) {
			//do nothing
		} else if (search.equals(ControlerSub.SEARCH_WITH_EQUI_NAVBAR)) {
			if (psPreviousSearch.equals(SEARCH_BY_PLANNER) || psPreviousSearch.equals(SEARCH_BY_NSN)) {
				nsnVpn = "";
			}
		} else if (search.equals("")) {
			if (psPreviousSearch.equals(SEARCH_BY_PLANNER) || psPreviousSearch.equals(SEARCH_BY_NSN)
					 || request.getMethod().equalsIgnoreCase("GET")) {
				nsnVpn = "";
			}
		}

		topNavBar.search(conn, searchBy,
				nsnVpn, plannerCode,
				nsiSid, partNo, "cboNsn",
				"txtNsiSid", "txtPartNo", "cboPlanner", "txtNomenclature");
		nsn = topNavBar.getNsn();
		if (logger.isDebugEnabled()) {
			logger.debug("nsn=" + nsn);
		}
		if (nsiSid.equals(NavBar.NO_SELECTION)) {
			this.nsiSid = topNavBar.getNsiSid();
			if (!nsiSid.equals(NavBar.NO_SELECTION)) {
				getCurTopNsn(userid);
			}
		}
		// check for partNo if there was only one or if it was selected
		partNo = topNavBar.getPartNo();
		if (logger.isDebugEnabled()) {
			logger.debug("partNo=" + partNo);
		}
		plannerCode = topNavBar.getPlannerCode();
		if (logger.isDebugEnabled()) {
			logger.debug("plannerCode=" + plannerCode);
		}
	}


	/**
	 *  Gets the chkEquivalentNsns attribute of the ControlerSub object
	 *
	 *@return    The chkEquivalentNsns value
	 */
	public String getChkEquivalentNsns() {
		return chkEquivalentNsns;
	}


	/**
	 *  Gets the cookie attribute of the ControlerSub object
	 *
	 *@param  cookieName    Description of the Parameter
	 *@param  defaultValue  Description of the Parameter
	 *@return               The cookie value
	 */
	private String getCookie(String cookieName, String defaultValue) {
		Cookie[] cookies = request.getCookies();
		return ServletUtilities.getCookieValue(cookies, cookieName, defaultValue);
	}


	/**
	 *  Gets the curTopNsn attribute of the ControlerSub object
	 *
	 *@param  userid                     Description of the Parameter
	 *@exception  java.sql.SQLException  Description of the Exception
	 *@exception  java.io.IOException    Description of the Exception
	 */
	private void getCurTopNsn(String userid)
			 throws java.sql.SQLException, java.io.IOException {
		logger.debug("getting top nsn........");
		if (!nsiSid.equals(NavBar.NO_SELECTION)) {
			topNsn = myWorkingSet.getItem(nsiSid);
			if (topNsn == null) {
				topNsn = myWorkingSet.load(nsiSid, userid);
				if (logger.isDebugEnabled()) {
					logger.debug("topNsn=" + topNsn);
				}
				session.putValue("SubWorkingSet", myWorkingSet);
			}
		}
	}


	/**
	 *  Gets the dataViaCookie attribute of the ControlerSub object
	 *
	 *@param  fieldName     Description of the Parameter
	 *@param  cookieName    Description of the Parameter
	 *@param  defaultValue  Description of the Parameter
	 *@return               The dataViaCookie value
	 */
	private String getDataViaCookie(String fieldName, String cookieName, String defaultValue) {
		String value;
		value = request.getParameter(fieldName);
		if (logger.isDebugEnabled()) {
			logger.debug("for " + fieldName + " request data had a value=" + value);
		}
		if (value == null) {
			value = getCookie(cookieName, defaultValue);
			if (logger.isDebugEnabled()) {
				logger.debug("for " + fieldName + " using cookie " + cookieName + " value=" + value);
			}
		} else {
			setCookie(cookieName, value);
			if (logger.isDebugEnabled()) {
				logger.debug("Saving " + fieldName + " as cookie " + cookieName + " with value=" + value);
			}
		}
		if (value == null) {
			if (logger.isDebugEnabled()) {
				logger.debug(fieldName + " had null value after retrival via cookie: using defaultValue of " + defaultValue);
			}
			value = defaultValue;
		}
		return value;
	}


	/**
	 *  Gets the equiNomenclature attribute of the ControlerSub object
	 *
	 *@return    The equiNomenclature value
	 */
	public String getEquiNomenclature() {
		return equiNomenclature;
	}


	/**
	 *  Gets the equiNsiSid attribute of the ControlerSub object
	 *
	 *@return    The equiNsiSid value
	 */
	public String getEquiNsiSid() {
		return equiNsiSid;
	}


	/**
	 *  Gets the equiNsn attribute of the ControlerSub object
	 *
	 *@return    The equiNsn value
	 */
	public String getEquiNsn() {
		return equiNsn;
	}


	/**
	 *  Gets the equiNsnVpn attribute of the ControlerSub object
	 *
	 *@return    The equiNsnVpn value
	 */
	public String getEquiNsnVpn() {
		return equiNsnVpn;
	}


	/**
	 *  Gets the equiPartNo attribute of the ControlerSub object
	 *
	 *@return    The equiPartNo value
	 */
	public String getEquiPartNo() {
		return equiPartNo;
	}



	/**
	 *  Gets the equiPlannerCode attribute of the ControlerSub object
	 *
	 *@return    The equiPlannerCode value
	 */
	public String getEquiPlannerCode() {
		return equiPlannerCode;
	}


	/**
	 *  Gets the equiSearchBy attribute of the ControlerSub object
	 *
	 *@return    The equiSearchBy value
	 */
	public String getEquiSearchBy() {
		return equiSearchBy;
	}


	/**
	 *  Gets the equivalentNsnSearch attribute of the ControlerSub object
	 *
	 *@return    The equivalentNsnSearch value
	 */
	public String getEquivalentNsnSearch() {
		logger.debug("getEquivalentNsnSearch......");
		return equivalentNsnSearch.getHtml();
	}


	/**
	 *  Gets the equivalentNsnsTable attribute of the ControlerSub object
	 *
	 *@return                          The equivalentNsnsTable value
	 *@exception  java.io.IOException  Description of the Exception
	 */
	public String getEquivalentNsnsTable() throws java.io.IOException {
		logger.debug("getting EquivalentNsnsTable..........");
		String html;
		if (topNsn == null) {
			return "";
		}
		EquivalentNsns equivalentNsns = topNsn.getEquivalentNsns();
		if (equivalentNsns == null) {
			return "";
		} else if (equivalentNsns.getCount() == 0) {
			return "";
		}

		html = "<table border=1 cellpadding=2 cellspacing=0 width=100%><!- Start TableB-->\n";
		html = html + "<tr bgcolor=#9bbad6>\n";
		html = html + "<td colspan=6><font face='Arial,Helvetica' size=-1>";
		html = html + "<input onFocus='lastField(this);' type=button onclick=\"DoAction('R')\" value=\"Remove\">\n";
		html = html + "checked item\n";
		html = html + "</td>\n";

		html = html + "<tr>\n";
		html = html + "<th>&nbsp\n";
		html = html + "<th>NSN\n";
		html = html + "<th>PN\n";
		html = html + "<th>Nomenclature\n";

		java.util.Iterator iterator = equivalentNsns.values().iterator();
		while (iterator.hasNext()) {
			EquivalentNsn equivalentNsn = (EquivalentNsn) iterator.next();
			if (equivalentNsn.getNsiSid().equals(topNsn.getNsiSid())) {
				continue;
			}

			String equiNsn = equivalentNsn.getNsn();
			String equiNsiSid = equivalentNsn.getNsiSid();
			html = html + "<tr>\n";
			html = html + "<td><input onFocus='lastField(this);' type=checkbox name=\"Remove\" value=" + equivalentNsn.getNsiSid() + ">\n";
			html = html + "<td>" + equiNsn + "\n";
			html = html + "<input type=hidden name=EquiNsn value=" + equiNsiSid + ">\n";
			logger.debug("equivalentNsn.getPartNo()=" + equivalentNsn.getPartNo());
			html = html + "<td>" + equivalentNsn.getPartNo() + "\n";
			html = html + "<td>" + equivalentNsn.getNomenclature() + "\n";
		}
		html = html + "<tr bgcolor=#ffffff>\n";
		html = html + "<td colspan=6>\n";
		html = html + "<font face=\"Arial,Helvetica\" size=-1>\n";
		html = html + "&nbsp;\n";
		html = html + "<a href=\"javascript:SetChecked(1)\">Check&nbsp;All</a>\n";
		html = html + "-\n";
		html = html + "<a href=\"javascript:SetChecked(0)\">Clear&nbsp;All</a>\n";
		html = html + "</font>\n";
		html = html + "</td></tr>\n";
		html = html + "<tr bgcolor=#9bbad6>\n";
		html = html + "<td colspan=6><font face=\"Arial,Helvetica\" size=-1>\n";
		html = html + "<input onFocus='lastField(this);' type=button onclick=\"DoAction('R')\" value=\"Remove\">\n";
		html = html + "checked item\n";
		html = html + "</td>\n";

		html = html + "</table><!- End TableB-->\n";

		return html;
	}


	/**
	 *  Gets the lastElement attribute of the ControlerSub object
	 *
	 *@return    The lastElement value
	 */
	public String getLastElement() {
		return lastElement;
	}


	/**
	 *  Gets the latestConfig attribute of the ControlerSub object
	 *
	 *@return    The latestConfig value
	 */
	public String getLatestConfig() {
		return latestConfig;
	}


	/**
	 *  Gets the msg attribute of the ControlerSub object
	 *
	 *@return    The msg value
	 */
	public String getMsg() {
		return this.msg.toString();
	}


	/**
	 *  Gets the myWorkingSet attribute of the ControlerSub object
	 *
	 *@return    The myWorkingSet value
	 */
	public WorkingSet getMyWorkingSet() {
		return myWorkingSet;
	}


	/**
	 *  Gets the nsiSid attribute of the ControlerSub object
	 *
	 *@return    The nsiSid value
	 */
	public String getNsiSid() {
		return this.nsiSid;
	}


	/**
	 *  Gets the nsn attribute of the ControlerSub object
	 *
	 *@return    The nsn value
	 */
	public String getNsn() {
		return nsn;
	}


	/**
	 *  Gets the nsnVpn attribute of the ControlerSub object
	 *
	 *@return    The nsnVpn value
	 */
	public String getNsnVpn() {
		return nsnVpn;
	}


	/**
	 *  Gets the partNo attribute of the ControlerSub object
	 *
	 *@return    The partNo value
	 */
	public String getPartNo() {
		return partNo;
	}


	/**
	 *  Gets the plannerCode attribute of the ControlerSub object
	 *
	 *@return    The plannerCode value
	 */
	public String getPlannerCode() {
		return plannerCode;
	}


	/**
	 *  Gets the requestData attribute of the ControlerSub object
	 *
	 *@exception  java.io.IOException  Description of the Exception
	 */
	private void getRequestData() throws java.io.IOException {

		this.theAction = request.getParameter("action");
		if (this.theAction == null) {
			this.theAction = "";
		}

		gotoBottom = getDataViaCookie("gotoBottom", "EquiGotoBottom", "");

		lastElement = request.getParameter("lastElement");
		if (lastElement == null) {
			lastElement = "0";
		}

		String debugParm = getDataViaCookie("debug", "EquiDebugParm", "");

		String debugLevel = getDataViaCookie("debugLevel", "EquiDebugLevel", "LOW");

		String nsiSidAndNsn = request.getParameter("cboNsn");

		if (logger.isDebugEnabled()) {
			logger.debug("nsiSidAndNsn=" + nsiSidAndNsn);
		}

		if (nsiSidAndNsn != null) {
			if (nsiSidAndNsn.indexOf("#") > 0) {
				nsiSid = nsiSidAndNsn.substring(0, nsiSidAndNsn.indexOf("#"));
			} else if (nsiSidAndNsn.indexOf("%") > 0) {
				nsiSid = nsiSidAndNsn.substring(0, nsiSidAndNsn.indexOf("%"));
			}
		} else {
			nsiSid = NavBar.NO_SELECTION;
		}

		if (nsiSid == null) {
			nsiSid = NavBar.NO_SELECTION;
		}
		if (logger.isDebugEnabled()) {
			logger.debug("nsiSid=" + nsiSid);
		}

		partNo = request.getParameter("txtPartNo");
		if (partNo == null) {
			partNo = "";
		}

		startDate = request.getParameter("txtStartDate");
		if (startDate == null) {
			startDate = "";
		}

		latestConfig = request.getParameter("cboLatestConfig");
		if (latestConfig == null) {
			latestConfig = "N";
		}

		plannerCode = request.getParameter("cboPlanner");
		if (plannerCode == null) {
			plannerCode = NavBar.NO_SELECTION;
		}

		search = request.getParameter("search");
		if (search == null) {
			search = "";
		}

		nsnVpn = getDataViaCookie("txtNsnVpn", "TopSearchBy", "");

		searchBy = getDataViaCookie("optSearchBy", "SearchBy", NavBar.BY_NSN);

		nsn = request.getParameter("txtNsn");
		if (nsn == null) {
			nsn = "";
		}

		equiNsn = getDataViaCookie(EQUIVALENT_NSN_COMBO_BOX, "EquiNsn", NavBar.NO_SELECTION);

		if (logger.isDebugEnabled()) {
			logger.debug("equiNsn=" + equiNsn);
		}
		if (equiNsn.indexOf("#") > 0) {
			equiNsiSid = equiNsn.substring(0, equiNsn.indexOf("#"));
		} else {
			equiNsiSid = NavBar.NO_SELECTION;
		}

		equiPartNo = request.getParameter("txtEquiPartNo");
		if (equiPartNo == null) {
			equiPartNo = "";
		}
		if (logger.isDebugEnabled()) {
			logger.debug("equiPARTNO ...=" + equiPartNo);
		}

		equiNomenclature = request.getParameter("txtEquiNomenclature");
		if (equiNomenclature == null) {
			equiNomenclature = "";
		}
		if (logger.isDebugEnabled()) {
			logger.debug("equiNomenclature=" + equiNomenclature);
		}

		equiPlannerCode = request.getParameter("cboEquiPlanner");
		if (equiPlannerCode == null) {
			equiPlannerCode = NavBar.NO_SELECTION;
		}

		equiNsnVpn = getDataViaCookie("txtEquiNsnVpn", "EquiNsnVpn", "").toUpperCase();

		equiSearchBy = getDataViaCookie("optEquiSearchBy", "EquiSearchBy", NavBar.BY_NSN);

		views = request.getParameterValues("chkView");

	}


	/**
	 *  Gets the search attribute of the ControlerSub object
	 *
	 *@return    The search value
	 */
	public String getSearch() {
		return search;
	}


	/**
	 *  Gets the searchBy attribute of the ControlerSub object
	 *
	 *@return    The searchBy value
	 */
	public String getSearchBy() {
		return searchBy;
	}


	/**
	 *  Gets the splitConfigurationTables attribute of the ControlerSub object
	 *
	 *@param  equivalentNsns  Description of the Parameter
	 *@return                 The splitConfigurationTables value
	 */

	public java.util.Map getSortedMap(EquivalentNsns equivalentNsns) {
		java.util.Set keys = equivalentNsns.keySet();
		java.util.Iterator iterator = keys.iterator();
		java.util.TreeMap map = new java.util.TreeMap();
		if (searchBy.equals(NavBar.BY_NSN)) {
			while (iterator.hasNext()) {
				EquivalentNsn equivalentNsn = (EquivalentNsn) equivalentNsns.get(iterator.next());
				map.put(equivalentNsn.getPartNo(), equivalentNsn);
			}
		} else {
			while (iterator.hasNext()) {
				EquivalentNsn equivalentNsn = (EquivalentNsn) equivalentNsns.get(iterator.next());
				map.put(equivalentNsn.getNsn(), equivalentNsn);
			}
		}
		return map;
	}


	/**
	 *  Gets the splitConfigurationTables attribute of the ControlerSub object
	 *
	 *@return                          The splitConfigurationTables value
	 *@exception  java.io.IOException  Description of the Exception
	 */
	public String getSplitConfigurationTables() throws java.io.IOException {
		logger.debug("getSplitConfigurationTables");
		String html;

		String byNsn = "";
		String byVpn = "";

		if (equiSearchBy.equals(NavBar.BY_NSN)) {
			byNsn = "checked";
		} else {
			byVpn = "checked";
		}

		/*
		 *  if (!splitEffect.equals("Split")) {
		 *  return "" ;
		 *  }
		 */
		html = "<hr>\n";
		html += "<a name=" + START_EQUIVALENT_NSNS + "></a>\n";

		html = html + "<table cellpadding=\"0\" cellspacing=\"0\" border=\"0\"><!- Start TableC-->\n";
		html = html + "<tr>\n";
		html = html + "<td>Component NSN\n";
		html = html + "<input onFocus='lastField(this);' type=button value=Search onClick=\"Search(2)\">\n";
		html = html + "<input onFocus='lastField(this);' type=button value=Add onclick=\"DoAction('A')\">\n";

		html = html + "<input onFocus='lastField(this);' type=\"RADIO\" name=\"optEquiSearchBy\" value=\"byNsn\" " + byNsn + ">&nbsp;NSN&nbsp;\n";

		html = html + "<input onFocus='lastField(this);' type=\"RADIO\" name=\"optEquiSearchBy\" value=\"byVpn\" " + byVpn + ">&nbsp;PN&nbsp;\n";
		html = html + "<input onFocus='lastField(this);' size=\"30\" type=\"text\" name=\"txtEquiNsnVpn\" value=\"" + equiNsnVpn + "\"></td>\n";
		html = html + "</table><!- End TableC-->\n";
		html = html + "<table cellpadding=\"0\" cellspacing=\"0\" border=\"0\"><!- Start TableD-->\n";
		html = html + "<tr>\n";
		html = html + "<td>\n";
		html = html + getEquivalentNsnSearch();

		html = html + "<td>\n";
		html = html + "<td>\n";

		html = html + "</table><!- End TableD-->\n";
		html = html + getEquivalentNsnsTable();
		html = html + "<br>\n";

		return html;
	}


	/**
	 *  Gets the startDate attribute of the ControlerSub object
	 *
	 *@return    The startDate value
	 */
	public String getStartDate() {
		return startDate;
	}


	/**
	 *  Gets the theAction attribute of the ControlerSub object
	 *
	 *@return    The theAction value
	 */
	public String getTheAction() {
		return theAction;
	}


	/**
	 *  Gets the topNavBar attribute of the ControlerSub object
	 *
	 *@return    The topNavBar value
	 */
	public String getTopNavBar() {
		return topNavBar.getHtmlWithControls();
	}


	/**
	 *  Gets the topNsn attribute of the ControlerSub object
	 *
	 *@return    The topNsn value
	 */
	public EquivalentNsn getTopNsn() {
		return topNsn;
	}


	/**
	 *  Gets the userid attribute of the ControlerSub object
	 *
	 *@return    The userid value
	 */
	public String getUserid() {
		return userid;
	}


	/**
	 *  Gets the views attribute of the ControlerSub object
	 *
	 *@return    The views value
	 */
	public String[] getViews() {
		return views;
	}


	/**
	 *  Description of the Method
	 *
	 *@return    Description of the Return Value
	 */
	public boolean getusePredefinedFleetSize() {
		return usePredefinedFleetSize;
	}


	/**
	 *  Description of the Method
	 *
	 *@param  userid                     Description of the Parameter
	 *@exception  java.sql.SQLException  Description of the Exception
	 *@exception  java.io.IOException    Description of the Exception
	 */
	private void add(String userid) throws java.sql.SQLException, java.io.IOException {
		Statement s = AmdDB.instance().getConnection(userid).createStatement();
		if (logger.isDebugEnabled()) {
			logger.debug("add: userid=" + userid);
		}
		if (equiPlannerCode.equals(NavBar.NO_SELECTION)) {
			errorOccured = true;
			msg.append("Select a planner.");
		}
		if (equiNsn.equals(NavBar.NO_SELECTION)) {
			errorOccured = true;
			msg.append("Select an NSN.");
		}
		equiNsiSid = equiNsn.substring(0, equiNsn.indexOf("#"));
		if (equiNsiSid.equals(topNsn.getNsiSid())) {
			errorOccured = true;
			msg.append("Can not make a part a component of itself");
		}
		if (errorOccured) {
			return;
		}

		equiNsn = equiNsn.substring(equiNsn.indexOf("#") + 1);

		EquivalentNsns equivalentNsns = topNsn.getEquivalentNsns();
		if (logger.isDebugEnabled()) {
			logger.debug("equiNsiSid=" + equiNsiSid + " equiNsn=" + equiNsn + " equiPartNo=" + equiPartNo + " equiNomenclature=" + equiNomenclature);
		}

		ResultSet parentCount;
		int cnt = 0;
		String sqlStmt = " Select count(*) as cnt from amd_product_structure aps, amd_national_stock_items ansi, amd_national_stock_items ansi2 where aps.comp_nsi_sid = ('" + equiNsiSid + "') and ansi.nsi_sid = aps.assy_nsi_sid and ansi2.nsi_sid = ('" + nsiSid + "') and ansi.effect_by != ansi2.effect_by ";
		logger.info(sqlStmt);
		parentCount = s.executeQuery(sqlStmt);
		if (parentCount.next()) {
			cnt = parentCount.getInt(1);
			if (logger.isDebugEnabled()) {
				logger.debug("parentCount = ('" + cnt + "')");
				logger.debug("topNsn.getNsiSid()=" + topNsn.getNsiSid());
				logger.debug("equiNsiSid=" + equiNsiSid);
			}
			if (cnt == 0) {
				if (equivalentNsns.containsKey(equiNsiSid)) {
					errorOccured = true;
					msg.append("The part being added is already component of this assembly.");
					return;
				} else {
					equivalentNsns.add(equiNsiSid, equiNsn, equiPartNo, equiNomenclature, equiNsiSid);
					topNsn.save(userid);
					String topNsnMsg = topNsn.getMsg();
					if (topNsnMsg != null && !topNsnMsg.equals("")) {
						errorOccured = true;
						msg.append(topNsnMsg);
					}
				}
			} else {
				String parentNsn = "";
				String primePartNo = "";
				ResultSet rsNsn;
				sqlStmt = "Select nsn, prime_part_no from amd_national_stock_items ansi, amd_product_structure aps where nsi_sid  = aps.assy_nsi_sid and aps.comp_nsi_sid = ('" + equiNsiSid + "')";
				rsNsn = s.executeQuery(sqlStmt);
				if (rsNsn.next()) {
					parentNsn = rsNsn.getString("nsn");
					primePartNo = rsNsn.getString("prime_part_no");
				}
				if (logger.isDebugEnabled()) {
				    logger.debug("Parent Nsn from database table >>>>>>>> = ('" + equiNsiSid + "', '" + parentNsn + "')");
				}
				errorOccured = true;
				msg.append("The Component NSN can not be added to this Assembly NSN because this Component is already a Component of Assembly  " + parentNsn + "  /  " + primePartNo + "  that defines effective aircraft using a different method ");
				logger.debug("CONTROLLERSUBNSNERRORMESSAGE ..." + msg.toString());
				rsNsn.close();
			}
		}
		parentCount.close();
	}


	/**
	 *  Description of the Method
	 *
	 *@exception  java.sql.SQLException  Description of the Exception
	 *@exception  java.io.IOException    Description of the Exception
	 */
	private void createEquivalentNsnSearchCntl()
			 throws java.sql.SQLException, java.io.IOException {
		equivalentNsnSearch = new NavBar();
		equivalentNsnSearch.setAllowPartNoSelect(true);

		String tmpNsnVpn = equiNsnVpn;
		if (theAction.equals(ControlerSub.ACTION_SELECT_EQUI_NSN)
				 || theAction.equals(ControlerSub.ACTION_SELECT_EQUI_PLANNER)) {
			tmpNsnVpn = "";
		}

		equivalentNsnSearch.search(conn, equiSearchBy,
				tmpNsnVpn, equiPlannerCode, equiNsiSid,
				"",
				EQUIVALENT_NSN_COMBO_BOX, "txtEquiNsiSid",
				"txtEquiPartNo", "cboEquiPlanner", "txtEquiNomenclature");
		equiNsn = equivalentNsnSearch.getNsn();
		equiPartNo = equivalentNsnSearch.getPartNo();
	}


	/**
	 *  Description of the Method
	 *
	 *@param  equivalentNsns  Description of the Parameter
	 */
	protected void dump(EquivalentNsns equivalentNsns) {
		Set keys = equivalentNsns.keySet();
		Iterator iterator = keys.iterator();
		while (iterator.hasNext()) {
			equivalentNsn = (EquivalentNsn) equivalentNsns.get(iterator.next());
			logger.debug("Nsn=" + equivalentNsn.getNsn() + " "
					 + "NsiSid=" + equivalentNsn.getNsiSid() + " "
					 + "PartNo=" + equivalentNsn.getPartNo());
		}
	}


	/**
	 *  Description of the Method
	 */
	private void enter() {
	}


	/**
	 *  Description of the Method
	 *
	 *@return                            Description of the Return Value
	 *@exception  java.sql.SQLException  Description of the Exception
	 *@exception  java.io.IOException    Description of the Exception
	 *@exception  Exception              Description of the Exception
	 */
	public boolean execute() throws java.sql.SQLException, java.io.IOException, Exception {
		logger.debug(">>>>>>>>> START CONTROLERSUB EXECUTE <<<<<<<<<<<");
		init();

		if (logger.isDebugEnabled()) {
			logger.debug("theAction=" + theAction + " search=" + search);
		}
		if (theAction.equals("A")) {
			add(userid);
			overrideLastElement();
		} else if (theAction.equals("R")) {
			remove();
			if (topNsn.getEquivalentNsns().size() > 0) {
				overrideLastElement();
			} else {
				lastElement = "document.forms[0]." + EQUIVALENT_NSN_COMBO_BOX + ".focus();";
			}

		} else if (theAction.equals("")) {
			enter();
			lastElement = "document.forms[0].elements[" + lastElement + "].focus();";
		}

		setTopNavBar(userid);
		createEquivalentNsnSearchCntl();
		if (errorOccured) {
			RE re = new RE("'");
			lastElement = "alert(\"" + re.subst(msg.toString(), "\\\"") + "\");";
		}
		logger.debug(">>>>>>>>>> END CONTROLERSUB EXECUTE <<<<<<<<<<");
		return true;
	}


	/**
	 *  Description of the Method
	 *
	 *@exception  java.sql.SQLException  Description of the Exception
	 *@exception  java.io.IOException    Description of the Exception
	 */
	private void init() throws java.sql.SQLException, java.io.IOException {
		this.session = request.getSession(false);
		userid = (String) session.getValue("userid");
		this.myWorkingSet = (WorkingSet) session.getValue("SubWorkingSet");
		if (this.myWorkingSet == null) {
			this.myWorkingSet = new WorkingSet();
		}

		getRequestData();

		if (!nsiSid.equals(NavBar.NO_SELECTION)) {
			getCurTopNsn(userid);
		}
	}


	/**
	 *  Description of the Method
	 */
	protected void overrideLastElement() {
		if (gotoBottom.equalsIgnoreCase("true")) {
			lastElement = "document.forms[0]." + BOTTOM_OF_PAGE + ".focus();";
		} else {
			lastElement = "goto(\"" + START_EQUIVALENT_NSNS + "\");";
		}
	}


	/**
	 *  Description of the Method
	 *
	 *@exception  java.sql.SQLException  Description of the Exception
	 *@exception  java.io.IOException    Description of the Exception
	 *@exception  Exception              Description of the Exception
	 */
	private void remove()
			 throws java.sql.SQLException, java.io.IOException, Exception {
		validateData();
		if (errorOccured) {
			return;
		}
		EquivalentNsns equivalentNsns = topNsn.getEquivalentNsns();

		String strRemoveNsiSid[] = request.getParameterValues("Remove");
		if (strRemoveNsiSid != null) {
			for (int i = 0; i < strRemoveNsiSid.length; i++) {
				equivalentNsns.remove(topNsn.getNsiSid(), strRemoveNsiSid[i], userid);
			}
			session.putValue("SubWorkingSet", myWorkingSet);
		}
	}


	/**
	 *  Description of the Method
	 *
	 *@param  p_no     Description of the Parameter
	 *@param  ac_no    Description of the Parameter
	 *@param  tail_no  Description of the Parameter
	 *@return          Description of the Return Value
	 */
	private String selectAircraft(String p_no, String ac_no, String tail_no) {
		if (aircraft == null) {
			return "<option value=\"" + p_no + "-" + ac_no + "-" + tail_no + "\">" + p_no + "-" + ac_no;
		}
		for (int i = 0; i < aircraft.length; i++) {
			if (aircraft[i].equals(p_no + "-" + ac_no + "-" + tail_no)) {
				return "<option selected value=\"" + p_no + "-" + ac_no + "-" + tail_no + "\">" + p_no + "-" + ac_no;
			}
		}
		return "<option value=\"" + p_no + "-" + ac_no + "-" + tail_no + "\">" + p_no + "-" + ac_no;
	}


	/**
	 *  Description of the Method
	 */
	private void validateData() {
		if (nsiSid.equals(NavBar.NO_SELECTION)) {
			errorOccured = true;
			msg.append("Select an nsn.");
		}
	}


	/**
	 *  Gets the author attribute of the ControlerSub object
	 *
	 *@return    The author value
	 */
	public static String getAuthor() {
		return author;
	}


	/**
	 *  Gets the revision attribute of the ControlerSub object
	 *
	 *@return    The revision value
	 */
	public static String getRevision() {
		return revision;
	}


	/**
	 *  Gets the workfile attribute of the ControlerSub object
	 *
	 *@return    The workfile value
	 */
	public static String getWorkfile() {
		return workfile;
	}


	/**
	 *  The main program for the ControlerSub class
	 *
	 *@param  args  The command line arguments
	 */
	public static void main(String[] args) {
		if (args.length > 0 && args[0].equals("-version")) {
			System.out.println(revision + "\n" +
					author + "\n" +
					workfile);
			System.exit(0);
		}
	}
}


