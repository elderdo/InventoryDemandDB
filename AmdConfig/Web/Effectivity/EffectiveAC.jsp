<%@ page import="java.util.*" %>
<%@ page import="java.sql.*"  %>
<%@ page import="Configuration.*" %>
<%@ page import="coreservlets.*"  %>
<%@ page import="effectivity.*"  %>

<jsp:useBean id="bar"         class="Configuration.NavBar" scope="request" />
<jsp:useBean id="formHandler" class="effectivity.FormBean" scope="request" />
<jsp:useBean id="acSelect"    class="effectivity.AcDisplayCntl" scope="request" />

<%
System.out.println("\n\n\n\n\n\n\n\n\n#######################################");
	String curSearchBy = "" ;
	String byNsn = "" ;
	String byVpn = "" ;

	if (request.getContentLength() > 0) 
	{
		curSearchBy = request.getParameter("optSearchBy") ;
		LongLivedCookie userCookie = new LongLivedCookie("SearchBy",curSearchBy);
		response.addCookie(userCookie) ;
	} 
	else 
	{
		Cookie[] cookies = request.getCookies() ;
		curSearchBy = ServletUtilities.getCookieValue(cookies,"SearchBy","byNsn");
	}

	if (curSearchBy.equals("byNsn")) 
	{
		byNsn = "checked" ;
	} 
	else 
	{
		byVpn = "checked" ;
	}


// BEGIN NAV BAR
	Connection conn = (Connection) session.getValue("DBConn");

	String strNsiSid       = null;
	String strSearch       = request.getParameter("search");
	String strSearchBy     = request.getParameter("optSearchBy");
	String txtNsnVpn       = request.getParameter("txtNsnVpn") ;
	String strPlannerCode  = request.getParameter("cboPlanner");
	String strNsnSidAndNsn = request.getParameter("cboNsn");

	String nsn;
	String nsnLink="";
	String plannerCodeLink;
	String partNoLink;

	if (strSearch != null && strSearch.equals("1")) 
	{
		// User clicked "Search"
		strPlannerCode = null;
	} 
	else if (strNsnSidAndNsn != null && strNsnSidAndNsn.indexOf("#") > 0) 
	{
		// User selected an nsn from the list box
		strNsiSid = strNsnSidAndNsn.substring(0, strNsnSidAndNsn.indexOf("#"));
	} 
	else
	{
		// User selected a planner code from the list box.
		txtNsnVpn = "";
	}

	if (strNsiSid == null)
		strNsiSid = "-None-";

	if (strPlannerCode == null)
		strPlannerCode = "-None-";

	if (txtNsnVpn == null)
		txtNsnVpn = "";


	bar.setConnection(conn);
	bar.setSearchBy(strSearchBy);
	bar.setNsnOrPartNo(txtNsnVpn);
	bar.setCboPlanner(strPlannerCode);
	bar.setCboNsn(strNsiSid);
	bar.search();

	nsn = bar.getNsn();

	if (nsn != null && !nsn.equals(""))
		nsnLink = ParseText.stringParse(bar.getNsiSid() + bar.getSeparator() + bar.getNsn());
	else
		nsnLink = ParseText.stringParse(bar.getCboNsn());

	if (!bar.getPlannerCode().equals(""))
		plannerCodeLink = bar.getPlannerCode();
	else
		plannerCodeLink = bar.getCboPlanner();

	if (!bar.getPartNo().equals(""))
		partNoLink = bar.getPartNo();
	else
		partNoLink = bar.getTxtPartNoFieldName();

// END NAV BAR
%>

<html>
<title>Effective Aircraft</title>
<META NAME="title" Content="Effective Aircraft">
<META NAME="subject" Content="AMD Effective Aircraft Application Data Entry Form to capture AMD Effectivity information">
<META NAME="creator" Content="335191-Fernando Fajardo">
<META NAME="date" Content="2002-07-15">
<META NAME="validuntil" Content="2007-07-15">
<META NAME="owner" Content="293539-Gino Aedo">
<META NAME="robots" Content="all">
<META NAME="Revision" Content="$Revision:   1.0  $">
<META NAME="Author" Content="$Author:   c970183  $">
<META NAME="Workfile" Content="$Workfile:   EffectiveAC.jsp  $">
<META NAME="Log" Content="$Log:   \\www-amssc-01\pds\archives\SDS-AMD\Web\Effectivity\EffectiveAC.jsp-arc  $">
/*   
/*      Rev 1.0   16 Sep 2002 10:50:54   c970183
/*   Initial revision.
<meta name="keywords" content=" Effective, Aircraft, AMD, SDS">
<meta name="revisit-after" content="7days">
<meta name="robots" content="index, follow"> 
<meta HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=iso-8859-1">
<script language=javascript>

	var viewIndex=0;

	function ChangeView(pAction,pSplitEffect)
	{
		var currView;

		currView = document.TheForm.view.options[viewIndex].value;

		if (currView == 'U')
		{
			if (pSplitEffect == 'Y')
			{
				if (confirm("Changing your view will cancel any unsaved changes you've made. Do you want to continue?"))
				{
					DoAction(pAction);
				}
				else
				{
					document.TheForm.view.selectedIndex = viewIndex;
				}
			}
			else
			{
				DoAction(pAction);
			}
		}
		else
		{
			DoAction(pAction);
		}

		return false;
	}

	function saveIndex(pForm)
	{
		viewIndex = document.TheForm.view.selectedIndex;
	}

	function ReadOnly()
	{
		alert("Your view must be set to 'User-Defined' to edit data.");
		return false;
	}

	function simRadioButton(row,ix)
	{
//		alert("simRadioButton(" + row + "," + ix + ")");

		if (ix == 0)
		{
			document.TheForm.effFleet[row].checked = false;
			document.TheForm.effShip[row].checked = true;
		}
		else
		{
			document.TheForm.effShip[row].checked = false;
			document.TheForm.effFleet[row].checked = true;
		}

		if (document.TheForm.nsn.length > 2)
			DoAction("ValDistribution");
	}

	function OptionChecked(row,ix)
	{
//		alert("OptionChecked(" + row + "," + ix + ")");

		if (ix == 0 && document.TheForm.effShip[row].checked != true)
		{
			alert("You must select the \"Effectivity by Ship Number\" option to select from this list.");
			return false;
		}
		if (ix == 1 && document.TheForm.effFleet[row].checked != true)
		{
			alert("You must select the \"Effectivity by % of Fleet\" option to select from this list.");
			return false;
		}

		return true;
	}

	function setAsCapable(pRow,pIx)
	{
		if (OptionChecked(pRow,pIx))
		{
			for (i=0;i<document.TheForm.asFlying[pRow].length;i++)
			{
				if (document.TheForm.asFlying[pRow].options[i].selected)
					document.TheForm.asCapable[pRow].options[i].selected = true;
				else
					document.TheForm.asCapable[pRow].options[i].selected = false;
	
			}
			calcRemainder();
			return true;
		}
		else
			return false;
	}


	function calcRemainder()
	{
		var   deliveredQty=document.TheForm.numShips.value;
		var   asFlyingQty=0;
		var   distribQty=0;
		var   methodDiff=0;
		var   remaining=0;

		for (i=0;i<document.TheForm.asFlying[0].length;i++)
		{
			for (j=0;j<document.TheForm.asFlying.length-1;j++)
			{
				if (document.TheForm.asFlying[j].options[i].selected)
				{
					asFlyingQty++;
					break;
				}
			}
		}


		for (i=0;i<document.TheForm.qty.length;i++)
		{
			if (! isNaN(parseInt(document.TheForm.qty[i].value)))
			{
				distribQty = distribQty + parseInt(document.TheForm.qty[i].value);
			}
		}
		
		methodDiff = document.TheForm.asFlying[0].length-deliveredQty;
		selectDiff = asFlyingQty-methodDiff;
		
		if (asFlyingQty > methodDiff)
			remaining = deliveredQty-distribQty-selectDiff;
		else
			remaining = deliveredQty-distribQty;
		
		document.TheForm.acRemainderQty.value = remaining;
	}


	function subTotal(pRow,pNo)
	{
//		alert("subTotal(" + pRow + "," + pNo + ")");
		var qty;
		var subTotal=0;
		var arrayLen = document.TheForm.qty.length-1;
		var group    = arrayLen/(document.TheForm.nsn.length-1);
		var startIx  = group * pRow;
		var endIx    = startIx + group;
		var ix       = startIx + pNo;

		if (! isNaN(document.TheForm.qty[ix].value))
		{
			for (var i=startIx;i<endIx;i++)
			{
				qty = parseInt(document.TheForm.qty[i].value);
				if (isNaN(qty))
				{
					document.TheForm.qty[i].value = "";
				}
				else
				{
					subTotal = subTotal + qty;
				}
			}
			document.TheForm.sTotal[pRow].value=subTotal;
		}
		else
		{
			alert("You must enter a numeric value for the quantities.");
			document.TheForm.qty[ix].value = "";
		}

		calcRemainder();
	}


	function subTotalAll()
	{
		for (var i=0;i<(document.TheForm.nsn.length-1);i++)
		{
			subTotal(i,0);
		}
	}


	function VerifyInput() {
		return true ;
	}

	function DoAction(TheAction) {
		document.TheForm.action.value = TheAction ;
		document.TheForm.submit() ;
	}
	function Search(WhichOne) {
		document.TheForm.action.value = "Search";
		document.TheForm.search.value = WhichOne ;
		document.TheForm.submit() ;
	}
	function cboPlannerChanged() {
		document.TheForm.cboNsn.options[0].selected = true;
		document.TheForm.submit();
		return true ;
	}
	function cboNsnChanged() {
		document.TheForm.action.value = "Search";
		document.TheForm.submit();
		return true ;
	}
	function cboPartNoChanged() {
		document.TheForm.submit();
		return true ;
	}
	function cboRelPlannerChanged() {
		document.TheForm.cboRelNsn.options[0].selected = true;
		document.TheForm.cboRelPartNo.options[0].selected = true;
		document.TheForm.submit();
		return true ;
	}
	function cboRelNsnChanged() {
		document.TheForm.cboRelPartNo.options[0].selected = true;
		document.TheForm.submit();
		return true ;
	}
	function cboRelPartNoChanged() {
		document.TheForm.submit();
		return true ;
	}
	function SetChecked(val) {
		dml=document.TheForm;
		len = dml.elements.length;
		var i=0;
		for( i=0 ; i<len ; i++) {
			if (dml.elements[i].name=='Pair') {
				dml.elements[i].checked=val;
			}
		}
	}
</script>

<body onLoad="subTotalAll()" topmargin=0 leftmargin=0 rightmargin=0 marginwidth=0 marginheight=0 bgcolor=#ffffff link=3690dc vlink=3690dc>

<%
	HtmlMenu htmlMenu = new HtmlMenu() ;
	htmlMenu.setNsn(bar.getNsn()) ;
	htmlMenu.setNsiSid(bar.getNsiSid()) ;
	htmlMenu.setPlannerCode(bar.getPlannerCode()) ;

	htmlMenu.setLink2("Config.jsp") ;
	htmlMenu.setLabel2("configuration") ;
	htmlMenu.setTitle2("Configuration") ;

	out.println(htmlMenu.getHtml()) ;
%>
<b>Effective Aircraft</b><br><br>
<!-- Page table for body offset -->
<table><tr><td>&nbsp;</td><td>

<form NAME="TheForm" METHOD="POST" ACTION="effControl.jsp">
<input type=hidden name=search>
<input type=button name=SearchByNsnVpn value=Search onClick="Search(1)">
<input type="Radio" name="optSearchBy" value="byNsn" <%=byNsn%>>&nbsp;NSN&nbsp;
<input type="RADIO" name="optSearchBy" value="byVpn" <%=byVpn%>>&nbsp;PN&nbsp; 
<input size="30" type="text" name="txtNsnVpn" value="<%=txtNsnVpn%>">

<table> <tr> <%=bar.getHtml()%> </tr> </table>

<%
// BEGIN BODY
	String action = (String) request.getParameter("action");

	AmdUtils.setDebugLevel(5);
	formHandler.setConnection(conn);
	formHandler.setView((String) request.getParameter("view"));
	formHandler.setDisplayBy((String) request.getParameter("acBy"));
	formHandler.setAction(action);

if (action == null)
	System.out.println("							action IS NULL!!!!!\n");
else
	System.out.println("							action:" + action);

	if (! nsn.equals("") && (action == null || action.equals("Search") || action.equals("UpdateView")))
	{
	   formHandler.retrieveData(nsn); 
	}
	else
		if (! nsn.equals(""))
		{
			formHandler.setNumShips();
			formHandler.setAcRemainderQty(request.getParameter("acRemainderQty"));
			formHandler.setNsn(request.getParameterValues("nsn"));
			formHandler.setEffShip(request.getParameterValues("effShip"));
			formHandler.setEffFleet(request.getParameterValues("effFleet"));
			formHandler.setAsFlying(request.getParameterValues("asFlying"));
			formHandler.setAsCapable(request.getParameterValues("asCapable"));
			formHandler.setLocation(request.getParameterValues("location"));
			formHandler.setQty(request.getParameterValues("qty"));
			formHandler.assembleData();

			if (action.equals("SAVE") || action.equals("ValDistribution"))
				formHandler.processData();
		}
// END BODY
%>
<%=formHandler.genHtml() %>

</form>
	</td></tr></table> <!-- Page table for body offset -->
<%
	out.println(htmlMenu.getHtml()) ;
%>
</body>
</html>
