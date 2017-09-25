package Configuration;
/*
 *  $Revision:   1.3  $
 *  $Author:   c970183  $
 *  $Workfile:   NavBar.java  $
 *  $Log:   \\www-amssc-01\pds\archives\SDS-AMD\Components-ClientServer\AmdConfig\Configuration\NavBar.java-arc  $
/*
/*   Rev 1.3   07 Aug 2002 10:14:14   c970183
/*Allow prime_part retrival via an equivalent part.
 *  *
 *  *   Rev 1.1   23 May 2002 06:57:52   c970183
 *  *Test Release
 */
import java.awt.*;
import java.sql.*;
import javax.servlet.jsp.*;
import org.apache.log4j.Logger;

/**
 *  This class is to be used by a JSP application. It combines searching and the
 *  generating of html in one convient class. <p>
 *
 *  Its primary function is to select a National Stock Number, a Part Number,
 *  and Nomenclature from the data base. <p>
 *
 *  The primary User Interface consists of html drop down list's:
 *  <ul>
 *    <li> A planner list
 *    <li> A Nsn list which contains the following:
 *    <ul>
 *      <li> NSN
 *      <li> Part Number
 *      <li> Nomenclature
 *    </ul>
 *
 *  </ul>
 *  Each list requires a JavaScript be coded for it. This script will get
 *  invoked whenever the onChange event occurs (an item in the list is
 *  selected). The JavaScript will be responsible for submitting the data to the
 *  JSP application. <p>
 *
 *  Usage: The search method should be executed first. This method has two
 *  variations: one without parameters and one with parameters. The one without
 *  parameters requires properties required by the search be set prior to
 *  invocation. <p>
 *
 *  If the SearchBy property or parameter is set, the search uses the
 *  NsnOrPartNo property to perform a search, otherwise the NsnOrPartNo is
 *  ignored. The NsnOrPartNo property can consist of a complete or partial NSN
 *  or Part Number. <p>
 *
 *  If only the planner code is supplied as a search parameter, all nsn's
 *  associated with that planner will be retrieved. <p>
 *
 *  If a specific nsi_sid is supplied as a search parameter, only that
 *  particular nsn will be retrieved. <p>
 *
 *  Whenever a unique nsn has been retrieved, the nsn, nsi_sid, part_no, and
 *  nomenclature are available via get methods and via html hidden fields. <p>
 *
 *  Once the search method is executed, either the getHtml method or the
 *  getHtmlWithControls method can be invoked. These method will return the html
 *  needed to interface with this method.
 *
 *@author     Douglas S. Elder
 *@version    1.0
 *@since      06/01/02
 */
public class NavBar extends java.lang.Object {

	/**
	 *@deprecated    This was used when the NavBar returned a part list. It is no
	 *      longer used.
	 */
	private boolean allowPartNoSelect = false;

	/**
	 *  The value returned by the nsn combo box.
	 */
	private String cboNsn;

	/**
	 *  The name attribute of the html select tag that is used for the nsn's.
	 */
	private String cboNsnFieldName;

	/**
	 *  The value returned by the planner combo box.
	 *
	 *@deprecated    plannerCode and its get/set method are now being used.
	 */
	private String cboPlanner;

	/**
	 *  The name attribute of the html select tag that is used for the planner
	 *  code's.
	 */
	private String cboPlannerFieldName;

	/**
	 *  An open JDBC connection object.
	 */
	private Connection conn;

	/**
	 *  The JavaScript that gets executed for the filter radio buttons: all nsn's
	 *  or new nsn's.
	 */
	private String filterScript;

	/**
	 *  used to cache the generated html.
	 *
	 *@see    #getHtml()
	 *@see    #getHtmlWithControls()
	 */
	private StringBuffer html = new StringBuffer(1000);

	/**
	 *  The maximum length of an nsn for the current search.
	 */
	private int maxLenNsn;

	/**
	 *  The maximum length of a part_no for the current search.
	 */
	private int maxLenPartNo;

	/**
	 *  The nomenclature returned by the search.
	 *
	 *@see    #nsn
	 *@see    #partNo
	 *@see    #plannerCode
	 */
	private String nomenclature = "";

	/**
	 *  The nsi_sid returned by the search.
	 */
	private String nsiSid;

	/**
	 *  The nsn returned by the search.
	 *
	 *@see    #partNo
	 *@see    #nomenclature
	 *@see    #plannerCode
	 */
	// gets set when a match is found
	private String nsn = "";

	/**
	 *  This can only have two values NavBar.ALL_NSNS or NavBar.NEW_NSNS.
	 */
	private String nsnFilter;

	/**
	 *  The JDBC ResultSet used to contain the list of nsns, nsi_sids,
	 *  prime_part_no, and nomenclature contained in the amd_national_stock_items
	 *  and amd_spare_parts table.
	 */
	private ResultSet nsnList;

	/**
	 *  The number of rows in the nsnList. This value in conjuntion with the max
	 *  string length for nsn and part number is used to compute the html
	 *  StringBuffer size.
	 */
	private int nsnListRecCount;

	/**
	 *  The JDBC statemented used in the creation of the nsnList.
	 */
	private Statement nsnListStatement;

	/**
	 *  When a searchBy with a value of NavBar.BY_NSN or NavBar.BY_VPN is used,
	 *  this field will contain the search argument. This can be a partial or
	 *  explicit value.
	 */
	private String nsnOrPartNo;

	/**
	 *  The part_no returned by the search.
	 *
	 *@see    #nsn
	 *@see    #nomenclature
	 *@see    #plannerCode
	 */
	// gets set when a match is found or when there
	// is only one partNo found
	private String partNo = "";

	/**
	 *  The planner_code returned by the search.
	 *
	 *@see    #nsn
	 *@see    #partNo
	 *@see    #nomenclature
	 */
	// gets set when a match is found
	private String plannerCode = "";

	/**
	 *  The complete list of planner codes contained in the
	 *  amd_national_stock_items table.
	 */
	private java.util.ArrayList plannerList;

	/**
	 *  When the nsn is being filtered, this qualifier will contain a check for a
	 *  null value for the amd_national_stock_items.asset_mgmt_status column.
	 */
	private String primaryNsnQualifier;

	/**
	 *  This can only have two value NavBar.BY_NSN or NavBar.BY_VPN
	 */
	private String searchBy;

	/**
	 *  The html form field name used to contain either the nsn or part number.
	 */
	private String searchFieldName;

	/**
	 *  This is the value used in previous searches. It is either an nsn or part
	 *  number. It should be persisted by the client application.
	 */
	private String searchFieldValue;

	/**
	 *  The JavaScript to get executed when the search button is pressed.
	 */
	private String searchScript;

	/**
	 *  This character field is used to separate the nsi sid and nsn that is
	 *  contained in the value attributes of the option tags for the nsn html
	 *  select list.
	 */
	private String separator;

	/**
	 *  When true all nsn's are retrieved regardless of the value contained in the
	 *  amd_national_stock_items.asset_mgmt_status column. When false only the
	 *  nsn's that have a null value contained in the
	 *  amd_national_stock_items.asset_mgmt_status are retrieved (additional
	 *  selection criteria is applied: planner code, full or partial nsn or vpn).
	 */
	private boolean showAllNsns;

	/**
	 *  The form name to be used by all the generated html.
	 */
	private String theFormName;

	/**
	 *  The name attribute of the html input tag that is used for the hidden
	 *  nomenclature.
	 */
	private String txtNomenclatureFieldName;

	/**
	 *  The field name used for the hidden html field that will contain the nsi_sid
	 *  for the current search.
	 */
	private String txtNsiSid;

	/**
	 *  The name attribute of the html input tag that is used for the hidden nsi
	 *  sid.
	 */
	private String txtNsiSidFieldName;

	/**
	 *  The part_no used to match the part_no list.
	 *
	 *@deprecated    This is no longer used.
	 */
	private String txtPartNo;

	/**
	 *  The name attribute of the html input tag that is used for the hidden part
	 *  number.
	 */
	private String txtPartNoFieldName;

	/**
	 *  When this is set to true, the primaryNsnQualifier is applied to all queries
	 *  that are used to create an nsnList.
	 */
	private boolean useNsnFilter;

	/**
	 *  The PVCS author.
	 */
	private static String author = "$Author:   c970183  $";

	/**
	 *  The log4j logger for this class.
	 */
	private static Logger logger = Logger.getLogger(NavBar.class.getName());

	/**
	 *  The PVCS revision.
	 */
	private static String revision = "$Revision:   1.3  $";

	/**
	 *  The PVCS workfile.
	 */
	private static String workfile = "$Workfile:   NavBar.java  $";

	/**
	 *  A constant value indicating that all nsn's are to be returned (ignores
	 *  amd_national_stock_items.asset_mgmt_status).
	 */
	public final static String ALL_NSNS = "allNsns";

	/**
	 *  A constant value indicating the search is to be done by nsn.
	 */
	public final static String BY_NSN = "byNsn";

	/**
	 *  A constant value indicating the search is to be done by part number
	 *  (formerly vendor part number).
	 */
	public final static String BY_VPN = "byVpn";

	/**
	 *  Indicated that only nsn's with a null value for
	 *  amd_national_stock_items.asset_mgmt_status will be returned.
	 *
	 *@see    #ALL_NSNS
	 */
	public final static String NEW_NSNS = "newNsns";

	/**
	 *  This is a constant used to indicate that nothing in the html list has been
	 *  selected.
	 */
	public final static String NO_SELECTION = "-None-";


	/**
	 *  This contstructor initializes various properties to default values. The
	 *  names of the various drop down lists are given default values. The state of
	 *  these lists are set to NO_SELECTION. The default delimited for the NSN
	 *  value is set to #. All NSN's will be displayed regardlesss of their
	 *  asset_management_status. This can be overriden by setting the ShowAllNsns
	 *  property to false.
	 */

	public NavBar() {
		searchBy = BY_NSN;
		searchFieldName = "txtNsnVpn";
		searchFieldValue = "";
		nsnOrPartNo = "";
		cboPlanner = NO_SELECTION;
		cboPlannerFieldName = "cboPlanner";
		cboNsn = NO_SELECTION;
		cboNsnFieldName = "cboNsn";
		txtPartNo = NO_SELECTION;
		txtPartNoFieldName = "txtPartNo";
		txtNsiSidFieldName = "txtNsiSid";
		txtNomenclatureFieldName = "txtNomenclature";
		separator = "#";
		showAllNsns = true;
		primaryNsnQualifier = "";
		theFormName = "TheForm";
		searchScript = "Search(1)";
		filterScript = "optNsnFilterClicked();";
		nsnFilter = NavBar.NEW_NSNS;
		useNsnFilter = true;
	}


	/**
	 *@param  allowPartNoSelect  Since the part no list is no longer displayed,
	 *      this method can be removed, but has been left in for backward
	 *      compatibility.
	 *@deprecated
	 */
	public void setAllowPartNoSelect(boolean allowPartNoSelect) {
		this.allowPartNoSelect = allowPartNoSelect;
	}


	/**
	 *@param  Nsn    The nsiSid used to do the search.
	 *@deprecated    Replaced by setNsiSid
	 */
	public void setCboNsn(String Nsn) {
		/*
		 *  cboNsn is really the nsiSid: see
		 *  setNsiSid's comments.
		 */
		cboNsn = Nsn;
		nsiSid = cboNsn;
	}


	/**
	 *@param  cboNsnFieldName  The name being used to by the html combo box that
	 *      contains the nsn list.
	 */
	public void setCboNsnFieldName(String cboNsnFieldName) {
		this.cboNsnFieldName = cboNsnFieldName;
	}


	/**
	 *@param  plannerCode  The value used to search by planner.
	 *@see                 #setPlannerCode(java.lang.String)
	 *@deprecated          This has been replaced by setPlannerCode
	 */
	public void setCboPlanner(String plannerCode) {
		cboPlanner = plannerCode;
	}


	/**
	 *@param  cboPlannerFieldName  The name being used to by the html combo box
	 *      that contains the planner list. The display item for this field is a
	 *      planner code.
	 */
	public void setCboPlannerFieldName(String cboPlannerFieldName) {
		this.cboPlannerFieldName = cboPlannerFieldName;
	}


	/**
	 *@param  connection
	 *@see                Configuration.AmdDB
	 */
	public void setConnection(java.sql.Connection connection) {
		conn = connection;
	}


	/**
	 *@param  filterScript  The JavaScript that is associated with the Nsn Filter
	 *      radio buttons.
	 */
	public void setFilterScript(String filterScript) {
		this.filterScript = filterScript;
	}


	/**
	 *  This is a utility method that retrieves the Maximum Length of a field for a
	 *  sql query.
	 *
	 *@param  sqlStmt                    An SQL statement that uses the Max
	 *      function and this function must have an alias of 'length'.
	 *@return                            Description of the Return Value
	 *@exception  java.sql.SQLException  This exception can occur, since the class
	 *      loads data from the Oracle data base via JDBC.
	 */
	private int setMaxLen(String sqlStmt) throws java.sql.SQLException {
		ResultSet rs;
		int len = 0;
		Statement s = conn.createStatement();
		if (logger.isDebugEnabled()) {
			logger.debug(sqlStmt);
		}
		rs = s.executeQuery(sqlStmt);
		if (rs.next()) {
			len = rs.getInt("length");
		}
		rs.close();
		s.close();
		return len;
	}


	/**
	 *  Determine the maximum length of an Nsn field.
	 *
	 *@param  sqlStmt                    An sql query that retrieves the maximum
	 *      length of an nsn using the Max function, which must have an alias of
	 *      'length'.
	 *@exception  java.sql.SQLException  This exception can occur, since the class
	 *      loads data from the Oracle data base via JDBC.
	 */
	protected void setMaxLenNsn(String sqlStmt) throws java.sql.SQLException {
		maxLenNsn = setMaxLen(sqlStmt);
	}


	/**
	 *  Determine the maximum length of a part_no field.
	 *
	 *@param  sqlStmt                    An sql query that retrieves the maximum
	 *      length of a part_no using the Max function, which must have an alias of
	 *      'length'.
	 *@exception  java.sql.SQLException  This exception can occur, since the class
	 *      loads data from the Oracle data base via JDBC.
	 */
	protected void setMaxLenPartNo(String sqlStmt) throws java.sql.SQLException {
		maxLenPartNo = setMaxLen(sqlStmt);
	}


	/**
	 *  Sets the nomenclature attribute of the NavBar object
	 *
	 *@param  nomenclature  The new nomenclature value
	 */
	protected void setNomenclature(String nomenclature) {
		this.nomenclature = nomenclature;
	}


	/**
	 *@param  nsiSid  The nsiSid used to do a search by nsiSid.
	 */
	public void setNsiSid(String nsiSid) {
		this.nsiSid = nsiSid;
		/*
		 *  cboNsn corresponds to the html select
		 *  tag for the NavBar - its value is the
		 *  nsiSid NOT the nsn - this may seem
		 *  confusing, but I left it this way
		 *  since that is the way it was initially
		 *  defined - however, it is now aliased
		 *  by nsiSid
		 */
		this.cboNsn = nsiSid;
	}


	/**
	 *  Sets the nsn attribute of the NavBar object
	 *
	 *@param  nsn  The new nsn value
	 */
	protected void setNsn(String nsn) {
		this.nsn = nsn;
	}


	/**
	 *@param  nsnFilter  This must be a string containing either NavBar.ALL_NSNS or
	 *      NavBar.NEW_NSNS.
	 */
	public void setNsnFilter(String nsnFilter) {
		this.nsnFilter = nsnFilter;
	}


	/**
	 *  Determines the number of rows that will be returned by an sql query.
	 *
	 *@param  sqlStmt                    An sql query that retrieves nsn, part_no,
	 *      nsi_sid, and nomenclature.
	 *@exception  java.sql.SQLException  This exception can occur, since the class
	 *      loads data from the Oracle data base via JDBC.
	 */
	protected void setNsnListRecCount(String sqlStmt) throws java.sql.SQLException {
		Statement s = conn.createStatement();
		if (logger.isDebugEnabled()) {
			logger.debug(sqlStmt);
		}
		ResultSet rs = s.executeQuery(sqlStmt);
		if (rs.next()) {
			nsnListRecCount = rs.getInt("rec_count");
		}
		rs.close();
		s.close();
	}


	/**
	 *@param  nsnOrPartNo
	 *@deprecated
	 */
	public void setNsnOrPartNo(String nsnOrPartNo) {
		this.nsnOrPartNo = nsnOrPartNo;
	}


	/**
	 *  This method is used to set the Part Number property once a corresponding
	 *  NSN has been selected. This method is for internal use only.
	 *
	 *@param  partNo  The part number associated with the current selected NSN.
	 */
	protected void setPartNo(String partNo) {
		this.partNo = partNo;
	}


	/**
	 *  Sets the plannerCode attribute of the NavBar object
	 *
	 *@param  plannerCode  The new plannerCode value
	 */
	public void setPlannerCode(String plannerCode) {
		this.plannerCode = plannerCode;
		setCboPlanner(plannerCode);
	}


	/**
	 *@param  searchBy  This must be a string containing either NavBar.BY_VPN or
	 *      NavBar.BY_NSN
	 */
	public void setSearchBy(String searchBy) {
		this.searchBy = searchBy;
	}


	/**
	 *@param  searchFieldName  The name of the html form text box field that is
	 *      used to input the search criteria.
	 */
	public void setSearchFieldName(String searchFieldName) {
		this.searchFieldName = searchFieldName;
	}


	/**
	 *@param  searchFieldValue  The data that is used to do the search
	 */
	public void setSearchFieldValue(String searchFieldValue) {
		this.searchFieldValue = searchFieldValue;
	}


	/**
	 *@param  searchScript  The JavaScript that is associated with the Search By
	 *      radio buttons.
	 */
	public void setSearchScript(String searchScript) {
		this.searchScript = searchScript;
	}


	/**
	 *@param  separator  The field separator character that separates the nsi sid
	 *      and the nsn. The concatenated fields are values returned by the nsn
	 *      combo box.
	 */
	public void setSeparator(String separator) {
		this.separator = separator;
	}


	/**
	 *@param  showAllNsns  All nsn's that match the input criteria and have a
	 *      amd_national_stock_items.asset_mgmt_status of null are returned.
	 */
	public void setShowAllNsns(boolean showAllNsns) {
		this.showAllNsns = showAllNsns;
		if (this.showAllNsns) {
			primaryNsnQualifier = "";
		} else {
			primaryNsnQualifier = " and items.asset_mgmt_status is null ";
		}
	}


	/**
	 *  All generated html will be associated with this form name.
	 *
	 *@param  theFormName  The name of the form.
	 */
	public void setTheFormName(String theFormName) {
		this.theFormName = theFormName;
	}


	/**
	 *@param  txtNomenclatureFieldName  The name being used to by the html hidden
	 *      field that contains the nomenclature that is associated with the item
	 *      selected in the nsn combo box.
	 */
	public void setTxtNomenclatureFieldName(String txtNomenclatureFieldName) {
		this.txtNomenclatureFieldName = txtNomenclatureFieldName;
	}


	/**
	 *@param  TxtNsiSidFieldName  The name being used to by the html hidden field
	 *      that contains the nsi_sid that is associated with the item selected in
	 *      the nsn combo box.
	 */
	public void setTxtNsiSidFieldName(String TxtNsiSidFieldName) {
		this.txtNsiSidFieldName = txtNsiSidFieldName;
	}


	/**
	 *@param  partNo  The name of the hiddend field that will contain the part
	 *      number returned by the search.
	 */
	public void setTxtPartNo(String partNo) {
		txtPartNo = partNo;
	}


	/**
	 *@param  txtPartNoFieldName  The name being used to by the html hidden field
	 *      that contains the part number. This part number is the result of the
	 *      search.
	 */
	public void setTxtPartNoFieldName(String txtPartNoFieldName) {
		this.txtPartNoFieldName = txtPartNoFieldName;
	}


	/**
	 *  This method is used in conjunction with the getHtmlWithControls. It allows
	 *  for the use of filtering NSN's by the
	 *  amd_national_stock_items.asset_mgmt_status column. When all NSN's are to be
	 *  displayed, this column is ignored. When NEW NSN's are to be displayed, this
	 *  column must be null.
	 *
	 *@param  useNsnFilter  When set to true, two extra radio buttons are generated
	 *      by the getHtmlWithControls method. These radio buttons allow filtering
	 *      of the nsn by the amd_national_stock_items.asset_mgmt_status column.
	 *@see                  #getHtmlWithControls()
	 */
	public void setUseNsnFilter(boolean useNsnFilter) {
		this.useNsnFilter = useNsnFilter;
	}


	/**
	 *  Gets the author attribute of the NavBar object
	 *
	 *@return    The author value
	 */
	public String getAuthor() {
		return author;
	}


	/**
	 *@return        The nsiSid used returned by the search or NavBar.NO_SELECTION
	 *      if a specific nsn was not found.
	 *@see           #getNsiSid()
	 *@deprecated    Replaced by getNsiSid
	 */
	public String getCboNsn() {
		return cboNsn;
	}


	/**
	 *@return    The name being used to by the html combo box that contains the nsn
	 *      list. The display items for this field are nsn, part number, and
	 *      nomenclature. The value is the nsi_sid concatenated with a field
	 *      separator followed by the nsn.
	 */
	public String getCboNsnFieldName() {
		return cboNsnFieldName;
	}


	/**
	 *@return        The planner code returned by the search or an empty string if
	 *      no planner code was found.
	 *@see           #getPlannerCode()
	 *@deprecated    This has been replaced by getPlannerCode()
	 */
	public String getCboPlanner() {
		return plannerCode;
	}


	/**
	 *@return    The name being used to by the html combo box that contains the
	 *      planner list.
	 */
	public String getCboPlannerFieldName() {
		return cboPlannerFieldName;
	}


	/**
	 *@return    the JavaScript that is associated with the Nsn Filter radio
	 *      buttons.
	 */
	public String getFilterScript() {
		return filterScript;
	}


	/**
	 *  The html property is used to cache the generated html created by the search
	 *  method. This html only contains the drop down boxes. Addtional controls can
	 *  be generated if the getHtmlWithControls method is used. If you use this
	 *  method DON'T use the getHtmlWithControls method.
	 *
	 *@return    A string that contains all of the html generated by the search
	 *      method. The html consists of 2 drop down lists (option tag's): a
	 *      planner list and a list that displays the nsn, part number, and
	 *      nomenclature.
	 *@see       #getHtmlWithControls()
	 */
	public java.lang.String getHtml() {
		return this.html.toString();
	}


	/**
	 *  This method generates html for the NavBar. The html consists of a search
	 *  Button, two radio buttons that control the type of search (by nsn or by
	 *  part number), a text box for entering the nsn or part number. Optionally,
	 *  two additional radio buttons may be
	 *
	 *@return    html conatining the following:
	 *      <ul>
	 *        <li> Search Button
	 *        <li> two radio buttons for the type of search: Nsn or Part Number.
	 *
	 *        <li> a text box that can be used in conjunction with the search
	 *        button and radio buttons.
	 *        <li> Optional radio buttons (can be turned off by setting the
	 *        UseNsnFilter property to true) that can filter out Nsn's based on the
	 *        value of the amd_national_stock_items.asset_mgmt_status: ALL_Nsn's
	 *        have a null value for this column and NEW_Nsn's have a non-null
	 *        value.
	 *      </ul>
	 *
	 *@see       #setUseNsnFilter(boolean useNsnFilter)
	 */
	public String getHtmlWithControls() {
		return getSearchCntl() + "<table><tr>" + this.html.toString() + "</tr></table>\n";
	}


	/**
	 *  Gets the nomenclature attribute of the NavBar object
	 *
	 *@return    The nomenclature value
	 */
	public String getNomenclature() {
		return this.nomenclature;
	}


	/**
	 *@return    The nsiSid returned by the search or NavBar.NO_SELECTION if the
	 *      search did not find a specific nsn.
	 */
	public String getNsiSid() {
		return this.nsiSid;
	}


	/**
	 *@return    Returns the current selected NSN or an empty string.
	 */
	public String getNsn() {
		return this.nsn;
	}


	/**
	 *  For a given nsiSid return it nsn from the amd_national_stock_items table.
	 *
	 *@param  nsiSid
	 *@return                            The Nsn assocated with the above nsiSid
	 *@exception  java.sql.SQLException  This exception can occur, since the class
	 *      loads data from the Oracle data base via JDBC.
	 */
	protected String getNsn(String nsiSid) throws java.sql.SQLException {
		String nsn = "";
		Statement s = conn.createStatement();
		String sqlStmt = "Select nsn from amd_national_stock_items where nsi_sid = " + nsiSid;
		if (logger.isDebugEnabled()) {
			logger.debug(sqlStmt);
		}
		ResultSet rs = s.executeQuery(sqlStmt);
		if (rs.next()) {
			nsn = rs.getString("nsn");
		}
		rs.close();
		s.close();
		return nsn;
	}


	/**
	 *@return    NavBar.ALL_NSNS or NavBar.NEW_NSNS
	 */
	public String getNsnFilter() {
		return nsnFilter;
	}


	/**
	 *  Select all the Nsn's, part numbers, and nomenclature that match the search
	 *  criteria.
	 *
	 *@param  searchBy                   This can have a value of NavBar.BY_NSN or
	 *      by NavBar.BY_VPN.
	 *@param  nsnOrPartNo
	 *@exception  java.sql.SQLException  This exception can occur, since the class
	 *      loads data from the Oracle data base via JDBC.
	 */
	protected void getNsnList(String searchBy, String nsnOrPartNo)
			 throws java.sql.SQLException {
		logger.debug("getting nsn List");
		if (searchBy.equals(BY_VPN)) {
			nsnListStatement = conn.createStatement();
			String sqlStmt = "Select distinct items.nsn, items.nsi_sid, items.prime_part_no, parts.nomenclature from amd_national_stock_items items, amd_spare_parts parts where (parts.part_no like '" + nsnOrPartNo + "%' and items.nsn = parts.nsn) " + primaryNsnQualifier + " order by items.prime_part_no";
			if (logger.isDebugEnabled()) {
				logger.debug(sqlStmt);
			}
			nsnList = nsnListStatement.executeQuery(sqlStmt);
			setMaxLenNsn("Select max(length(items.nsn)) length from amd_national_stock_items items, amd_spare_parts parts where (parts.part_no like '" + nsnOrPartNo + "%' and items.nsn = parts.nsn)  " + primaryNsnQualifier);
			setMaxLenPartNo("Select max(length(items.prime_part_no)) length from amd_national_stock_items items, amd_spare_parts parts where (parts.part_no like '" + nsnOrPartNo + "%' and items.nsn = parts.nsn)  " + primaryNsnQualifier);
			setNsnListRecCount("Select count(*) rec_count from amd_national_stock_items items, amd_spare_parts parts where (parts.part_no like '" + nsnOrPartNo + "%' and items.nsn = parts.nsn)  " + primaryNsnQualifier);
		} else if (searchBy.equals(BY_NSN)) {
			nsnListStatement = conn.createStatement();
			String sqlStmt = "Select items.nsn, items.nsi_sid, items.prime_part_no, parts.nomenclature  from amd_national_stock_items items, amd_spare_parts parts where items.nsn like '" + nsnOrPartNo + "%'" + primaryNsnQualifier + " and items.prime_part_no = parts.part_no order by items.nsn";
			if (logger.isDebugEnabled()) {
				logger.debug(sqlStmt);
			}
			nsnList = nsnListStatement.executeQuery(sqlStmt);
			setMaxLenNsn("Select max(length(items.nsn)) length  from amd_national_stock_items items where items.nsn like '" + nsnOrPartNo + "%'" + primaryNsnQualifier);
			setMaxLenPartNo("Select max(length(items.prime_part_no)) length  from amd_national_stock_items items where items.nsn like '" + nsnOrPartNo + "%'" + primaryNsnQualifier);
			setNsnListRecCount("Select count(*) rec_count from amd_national_stock_items items where nsn like '" + nsnOrPartNo + "%'" + primaryNsnQualifier);
		}
	}


	/**
	 *  For the given nsiSid retrieve the specific nsn, part number, and
	 *  nomenclature.
	 *
	 *@param  nsiSid
	 *@exception  java.sql.SQLException  This exception can occur, since the class
	 *      loads data from the Oracle data base via JDBC.
	 */
	protected void getNsnListByNsiSid(String nsiSid)
			 throws java.sql.SQLException {
		logger.debug("getting nsn list by nsiSid");

		nsnListStatement = conn.createStatement();
		String sqlStmt = "Select items.nsn, items.nsi_sid, items.prime_part_no, parts.nomenclature from amd_national_stock_items items, amd_spare_parts parts where items.nsi_sid = " + nsiSid + primaryNsnQualifier + " and items.prime_part_no = parts.part_no order by nsn";
		if (logger.isDebugEnabled()) {
			logger.debug(sqlStmt);
		}
		nsnList = nsnListStatement.executeQuery(sqlStmt);
		setMaxLenNsn("Select max(length(items.nsn)) length from amd_national_stock_items items where nsi_sid = " + nsiSid + primaryNsnQualifier);
		setMaxLenPartNo("Select max(length(items.prime_part_no)) length from amd_national_stock_items items where nsi_sid = " + nsiSid + primaryNsnQualifier);
		setNsnListRecCount("Select count(*) rec_count from amd_national_stock_items items where nsi_sid = " + nsiSid + primaryNsnQualifier);
	}


	/**
	 *  Retrieve all the nsn's for a given planner code and place the ResultSet in
	 *  the private nsnList property.
	 *
	 *@param  plannerCode
	 *@param  searchBy
	 *@exception  java.sql.SQLException  This exception can occur, since the class
	 *      loads data from the Oracle data base via JDBC.
	 */
	protected void getNsnListByPlanner(String plannerCode, String searchBy)
			 throws java.sql.SQLException {
		if (logger.isDebugEnabled()) {
			logger.debug("getting nsn list by planner: plannerCode=" + plannerCode);
		}

		nsnListStatement = conn.createStatement();
		String sqlStmt = "Select items.nsn, items.nsi_sid, items.prime_part_no, parts.nomenclature from amd_national_stock_items items, amd_spare_parts parts where planner_code = '" + plannerCode + "'" + primaryNsnQualifier + " and items.prime_part_no = parts.part_no order by ";
		if (searchBy.equals(NavBar.BY_NSN)) {
			sqlStmt += " nsn";
		} else if (searchBy.equals(NavBar.BY_VPN)) {
			sqlStmt += " items.prime_part_no";
		} else {
			sqlStmt += " nsn";
		}
		if (logger.isDebugEnabled()) {
			logger.debug(sqlStmt);
		}
		nsnList = nsnListStatement.executeQuery(sqlStmt);
		setMaxLenNsn("Select max(length(items.nsn)) length from amd_national_stock_items items where planner_code = '" + plannerCode + "'" + primaryNsnQualifier);
		setMaxLenPartNo("Select max(length(items.prime_part_no)) length from amd_national_stock_items items where planner_code = '" + plannerCode + "'" + primaryNsnQualifier);
		setNsnListRecCount("Select count(*) rec_count from amd_national_stock_items items where planner_code = '" + plannerCode + "'" + primaryNsnQualifier);
	}


	/**
	 *  Gets the nsnListRecCount attribute of the NavBar object
	 *
	 *@return    The nsnListRecCount value
	 */
	public int getNsnListRecCount() {
		return this.nsnListRecCount;
	}


	/**
	 *@return        The nsn or part number used to do the search. This has been
	 *      replaced by getSearchFieldValue.
	 *@deprecated
	 */
	public String getNsnOrPartNo() {
		return nsnOrPartNo;
	}


	/**
	 *@return    The selected part number or an empty string.
	 */

	public String getPartNo() {
		return this.partNo;
	}


	/**
	 *@return    The current planner code or an empty string if the planner code
	 *      was not found by the search.
	 */
	public String getPlannerCode() {
		return this.plannerCode;
	}



	/**
	 *  Return a specific planner code for a give nsiSid, national stock items
	 *  sequence identification.
	 *
	 *@param  nsiSid                     The nsiSid key needed to retrieve the
	 *      planner code.
	 *@return                            The planner code associated with the given
	 *      nsiSid.
	 *@exception  java.sql.SQLException  This exception can occur, since the class
	 *      loads data from the Oracle data base via JDBC.
	 */
	protected String getPlannerCode(String nsiSid) throws java.sql.SQLException {
		if (logger.isDebugEnabled()) {
			logger.debug("getPlannerCode: nsiSid=" + nsiSid);
		}
		String plannerCode = "";
		Statement s = conn.createStatement();
		String sqlStmt = "Select planner_code from amd_national_stock_items where nsi_sid = " + nsiSid;
		if (logger.isDebugEnabled()) {
			logger.debug(sqlStmt);
		}
		ResultSet rs = s.executeQuery(sqlStmt);
		if (rs.next()) {
			plannerCode = rs.getString("planner_code");
		}
		rs.close();
		s.close();
		return plannerCode;
	}


	/**
	 *  Sets up the private plannerList property to the complete list of planner
	 *  code's contained in the amd_national_stock_items table.
	 *
	 *@exception  java.sql.SQLException  This exception can occur, since the class
	 *      loads data from the Oracle data base via JDBC.
	 */
	protected void getPlannerList() throws java.sql.SQLException {
		Statement s = conn.createStatement();
		String sqlStmt = "Select planner_code from amd_planners";
		if (logger.isDebugEnabled()) {
			logger.debug(sqlStmt);
		}
		ResultSet rs = s.executeQuery(sqlStmt);
		plannerList = new java.util.ArrayList();
		while (rs.next()) {
			plannerList.add(rs.getString("planner_code"));
		}
		rs.close();
		s.close();
	}


	/**
	 *  Gets the revision attribute of the NavBar object
	 *
	 *@return    The revision value
	 */
	public String getRevision() {
		return revision;
	}


	/**
	 *  A search can be done by part number, BY_VPN, or by NSN, BY_NSN. When a
	 *  search is done with either of these parameters, the NsnOrPartNo property
	 *  must be supplied.
	 *
	 *@return    One of the following constants: BY_VPN or BY_NSN.
	 */
	public String getSearchBy() {
		return searchBy;
	}


	/**
	 *@return    Returns a string containing the html tags needed to generate a
	 *      search button, two radio boxes used to determine if the search is by
	 *      nsn of by part number, and a search field that will contain the serarch
	 *      data: this data will be set to upper case, it may be a partial nsn or a
	 *      partial part number.
	 */
	public String getSearchCntl() {
		String html;
		html = "<input onFocus='lastField(" + theFormName + "." + cboNsnFieldName + ");' type=button name=SearchByNsnVpn value=Search onClick='" + searchScript + "'>\n";

		String byNsn = "";
		String byVpn = "";
		if (searchBy.equals(NavBar.BY_NSN)) {
			byNsn = "checked";
		} else {
			byVpn = "checked";
		}

		html += "<input type=\"Radio\" name=\"optSearchBy\" value=\"byNsn\" " + byNsn + ">&nbsp;NSN&nbsp;\n";
		html += "<input type=\"Radio\" name=\"optSearchBy\" value=\"byVpn\" " + byVpn + ">&nbsp;PN&nbsp;\n";
		html += "<input size=\"30\" type=\"text\" name=\"" + searchFieldName + "\" value=\"" + searchFieldValue + "\" onChange='this.value = this.value.toUpperCase();'></td>";
		if (logger.isDebugEnabled()) {
			logger.debug("useNsnFilter=" + useNsnFilter);
		}
		if (useNsnFilter) {
			String newNsns = "";
			String allNsns = "";
			if (nsnFilter.equals(NavBar.ALL_NSNS)) {
				allNsns = "checked";
			} else {
				newNsns = "checked";
			}
			html += "<input type=\"Radio\" name=\"optNsnFilter\" value=\"" + NavBar.NEW_NSNS + "\" " + newNsns + " onClick='" + filterScript + "'>New Nsn's</td>";
			html += "<input type=\"Radio\" name=\"optNsnFilter\" value=\"" + NavBar.ALL_NSNS + "\" " + allNsns + " onClick='" + filterScript + "'>All Nsn's</td>";
		}
		return html;
	}


	/**
	 *@return    The value of the name attribute associated with the input text box
	 *      used to do searches.
	 */
	public String getSearchFieldName() {
		return searchFieldName;
	}


	/**
	 *@return    The value contained in the search field.
	 */
	public String getSearchFieldValue() {
		return searchFieldValue;
	}


	/**
	 *@return    the JavaScript that is associated with the Search By radio
	 *      buttons.
	 */
	public String getSearchScript() {
		return searchScript;
	}


	/**
	 *@return    The field separator character that separates the nsi sid and the
	 *      nsn. The concatenated fields are values returned by the nsn combo box.
	 */
	public String getSeparator() {
		return separator;
	}


	/**
	 *@return    If a true value is returned, the search is ignoring the value
	 *      contained in the amd_national_stock_items.asset_mgmt_status column. If
	 *      false only rows containing an amd_national_stock_items.asset_mgmt_status
	 *      column of null are returned.
	 */
	public boolean getShowAllNsns() {
		return showAllNsns;
	}


	/**
	 *  The generated html will be associated with a form.
	 *
	 *@return    Returns the name of the html form used by the generated html.
	 */
	public String getTheFormName() {
		return theFormName;
	}


	/**
	 *@return    The name being used to by the html hidden field that contains the
	 *      nomenclature that is associated with the item selected in the nsn combo
	 *      box.
	 */
	public String getTxtNomenclatureFieldName() {
		return txtNomenclatureFieldName;
	}


	/**
	 *@return    The name being used to by the html hidden field that contains the
	 *      nsi_sid that is associated with the item selected in the nsn combo box.
	 */
	public String getTxtNsiSidFieldName() {
		return txtNsiSidFieldName;
	}


	/**
	 *@return    The hidden text box field that contains the returned part number.
	 */
	public String getTxtPartNo() {
		return txtPartNo;
	}


	/**
	 *@return    The name being used to by the html hidden field that contains the
	 *      part number. This part number is the result of the search.
	 */
	public String getTxtPartNoFieldName() {
		return txtPartNoFieldName;
	}


	/**
	 *  The nsn filter is used to get only NavBar.NEW_NSNS or NavBar.ALL_NSNS. New
	 *  nsn's have a null value for the amd_national_stock_items.asset_mgmt_status
	 *  column.
	 *
	 *@return    When this returns true only the NavBar.NEW_NSNS are returned,
	 *      otherwise all nsn's are returned.
	 */
	public boolean getUseNsnFilter() {
		return this.useNsnFilter;
	}


	/**
	 *  Gets the workfile attribute of the NavBar object
	 *
	 *@return    The workfile value
	 */
	public String getWorkfile() {
		return workfile;
	}


	/**
	 *  Create the html for the planner list, nsn list, hidden part number, and
	 *  hidden nomenclature which has already been gathered into JDBC ResultSet
	 *  based on the selection criteria.
	 *
	 *@param  plannerCode                The planner code that will be selected in
	 *      the planner list.
	 *@param  nsiSid
	 *@param  partNo
	 *@exception  java.sql.SQLException  This exception can occur, since the class
	 *      loads data from the Oracle data base via JDBC.
	 */
	protected void buildHtml(String plannerCode, String nsiSid,
			String partNo)
			 throws java.sql.SQLException {

		logger.debug("building html.");

		buildPlannerList(plannerCode);
		buildNsnList(nsiSid);
		buildPartHiddenFields();

	}


	/**
	 *  Using the private nsnList property create an html combo box for all rows
	 *  contained in the list. SELECT the nsn, part number, and nomenclature that
	 *  matches the input parameter.
	 *
	 *@param  nsiSid                     The nsiSid to select.
	 *@exception  java.sql.SQLException  This exception can occur, since the class
	 *      loads data from the Oracle data base via JDBC.
	 */
	protected void buildNsnList(String nsiSid)
			 throws java.sql.SQLException {
		logger.debug("building nsn list html.");
		setNsn("");
		outputHtml("<td>NSN:");
		if (nsnList == null) {
			outputHtml("<select name=" + cboNsnFieldName + " size=1 onChange='" + cboNsnFieldName + "Changed()'>");
			outputHtml("<option selected value=\"" + NO_SELECTION + "\">-Choose One-</select>");
			return;
		}

		if (logger.isDebugEnabled()) {
			logger.debug("nsnListRecCount=" + nsnListRecCount);
		}

		if (nsnListRecCount == 1) {
			outputHtml("<select name=" + cboNsnFieldName + " size=1 onChange='" + cboNsnFieldName + "Changed()'>");
			outputHtml("<option value=\"" + NO_SELECTION + "\">-Choose One-");
			setPartNo(nsnList.getString("prime_part_no"));
			setNomenclature(nsnList.getString("nomenclature"));
			setNsn(nsnList.getString("nsn"));
			outputHtml("<option selected value="
					 + nsnList.getString("nsi_sid")
					 + separator + getNsn()
					 + ">" + Utils.pad(getNsn(), maxLenNsn)
					 + "&nbsp;&nbsp;"
					 + Utils.pad(getPartNo(), maxLenPartNo)
					 + "&nbsp;&nbsp;["
					 + this.nomenclature
					 + "]");
			outputHtml("</select>");
			return;
		} else {
			html.setLength(html.length() + nsnListRecCount * 55);
		}

		outputHtml("<select name=" + cboNsnFieldName + " size=1 onChange='" + cboNsnFieldName + "Changed()'>");
		if (nsiSid.equals(NO_SELECTION) || nsiSid.equals("")) {
			outputHtml("<option selected value=\"" + NO_SELECTION + "\">-Choose One-");
		} else {
			outputHtml("<option value=\"" + NO_SELECTION + "\">-Choose One-");
		}

		if (logger.isDebugEnabled()) {
			logger.debug("trying to match " + nsiSid);
		}
		boolean match = false;
		while (nsnList.next()) {
			if (nsiSid.equals(nsnList.getString("nsi_sid"))) {
				setPartNo(nsnList.getString("prime_part_no"));
				setNomenclature(nsnList.getString("nomenclature"));
				setNsn(nsnList.getString("nsn"));
				match = true;
				if (logger.isDebugEnabled()) {
					logger.debug("matched on nsiSid=" + nsiSid + " for part=" + getPartNo());
				}
				outputHtml("<option selected value="
						 + nsnList.getString("nsi_sid")
						 + separator + getNsn()
						 + ">"
						 + Utils.pad(getNsn(), maxLenNsn)
						 + "&nbsp;&nbsp;"
						 + Utils.pad(getPartNo(), maxLenPartNo)
						 + "&nbsp;&nbsp;["
						 + getNomenclature()
						 + "]");
			} else {
				outputHtml("<option value="
						 + nsnList.getString("nsi_sid")
						 + separator + nsnList.getString("nsn")
						 + ">"
						 + Utils.pad(nsnList.getString("nsn"), maxLenNsn)
						 + "&nbsp;&nbsp;"
						 + Utils.pad(nsnList.getString("prime_part_no"), maxLenPartNo)
						 + "&nbsp;&nbsp;["
						 + nsnList.getString("nomenclature")
						 + "]");
			}
		}
		outputHtml("</select>");
		if (logger.isDebugEnabled() && !match) {
			logger.debug("match not found for nsiSid=" + nsiSid);
		}
	}


	/**
	 *  For the selected nsn create a html hidden field that contains the part
	 *  number and nomenclature
	 *
	 *@exception  java.sql.SQLException  This exception can occur, since the class
	 *      loads data from the Oracle data base via JDBC.
	 */
	protected void buildPartHiddenFields()
			 throws java.sql.SQLException {
		logger.debug("building Part List...");
		outputHtml("<input type=hidden name=" + txtPartNoFieldName + " value=\"" + partNo + "\">");
		outputHtml("<input type=hidden name=" + txtNomenclatureFieldName + " value=\"" + nomenclature + "\">");
		if (logger.isDebugEnabled()) {
			logger.debug("writing hidden field " + txtPartNoFieldName + " value=" + partNo);
			logger.debug("writing hidden field " + txtNomenclatureFieldName + " value=" + nomenclature);
		}

		return;
	}


	/**
	 *  Using the private plannerList property create an html combo box for all
	 *  rows contained in the list. SELECT the planner code that matches the input
	 *  parameter.
	 *
	 *@param  plannerCode                The selected planner code.
	 *@exception  java.sql.SQLException  This exception can occur, since the class
	 *      loads data from the Oracle data base via JDBC.
	 */
	protected void buildPlannerList(String plannerCode)
			 throws java.sql.SQLException {
		outputHtml("<td>Planner:<select name=" + cboPlannerFieldName + " size=1 onChange='" + cboPlannerFieldName + "Changed();' >");
		if (plannerList.size() == 0) {
			outputHtml("<option selected value=\"" + NO_SELECTION + "\">-Choose One-</select>");
			return;
		}
		if (plannerCode.equals(NO_SELECTION) || plannerCode.equals("")) {
			outputHtml("<option selected value=\"" + NO_SELECTION + "\">-Choose One-");
		} else {
			outputHtml("<option value=\"" + NO_SELECTION + "\">-Choose One-");
		}
		for (int i = 0; i < plannerList.size(); i++) {
			if (plannerCode.equals(plannerList.get(i))) {
				plannerCode = (String) plannerList.get(i);
				outputHtml("<option selected>" + plannerCode);
			} else {
				outputHtml("<option>" + plannerList.get(i));
			}
		}
		outputHtml("</select>");
	}


	/**
	 *  If the Jsp out object is not null, write the text directly to the output
	 *  stream, otherwise cache it into the public html property.
	 *
	 *@param  theText  The html text to be written.
	 */
	protected void outputHtml(String theText) {
		html.append(theText);
	}


	/**
	 *@param  rs                         The ResultSet whose rows are counted.
	 *@return                            The number of rows contained in the
	 *      ResultSet. The ResultSet is re-positioned to before the first row.
	 *@exception  java.sql.SQLException  This exception can occur, since the class
	 *      loads data from the Oracle data base via JDBC.
	 */
	protected int recordCount(ResultSet rs) throws java.sql.SQLException {
		int numberOfRows = 0;
		if (rs != null) {
			rs.last();
			numberOfRows = rs.getRow();
			rs.beforeFirst();
		}
		return numberOfRows;
	}


	/**
	 *  This performs the search provided the proper public properties have been
	 *  set:
	 *  <ul>
	 *    <li> required: Conn - contains an open JDBC connection object
	 *    <li> plannerCode - a specific amd_national_stock_items.planner_code
	 *    <li> optional: nsnOrPartNo - the complete or partion nsn or the complete
	 *    or partial part number to search for defaults to an empty string.
	 *    <li> searchBy - NavBar.BY_NSN (default)or NavBar.BY_VPN
	 *    <li> nsiSid - the specific nsi sid to be selected
	 *    <li> partNo
	 *    <li> cboNsnFieldName (defaults to cboNsn) - the nsn html select list
	 *    <li> txtNsiSidFieldName (defaults to txtNsiSid) - the hidden field for
	 *    the selected nsn
	 *    <li> txtPartNoFieldName (defaults to txtPartNo) - the hidden field for
	 *    the selected part number
	 *    <li> cboPlannerFieldName (defaults to cboPlanner) - the planner html
	 *    select list
	 *    <li> txtNomenclatureFieldName (defaults to txtNomenclature) - the hidden
	 *    nomenclature field
	 *  </ul>
	 *
	 *
	 *@exception  java.sql.SQLException  This exception can occur, since the class
	 *      loads data from the Oracle data base via JDBC.
	 */
	public void search()
			 throws java.sql.SQLException {
		logger.debug("searching");
		search(conn, searchBy, nsnOrPartNo, cboPlanner,
				cboNsn, txtPartNo, cboNsnFieldName,
				txtNsiSidFieldName, txtPartNoFieldName,
				cboPlannerFieldName, txtNomenclatureFieldName);
	}


	/**
	 *@param  curConn
	 *@param  searchBy
	 *@param  nsnOrPartNo
	 *@param  plannerCode
	 *@param  nsiSid
	 *@param  partNo
	 *@param  cboNsnFieldName
	 *@param  txtNsiSidFieldName
	 *@param  txtPartNoFieldName
	 *@param  cboPlannerFieldName
	 *@param  txtNomenclatureFieldName
	 *@exception  java.sql.SQLException  Description of the Exception
	 */
	public void search(Connection curConn, String searchBy,
			String nsnOrPartNo, String plannerCode,
			String nsiSid, String partNo, String cboNsnFieldName,
			String txtNsiSidFieldName, String txtPartNoFieldName,
			String cboPlannerFieldName, String txtNomenclatureFieldName)
			 throws java.sql.SQLException {
		if (logger.isDebugEnabled()) {
			logger.debug("serarchBy=" + searchBy + " nsnOrPartNo=" + nsnOrPartNo);
			logger.debug("plannerCode=" + plannerCode + " nsiSid=" + nsiSid);
			logger.debug("partNo=" + partNo);
			logger.debug("cboNsiFieldName=" + cboNsnFieldName + " txtNsiSidFieldName=" + txtNsiSidFieldName);
			logger.debug("txtPartNoFieldName=" + txtPartNoFieldName + " cboPlannerFieldName=" + cboPlannerFieldName);
			logger.debug("txtNomenclatureFieldName=" + txtNomenclatureFieldName);
		}
		// set default
		if (searchBy == null) {
			searchBy = BY_NSN;
		}
		if (nsnOrPartNo == null) {
			nsnOrPartNo = "";
		}
		nsnOrPartNo = nsnOrPartNo.toUpperCase();
		if (plannerCode == null) {
			plannerCode = NO_SELECTION;
		}
		if (nsiSid == null || nsiSid.equals("")) {
			nsiSid = NO_SELECTION;
		}
		partNo = NO_SELECTION;
		// partNo should never be used anymore

		// Override defaults
		if (cboNsnFieldName != null) {
			this.cboNsnFieldName = cboNsnFieldName;
		}
		if (txtNsiSidFieldName != null) {
			this.txtNsiSidFieldName = txtNsiSidFieldName;
		}
		if (txtPartNoFieldName != null) {
			this.txtPartNoFieldName = txtPartNoFieldName;
		}
		if (cboPlannerFieldName != null) {
			this.cboPlannerFieldName = cboPlannerFieldName;
		}
		if (txtNomenclatureFieldName != null) {
			this.txtNomenclatureFieldName = txtNomenclatureFieldName;
		}

		// check for valid connection
		if (curConn == null) {
			outputHtml("Missing connection object.");
			return;
		}
		conn = curConn;
		getPlannerList();
		if (!searchBy.equals("") && !nsnOrPartNo.equals("")) {
			getNsnList(searchBy, nsnOrPartNo);
			if (nsnListRecCount == 1) {
				if (nsnList.next()) {
					nsiSid = nsnList.getString("nsi_sid");
				}
				plannerCode = getPlannerCode(nsiSid);
				this.plannerCode = plannerCode;
			} else {
				if (logger.isDebugEnabled()) {
					logger.debug("nsiSid=" + nsiSid);
				}
				if (!nsiSid.equals(NavBar.NO_SELECTION)) {
					plannerCode = getPlannerCode(nsiSid);
					this.plannerCode = plannerCode;
				}
				partNo = NO_SELECTION;
			}
		} else {
			if (!plannerCode.equals(NO_SELECTION) && !plannerCode.equals("")) {
				getNsnListByPlanner(plannerCode, searchBy);
				if (nsnListRecCount == 1) {
					if (nsnList.next()) {
						nsiSid = nsnList.getString("nsi_sid");
					}
				}
				this.plannerCode = plannerCode;
			}
			if (!nsiSid.equals(NO_SELECTION) && !nsiSid.equals("")) {
				if (plannerCode.equals(NO_SELECTION) || plannerCode.equals("")) {
					plannerCode = getPlannerCode(nsiSid);
					this.plannerCode = plannerCode;
    				getNsnListByPlanner(plannerCode, searchBy);
					if (nsnListRecCount == 1) {
						nsnList.next();
						// do this so buildNsnHtml works correctly
					}
				}
			}
		}
		logger.debug("partNo=" + partNo + "this.partNo=" + this.partNo);
		buildHtml(plannerCode, nsiSid, partNo);
		if (nsnList != null) {
			nsnList.close();
		}
		if (nsnListStatement != null) {
			nsnListStatement.close();
		}
		setNsiSid(nsiSid);
	}


	/**
	 *  This is strictly used for testing.
	 *
	 *@param  args
	 *@exception  java.sql.SQLException  This exception can occur, since the class
	 *      loads data from the Oracle data base via JDBC.
	 */
	public static void main(String args[])
			 throws java.sql.SQLException {
		if (args.length > 0 && args[0].equals("-version")) {
			System.out.println(revision + "\n" +
					author + "\n" +
					workfile);
			System.exit(0);
		}
		System.out.println("Test Start");
		NavBar nav = new NavBar();

		AmdDB amd = AmdDB.instance();
		Connection conn = amd.getConnection("amd_owner", "sdsproject");
		/*
		 *  nav.search(conn, NavBar.BY_VPN, "1B489", "NSK", "", "", "cboRelNsn",
		 *  "txtRelNsiSid", "cboRelPartNo", "cboRelPlanner", "txtRelNomenclature") ;
		 */
		nav.setConnection(conn);
		nav.search();
		/*
		 *  nav.search(conn, NavBar.BY_VPN,
		 *  "367-069-101", // nsnVpn
		 *  "AVC", // plannerCode
		 *  "811251", // nsiSid
		 *  "", // partNo
		 *  "cboRelNsn",
		 *  "txtRelNsiSid", "cboRelPartNo",
		 *  "cboRelPlanner", "txtRelNomenclature") ;
		 */
		System.out.println(nav.getHtml());
		System.out.println("nav.getPartNo()=" + nav.getPartNo());
		System.out.println("nav.getNsiSid()=" + nav.getNsiSid());
		System.out.println("nav.getPlannerCode()=" + nav.getPlannerCode());
		System.out.println("nav.getNomenclature()=" + nav.getNomenclature());
		System.out.println("Test Ending.");
	}

}

