package Configuration;
import coreservlets.*;
import effectivity.AcDisplayCntl;
import java.sql.*;
import effectivity.AmdUtils ;
/*
 *  $Revision:   1.5  $
 *  $Author:   c970408  $
 *  $Workfile:   Controller.java  $
 *  $Log:   \\www-amssc-01\pds\archives\SDS-AMD\Components-ClientServer\AmdConfig\Configuration\Controller.java-arc  $
/*
/*   Rev 1.5   12 Nov 2002 09:14:06   c970408
/*Mod'd getRequestData() to not get from cookie the value for txtNsnVpn if user came from other page. Display fleet_size_name correctly now.
/*
/*   Rev 1.4   19 Aug 2002 14:55:58   c970183
/*Added the display of the effect_last_update_dt and effect_last_update_id for the topNsn
/*
/*   Rev 1.3   12 Aug 2002 13:54:44   c970183
/*Changed goto(....... JavaScript to gotoLink(...........  Fixed named anchor's to work in Netscape.  Checked if Top Nsn selected before trying to retrieve data regardless of old cookie data for the related nsn.
 *  *
 *  *   Rev 1.1   23 May 2002 06:57:48   c970183
 *  *Test Release
 */
import java.text.*;
import javax.servlet.http.*;
import javax.servlet.jsp.*;
import org.apache.log4j.*;
import org.apache.regexp.RE ;

/**
 * This is the main class for the Config.jsp page. It controls all input and
 *  output for the application.
 * 
 * @author Douglas S. Elder
 * @version 1.0
 * @since June 20, 2002
 */
public class Controller {
	private String acBy;
	private String aircraft[];
	private String aircraftHtml;
	private String chkPairs;
	private String chkRelatedNsns;
	private String confirmMsg = "";
	private Connection conn;
	private String depleteBy;
	private boolean errorOccured = false;
	private String gotoBottom;
	private boolean inheritFleetSize = false;
	private String lastElement;
	private String latestConfig;
	private Msg msg = new Msg();
	private WorkingSet myWorkingSet;
	private NsiGroup nsiGroup;
	private String nsiSid;
	private String nsiSidToBeRemovedList[];
	private String nsn;
	private String nsnFilter;
	private String nsnVpn;
	private JspWriter out;
	private PageContext pageContext;
	private String partNo;
	private String plannerCode;
	private String predefinedFleetSizeDesc;
	private String predefinedFleetSizeHtml;
	private String predefinedFleetSizeName;
	private String relNomenclature;
	private String relNsiSid;
	private String relNsiSidList[];
	private String relNsn;
	private String relNsnVpn;
	private String relPartNo;
	private String relPlannerCode;
	private String relSearchBy;
	private String relStartDateList[];
	private String relatedNsnDepleteBy[];
	private String relatedNsnLatestConfig[];
	private NavBar relatedNsnSearch;
	private HttpServletRequest request;
	private HttpServletResponse response;
	private String search;
	private String searchBy;
	private HttpSession session;
	private String splitEffect;
	private String startDate;
	private String strNsnSidAndNsn;
	private String theAction;
	private NavBar topNavBar;
	private RelatedNsn topNsn;
	private boolean usePredefinedFleetSize;
	private String userid;
	private String views[];
	private final String IDENTIFY_INSTALLED_ON = "Specific 'Installed On' aircraft must be identified in the Effective Aircraft screen.";
	private final String latestConfigDefault = "N";
	private static String author = "$Author:   c970408  $";

	static Logger logger = Logger.getLogger(Controller.class.getName());

	private static String revision = "$Revision:   1.5  $";
	private static String workfile = "$Workfile:   Controller.java  $";

	/**
	 *  Currently this action is not used.
	 */
	public final static String ACTION_ACSORT = "ACSORT";
	/**
	 *  Currently this action is not used
	 */
	public final static String ACTION_AC_CHANGED = "AC_CHANGED";
	/**
	 *  Add a related nsn to the group.
	 *
	 *@see    #move(java.lang.String)
	 */
	public final static String ACTION_ADD = "A";
	/**
	 *  Currently this action is not used.
	 */
	public final static String ACTION_CHANGED_VIEW = "CHANGEDVIEW";

	/**
	 *  Description of the Field
	 */
	public final static String ACTION_CHANGE_NSN_FILTER = "CHGFILTER";
	/**
	 *  Remove a related nsn from a group and assign it a new group.
	 *
	 *@see    #remove()
	 */
	public final static String ACTION_REMOVE = "R";

	/**
	 *  Save all the data.
	 *
	 *@see    #save()
	 */
	public final static String ACTION_SAVE = "S";
	/**
	 *  Retrieve the current information based on the search parameter.
	 */
	public final static String ACTION_SEARCH = "S";
	/**
	 *  Select a related nsn.
	 */
	public final static String ACTION_SELECT_RELATED_NSN = "D";

	/**
	 *  The value returned from the Config.jsp page in the search field
	 *  when the planner is selected for thw 2nd NavBar
	 */
	public final static String ACTION_SELECT_RELATED_PLANNER = "SELRELPLANNER";
	private final static String AUTOSWITCH_MSG = "'AutoSwitched' to All Nsn's.";

	/**
	 *  Do a search by Nsn for a partial or explicit value.
	 *
	 *@see    #setTopNavBar()
	 */
	public final static String BY_NSN = "byNsn";
	/**
	 *  Do a search by part number.
	 *
	 *@see    #setTopNavBar()
	 */
	public final static String BY_VPN = "byVpn";
	private final static String CBO_NSN_FIELD_NUMBER = "7";
	/**
	 *  The name of the html form used for this application.
	 */
	public final static String FORM_NAME = "TheForm";
	private final static String LAST_REMOVE_BUTTON = "Remove2";
	/**
	 *  The name of the last save button on the html form
	 *
	 *@see    #FORM_NAME
	 */
	public final static String LAST_SAVE_BUTTON = "LastSave";
	/**
	 *  The value used for the aircraft lists to indicate that no aircraft has been
	 *  selected.
	 */
	public final static String NO_SELECTION = "-None-";
	private final static String NSNFILTER = "NsnFilter";
	private final static String RELATED_NOMEN_TEXT_BOX = "txtRelNomenclature";
	private final static String RELATED_NSISID_HIDDEN_FIELD = "txtRelNsiSid";
	private final static String RELATED_NSN_COMBO_BOX = "cboRelNsn";
	private final static String RELATED_PARTNO_COMBO_BOX = "cboRelPartNo";
	private final static String RELATED_PLANNER_COMBO_BOX = "cboRelPlanner";
	/**
	 *  Do a search by the Nsn selected from a list of nsn's.
	 */
	public final static String SEARCH_BY_NSN = "4";
	/**
	 *  Do a search by planner and return a list of nsn's.
	 */
	public final static String SEARCH_BY_PLANNER = "3";
	/**
	 *  Do a search using the related nsn NavBar.
	 */
	public final static String SEARCH_WITH_REL_NAVBAR = "2";
	/**
	 *  Do a search using the top NavBar.
	 */
	public final static String SEARCH_WITH_TOP_NAVBAR = "1";
	private final static String START_RELATED_NSNS = "RelatedNsns"; // 8/12/02 dse rmoved # 


	/**
	 *  Set the conn property to an open JDBC connection object.
	 *
	 *@param  conn                       An open JDBC Connection object.
	 *@exception  java.sql.SQLException  This exception can occur, since the class
	 *      loads data from the Oracle data base via JDBC.
	 */
	public void setConn(Connection conn) throws java.sql.SQLException {
		if (conn != null) {
			this.conn = conn;
			if (this.conn.isClosed()) {
				logger.error("Database connection is closed: notify application support.");
			}
		} else {
			logger.error("Controler.setConn: conn is null.");
		}
	}


	/**
	 *  Assign a Long Lived cookie a value
	 *
	 *@param  cookieName  The name of the cookie
	 *@param  value       The new cookie value
	 */
	private void setCookie(String cookieName, String value) {
		LongLivedCookie userCookie = new LongLivedCookie(cookieName, value);
		response.addCookie(userCookie);
	}


	/**
	 *  Turn on debuging for the logger associated with this class.
	 *
	 *@param  debug  If true, enables logger debugging for this class.
	 */
	public void setDebug(boolean debug) {
		if (debug) {
			logger.setLevel(org.apache.log4j.Level.DEBUG);
		}
	}


	/**
	 *@param  nsn  The nsn to be used as the top nsn for the Config.jsp page.
	 */
	public void setNsn(String nsn) {
		this.nsn = nsn;
	}


	/**
	 *  Sets the out attribute of the Controller object
	 *
	 *@param  out  The new out value
	 */
	public void setOut(JspWriter out) {
		this.out = out;
	}


	/**
	 *  Sets the pageContext attribute of the Controller object
	 *
	 *@param  pageContext  The new pageContext value
	 */
	public void setPageContext(PageContext pageContext) {
		this.pageContext = pageContext;
		this.response = (HttpServletResponse) pageContext.getResponse();
	}


	/**
	 *@param  partNo  The Part Number of the top nsn.
	 */
	public void setPartNo(String partNo) {
		this.partNo = partNo;
	}


	/**
	 *  Sets the request attribute of the Controller object
	 *
	 *@param  request  The new request value
	 */
	public void setRequest(HttpServletRequest request) {
		this.request = request;
	}


	/**
	 *  Sets the response attribute of the Controller object
	 *
	 *@param  response  The new response value
	 */
	public void setResponse(HttpServletResponse response) {
		this.response = response;
	}


	/**
	 *  Sets the topNavBar attribute of the Controller object
	 *
	 *@exception  java.sql.SQLException  This exception can occur, since the class
	 *      loads data from the Oracle data base via JDBC.
	 */
	protected void setTopNavBar()
			 throws java.sql.SQLException {
		logger.debug("setting top NavBar.");

		topNavBar = new NavBar();
		// since the out property is not set html will be available in the
		// html property
		if (logger.isDebugEnabled()) {
			logger.debug("nsnFilter=" + nsnFilter);
		}
		String autoSwitch = getCookie("AutoSwitch", "On");
		String cboNsn = request.getParameter("cboNsn");
		if (logger.isDebugEnabled()) {
			logger.debug("request.getMethod()=" + request.getMethod());
			logger.debug("cboNsn=" + cboNsn);
			logger.debug("nsnFilter=" + nsnFilter);
			logger.debug("autoSwitch=" + autoSwitch);
		}
		if (request.getMethod().equals("GET")
				 && nsnFilter.equals(NavBar.NEW_NSNS)
				 && autoSwitch.equalsIgnoreCase("on")
				 && cboNsn != null) {
			msg.append(AUTOSWITCH_MSG);
			nsnFilter = NavBar.ALL_NSNS;
			setCookie(NSNFILTER, NavBar.ALL_NSNS);
		}

		topNavBar.setNsnFilter(nsnFilter);
		setCookie("AutoSwitch", autoSwitch);

		topNavBar.setSearchBy(searchBy);
		topNavBar.setSearchFieldValue(nsnVpn);
		topNavBar.setShowAllNsns(nsnFilter.equals(NavBar.ALL_NSNS));
		topNavBar.setAllowPartNoSelect(true);
		// if there is only one part_no select it

		String previousSearch = getCookie("PreviousSearch", "");
		if (logger.isDebugEnabled()) {
			logger.debug("search=" + search + " previousSearch=" + previousSearch);
		}
		if (search.equals(SEARCH_BY_NSN)) {
			if (previousSearch.equals(SEARCH_BY_PLANNER)
					 || previousSearch.equals(Controller.SEARCH_BY_NSN)) {
				nsnVpn = "";
			}
			setCookie("PreviousSearch", search);
		} else if (search.equals(SEARCH_BY_PLANNER)) {
			nsnVpn = "";
			setCookie("PreviousSearch", search);
		} else if (search.equals(Controller.SEARCH_WITH_TOP_NAVBAR)) {
			// do nothing
		} else if (search.equals(Controller.SEARCH_WITH_REL_NAVBAR)) {
			if (previousSearch.equals(SEARCH_BY_PLANNER) || previousSearch.equals(SEARCH_BY_NSN)) {
				nsnVpn = "";
			}
		} else if (search.equals("")) {
			if (previousSearch.equals(SEARCH_BY_PLANNER)
					 || previousSearch.equals(SEARCH_BY_NSN)
					 || request.getMethod().equalsIgnoreCase("GET")) {
				nsnVpn = "";
			}
		}
		if (logger.isDebugEnabled()) {
			logger.debug("searchBy=" + searchBy
					 + " nsnVpn=" + nsnVpn
					 + " plannerCode=" + plannerCode
					 + " nsiSid=" + nsiSid
					 + " partNo=" + partNo);
		}
		topNavBar.search(conn, searchBy,
				nsnVpn, plannerCode,
				nsiSid, partNo, "cboNsn",
				"txtNsiSid", "txtPartNo", "cboPlanner", "txtNomenclature");
		nsn = topNavBar.getNsn();
		if (logger.isDebugEnabled()) {
			logger.debug("nsn=" + nsn);
		}
		if (logger.isDebugEnabled()) {
			logger.debug("nsiSid=" + this.nsiSid);
		}

		if (nsiSid.equals(NavBar.NO_SELECTION)) {
			this.nsiSid = topNavBar.getNsiSid();
			if (logger.isDebugEnabled()) {
				logger.debug("nsiSid=" + this.nsiSid);
			}
			if (!nsiSid.equals(NavBar.NO_SELECTION)) {
				getCurTopNsn();
				LongLivedCookie userCookie = new LongLivedCookie("NsiSidAndNsn", nsiSid + topNavBar.getSeparator() + nsn);
				response.addCookie(userCookie);
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
		if (topNavBar.getNsnListRecCount() == 0) {
			if (logger.isDebugEnabled()) {
				logger.debug("nsnVpn=" + nsnVpn + " plannerCode=" + plannerCode + " nsiSid=" + nsiSid);
			}
			if (nsnVpn.equals("")
					 && (plannerCode.equals(NavBar.NO_SELECTION) || plannerCode.equals(""))
					 && nsiSid.equals(NavBar.NO_SELECTION) || nsiSid.equals("")) {
				// do nothing
			} else {
				msg.append("No data found.");
				if (nsnFilter.equals(NavBar.NEW_NSNS)) {
					msg.append("Try selecting All Nsn's.");
				}
			}
		}
	}


	/**
	 *  This returns a CUSTOM list of aircraft rather than a predefined fleet size.
	 *
	 *@return    An array of strings containing the following format:
	 *      p_no-ac_no-tail_no.
	 */
	public String[] getAircraft() {
		return aircraft;
	}


	/**
	 *  The html needed to display the CUSTOM (user defined) list of aircraft.
	 *
	 *@return    The aircraftHtml value
	 */

	public String getAircraftHtml() {
		return aircraftHtml;
	}


	/**
	 *  Gets the author attribute of the Controller object
	 *
	 *@return    The author value
	 */
	public String getAuthor() {
		return author;
	}


	/**
	 *  Gets the chkPairs attribute of the Controller object
	 *
	 *@return    The chkPairs value
	 */
	public String getChkPairs() {
		return chkPairs;
	}


	/**
	 *  Gets the chkRelatedNsns attribute of the Controller object
	 *
	 *@return    The chkRelatedNsns value
	 */
	public String getChkRelatedNsns() {
		return chkRelatedNsns;
	}


	/**
	 *  Under certains conditions the user needs to be prompted to confirm certain
	 *  update actions. The confirm message property will contain a non-blank value
	 *  when such a prompt is necessary. This value should be engineered into the
	 *  html's JavaScript, so that when the action is invoked the confirm message
	 *  is displayed.
	 *
	 *@return    A specific type of confirmation message.
	 */
	public String getConfirmMsg() {
		return confirmMsg;
	}


	/**
	 *  Gets the cookie attribute of the Controller object
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
	 *  Gets the curTopNsn attribute of the Controller object
	 *
	 *@exception  java.sql.SQLException  This exception can occur, since the class
	 *      loads data from the Oracle data base via JDBC.
	 */
	protected void getCurTopNsn()
			 throws java.sql.SQLException {
		if (logger.isDebugEnabled()) {
			logger.debug("getting current top nsn for " + nsiSid);
		}

		topNsn = myWorkingSet.getItem(nsiSid);
		if (topNsn == null) {
			topNsn = myWorkingSet.load(nsiSid, userid);
		}
		if (topNsn != null) {
			// get the current values
			nsiGroup = topNsn.getNsiGroup();
			if (logger.isDebugEnabled()) {
				nsiGroup.getRelatedNsns().dump();
			}
			if (logger.isDebugEnabled()) {
			    logger.debug("theAction=" + theAction ) ;
			}
			if (!theAction.equals(Controller.ACTION_SAVE) 
			    && !theAction.equals(Controller.ACTION_ADD)
			    && !theAction.equals(Controller.ACTION_REMOVE)) {
                if (nsiGroup.getFleetSize().getPredefinedFleetSize()) {
                    predefinedFleetSizeName = nsiGroup.getFleetSize().getFleetSizeName() ;
                } else {
                    predefinedFleetSizeName = NavBar.NO_SELECTION ;
			        aircraft = nsiGroup.getFleetSize().getAircraftArray() ;
                }
            }
			if (logger.isDebugEnabled()) {
                    logger.debug("predefinedFleetSizeName=" + predefinedFleetSizeName) ;
            }
		}
	}


	/**
	 *  When the user has request a search, this routine is always executed.
	 *
	 *@exception  java.sql.SQLException  This exception can occur, since the class
	 *      loads data from the Oracle data base via JDBC.
	 */
	protected void getCurValues() throws java.sql.SQLException {
		logger.debug("getCurValues");

		if (nsiGroup != null && nsiGroup.getSplitEffect().equals(NsiGroup.SPLIT_EFFECTIVITY)) {
			logger.debug("got SPLIT from nsiGroup.");
			splitEffect = NsiGroup.SPLIT_EFFECTIVITY;
		} else {
			if (logger.isDebugEnabled()) {
				logger.debug("nsiGroup=" + nsiGroup + " splitEffect set to SINGLE.");
			}
			splitEffect = NsiGroup.SINGLE_EFFECTIVITY;
		}

		if (topNsn != null) {
			if (depleteBy.equals("")) {
				depleteBy = topNsn.getDepleteBy();
				if (depleteBy == null) {
					depleteBy = "";
				}
			}

			if (startDate.equals("")) {
				startDate = topNsn.getStartDate();
				if (startDate == null) {
					startDate = "";
				}
			}

			latestConfig = topNsn.getLatestConfig();
			if (logger.isDebugEnabled()) {
				logger.debug("latestConfig=" + latestConfig);
			}
			if (latestConfig == null) {
				latestConfig = latestConfigDefault;
			}
		}

		if (!nsiSid.equals(NavBar.NO_SELECTION) &&  relNsn != null && relNsn.indexOf("#") > 0) {
			NsiGroup srcNsiGroup = getOtherNsiGroup(relNsn.substring(0, relNsn.indexOf("#")));
			if (srcNsiGroup != null && nsiGroup != null) {
				String nsiGroupSid = srcNsiGroup.getNsiGroupSid();
				if (nsiGroupSid != null && !nsiGroupSid.equals(nsiGroup.getNsiGroupSid())) {
					if (splitEffect.equals(NsiGroup.SPLIT_EFFECTIVITY)
							 && srcNsiGroup.getSplitEffect().equals(NsiGroup.SPLIT_EFFECTIVITY)) {
						msg.append("[Warning: the selected related NSN has a SPLIT effectivity.]");
						confirmMsg = "Warning: the selected related NSN has a SPLIT effectivity - continue?";
					}
				}
			}
		}
	}


	/**
	 *  Attempt to get the data for a given field from the request object.
	 *  If the data is not in the request object, attempt to retrieve it
	 *  from a cookie.  If cookie data cannot be found, use the default
	 *  data.  Convert the data to upppercase when indicated.
	 *
	 *@param  fieldName           Description of the Parameter
	 *@param  cookieName          Description of the Parameter
	 *@param  defaultValue        Description of the Parameter
	 *@param  convertToUpperCase  Description of the Parameter
	 *@return                     The dataViaCookie value
	 */
	private String getDataViaCookie(String fieldName, String cookieName, String defaultValue, boolean convertToUpperCase) {
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
			if (convertToUpperCase) {
				value = value.toUpperCase();
			}
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
	 *  Attempt to get the data for a given field from the request object.
	 *  If the data is not in the request object, attempt to retrieve it
	 *  from a cookie.  If cookie data cannot be found, use the default
	 *  data.  
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
	 *@return    The deplete by date for the top nsn of the Config.jsp page.
	 */
	public String getDepleteBy() {
		return depleteBy;
	}


	/**
	 *  Create a FleetSize object
	 *
	 *@param  aircraft                   the aircraft selected by the Config.jsp
	 *      page
	 *@param  fleetSizeName              the fleet size name
	 *@param  fleetSizeDesc              the description of the fleet
	 *@param  predefined                 indicates if the fleet size is predefined
	 *@return                            The fleetSize value
	 *@exception  java.sql.SQLException  Description of the Exception
	 */
	protected FleetSize getFleetSize(String aircraft[],
			String fleetSizeName,
			String fleetSizeDesc,
			boolean predefined) throws java.sql.SQLException {
		logger.debug("getting fleet size.");
		String p_no = "";
		String ac_no = "";
		String tail_no = "";

		FleetSize fleetSize = new FleetSize();
		fleetSize.setFleetSizeName(fleetSizeName);
		fleetSize.setFleetSizeDesc(fleetSizeDesc);
		fleetSize.setPredefinedFleetSize(predefined);

		FleetSizeMembers fleetSizeMembers = fleetSize.getFleetSizeMembers();

		if (aircraft != null) {
			for (int i = 0; i < aircraft.length; i++) {
				String items[] = Utils.split(aircraft[i], "-");
				fleetSizeMembers.add(fleetSizeName,
				/*
				 *  pNo
				 */
						items[0],
				/*
				 *  acNo
				 */
						items[1],
				/*
				 *  tailNo
				 */
						items[2]);
			}
		} else {
			fleetSizeMembers.load(fleetSizeName, userid);
		}
		return fleetSize;
	}


	/**
	 *  This returns the lastElement accesed by the Config.jsp form. It can cause
	 *  the output html page to scroll to a specific spot - using either a hidden
	 *  html anchor or by using the focus method for the given element - in the
	 *  case the element is the index into the the JavaScript object
	 *  document.forms[subscript].elements[lastElenent]. This field number is
	 *  returned by a JavaScript that is invoked whenever an element receives
	 *  focus. This scripts then determines the index number for the element.
	 *
	 *@return    The lastElement value
	 */
	public String getLastElement() {
		return lastElement;
	}


	/**
	 *@return    The latestConfig for the top nsn of the Config.jsp page.
	 */
	public String getLatestConfig() {
		return latestConfig;
	}


	/**
	 *@return    Any warning or error message generated during the invocation of
	 *      the execute method.
	 *@see       #execute()
	 */
	public String getMsg() {
		return this.msg.toString();
	}


	/**
	 *  All the data for a session is maintained in an instance of the class
	 *  WorkingSet. This class contains a collection of all the data worked on
	 *  during a session.
	 *
	 *@return    The myWorkingSet value
	 */
	public WorkingSet getMyWorkingSet() {
		return myWorkingSet;
	}


	/**
	 *@return    The current nsi_sid for the top nsn
	 */
	public String getNsiSid() {
		return this.nsiSid;
	}


	/**
	 *@return    The top nsn
	 */
	public String getNsn() {
		return nsn;
	}


	/**
	 *  Gets the Nsn Filter used by the top NavBar object.
	 *
	 *@return    NavBar.ALL_NSNS or NavBar.NEW_NSNS
	 */
	public String getNsnFilter() {
		return nsnFilter;
	}


	/**
	 *  Gets the nsnListRecCount attribute of the Controller object
	 *
	 *@return    The nsnListRecCount value
	 */
	public int getNsnListRecCount() {
		return topNavBar.getNsnListRecCount();
	}


	/**
	 *@return    The Nsn or Part Number used to do a search by the top instance of
	 *      the NavBar class. This could be an empty string.
	 */
	public String getNsnVpn() {
		return nsnVpn;
	}


	/**
	 *  Create a Pairs object that is ordered by NSN or by Part Number
	 *
	 *@param  pairs        the pairs belonging to the current group
	 *@param  relatedNsns  the related nsn's belonging to the current group
	 *@return              The orderedPairs value: sorted by NSN or by PartNo
	 */
	protected java.util.Map getOrderedPairs(Pairs pairs, RelatedNsns relatedNsns) {
	    logger.debug("in getOrderedPairs") ;
		
		if (pairs == null) {
			return null;
		}

		java.util.Set keys = pairs.keySet();
		if (keys == null) {
			return null;
		}

		java.util.Iterator iterator = keys.iterator();
		java.util.TreeMap map = new java.util.TreeMap();
		if (logger.isDebugEnabled()) {
		    logger.debug("searchBy=" + searchBy) ;
		}
		if (searchBy.equals(NavBar.BY_NSN)) {
			while (iterator.hasNext()) {
				Pair pair = (Pair) pairs.get(iterator.next());
				map.put(pair.getLhs() + pair.getRhs(), pair);
			}
		} else if (searchBy.equals(NavBar.BY_VPN)) {
		    try {
			    while (iterator.hasNext()) {
				    Pair pair = (Pair) pairs.get(iterator.next());
				    if (pair == null) {
				        continue ;
				    }
				    RelatedNsn relNsn1 = (RelatedNsn) relatedNsns.get(pair.getLhsNsiSid());
				    if (relNsn1 == null) {
				        continue ;
				    }
				    if (logger.isDebugEnabled()) {
				        logger.debug("relNsn1.getNsn()=" + relNsn1.getNsn()) ;
				    }
				    String Part1 = relNsn1.getPartNo();
				    if (logger.isDebugEnabled()) {
				        logger.debug("Part1=" + Part1) ;
				    }
				    if (logger.isDebugEnabled()) {
				        logger.debug("pair.getRhsNsiSid()=" + pair.getRhsNsiSid()) ;
				    }
				    RelatedNsn relNsn2 = (RelatedNsn) relatedNsns.get(pair.getRhsNsiSid());
				    if (logger.isDebugEnabled()) {
				        logger.debug("relNsn2=" + relNsn2) ;
				    }    
				    if (relNsn2 == null) {
				        continue ;
				    }
				    if (logger.isDebugEnabled()) {
				        logger.debug("relNsn2.getNsn()=" + relNsn2.getNsn()) ;
				    }
				    String Part2 = relNsn2.getPartNo();
				    if (logger.isDebugEnabled()) {
				        logger.debug("Part1=" + Part1 + " Part2=" + Part2) ;
				    }
    				
				    map.put(Part1 + Part2, pair);
			    }
			} catch (Exception e) {
			    logger.error(e.toString() + ": " + e.getMessage()) ;
			}
			logger.debug("end while") ;
		} else {
			while (iterator.hasNext()) {
				Pair pair = (Pair) pairs.get(iterator.next());
				map.put(pair.getLhs() + pair.getRhs(), pair);
			}
		}
		if (logger.isDebugEnabled()) {
		    logger.debug("map=" + map) ;
		}
		return map;
	}


	/**
	 *  For a given nsiSid create its NsiGroup object
	 *
	 *@param  nsiSid                     the national stock items key
	 *@return                            the nsi_group associated with the given
	 *      key
	 *@exception  java.sql.SQLException  This exception can occur, since the class
	 *      loads data from the Oracle data base via JDBC.
	 */
	protected NsiGroup getOtherNsiGroup(String nsiSid)
			 throws java.sql.SQLException {
		logger.debug("getting other group for the selected nsn.");

		RelatedNsn srcRelatedNsn = RelatedNsn.load(nsiSid, userid);
		// 08/12/02 dse check for null value
		if (srcRelatedNsn != null) {
		    return srcRelatedNsn.getNsiGroup();
		} else {
		    return null ;
		}
	}


	/**
	 *  Gets the pairsTable attribute of the Controller object
	 *
	 *@return    The pairsTable value
	 */
	public String getPairsTable() {
		logger.debug("getting pairs table.");

		String html;
		if (topNsn == null) {
			return "";
		}
		java.util.Map pairs = getOrderedPairs(nsiGroup.getPairs(), nsiGroup.getRelatedNsns());
		if (logger.isDebugEnabled()) {
		    logger.debug("pairs=" + pairs) ;
		}
		if (pairs == null) {
			logger.error("pairs is null");
			return "";
		} else if (pairs.size() == 0) {
			logger.debug("pairs is empty");
			return "";
		}

		html = "<table border=1 cellpadding=2 cellspacing=0 width=100%><!- Start TableC-->\n";
		html = html + "<tr bgcolor=\"#9bbad6\">\n";
		html = html + "<td colspan=4 align=left><font face=\"Arial,Helvetica\" size=-1>\n";
		html = html + "<input type=button onclick=\"DoAction('" + ACTION_SAVE + "');\" value=\"Save\">\n";
		html = html + "</td>\n";
		html = html + "<tr>\n";
		html = html + "<th>NSN1 / PN1\n";
		html = html + "<th>NSN2 / PN2\n";
		html = html + "<th>Type\n";
		html = html + "<th>Upgradable\n";

		java.util.Iterator iterator = pairs.values().iterator();
		RelatedNsns relatedNsns = nsiGroup.getRelatedNsns();
		while (iterator.hasNext()) {
			Pair aPair = (Pair) iterator.next();
			String Nsn1 = aPair.getLhs();
			if (logger.isDebugEnabled()) {
				logger.debug("Nsn1=" + Nsn1);
			}
			if (logger.isDebugEnabled()) {
				logger.debug("nsiGroupSid=" + nsiGroup.getNsiGroupSid());
			}
			if (logger.isDebugEnabled()) {
				logger.debug("aPair.getLhsNsiSid()=" + aPair.getLhsNsiSid());
			}
			RelatedNsn relNsn1 = (RelatedNsn) relatedNsns.get(aPair.getLhsNsiSid());
			if (logger.isDebugEnabled()) {
				logger.debug("relNsn1=" + relNsn1 + " aPair.getLhsNsiSid()=" + aPair.getLhsNsiSid());
			}
			if (relNsn1 == null) {
				logger.error("relNsn1 is NULL.");
				continue;
			}
			String Part1 = relNsn1.getPartNo();
			String Nsn2 = aPair.getRhs();

			if (logger.isDebugEnabled()) {
				logger.debug("aPair.getRhsNsiSid()=" + aPair.getRhsNsiSid());
			}

			RelatedNsn relNsn2 = (RelatedNsn) nsiGroup.getRelatedNsns().get(aPair.getRhsNsiSid());
			if (relNsn2 == null) {
				logger.error("relNsn2 is NULL.");
				continue;
			}
			String Part2 = relNsn2.getPartNo();
			Nsn1 = Nsn1 + " / " + Part1;
			Nsn2 = Nsn2 + " / " + Part2;
			String InterChgNot = "";
			String InterChg1Way = "";
			String InterChg2Way = "";
			String InterChgLimited = "";
			if (logger.isDebugEnabled()) {
			    logger.debug("For " + Nsn1 + " and " + Nsn2 + " interchangeTyep=" + aPair.getInterChangeType()) ;
			}
			if (aPair.getInterChangeType().equalsIgnoreCase(Pair.NOT_INTERCHANGEABLE)) {
				InterChgNot = "selected";
			} else if (aPair.getInterChangeType().equalsIgnoreCase(Pair.ONE_WAY)) {
				InterChg1Way = "selected";
			} else if (aPair.getInterChangeType().equalsIgnoreCase(Pair.TWO_WAY)) {
				InterChg2Way = "selected";
			} else {
				InterChgLimited = "selected";
			}

			String UpgrdYes = "";
			String UpgrdNo = "";
			if (aPair.getUpgradable()) {
				UpgrdYes = "selected";
			} else {
				UpgrdNo = "selected";
			}
			html = html + "<tr>\n";
			html = html + "<td>" + Nsn1 + "\n";
			html = html + "<input type=hidden name=Nsn1 value=" + Nsn1 + ">\n";
			html = html + "<td>" + Nsn2 + "\n";
			html = html + "<input type=hidden name=Nsn2 value=" + Nsn2 + ">\n";
			html = html + "<td align=center><select onFocus='lastField(this);' name=cboInterChg>\n";
			html = html + "<option " + InterChgNot + " value=" + Pair.NOT_INTERCHANGEABLE + ">Not Interchangeable\n";
			html = html + "<option " + InterChg1Way + ">" + Pair.ONE_WAY + "\n";
			html = html + "<option " + InterChg2Way + ">" + Pair.TWO_WAY + "\n";
			html = html + "<option " + InterChgLimited + " value=" + Pair.LIMITED + ">Limited\n";
			html = html + "</select>\n";
			html = html + "<td align=center><select onFocus='lastField(this);' name=cboUpgradable>\n";
			html = html + "<option " + UpgrdYes + ">Yes\n";
			html = html + "<option " + UpgrdNo + ">No\n";
			html = html + "</select>\n";
		}
		html = html + "<tr bgcolor=\"#9bbad6\">\n";
		html = html + "<td colspan=4 align=right><font face=\"Arial,Helvetica\" size=-1>\n";
		html += "&nbsp;\n";
		html = html + "</td>\n";
		html = html + "</table><!- End TableC-->\n";
		return html;
	}


	/**
	 *@return    The Part Number of the top nsn.
	 */
	public String getPartNo() {
		return partNo;
	}


	/**
	 *@return    The planner code associated with the top nsn of the Config.jsp
	 *      page.
	 */
	public String getPlannerCode() {
		return plannerCode;
	}


	/**
	 *@return    The predefinedFleetSizeDesc value
	 */
	public String getPredefinedFleetSizeDesc() {
		return predefinedFleetSizeDesc;
	}


	/**
	 *@return    The html needed to generate the predefined fleet size list.
	 */
	public String getPredefinedFleetSizeHtml() {
		return predefinedFleetSizeHtml;
	}


	/**
	 *@return    The name of a predefined fleet size: currently this can be All
	 *      Aircraft, USAF, or UK.
	 */
	public String getPredefinedFleetSizeName() {
		return predefinedFleetSizeName;
	}


	/**
	 *  Gets the primaryNsnHtml attribute of the Controller object
	 *
	 *@return    The primaryNsnHtml value
	 */
	public String getPrimaryNsnHtml() {
		logger.debug("getting primary (top) nsn html.");

		String html;
		html = "<table border=\"0\" width=100% cellspacing=\"2\" cellpadding=\"0\"><!- Start TableA-->\n";
		html = html + "<tr valign=top><!- Row 1 for TableA -->\n";
		html = html + "<td>\n";

		html = html + startFrame("Effectivity Type");

		html = html + "<table border=\"0\" cellpadding=\"4\" cellspacing=\"0\"><!- Start TableC-->\n";
		html = html + "<tr height=100%><td align=\"center\">\n";
		html = html + "<table border=\"0\" cellpadding=\"0\" cellspacing=\"0\"><!- Start TableC.1-->\n";
		html = html + "<tr>\n";
		html = html + "<td align=\"right\">\n";
		html = html + "Single Configuration\n";
		html = html + "</td>\n";

		String SplitEffectivity = "";
		String SingleEffectivity = "";

		if (splitEffect.equals(NsiGroup.SPLIT_EFFECTIVITY)) {
			SplitEffectivity = "checked";
		} else if (splitEffect.equals(NsiGroup.SINGLE_EFFECTIVITY)) {
			SingleEffectivity = "checked";
		} else {
			SingleEffectivity = "checked";
		}
		html = html + "<td><input onFocus='lastField(this);' type=radio name=SplitEffect " + SingleEffectivity + " value=" + NsiGroup.SINGLE_EFFECTIVITY + " ></td>\n";
		html = html + "<td align=\"right\">Split Configuration</td>\n";
		html = html + "<td><input onFocus='lastField(this);' type=radio name=SplitEffect " + SplitEffectivity + " value=" + NsiGroup.SPLIT_EFFECTIVITY + " ></td>\n";
		html = html + "</table><!- End TableC.1-->\n";

		html = html + "</td>\n";
		html = html + "</tr>\n";
		html = html + "<tr>\n";
		html = html + "<td>\n";

		html = html + "<table border=\"0\" cellpadding=\"0\" cellspacing=\"0\"><!- Start TableN-->\n";
		html = html + "<tr>\n";
		html = html + "<td colspan=2>For " + nsn + "</td>\n";
		html = html + "</tr>\n";
		html = html + "<tr>\n";
		html = html + "<td align=right nowrap>Start Date:</td>\n";
		html = html + "<td><input onFocus='lastField(this);' type=text size=10 name=txtStartDate value=\"" + startDate + "\"><a href=\"javascript:show_calendar('" + Controller.FORM_NAME + ".txtStartDate');\" onmouseover=\"window.status='Date Picker';return true;\" onmouseout=\"window.status='';return true;\"><img src=\"images/show-calendar.gif\" width=24 height=22 border=0></a>\n";
		html = html + "</td>\n";
		html = html + "</tr>\n";
		html = html + "<tr>\n";
		html = html + "<td align=right nowrap>Never Buy/Deplete Stock:</td>\n";
		html = html + "<td><input onFocus='lastField(this);' type=text size=10 name=txtNeverBuy value=\"" + depleteBy + "\"><a href=\"javascript:show_calendar('" + Controller.FORM_NAME + ".txtNeverBuy');\" onmouseover=\"window.status='Date Picker';return true;\" onmouseout=\"window.status='';return true;\"><img src=\"images/show-calendar.gif\" width=24 height=22 border=0></a>\n";
		html = html + "</td>\n";
		html = html + "</tr>\n";
		html = html + "<tr>\n";
		html = html + "<td align=right nowrap>Latest Config:</td>\n";
		html = html + "<td><select onFocus='lastField(this);' name=cboLatestConfig>\n";
		String LatestConfigYes = "";
		String LatestConfigNo = "";
		if (logger.isDebugEnabled()) {
			logger.debug("2. latestConfig=" + latestConfig);
		}
		if (latestConfig.equals("Y")) {
			LatestConfigYes = "selected";
		} else {
			LatestConfigNo = "selected";
		}

		html += "<option value='Y' " + LatestConfigYes + ">Yes\n";
		html += "<option value='N' " + LatestConfigNo + ">No\n";
		html += "</select>\n";
		html += "</td>\n";
		html += "</tr>\n";
		html += "<tr>\n" ;
		html += "<td align=right nowrap>Updated:</td>\n" ;
		html += "<td>" + topNsn.getEffectLastUpdateDt() + "</td>\n" ;
		html += "</tr>\n" ;
		html += "<tr>\n" ;
		html += "<td align=right nowrap>By:</td>\n" ;
		html += "<td>" + topNsn.getEffectLastUpdateId() + "</td>\n" ;
		html += "</tr>\n" ;
		html += "</table><!- End TableN-->\n";
		html += "</table><!- End TableC-->\n";

		html += endFrame("Effectivity Type");

		html += "<td valign=top width=5 background=\"images/bg.gif\"></td>\n";
		html += "<td><!- Cell 2 for TableA Fleetsize-->\n";

		html = html + "<table bgcolor=\"#a0b8c8\" border=\"0\" cellpadding=\"2\" cellspacing=\"0\" width=100%><!- Start TableP with pale blue border-->\n";
		html = html + "<tr><td>\n";
		html = html + "<table bgcolor=\"#eeeeee\" border=\"0\" cellpadding=\"2\" cellspacing=\"0\" width=\"100%\"><!- Start TableP.1 with slightly gray border-->\n";
		html = html + "<tr><td>\n";
		html = html + "<table border=\"0\" cellspacing=\"6\" cellpadding=\"6\" bgcolor=\"#ffffff\" width=\"100%\"><!- Start TableP.1.1 with white border-->\n";
		html = html + "<tr bgcolor=\"#eeeeee\"><!- row content should have slightly gray background -->\n";
		html = html + "<td align=\"center\"><font face=\"arial\"><b>Predefined Fleetsize\n";
		html = html + "</b></font>\n";
		html = html + "<table border=\"0\" cellpadding=\"4\" cellspacing=\"0\"><!- Start TableP.1.1.1-->\n";
		html = html + "<tr>\n";
		html = html + "<td>\n";
		html = html + getPredefinedFleetSizeHtml();
		html = html + "<td align=left>" + getPredefinedFleetSizeDesc() + "\n";
		html = html + "<tr bgcolor=\"#eeeeee\">\n";
		html = html + "<td align=\"center\"> <font face=\"arial\"><b>- OR -\n";
		html = html + "</b></font>\n";

		html = html + "<tr bgcolor=\"#eeeeee\">\n";
		html = html + "<td align=\"center\"> <font face=\"arial\"><b>User Defined Fleetsize\n";
		html = html + "</b></font>\n";
		html = html + "<table border=\"0\" cellpadding=\"4\" cellspacing=\"0\"><!- Start TableU-->\n";
		html = html + "<tr><td>\n";
		html = html + getAircraftHtml();
		html = html + "</td>\n";
		html = html + "<td>\n";
		html = html + "<table cellspacing=\"0\" cellpadding=\"0\"><!- Start TableU.1-->\n";
		html = html + "<tr>\n";
		html = html + "<td align=center>\n";
		effectivity.AcDisplayCntl acDisplayCntl = new AcDisplayCntl();
		acDisplayCntl.setOnChange("acByChanged();");
		acDisplayCntl.setBy(acBy);
		try {
			acDisplayCntl.genHtml();
		} catch (Exception e) {
			html += e.getMessage();
		}
		html += acDisplayCntl.getHtml();
		html = html + "</table><!- End TableU.1-->\n";
		html = html + "</table><!- End TableU-->\n";
		html = html + "</table><!- End TableP.1.1.1-->\n";
		html = html + "</table><!- End TableP.1.1-->\n";
		html = html + "</table><!- End TableP.1-->\n";
		html = html + "</table><!- End TableP-->\n";
		html = html + "</td>\n";
		html = html + "</tr>\n";
		html = html + "</table><!- End TableA-->\n";
		html = html + "<input onFocus='lastField(this);' type=button onClick=\"DoAction('" + ACTION_SAVE + "')\" value=Save>\n";
		return html;
	}


	/**
	 *  For the 2nd NavBar used to select related nsn's that are to be added to the
	 *  group, this returns the nomenclature associated with that nsn.
	 *
	 *@return    The nomenclature of the currently selected related nsn.
	 */
	public String getRelNomenclature() {
		return relNomenclature;
	}


	/**
	 *  RELATED nsn's are selected using the 2nd instance of the NavBar class
	 *  contained on the html page generated by the Config.jsp. They are placed in
	 *  a single group using the ADD button associated with the 2nd NavBar.
	 *
	 *@return    The nsi_sid of the currently selected related nsn.
	 */
	public String getRelNsiSid() {
		return relNsiSid;
	}


	/**
	 *@return    The Nsn of the currently selected RELATED nsn.
	 */
	public String getRelNsn() {
		return relNsn;
	}


	/**
	 *@return    The RELATED nsn or part number used by the 2nd NavBar
	 */
	public String getRelNsnVpn() {
		return relNsnVpn;
	}


	/**
	 *@return    The RELATED part no currently selected by the 2nd NavBar on the
	 *      Config.jsp page.
	 */
	public String getRelPartNo() {
		return relPartNo;
	}


	/**
	 *@return    The current RELATED planner code selected by the 2nd NavBar on the
	 *      Config.jsp page.
	 */
	public String getRelPlannerCode() {
		return relPlannerCode;
	}


	/**
	 *@return    The RELATED search criteria used by the 2nd NavBar.
	 */
	public String getRelSearchBy() {
		return relSearchBy;
	}


	/**
	 *@return    The instance of the NavBar associated with the RELATED nsn's.
	 */
	public String getRelatedNsnSearch() {
		return relatedNsnSearch.getHtml();
	}


	/**
	 *  Gets the relatedNsnsTable attribute of the Controller object
	 *
	 *@return    The html for the relatedNsnsTable
	 */
	public String getRelatedNsnsTable() {
		logger.debug("getting the related nsn table.");

		String html;
		if (topNsn == null) {
			return "";
		}
		if (logger.isDebugEnabled()) {
			logger.debug("nsiGroupSid=" + nsiGroup.getNsiGroupSid());
		}
		java.util.Map relatedNsns = getSortedMap(nsiGroup.getRelatedNsns());

		if (logger.isDebugEnabled()) {
			logger.debug("relatedNsns.size()=" + relatedNsns.size());
		}
		if (relatedNsns == null) {
			return "";
		} else if (relatedNsns.size() == 0) {
			return "";
		}

		html = "<table border=1 cellpadding=2 cellspacing=0 width=100%><!- Start TableB-->\n";
		html = html + "<tr bgcolor=#9bbad6>\n";
		html = html + "<td colspan=7><font face='Arial,Helvetica' size=-1>";
		html = html + "<input onFocus='lastField(this);' type=button onclick=\"DoAction('" + ACTION_REMOVE + "')\" value=\"Remove\">\n";
		html = html + "checked item\n";
		html = html + "</td>\n";
		html = html + "<tr>\n";
		html = html + "<th>&nbsp\n";
		html = html + "<th>NSN\n";
		html = html + "<th>PN\n";
		html = html + "<th>Nomenclature\n";
		html = html + "<th>Start Date\n";
		html = html + "<th>Never/Buy Deplete Stock\n";
		html = html + "<th>Latest Config\n";

		java.util.Iterator iterator = relatedNsns.values().iterator();
		int i = 0;
		int size = relatedNsns.size();
		while (iterator.hasNext()) {
			RelatedNsn relatedNsn = (RelatedNsn) iterator.next();
			if (relatedNsn.getNsiSid().equals(topNsn.getNsiSid())) {
				continue;
			}
			String depleteBy = relatedNsn.getDepleteBy();
			if (depleteBy == null) {
				depleteBy = "";
			}
			String startDate = relatedNsn.getStartDate();
			if (startDate == null) {
				startDate = "";
			}
			String latestConfig = relatedNsn.getLatestConfig();
			if (latestConfig == null) {
				latestConfig = latestConfigDefault;
			}

			String relNsn = relatedNsn.getNsn();
			String relNsiSid = relatedNsn.getNsiSid();
			html = html + "<tr>\n";
			html = html + "<td><input onFocus='lastField(this);' type=checkbox name=\"Remove\" value=" + relatedNsn.getNsiSid() + ":" + relatedNsn.getNsn() + ">\n";
			html = html + "<td>" + relNsn + "\n";
			html = html + "<input onFocus='lastField(this);' type=hidden name=RelNsn value=" + relNsiSid + ">\n";
			html = html + "<td>" + relatedNsn.getPartNo() + "\n";
			html = html + "<td>" + relatedNsn.getNomenclature() + "\n";
			if (size > 2) {
				html = html + "<td><input onFocus='lastField(this);'  type=text width=15 name=txtAStartDate value=\"" + startDate + "\"><a href=\"javascript:show_calendar('" + Controller.FORM_NAME + ".txtAStartDate(" + i + ")');\" onmouseover=\"window.status='Date Picker';return true;\" onmouseout=\"window.status='';return true;\"><img src=\"images/show-calendar.gif\" width=24 height=22 border=0></a>\n";
				html = html + "<td><input onFocus='lastField(this);' type=text width=15 name=txtDepleteBy value=\"" + depleteBy + "\"><a href=\"javascript:show_calendar('" + Controller.FORM_NAME + ".txtDepleteBy(" + i + ")');\" onmouseover=\"window.status='Date Picker';return true;\" onmouseout=\"window.status='';return true;\"><img src=\"images/show-calendar.gif\" width=24 height=22 border=0></a>\n";
				i++;
			} else {
				html = html + "<td><input onFocus='lastField(this);' type=text width=15 name=txtAStartDate value=\"" + startDate + "\"><a href=\"javascript:show_calendar('" + Controller.FORM_NAME + ".txtAStartDate');\" onmouseover=\"window.status='Date Picker';return true;\" onmouseout=\"window.status='';return true;\"><img src=\"images/show-calendar.gif\" width=24 height=22 border=0></a>\n";
				html = html + "<td><input onFocus='lastField(this);' type=text width=15 name=txtDepleteBy value=\"" + depleteBy + "\"><a href=\"javascript:show_calendar('" + Controller.FORM_NAME + ".txtDepleteBy');\" onmouseover=\"window.status='Date Picker';return true;\" onmouseout=\"window.status='';return true;\"><img src=\"images/show-calendar.gif\" width=24 height=22 border=0></a>\n";
			}
			html = html + "<td width=25><select onFocus='lastField(this);' name=cboALatestConfig>\n";

			String LatestConfigYes = "";
			String LatestConfigNo = "";

			if (latestConfig.equals("Y")) {
				LatestConfigYes = "selected";
			} else {
				LatestConfigNo = "selected";
			}
			html = html + "<option value='Y' " + LatestConfigYes + ">Yes\n";
			html = html + "<option value='N' " + LatestConfigNo + ">No\n";
			html += "</select>";
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
		html = html + "<td colspan=7><font face=\"Arial,Helvetica\" size=-1>\n";
		html = html + "<input onFocus='lastField(this);' name=" + LAST_REMOVE_BUTTON + " type=button onclick=\"DoAction('" + ACTION_REMOVE + "')\" value=\"Remove\">\n";
		html = html + "checked item\n";
		html = html + "</td>\n";
		html = html + "</table><!- End TableB-->\n";

		return html;
	}


	/**
	 *  Using the request object retrieve all the data 
	 *  used by the html FORM for the Config.jsp page
	 */
	protected void getRequestData() 
	{
		logger.debug("getting request data");

		this.theAction = request.getParameter("action");
		if (logger.isDebugEnabled()) {
			logger.debug("theAction=" + theAction);
		}
		if (this.theAction == null) {
			this.theAction = "";
		}

		gotoBottom = getDataViaCookie("gotoBottom", "GotoBottom", "");

		lastElement = request.getParameter("lastElement");
		if (lastElement == null) {
			lastElement = "0";
		}

		String debugParm = getDataViaCookie("debug", "DebugParm", "");
		if (debugParm.equalsIgnoreCase("true")) {
			this.setDebug(true);
		} else {
			this.setDebug(false);
		}

		nsnFilter = getDataViaCookie("optNsnFilter", NSNFILTER, NavBar.NEW_NSNS);

		search = getDataViaCookie("search", "Search", "");
		logger.debug("search=" + search);

		String nsiSidAndNsn = request.getParameter("cboNsn");
		if (logger.isDebugEnabled()) {
			logger.debug("nsiSidAndNsn=" + nsiSidAndNsn);
		}

		if (!search.equals(SEARCH_WITH_REL_NAVBAR) && !search.equals(SEARCH_WITH_TOP_NAVBAR)) {
			nsiSidAndNsn = getDataViaCookie("cboNsn", "NsiSidAndNsn", NavBar.NO_SELECTION);
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
			partNo = NavBar.NO_SELECTION;
		}

		splitEffect = request.getParameter("SplitEffect");
		if (splitEffect == null) {
			splitEffect = "";
		}
		if (logger.isDebugEnabled()) {
			logger.debug("splitEffect=" + splitEffect);
		}
		if (logger.isDebugEnabled()) {
			logger.debug("splitEffect=" + splitEffect);
		}
		depleteBy = request.getParameter("txtNeverBuy");
		if (depleteBy == null) {
			depleteBy = "";
		}
		relatedNsnDepleteBy = request.getParameterValues("txtDepleteBy");

		startDate = request.getParameter("txtStartDate");
		if (startDate == null) {
			startDate = "";
		}

		latestConfig = request.getParameter("cboLatestConfig");
		if (latestConfig == null) {
			latestConfig = latestConfigDefault;
		}

		nsiSidToBeRemovedList = request.getParameterValues("Remove");
		relatedNsnLatestConfig = request.getParameterValues("cboALatestConfig");
		relNsiSidList = request.getParameterValues("RelNsn");
		relStartDateList = request.getParameterValues("txtAStartDate");

		predefinedFleetSizeName = request.getParameter("cboFleetSize");
		if (predefinedFleetSizeName == null) {
			predefinedFleetSizeName = NavBar.NO_SELECTION;
		}

		acBy = getDataViaCookie("acBy", "ACBy", "p_no");
		if (acBy.equals("")) {
			acBy = "p_no";
		}

		aircraft = request.getParameterValues("cboAC");
		if (aircraft != null && !aircraft[0].equals(NO_SELECTION)) {
			predefinedFleetSizeName = "?";
			predefinedFleetSizeDesc = "?";
			usePredefinedFleetSize = false;
		} else {
			usePredefinedFleetSize = true;
		}

		plannerCode = request.getParameter("cboPlanner");
		if (logger.isDebugEnabled()) {
			logger.debug("plannerCode=" + plannerCode);
		}
		if (plannerCode == null) {
			plannerCode = NavBar.NO_SELECTION;
		}

		if (request.getParameter("txtNsnVpn") == null)
			nsnVpn = "";
		else
			nsnVpn = getDataViaCookie("txtNsnVpn", "TopSearchBy", "", true);
		

		searchBy = getDataViaCookie("optSearchBy", "SearchBy", NavBar.BY_NSN);

		nsn = request.getParameter("txtNsn");
		if (nsn == null) {
			nsn = "";
		}

		relNsn = getDataViaCookie(RELATED_NSN_COMBO_BOX, "RelNsn", NavBar.NO_SELECTION);
		if (relNsn.indexOf("#") > 0) {
			relNsiSid = relNsn.substring(0, relNsn.indexOf("#"));
		} else {
			relNsiSid = NavBar.NO_SELECTION;
		}

		relPartNo = request.getParameter(RELATED_PARTNO_COMBO_BOX);
		if (relPartNo == null) {
			relPartNo = NavBar.NO_SELECTION;
		}

		relNomenclature = request.getParameter(RELATED_NOMEN_TEXT_BOX);
		if (relNomenclature == null) {
			relNomenclature = "";
		}

		relPlannerCode = request.getParameter(RELATED_PLANNER_COMBO_BOX);
		if (logger.isDebugEnabled()) {
			logger.debug("relPlannerCode=" + relPlannerCode);
		}
		if (relPlannerCode == null) {
			relPlannerCode = NavBar.NO_SELECTION;
		}

		// needs to be uppercase
		relNsnVpn = getDataViaCookie("txtRelNsnVpn", "RelNsnVpn", "", true);

		relSearchBy = getDataViaCookie("optRelSearchBy", "RelSearchBy", NavBar.BY_NSN);

		views = request.getParameterValues("chkView");
		if (views == null) {
			chkPairs = getCookie("ChkPairs", "");
			chkRelatedNsns = getCookie("ChkRelatedNsns", "checked");
		} else {
			chkPairs = "";
			chkRelatedNsns = "";
			for (int i = 0; i < views.length; i++) {
				if (views[i].equals("RelatedNsns")) {
					chkRelatedNsns = "checked";
				}
				if (views[i].equals("Pairs")) {
					chkPairs = "checked";
				}
			}
			setCookie("ChkPairs", chkPairs);
			setCookie("ChkRelatedNsns", chkRelatedNsns);
		}
		if (chkPairs == null) {
			chkPairs = "";
		}
		if (chkRelatedNsns == null) {
			chkRelatedNsns = "";
		}
		if (chkPairs.equals("") && chkRelatedNsns.equals("")) {
			chkRelatedNsns = "checked";
		}
	}


	/**
	 *  Gets the revision attribute of the Controller object
	 *
	 *@return    The revision value
	 */
	public String getRevision() {
		return revision;
	}


	/**
	 *@return    The value used by the Search JavaScript associated with both
	 *      NavBar's. This is used to distinguish which NavBar is doing the search:
	 *      Controller.SEARCH_WITH_TOP_NAVBAR or
	 *      Controller.SEARCH_WITH_BOTTOM_NAVBAR.
	 */
	public String getSearch() {
		return search;
	}


	/**
	 *@return    The search criteria used by the top NavBar: NavBar.BY_NSN or
	 *      NavBar.BY_VPN.
	 */
	public String getSearchBy() {
		return searchBy;
	}


	/**
	 *  For a given RelatedNsns object create a Map that is
	 *  ordered by nsn or by part number.  The searchBy field
	 *  is retrieved from the request object (the html form).
	 * 
	 *
	 *@param  relatedNsns  the collection of related nsn's for the current group
	 *@return              The sortedMap value order by Nsn or PartNo
	 */
	protected java.util.Map getSortedMap(RelatedNsns relatedNsns) {
		java.util.Set keys = relatedNsns.keySet();
		java.util.Iterator iterator = keys.iterator();
		java.util.TreeMap map = new java.util.TreeMap();
		if (searchBy.equals(NavBar.BY_NSN)) {
			while (iterator.hasNext()) {
				RelatedNsn relatedNsn = (RelatedNsn) relatedNsns.get(iterator.next());
				map.put(relatedNsn.getNsn(), relatedNsn);
			}
		} else if (searchBy.equals(NavBar.BY_VPN)) {
			while (iterator.hasNext()) {
				RelatedNsn relatedNsn = (RelatedNsn) relatedNsns.get(iterator.next());
				map.put(relatedNsn.getPartNo(), relatedNsn);
			}
		} else {
			while (iterator.hasNext()) {
				RelatedNsn relatedNsn = (RelatedNsn) relatedNsns.get(iterator.next());
				map.put(relatedNsn.getNsn(), relatedNsn);
			}
		}
		return map;
	}


	/**
	 *  Gets the splitConfigurationTables attribute of the Controller object
	 *
	 *@return    The html for the splitConfigurationTables
	 */
	public String getSplitConfigurationTables() {
		logger.debug("getting split configuration tables.");

		String html;

		html = "<hr>\n";
		html += "<a name=\"" + START_RELATED_NSNS + "\"></a>";
		html = html + "<table cellpadding=\"0\" cellspacing=\"0\" border=\"0\"><!- Start TableC-->\n";
		html = html + "<tr>\n";
		html = html + "<td>Related NSN\n";
		// 08/12/02 dse changed goto to gotoLink to conform to the Config.jsp file and Netscape's strict usage of JavaScript reservied words.  Added # to generate correct hyperlink to a named anchor, which does not have the #.
		html = html + "<input onFocus='document.forms[0].elements.value=\"gotoLink(\\\"#" + START_RELATED_NSNS + "\\\");\";' type=button value=Search onClick=\"Search(" + SEARCH_WITH_REL_NAVBAR + ")\">\n";
		html = html + "<input onFocus='lastField(" + Controller.FORM_NAME + "." + LAST_REMOVE_BUTTON + ");' type=button value=Add onclick=\"DoAction('" + ACTION_ADD + "')\">\n";
		String byNsn = "";
		String byVpn = "";
		if (relSearchBy.equals(BY_VPN)) {
			byVpn = "checked";
		} else {
			byNsn = "checked";
		}

		html = html + "<input onFocus='lastField(this);' type=\"Radio\" name=\"optRelSearchBy\" value=\"" + BY_NSN + "\"" + byNsn + ">&nbsp;NSN&nbsp;\n";
		html = html + "<input onFocus='lastField(this);' type=\"RADIO\" name=\"optRelSearchBy\" value=\"" + BY_VPN + "\"" + byVpn + ">&nbsp;PN&nbsp;\n";
		html = html + "<input onFocus='lastField(this);' size=\"30\" type=\"text\" name=\"txtRelNsnVpn\" value=\"" + relNsnVpn + "\" onChange='this.value = this.value.toUpperCase();'></td>\n";
		html = html + "</table><!- End TableC-->\n";
		html = html + "<table cellpadding=\"0\" cellspacing=\"0\" border=\"0\"><!- Start TableD-->\n";
		html = html + "<tr>\n";
		html = html + "<td>\n";
		html = html + getRelatedNsnSearch();

		html = html + "<td>\n";
		html = html + "<input onFocus='lastField(this);' type=checkbox name=chkView value=RelatedNsns " + chkRelatedNsns + " onClick=\"ViewChanged();\">View Related Nsns</input>\n";
		html = html + "<td>\n";
		if (logger.isDebugEnabled()) {
			logger.debug("chkRelatedNsns=" + chkRelatedNsns);
		}
		if (logger.isDebugEnabled()) {
			logger.debug("splitEffect=" + splitEffect + " ");
		}
		html = html + "<input onFocus='lastField(this);' type=checkbox name=chkView value=Pairs " + chkPairs + " onClick=\"ViewChanged();\">View Pair List</input>\n";
		html = html + "</table><!- End TableD-->\n";

		if (chkRelatedNsns.equals("checked")) {
			html = html + getRelatedNsnsTable();
		}

		html = html + "<br>\n";
		if (chkPairs.equals("checked")) {
			html = html + getPairsTable();
		}
		return html;
	}


	/**
	 *  The nsn's belong to a group identified by system generated sequence number.
	 *  The group is identified as either a NsiGroup.SINGLE_EFFECTIVITY or a
	 *  NsiGroup.SPLIT_EFFECTIVITY.
	 *
	 *@return    The split effect associated with the group: amd_nsi_groups.
	 */
	public String getSplitEffect() {
		return splitEffect;
	}


	/**
	 *@return    The start date for the top nsn of the Config.jsp page.
	 */
	public String getStartDate() {
		return startDate;
	}


	/**
	 *  Currently there are four actions defined for the Config.jsp page: add,
	 *  remove, save, and enter.
	 *
	 *@return    The current action: ACTION_ADD, ACTION_REMOVE, ACTION_SAVE, or
	 *      ACTION_SEARCH.
	 *@see       #getSearch()
	 */
	public String getTheAction() {
		return theAction;
	}


	/**
	 *@return    The html for the top instance of the NavBar that occurs on the Config.jsp page
	 *      (there are only two NavBar's - top and related nsn's).
	 */
	public String getTopNavBar() {
		return topNavBar.getHtmlWithControls();
	}


	/**
	 *  On the Config.jsp one of the nsn's belonging to a group is selected using
	 *  the top instance of the NavBar. This nsn will be refered to as the TOP NSN.
	 *
	 *@return    This object contains all the information for the top nsn.
	 */
	public RelatedNsn getTopNsn() {
		return topNsn;
	}


	/**
	 *  Gets the userid attribute of the Controller object
	 *
	 *@return    The userid value
	 */
	public String getUserid() {
		return userid;
	}


	/**
	 *  The Config.jsp page has two views: 
	 *  <ul>
	 *  <li>Related Nsns
	 *  <li>Pairs
	 *  </utl>
	 *
	 *@return    The views value
	 */
	public String[] getViews() {
		return views;
	}


	/**
	 *  Gets the PVCS workfile attribute of the Controller object
	 *
	 *@return    The PVCS workfile value
	 */
	public String getWorkfile() {
		return workfile;
	}


	/**
	 *  Gets the indicator that says the predefined fleet size is being used.
	 *
	 *@return    true if the predefined fleet size is being used
	 */
	public boolean getusePredefinedFleetSize() {
		return usePredefinedFleetSize;
	}


	/**
	 *  Gets the beingRemoved attribute of the Controller object
	 *
	 *@param  nsiSid  The national stock items key
	 *@return         The beingRemoved value: true if the given key is being
	 *      removed
	 */
	protected boolean isBeingRemoved(String nsiSid) {
		if (nsiSidToBeRemovedList != null) {
			for (int i = 0; i < nsiSidToBeRemovedList.length; i++) {
				if (nsiSidToBeRemovedList[i].substring(0, nsiSidToBeRemovedList[i].indexOf(":")).equals(nsiSid)) {
					return true;
				}
			}
		}
		return false;
	}


	/**
	 *  A RelatedNsn that has its LatestConfig attribute
	 *  set to 'Y' cannot be removed from the NsiGroup
	 *  unless another RelatedNsn has its LatestConfig
	 *  attribute set to 'Y'.
	 *
	 *@return    The okToRemove value
	 */
	protected boolean isOkToRemove() {
		logger.debug("isOkToRemove");
		return willOneLatestConfigRemain()
				 && willOneDepleteByRemainBlank();
	}


	/**
	 *  Validate the data before any update
	 *
	 *@return    The validData value
	 */
	protected boolean isValidData() {
		logger.debug("validating data.");
		if (nsiSid.equals(NavBar.NO_SELECTION)) {
			errorOccured = true;
			if (msg.length() == 0) {
				lastElement = CBO_NSN_FIELD_NUMBER;
			}
			msg.append("Select an nsn.");
		}
		int numberOfBlankDepleteBy = 0;
		if (depleteBy.equals("")) {
			numberOfBlankDepleteBy++;
		}
		if (relatedNsnDepleteBy != null) {
			for (int i = 0; i < relatedNsnDepleteBy.length; i++) {
				if (relatedNsnDepleteBy[i].equals("")) {
					numberOfBlankDepleteBy++;
				}
			}
		}
		if (numberOfBlankDepleteBy == 0) {
			errorOccured = true;
			msg.append("Add least one Never Buy/Deplete Stock Date must be blank.");
		}

		/*
		 *  Check for one and only one latestConfig when
		 *  nothing is being removed or when there will be
		 *  at least 2 Nsn's in the group after some Nsn's
		 *  have been removed.
		 */
		if (nsiSidToBeRemovedList == null || (nsiGroup != null && nsiGroup.getRelatedNsns().size() - 1 != nsiSidToBeRemovedList.length)) {
			int numberOfLatestConfigsEqualYes = 0;
			if (latestConfig.equals("Y")) {
				numberOfLatestConfigsEqualYes++;
				if (logger.isDebugEnabled()) {
					logger.debug("latestConfig=" + latestConfig + " numberOfLatestConfigsEqualYes=" + numberOfLatestConfigsEqualYes);
				}
			}
			if (relatedNsnLatestConfig != null) {
				for (int i = 0; i < relatedNsnLatestConfig.length; i++) {
					if (!isBeingRemoved(relNsiSidList[i]) && relatedNsnLatestConfig[i].equals("Y")) {
						numberOfLatestConfigsEqualYes++;
						if (logger.isDebugEnabled()) {
							logger.debug("relNsiSidList[" + i + "]="
									 + relNsiSidList[i]
									 + " relatedNsnLatestConfig[" + i + "]="
									 + relatedNsnLatestConfig[i]
									 + " numberOfLatestConfigsEqualYes="
									 + numberOfLatestConfigsEqualYes);
						}
					}
				}
			}
			if (numberOfLatestConfigsEqualYes > 1) {
				errorOccured = true;
				msg.append("Only one Latest Config can be 'Yes'.");
			}
			if (!theAction.equals(Controller.ACTION_ADD)) {
				if (numberOfLatestConfigsEqualYes == 0) {
					errorOccured = true;
					if (theAction.equals(Controller.ACTION_REMOVE)) {
						msg.append("Since you are removing the latest config, you must specifiy a replacement latest config.");
					} else {
						msg.append("At least one Latest Config should be 'Yes'.");
					}
				}
			}
		}
		if (predefinedFleetSizeName.equals(NavBar.NO_SELECTION) && (aircraft == null || (aircraft != null && aircraft.length == 0))) {
			errorOccured = true;
			msg.append("Select a fleet size.");
		} else if (aircraft != null && aircraft.length == 1 && aircraft[0].equals(NavBar.NO_SELECTION)) {
			errorOccured = true;
			msg.append("Select a fleet size.");
		}

		if (splitEffect.equals(NsiGroup.SPLIT_EFFECTIVITY)) {
			if (topNsn != null) {
				RelatedNsns relatedNsns = topNsn.getNsiGroup().getRelatedNsns();

				if (relatedNsns != null && relatedNsns.size() > 1) {
					;
					// do nothing everything is OK
				} else {
					errorOccured = true;
					msg.append("You must add a related nsn before saving a split effectivity.");
				}
			} else {
				errorOccured = true;
				msg.append("You must add a related nsn before saving a split effectivity.");
			}
		}

		return !errorOccured;
	}


	/**
	 *  Create an html (select tag) list of aircrafts.
	 *
	 *@exception  java.sql.SQLException  This exception can occur, since the class
	 *      loads data from the Oracle data base via JDBC.
	 */
	protected void createAircraftList() throws java.sql.SQLException {
		logger.debug("creating Aircraft combo box.");

		aircraftHtml = "<select onFocus='lastField(this);' name=cboAC size=5 multiple>\n";
		ResultSet objAC = null;
		Statement s = conn.createStatement();
		String sqlStmt;
		sqlStmt = "Select p_no, ac_no, tail_no, bun, fsn, fus from amd_aircrafts where not p_no = 'DUM' order by " + acBy;
		logger.info(sqlStmt);
		objAC = s.executeQuery(sqlStmt);
		aircraftHtml += "<option value='" + NO_SELECTION + "'>-None-\n";

		if (objAC != null) {
			while (objAC.next()) {
				aircraftHtml += selectAircraft(objAC.getString("p_no"), objAC.getString("ac_no"), objAC.getString("tail_no"), objAC.getString(acBy)) + "\n";
			}
			objAC.close();
		}
		if (aircraft != null) {
			if (aircraft.length > 0) {
				aircraftHtml += "</select><img src=\"images/red_arrow_down.gif\">\n";
			} else {
				aircraftHtml += "</select>\n";
			}
		} else {
			aircraftHtml += "</select>\n";
		}
		s.close();
	}


	/**
	 *  Create an html (select tag) list of the predefined fleet's that exist in
	 *  the Oracle data base.
	 *
	 *@exception  java.sql.SQLException  This exception can occur, since the class
	 *      loads data from the Oracle data base via JDBC.
	 */
	protected void createPredefinedFleetSizeList()
			 throws java.sql.SQLException {
		logger.debug("creating predefined fleet size combo box.");

		predefinedFleetSizeHtml = "<select onFocus='lastField(this);' name=cboFleetSize size=1 onChange='cboACReset();'>\n";

		if (!predefinedFleetSizeName.equals(NavBar.NO_SELECTION) &&
			!predefinedFleetSizeName.equals("?"))
		{
			aircraft = null;
		}

		if (predefinedFleetSizeName.equals(NavBar.NO_SELECTION)) {
			predefinedFleetSizeHtml = predefinedFleetSizeHtml + "<option selected value='" + NO_SELECTION + "'>-Choose One-\n";
		} else {
			predefinedFleetSizeHtml = predefinedFleetSizeHtml + "<option value='" + NO_SELECTION + "'>-Choose One-\n";
		}

		ResultSet objFleetSizes = null;
		Statement s = conn.createStatement();
		String sqlStmt = "Select fleet_size_name, fleet_size_desc from amd_fleet_sizes where predefined = 'Y' order by fleet_size_name" ;
		logger.info(sqlStmt) ;
		objFleetSizes = s.executeQuery(sqlStmt);

		predefinedFleetSizeDesc = "&nbsp";
		if (objFleetSizes != null) {
			while (objFleetSizes.next()) {
				String fleet_size_name = objFleetSizes.getString("fleet_size_name");
				if (predefinedFleetSizeName.equalsIgnoreCase(fleet_size_name)) {
					predefinedFleetSizeHtml = predefinedFleetSizeHtml + "<option selected value=\"" + fleet_size_name + "\">" + fleet_size_name;
					predefinedFleetSizeDesc = objFleetSizes.getString("fleet_size_desc");
				} else {
					predefinedFleetSizeHtml = predefinedFleetSizeHtml + "<option value=\"" + fleet_size_name + "\">" + fleet_size_name + "\n";
				}
			}
			objFleetSizes.close();
		}
		predefinedFleetSizeHtml = predefinedFleetSizeHtml + "</select>\n";
		s.close();
	}


	/**
	 *  Create the html needed to display the set of related nsn's.
	 *
	 *@exception  java.sql.SQLException  This exception can occur, since the class
	 *      loads data from the Oracle data base via JDBC.
	 */
	protected void createRelatedNsnSearchCntl() throws java.sql.SQLException {
		logger.debug("creating Related Nsn search control using a NavBar.");

		relatedNsnSearch = new NavBar();
		relatedNsnSearch.setUseNsnFilter(false);
		relatedNsnSearch.setSearchBy(relSearchBy);
		relatedNsnSearch.setSearchFieldValue(relNsnVpn);
		relatedNsnSearch.setAllowPartNoSelect(true);
		if (logger.isDebugEnabled()) {
			logger.debug("relNsiSid=" + relNsiSid);
		}
		if (logger.isDebugEnabled()) {
			logger.debug("relNsnVpn=" + relNsnVpn);
		}
		String tempNsnVpn = relNsnVpn;
		if (theAction.equals(Controller.ACTION_SELECT_RELATED_NSN)
				 || theAction.equals(Controller.ACTION_SELECT_RELATED_PLANNER)) {
			tempNsnVpn = "";
		}

		relatedNsnSearch.search(conn, relSearchBy,
				tempNsnVpn, relPlannerCode, relNsiSid,
				relPartNo, RELATED_NSN_COMBO_BOX, RELATED_NSISID_HIDDEN_FIELD,
				RELATED_PARTNO_COMBO_BOX, RELATED_PLANNER_COMBO_BOX, RELATED_NOMEN_TEXT_BOX);
		relNsn = relatedNsnSearch.getNsn();
		if (logger.isDebugEnabled()) {
			logger.debug("createdRelatedNsnSearchCntl: relNsn=" + relNsn);
		}
		relPartNo = relatedNsnSearch.getPartNo();
		if (logger.isDebugEnabled()) {
			logger.debug("createdRelatedNsnSearchCntl: relPartNo=" + relPartNo);
		}
	}


	/**
	 *  End's an html table used to create a 'frame effect'
	 *
	 *@param  frameTitle  The name of the frame
	 *@return             the html tag to end a table plus a comment containing the
	 *      frame's title
	 */
	protected String endFrame(String frameTitle) {
		logger.debug("ending a frame.");

		return "</table><!- End " + frameTitle + "-->\n";
	}


	/**
	 *  Execute a transaction based on the action command or the search command
	 *  given via the html form.
	 *
	 *@return                                          Description of the Return
	 *      Value
	 *@exception  java.sql.SQLException                This exception can occur,
	 *      since the class loads data from the Oracle data base via JDBC.
	 *      org.apache.regexp.RESyntaxException When a regular expression is
	 *      incorrect this exception is thrown Exception The move method can throw
	 *      an exception if an improper user_defined value is generated
	 *@exception  org.apache.regexp.RESyntaxException
	 *@exception  Exception                            Description of the Exception
	 */
	public boolean execute() throws
			java.sql.SQLException,
			org.apache.regexp.RESyntaxException,
			Exception {
		logger.debug("****** START EXECUTE ******");
		init();
		if (logger.isDebugEnabled() && nsiGroup != null) {
			nsiGroup.getRelatedNsns().dump();
		}
		if (logger.isDebugEnabled()) {
			logger.debug("theAction=" + theAction + " search=" + search);
		}
		if (theAction.equals(ACTION_ADD)) {
			// This is really a move of one complete Group to
			// another, however, the user thinks it is an ADD
			NsiGroup srcNsiGroup = null;
			if (okToMove()) {
				srcNsiGroup = move(relNsn.substring(0, relNsn.indexOf("#")));
				// 08/12/02 dse checked for null value
				if (srcNsiGroup != null) {
				    if (isValidData()) {
					    save();
					    effectivity.AmdUtils.setConnection(conn) ;
					    if (logger.isDebugEnabled()) {
					        logger.debug("effectivity.AmdUtils.updateAssetMgmtStatus(" + nsiGroup.getNsiGroupSid() + ")") ;
					    }
					    effectivity.AmdUtils.updateAssetMgmtStatus(Integer.parseInt(nsiGroup.getNsiGroupSid())) ;
					    if (logger.isDebugEnabled()) {
						    logger.debug("deleting nsiGroup " + srcNsiGroup.getNsiGroupSid());
					    }
					    if (srcNsiGroup.getRelatedNsns().size() == 0) {
						    srcNsiGroup.delete(userid);
					    }
					    overrideLastElement();
				    }
				}
			}
		} else if (theAction.equals(ACTION_REMOVE)
				 && nsiSidToBeRemovedList != null) {
			if (isValidData() && isOkToRemove()) {
				if (logger.isDebugEnabled()) {
					nsiGroup.getRelatedNsns().dump();
				}
				remove();
				save();
				effectivity.AmdUtils.setConnection(conn) ;
				if (logger.isDebugEnabled()) {
				    logger.debug("effectivity.AmdUtils.updateAssetMgmtStatus(" + nsiGroup.getNsiGroupSid() + ")") ;
				}
				effectivity.AmdUtils.updateAssetMgmtStatus(Integer.parseInt(nsiGroup.getNsiGroupSid())) ;
				overrideLastElement();
			}
		} else if (theAction.equals(ACTION_SAVE)) {
			if (isValidData()) {
				save();
				effectivity.AmdUtils.setConnection(conn) ;
				if (logger.isDebugEnabled()) {
				    logger.debug("effectivity.AmdUtils.updateAssetMgmtStatus(" + nsiGroup.getNsiGroupSid() + ")") ;
				}
				effectivity.AmdUtils.updateAssetMgmtStatus(Integer.parseInt(nsiGroup.getNsiGroupSid())) ;
			}
			if (Utils.isNumber(lastElement)) {
				lastElement = "document.forms[0].elements[" + lastElement + "].focus();";
			}
		} else if (theAction.equals(ACTION_SEARCH) || theAction.equals(ACTION_SELECT_RELATED_NSN)) {
			//enter();
			if (theAction.equals(ACTION_SELECT_RELATED_NSN)) {
				overrideLastElement();
			} else {
				if (Utils.isNumber(lastElement)) {
					lastElement = "document.forms[0].elements[" + lastElement + "].focus();";
				}
			}
		} else if (theAction.equals(ACTION_ACSORT)) {
			// Ok do nothing
		}

		setTopNavBar();
		if (search.equals(Controller.SEARCH_BY_NSN)
				 || search.equals(Controller.SEARCH_BY_PLANNER)
				 || search.equals(Controller.SEARCH_WITH_TOP_NAVBAR)
				 || (theAction.equals("") && !search.equals(Controller.SEARCH_WITH_REL_NAVBAR))) {
			getCurValues();
		}

		createPredefinedFleetSizeList();
		createAircraftList();
		createRelatedNsnSearchCntl();

		if (logger.isDebugEnabled()) {
			logger.debug("exend: partNo=" + partNo + " plannerCode=" + plannerCode);
		}
		if (nsiGroup != null) {
			myWorkingSet.refresh(nsiSid, nsiGroup.getRelatedNsns(), userid);
		}
		session.putValue("WorkingSet", myWorkingSet);
		if (logger.isDebugEnabled() && nsiGroup != null) {
			nsiGroup.getRelatedNsns().dump();
		}
		if (errorOccured) {
			RE re = new RE("'");
			lastElement = "alert(\"" + re.subst(msg.toString(), "\\\"") + "\");";
		}
		logger.debug("****** END EXECUTE ******");
		return true;
	}


	/**
	 *  Set up the instance of the WorkingSet class: get it from the current
	 *  session or create one if it does not exist. Retrieve all the data from the
	 *  request object and the cookies.
	 *
	 *@exception  java.sql.SQLException  This exception can occur, since the class
	 *      loads data from the Oracle data base via JDBC.
	 */
	protected void init()
			 throws java.sql.SQLException {
		logger.debug("initializing....");
		this.session = request.getSession(false);
		userid = (String) session.getValue("userid");
		this.myWorkingSet = (WorkingSet) session.getValue("WorkingSet");
		if (this.myWorkingSet == null) {
			this.myWorkingSet = new WorkingSet();
		}

		getRequestData();
		if (logger.isDebugEnabled()) {
			logger.debug("nsiSid=" + nsiSid);
		}
		if (!nsiSid.equals(NavBar.NO_SELECTION)) {
			getCurTopNsn();
		}
	}


	/**
	 *  Move a group of nsn's to another group.
	 *
	 *@param  nsiSid
	 *@return                            Description of the Return Value
	 *@exception  java.sql.SQLException
	 *@exception  Exception              Description of the Exception
	 */
	protected NsiGroup move(String nsiSid)
			 throws java.sql.SQLException,
			Exception {
		logger.debug("moving nsn from one group to another.");
		NsiGroup otherNsiGroup = getOtherNsiGroup(nsiSid);
		// 08/12/02 dse check for null value
		if (otherNsiGroup == null) {
		    return null ;
		}
		if (logger.isDebugEnabled()) {
			logger.debug("current group for topNsn is " + topNsn.getNsiGroup().getNsiGroupSid());
			logger.debug("before latestConfig=" + latestConfig);
			logger.debug("other group  is " + otherNsiGroup.getNsiGroupSid());
		}
		if (nsiGroup.getRelatedNsns().size() >=
				otherNsiGroup.getRelatedNsns().size()) {
			if (nsiGroup.getSplitEffect().equals(otherNsiGroup.getSplitEffect())) {
				// use the biggest group, since both have the same splitEffect
				logger.debug("1. Moving bottom group to top group.");
				nsiGroup.move(otherNsiGroup);
				if (logger.isDebugEnabled()) {
					logger.debug("latestConfig=" + latestConfig);
				}
			} else {
				// split takes priority over size
				if (nsiGroup.getSplitEffect().equals(NsiGroup.SPLIT_EFFECTIVITY)) {
					logger.debug("2. Moving bottom group top group.");
					nsiGroup.move(otherNsiGroup);
					if (logger.isDebugEnabled()) {
						logger.debug("latestConfig=" + latestConfig);
					}
				} else {
					logger.debug("3. Moving top group to bottom group.");
					otherNsiGroup.move(nsiGroup);
					if (logger.isDebugEnabled()) {
						logger.debug("latestConfig=" + latestConfig);
					}
					NsiGroup temp = otherNsiGroup;
					otherNsiGroup = nsiGroup;
					nsiGroup = temp;
					inheritFleetSize = true;
				}
			}
		} else {
			if (otherNsiGroup.getSplitEffect().equals(nsiGroup.getSplitEffect())) {
				// use the biggest group, since both have the same splitEffect
				logger.debug("4. Moving bottom group top group.");
				otherNsiGroup.move(nsiGroup);
				if (logger.isDebugEnabled()) {
					logger.debug("latestConfig=" + latestConfig);
				}
				logger.debug("swapping groups.");
				NsiGroup temp = otherNsiGroup;
				otherNsiGroup = nsiGroup;
				nsiGroup = temp;
				if (logger.isDebugEnabled()) {
					logger.debug("nsiGroupSid of new top group is " + nsiGroup.getNsiGroupSid());
				}
				inheritFleetSize = true;
				if (!topNsn.getNsiGroup().equals(nsiGroup)) {
					logger.fatal("!topNsn.getNsiGroup().equals(nsiGroup)");
					throw new Exception("!topNsn.getNsiGroup().equals(nsiGroup)");
				}
			} else {
				// split takes priority over size
				if (otherNsiGroup.getSplitEffect().equals(NsiGroup.SPLIT_EFFECTIVITY)) {
					logger.debug("5. Moving bottom group top group.");
					otherNsiGroup.move(nsiGroup);
					if (logger.isDebugEnabled()) {
						logger.debug("latestConfig=" + latestConfig);
					}
					splitEffect = otherNsiGroup.getSplitEffect();
					if (logger.isDebugEnabled()) {
						logger.debug("splitEffect=" + splitEffect);
					}
					NsiGroup temp = otherNsiGroup;
					otherNsiGroup = nsiGroup;
					nsiGroup = temp;
					inheritFleetSize = true;
					if (!topNsn.getNsiGroup().equals(nsiGroup)) {
						logger.fatal("!topNsn.getNsiGroup().equals(nsiGroup)");
						throw new Exception("!topNsn.getNsiGroup().equals(nsiGroup)");
					}
				} else {
					logger.debug("6. Moving bottom group to top group.");
					nsiGroup.move(otherNsiGroup);
					if (logger.isDebugEnabled()) {
						logger.debug("latestConfig=" + latestConfig);
					}
				}
			}
		}
		latestConfig = topNsn.getLatestConfig();
		if (logger.isDebugEnabled()) {
			logger.debug("after move latestConfig=" + latestConfig);
			logger.debug("group that should be removed: " + otherNsiGroup.getNsiGroupSid());
		}
		return otherNsiGroup;
	}


	/**
	 *  Determines if it is OK to move a related nsn and any nsn in its group to
	 *  another group.
	 *
	 *@return    true if the related nsn can be moved
	 */
	protected boolean okToMove() {
		logger.debug("checking if Related Nsn can be moved to another group.");
		boolean OK = true;
		if (relPlannerCode.equals(NavBar.NO_SELECTION)
				 && relNsn.equals(NavBar.NO_SELECTION)) {
			errorOccured = true;
			OK = false;
			msg.append("Select a planner.");
		}

		if (relNsn.equals(NavBar.NO_SELECTION)) {
			errorOccured = true;
			OK = false;
			msg.append("Select an NSN.");
		}
		if (relNsn.substring(0, relNsn.indexOf("#")).equals(nsiSid)) {
		    errorOccured = true ;
		    OK = false ;
		    msg.append("The NSN can not be added as a related part to itself, please select a different part number.") ;
		}
		
		if (nsiGroup.getRelatedNsns().containsKey(relNsn.substring(0, relNsn.indexOf("#")))) {
		    errorOccured = true ;
		    OK = false ;
		    msg.append("This NSN is already in the group.") ;
		}
		
		return OK;
	}


	/**
	 *  The lastElement is used to cause the browser to scroll to a specific
	 *  location, however, in this particular case the application will go to a
	 *  location other than the last element that had focus on the html form.
	 */
	protected void overrideLastElement() {
		if (gotoBottom.equalsIgnoreCase("true")) {
			lastElement = "document.forms[0]." + LAST_SAVE_BUTTON + ".focus();";
		} else {
    		// 08/12/02 dse changed goto to gotoLink to conform to the Config.jsp file and Netscape's strict usage of JavaScript reservied words.  Added # to generate correct hyperlink to a named anchor, which does not have the #.
			lastElement = "gotoLink(\"#" + START_RELATED_NSNS + "\");";
		}
	}


	/**
	 *  Remove one or more nsn's from the group and place them in their own
	 *  individual group.
	 *
	 *@exception  java.sql.SQLException  This exception can occur, since the class
	 *      deletes data from the Oracle data base via JDBC.
	 *@exception  Exception              The NsiGroup can throw an exception when
	 *      the user_defined has an incorrect value
	 */
	protected void remove() throws
			java.sql.SQLException,
			Exception {
		logger.debug("removing an nsn from a the topNsn's group.");
		if (errorOccured) {
			return;
		}
		if (logger.isDebugEnabled()) {
			nsiGroup.getRelatedNsns().dump();
		}
		if (nsiSidToBeRemovedList != null) {
			for (int i = 0; i < nsiSidToBeRemovedList.length; i++) {
				if (logger.isDebugEnabled()) {
					logger.debug("nsiSidToBeRemovedList[" + i + "]=" + nsiSidToBeRemovedList[i]);
				}
				String nsiSid = nsiSidToBeRemovedList[i].substring(0, nsiSidToBeRemovedList[i].indexOf(":"));
				nsiGroup.remove(nsiSid, userid);
				if (myWorkingSet.containsKey(nsiSid)) {
					myWorkingSet.remove(nsiSid);
				}
			}
			splitEffect = nsiGroup.getSplitEffect();
			/*
			 *  if there is only one in the group, it must
			 *  be the Top Nsn, so make sure its latestConfig
			 *  is set to a Y.
			 */
			if (nsiGroup.getRelatedNsns().size() == 1) {
				topNsn.setLatestConfig("Y");
				latestConfig = "Y";
			}
		}
	}


	/**
	 *  Save all the data for the current top nsn: all related nsns and its group.
	 *
	 *@exception  java.sql.SQLException
	 *@exception  Exception              Description of the Exception
	 */
	/**
	 *  Saves all the data for the topNsn and its related nsn's and group
	 *
	 *@exception  java.sql.SQLException  This exception can occur, since the class
	 *      saves data to the Oracle data base via JDBC.
	 *@exception  Exception              Description of the Exception
	 */
	protected void save()
			 throws java.sql.SQLException,
			Exception {
		logger.debug("saving data.");

		if (errorOccured) {
			return;
		}

		if (updateTopNsnSuccessfull()) {
			updateRelatedNsns();
			topNsn.getNsiGroup().getRelatedNsns().dump();
			updatePairs();
			topNsn.save(userid);
			if (logger.isDebugEnabled()) {
				logger.debug("topNsn.getNsiGroup().getGroupComplete()=" + topNsn.getNsiGroup().getGroupComplete());
			}
			if (theAction.equals(this.ACTION_REMOVE) && !topNsn.getNsiGroup().getGroupComplete()) {
				msg.append(this.IDENTIFY_INSTALLED_ON);
			}
			msg.append("Update complete.");
		}
	}


	/**
	 *  Based on the input aircraft array from the html form, return the
	 *  appropriate html option tag with or without the selected attribute.
	 *
	 *@param  p_no       The plane number to be used for the option tag.
	 *@param  ac_no      The aircraft number to be used for the option tag.
	 *@param  tail_no    The tail number to be used for the option tag.
	 *@param  sortOrder  The sort order of the aircraft list.
	 *@return            An option tag with or without the selected attribute
	 *      depending on the contents of the aircraft array.
	 */
	protected String selectAircraft(String p_no, String ac_no, String tail_no, String sortOrder) {
		//logger.debug("selecting aircraft") ;
		if (aircraft == null) {
			return "<option value=\"" + p_no + "-" + ac_no + "-" + tail_no + "\">" + sortOrder;
		}
		for (int i = 0; i < aircraft.length; i++) {
			/*
			 *  if (logger.isDebugEnabled()) {
			 *  logger.debug("aircraft[" + i + "]=" + aircraft[i]) ;
			 *  }
			 */
			if (aircraft[i].equals(p_no + "-" + ac_no + "-" + tail_no)) {
				return "<option selected value=\"" + p_no + "-" + ac_no + "-" + tail_no + "\">" + sortOrder;
			}
		}
		return "<option value=\"" + p_no + "-" + ac_no + "-" + tail_no + "\">" + sortOrder;
	}


	/**
	 *  Starts an html table that will generate a frame effect
	 *
	 *@param  frameTitle  the title used in the html comment for this frame
	 *@return             the html needed to generate a frame effect
	 */
	protected String startFrame(String frameTitle) {
		logger.debug("starting a frame.");

		String html;
		html = "<table border=\"0\" cellspacing=\"6\" cellpadding=\"6\" bgcolor=\"ffffff\" width=\"100%\"><!- " + frameTitle + " with white border-->\n";
		html = html + "<tr>\n";
		html = html + "<td align=\"center\"> <font face=\"arial\"><b>" + frameTitle + "\n";
		html = html + "</b></font>\n";
		return html;
	}


	/**
	 *  Update all the pairs for the group
	 *
	 *@exception  java.sql.SQLException  This exception can occur, since the class
	 *      updates data in the Oracle data base via JDBC.
	 */
	protected void updatePairs()
			 throws java.sql.SQLException {
		logger.debug("updating pairs.");

		Pairs pairs = nsiGroup.getPairs();
		if (pairs != null & pairs.size() > 0) {
			String nsns1[] = request.getParameterValues("Nsn1");
			if (nsns1 == null) {
				return;
			}
			String nsns2[] = request.getParameterValues("Nsn2");
			String interChgs[] = request.getParameterValues("cboInterChg");
			String upgradables[] = request.getParameterValues("cboUpgradable");
			boolean interChgTypeIsDiff[] = new boolean[upgradables.length];
			int numChgs = 0;
			for (int i = 0; i < nsns1.length; i++) {
				Pair pair = pairs.getItem(nsns1[i] + nsns2[i]);
				if (pair != null) {
					interChgTypeIsDiff[i] = !pair.getInterChangeType().equals(interChgs[i]);
				}
			}
			boolean selectedMsg = false ;
			for (int i = 0; i < nsns1.length; i++) {
				Pair pair = pairs.getItem(nsns1[i] + nsns2[i]);
				if (pair == null) {
					continue;
				}
				if (interChgTypeIsDiff[i]) {
					if (pair.getInterChangeType().equals(Pair.TWO_WAY) && !interChgs[i].equals(Pair.TWO_WAY)) {
						Pair otherPair = pairs.getItem(nsns2[i] + nsns1[i]);
						otherPair.setInterChangeType(interChgs[i]);
					}
					pair.setInterChangeType(interChgs[i]);
					if (interChgs[i].equals(Pair.TWO_WAY)) {
						Pair interChgPair = pairs.getItem(nsns2[i] + nsns1[i]);
						interChgPair.setInterChangeType(interChgs[i]);
					}
					if (interChgs[i].equals(Pair.LIMITED) && !selectedMsg) {
						msg.append("You have selected a Limited interchangeability type, you must manually select the specific Usable On aircraft in the Effective Aircraft screen.");
						selectedMsg = true ;
					}
				}
				pair.setUpgradable((upgradables[i].equals("Yes") ? true : false));
			}
		}
	}


	/**
	 *  Update all the related nsns for the group
	 *
	 *@exception  java.sql.SQLException  This exception can occur, since the class
	 *      updates data in the Oracle data base via JDBC.
	 */
	protected void updateRelatedNsns() throws java.sql.SQLException {
		logger.debug("updating related nsn's");

		if (relNsiSidList != null) {
			RelatedNsns relatedNsns = nsiGroup.getRelatedNsns();
			if (relatedNsns != null) {
				int cnt = 0;
				for (int i = 0; i < relNsiSidList.length; i++) {
					if (logger.isDebugEnabled()) {
						logger.debug("relNsiSidList[" + i + "]=" + relNsiSidList[i]);
					}

					RelatedNsn relatedNsn = relatedNsns.getItem(relNsiSidList[i]);
					if (relatedNsn == null) {
						// this can occur when the nsn has just been removed - so skip to the next one
						continue;
					}
					cnt++;
					if (relatedNsnDepleteBy[i] != null) {
						relatedNsn.setDepleteBy(relatedNsnDepleteBy[i]);
					}
					if (relStartDateList[i] != null) {
						relatedNsn.setStartDate(relStartDateList[i]);
					}
					if (!theAction.equals(Controller.ACTION_ADD) && relatedNsnLatestConfig[i] != null) {
						relatedNsn.setLatestConfig(relatedNsnLatestConfig[i]);
					}
				}
				if (cnt == 0) {
					latestConfig = "Y";
					topNsn.setLatestConfig("Y");
				}
			}
		}
	}


	/**
	 *  update the top nsn
	 *
	 *@return                            true if the update worked
	 *@exception  java.sql.SQLException  This exception can occur, since the class
	 *      updates data in the Oracle data base via JDBC.
	 */
	protected boolean updateTopNsnSuccessfull()
			 throws java.sql.SQLException {
		logger.debug("updating top nsn.");

		String desc = "";

		if (predefinedFleetSizeDesc == null) {
			desc = predefinedFleetSizeName;
		} else {
			desc = predefinedFleetSizeDesc;
		}

		if (depleteBy != null) {
			topNsn.setDepleteBy(depleteBy);
		}
		if (startDate != null) {
			topNsn.setStartDate(startDate);
		}

		if (latestConfig != null) {
			topNsn.setLatestConfig(latestConfig);
		}

		NsiGroup nsiGroup = topNsn.getNsiGroup();
		/*
		 *  This should not happen anymore, since all Nsn have
		 *  a nsiGroup and the nsiGroup object gets loaded when
		 *  the Nsn is loaded
		 *  if (nsiGroup == null) {
		 *  nsiGroup = new NsiGroup() ;
		 *  nsiGroup.getRelatedNsns().add(nsiSid, topNsn) ;
		 *  }
		 */
		if (logger.isDebugEnabled()) {
			logger.debug("inheritFleetSize=" + inheritFleetSize);
		}
		if (inheritFleetSize) {
			FleetSize fleetSize = nsiGroup.getFleetSize();
			usePredefinedFleetSize = fleetSize.getPredefinedFleetSize();
			predefinedFleetSizeName = fleetSize.getFleetSizeName();
			desc = fleetSize.getFleeSizeDesc();
			if (!usePredefinedFleetSize) {
				aircraft = fleetSize.getAircraftArray();
			}
		}
		if (logger.isDebugEnabled()) {
			logger.debug("aircraft=" + aircraft
					 + " predefinedFleetSizeName=" + predefinedFleetSizeName
					 + "nsiGroup.getFleetSize().getFleetSizeName()=" + nsiGroup.getFleetSizeName());
		}
		int curFleetSize = nsiGroup.getFleetSize().getFleetSizeMembers().size();

		if (aircraft != null || !predefinedFleetSizeName.equals(nsiGroup.getFleetSizeName())) {
			nsiGroup.setFleetSize(getFleetSize(aircraft, predefinedFleetSizeName, desc, usePredefinedFleetSize));
		}

		if (logger.isDebugEnabled()) {
			logger.debug("splitEffect=" + splitEffect);
		}
		if (logger.isDebugEnabled()) {
			logger.debug("nsiGroup.getSplitEffect()=" + nsiGroup.getSplitEffect());
		}

		String autoSwitch = getCookie("AutoSwitch", "On");

		if (splitEffect.equals(NsiGroup.SPLIT_EFFECTIVITY)) {
			nsiGroup.setSplitEffect(NsiGroup.SPLIT_EFFECTIVITY);
			if (theAction.equals(this.ACTION_ADD)
					 || (curFleetSize < nsiGroup.getFleetSize().getFleetSizeMembers().size())) {
				msg.append(this.IDENTIFY_INSTALLED_ON);
			}
			if (nsnFilter.equals(NavBar.NEW_NSNS)) {
				if (autoSwitch.equalsIgnoreCase("On")) {
					nsnFilter = NavBar.ALL_NSNS;
					setCookie(NSNFILTER, NavBar.ALL_NSNS);
					msg.append(AUTOSWITCH_MSG);
				} else {
					msg.append(nsn + "/" + partNo + " will no longer appear in the nsn list, unless All Nsn's is selected.");
				}
				lastElement = "0";
			}
		} else {
			nsiGroup.setSplitEffect(NsiGroup.SINGLE_EFFECTIVITY);
			if (nsnFilter.equals(NavBar.NEW_NSNS)) {
				if (autoSwitch.equalsIgnoreCase("On")) {
					nsnFilter = NavBar.ALL_NSNS;
					setCookie(NSNFILTER, NavBar.ALL_NSNS);
					msg.append(AUTOSWITCH_MSG);
				} else {
					msg.append(nsn + "/" + partNo + " will no longer appear in the nsn list, unless All Nsn's is selected.");
				}
				lastElement = "0";
			}
		}
		logger.debug("returning true from updateTopNsnSuccessfull.");
		return true;
	}


	/**
	 *  The system must have at least one depleteBy that is blank
	 *
	 *@return    true if one depleteBy field is blank
	 */
	protected boolean willOneDepleteByRemainBlank() {

		logger.debug("willOneDepletebyRemainBlank");
		String nsiSid;

		boolean result = true;
		java.util.HashSet toBeRemoved = new java.util.HashSet();
		// build a set of those nsn's to be removed
		for (int i = 0; i < nsiSidToBeRemovedList.length; i++) {
			nsiSid = nsiSidToBeRemovedList[i].substring(0, nsiSidToBeRemovedList[i].indexOf(":"));
			toBeRemoved.add(nsiSid);
		}

		java.util.HashSet remainingNsns = new java.util.HashSet();
		java.util.Set keys = nsiGroup.getRelatedNsns().keySet();
		java.util.Iterator iterator = keys.iterator();
		while (iterator.hasNext()) {
			remainingNsns.add(iterator.next());
		}
		remainingNsns.removeAll(toBeRemoved);
		remainingNsns.removeAll(toBeRemoved);
		int numberOfBlankDepleteBy = 0;
		// check if topNsn will have a blank depleteBy
		if (depleteBy.equals("")) {
			numberOfBlankDepleteBy++;
		}
		if (relatedNsnDepleteBy != null) {
			for (int i = 0; i < relatedNsnDepleteBy.length; i++) {
				// count only the ones that will remain
				if (remainingNsns.contains(relNsiSidList[i])) {
					if (relatedNsnDepleteBy[i].equals("")) {
						numberOfBlankDepleteBy++;
					}
				}
			}
		}
		if (numberOfBlankDepleteBy == 0) {
			errorOccured = true;
			result = false;
			msg.append("Since you are removing all the deplete by dates that are blank, you must change at least one Never Buy/Deplete Stock Date to a blank.");
		}
		if (logger.isDebugEnabled()) {
			logger.debug("result=" + result);
		}
		return result;
	}


	/**
	 *  One and only one latest config must have a 'Y' value
	 *
	 *@return    true 1 and only 1 latestConfig == 'Y'
	 */
	protected boolean willOneLatestConfigRemain() {
		logger.debug("willOneLatestConfigRemain");
		boolean result = true;

		RelatedNsns relatedNsns = nsiGroup.getRelatedNsns();
		if (relatedNsns.size() - 1 == nsiSidToBeRemovedList.length) {
			/*
			 *  removing all related nsn's - topNsn will
			 *  automatically be assigned as the latestConfig
			 */
			return true;
		}
		String nsiSid;
		for (int i = 0; i < nsiSidToBeRemovedList.length; i++) {
			nsiSid = nsiSidToBeRemovedList[i].substring(0, nsiSidToBeRemovedList[i].indexOf(":"));
			RelatedNsn relatedNsn = (RelatedNsn) relatedNsns.get(nsiSid);
			// check if the one being removed is the latestConfig
			if (relatedNsn != null && relatedNsn.getLatestConfig().equals("Y")) {
				// cannot remove this without providing a replacement
				if (!latestConfig.equals("Y")) {
					// topNsn is NOT being used as a replacement latestConfig - check for others
					boolean replacementFound = false;
					for (int x = 0; x < relatedNsnLatestConfig.length; x++) {
						logger.debug("relatedNsnLatestConfig[" + x + "]="
								 + relatedNsnLatestConfig[x]
								 + "relNsiSidList[" + x + "]" + relNsiSidList[x]);
						if (relatedNsnLatestConfig[x].equals("Y")
								 && !relNsiSidList[x].equals(nsiSid)) {
							// OK there is a new latestConfig
							replacementFound = true;
							break;
						}
					}
					if (!replacementFound) {
						result = false;
						errorOccured = true;
						msg.append("Since you are removing the latest config, you must specifiy a replacement latest config.");
					}
				}
				break;
			}
		}
		return result;
	}


	/**
	 *  The main program for the Controller class.
	 *  This is used for testing only.
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


	/**
	 *  Used to create error or information messages
	 *
	 *@author     Douglas S. Elder
	 *@version    1.0
	 *@since      06/20/02
	 */
	class Msg {
		private String msg = "";


		/**
		 *  Adds the text to the end of message
		 *
		 *@param  msg  Text to be added to the end of the message
		 */
		public void append(String msg) {
			if (msg.equals("")) {
				this.msg = msg;
			} else {
				this.msg = this.msg + " " + msg;
			}
		}


		/**
		 *  Determine the length of the message
		 *
		 *@return    length of the message
		 */
		public int length() {
			return msg.length();
		}


		/**
		 *  Convert the message into a string
		 *
		 *@return    the string value of the message
		 */
		public String toString() {
			return msg;
		}
	}

}

