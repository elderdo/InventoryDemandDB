package effectivity;

import java.util.*;
import java.sql.*;
import Configuration.*;

public class FormBean 
{
	private int        debugLevel;
	private ResultSet  rs;

	private String     acBy;
	private String     acView;
	private String     action;
	private String     username;
	private Connection conn;
	private int        numShips;
	private Nsns       nsnList;
	private boolean    effShip[];
	private boolean    effFleet[];
	private Aircrafts  asFlying;
	private Aircrafts  asCapable;
	private String     locations[];
	private int        qty[];

	private PageSet     pageSet;
	private Aircrafts   allAircraft;
	private Locations   allLocations;
	private AcDisplayCntl  acDisplay;
	private int            acRemainderQty=0;
	private DBQuery        db;
	private int            sumShips;
	private int            qtySelected;
	private String         fleetSize;

	
	public FormBean() 
	{
		db        = new DBQuery();
		nsnList   = new Nsns();
		pageSet   = new PageSet();
		acDisplay = new AcDisplayCntl();
		asFlying  = new Aircrafts();
		asCapable = new Aircrafts();
		acBy      = "p_no";
		acView    = "U";
		action    = "";
		debugLevel= 0;
		sumShips  = 0;
	}

	public void setDebugLevel(int pLevel)
	{
		debugLevel = pLevel;
	}

	public void setView(String pView)
	{
		if (pView != null) 
			acView = pView;
	}

	public String getView()
	{
		return acView;
	}

	public void setNumShips()
	{
		numShips = getDeliveredQty();
	}

	int getNumShips()
	{
		return numShips;
	}

	public void setConnection(Connection pConn)
	{
		conn = pConn;
		db.setConnection(conn);
	}

	public void setDisplayBy(String pBy)
	{
		if (pBy != null)
			acBy = pBy;
	}

	public void setNsn(String pNsns[])
	{
		AmdUtils.displayMsg("setNsn()");
		Nsn    nsn;

		AmdUtils.setConnection(conn);

		// the last nsn is just a dummy one so ignore it.
		for (int i=0;i<(pNsns.length-1);i++)
		{
			nsn = AmdUtils.getNsn(pNsns[i]);
			nsnList.add(String.valueOf(i),nsn);
			fleetSize = nsn.getFleetSize();
		}
	}

	public void setEffShip(String pEffShip[])
	{
//		AmdUtils.displayMsg("setEffShip()");
		effShip = new boolean[nsnList.size()];
		
		for (int i=0;i<effShip.length;i++)
			effShip[i] = false;

		for (int i=0;i<(pEffShip.length-1);i++)
		{ 
			effShip[Integer.parseInt(pEffShip[i])] = true;
		}
	}

	public void setEffFleet(String pEffFleet[])
	{
		effFleet = new boolean[nsnList.size()];
		
		for (int i=0;i<effFleet.length;i++)
			effFleet[i] = false;

		for (int i=0;i<(pEffFleet.length-1);i++)
		{ 
			effFleet[Integer.parseInt(pEffFleet[i])] = true;
		}
	}

	public void setAsFlying(String pAsFlying[])
	{
		AmdAircraft ac;

		for (int i=0;i<(pAsFlying.length-1);i++)
		{
			ac = new AmdAircraft();
			ac.setTailNo(pAsFlying[i]);
			asFlying.add(ac.getTailNo(),ac);
		}
	}

	public void setAsCapable(String pAsCapable[])
	{
		AmdAircraft ac;

		for (int i=0;i<(pAsCapable.length-1);i++)
		{
			ac = new AmdAircraft();
			ac.setTailNo(pAsCapable[i]);
			asCapable.add(ac.getTailNo(),ac);
		}
	}

	public void setLocation(String pLocations[])
	{
		locations = pLocations;
	}

	public void setQty(String pQty[])
	{
		qty = new int[pQty.length-1];

		// the last value is just a dummy one so ignore it.
		for (int i=0;i<(pQty.length-1);i++)
		{
			try
			{
				qty[i] = Integer.parseInt(pQty[i]);
			}
			catch (Exception e)
			{
				qty[i] = 0;
			}
		}
	}


	public void setAcRemainderQty(String pAcRemainderQty)
	{
		acRemainderQty = Integer.parseInt(pAcRemainderQty);
	}


	public void setAction(String pAction)
	{
		if (pAction != null)
			action = pAction;
	}




	public void retrieveData(String pNsn) 
	{
		AmdUtils.displayMsg("retrieveData()",1);

		AmdUtils.setConnection(conn);
		setNumShips();
		allAircraft  = loadAllAircraft(pNsn);
		allLocations = loadAllLocations();
		pageSet      = AmdUtils.loadEffectivity(pNsn,acView);
		setNsn(AmdUtils.getNsnList());
	} 

	public boolean validate()
	{
		AmdUtils.displayMsg("validate()",1);
		AmdUtils.setConnection(conn);

		boolean status=true;

		status = valAsFlying();
		status = status ? valDistribution()              : status;
		status = status ? valCommon()                    : status;
//		status = status ? AmdUtils.valAsCapable(pageSet) : status;
		
		return status;
	}


	boolean valAsFlying()
	{
		AmdUtils.displayMsg("valAsFlying()");
		boolean      status = true;
		Aircrafts    checkList=new Aircrafts();
		Aircrafts    asFlying;
		AmdAircraft  ac;
		String       key;
		Set          keys;
		Iterator     iter;
		Nsn          nsnItem;
		Nsn          nsn;

		qtySelected = 0;

		for (int i=0;i<nsnList.size();i++)
		{
			nsnItem  = nsnList.getItem(String.valueOf(i));
			nsn   = pageSet.getItem(nsnItem.getNsn());
AmdUtils.displayMsg("nsn.getNsn():"+nsn.getNsn()+"nsn.getEffectBy():"+nsn.getEffectBy());

			if (nsn.getEffectBy().equals("S"))
			{
				asFlying = nsn.getAircraftList();
				keys     = asFlying.keySet();
				iter     = keys.iterator();

				while(iter.hasNext())
				{
					key      = (String)iter.next();
					ac       = asFlying.getItem(key);
					if (ac.isAsFlying())
					{
						if (checkList.getItem(key) == null)
						{
AmdUtils.displayMsg("checkList - adding:"+ key);
							checkList.add(key,ac);
						}
						else
						{
							pageSet.setErrorMsg("Installed aircraft must not overlap nsns.");
							nsn.setErrorMsg("One or more aircraft installed here overlap with aircraft installed on another Nsn.");
							status = false;
						}
					}
				}
			}
		}

		qtySelected = checkList.count();

		return status;
	}


	boolean valCommon()
	{
		AmdUtils.displayMsg("qtyByShip("+pageSet.getQtyByShip()+")");
		AmdUtils.displayMsg("qtyByFleet("+pageSet.getQtyByFleet()+")");

		if (pageSet.getQtyByShip() != 0)
			if (allAircraft.size() != (qtySelected + sumShips))
			{
				pageSet.setErrorMsg("All aircraft must be accounted for, either by ship number or by percent of fleet.");
				return false;
			}
			else
				return true;
		else if (numShips != sumShips)
			{
				pageSet.setErrorMsg("All aircraft must be accounted for, either by ship number or by percent of fleet.");
				return false;
			}
		else
			return true;
	}


	public void processData()
	{
		AmdUtils.displayMsg("processData()",1);

		if (validate())
		{
			if (action.equals("SAVE"))
			{
				AmdUtils.setConnection(conn);
				AmdUtils.deriveAsCapable(pageSet);
				saveData();
			}
		}
	}


	int getDeliveredQty()
	{
		AmdUtils.displayMsg("getDeliveredQty()");

		String    sqlStmt;
		ResultSet rs;
		int       qty = 0;

		sqlStmt = "select count(distinct aa.tail_no) " +
				" from amd_aircrafts aa, amd_ac_assigns aaa " +
				"where aa.tail_no != 'DUMMY' " +
				"   and aa.tail_no = aaa.tail_no " +
				"   and aaa.assignment_start <= sysdate";

		db.createStatement();
		rs = db.execQuery(sqlStmt);
		try
		{
			while (rs.next())
			{
				qty = rs.getInt(1);
			}
		}
		catch (java.sql.SQLException e)
		{
			AmdUtils.displayMsg("getDeliveredQty(): exception");
		}
		db.closeStatement();

		return qty;
	}


	boolean hasChildren(String pNsiSid)
	{
		ResultSet    rs;
		int          qtyChildren=0;
		boolean      status=true;

		db.createStatement();
		try
		{
			rs = db.execQuery("select count(*) from amd_product_structure where comp_nsi_sid in (select comp_nsi_sid from amd_product_structure where assy_nsi_sid = "+pNsiSid+") and assy_nsi_sid != "+pNsiSid);
			rs.next();
			qtyChildren = rs.getInt(1);

			if (qtyChildren == 0)
				status = false;
		}
		catch (Exception e)
		{
		}
		db.closeStatement();

		// Return TRUE because we want to disable the changing to by-fleet by
		// saying the part has children and without removing the code.
		status = true;

		return status;
	}


	boolean valDistribution()
	{
		boolean      status=true;
		Nsn          nsnItem;
		Nsn          nsn;
		Locations    locList;
		Location     loc;
		String       key;
		Set          keys;
		Iterator     iter;
		boolean      byFleetInd=false;

		
		for (int i=0;i<nsnList.size();i++)
		{
			nsnItem = nsnList.getItem(String.valueOf(i));
			nsn  = pageSet.getItem(nsnItem.getNsn());
			locList = nsn.getLocations();
			keys    = locList.keySet();
			iter    = keys.iterator();

			if (nsn.getEffectBy().equals("F"))
			{
				if (! hasChildren(nsn.getNsiSid()))
				{
					AmdUtils.setConnection(conn);
					AmdUtils.resetAc(nsn.getAircraftList());
					byFleetInd = true;
					while(iter.hasNext())
					{
						key      = (String)iter.next();
						loc      = locList.getItem(key);
						loc.setUserDefined("Y");
						loc.setDerived("N");
						sumShips = sumShips + loc.getQty();
					}
				}
				else
				{
					nsn.setEffectBy("S");
					nsn.setErrorMsg("Nsn " + nsn.getNsn() + " has associated children.  Cannot change the \"effect by\" status to \" By Fleet\"");
					status = false;

					// This functionality has been disabled by returning true from 
					// hasChildred().  Set this error message.
					nsn.setErrorMsg("The \"Effectivity by % of Fleet\" option has been disabled until the next software release.");

				}
			}
		}

		if (! status)
			pageSet.setErrorMsg("Errors have been found.  Please see below.");
		
		return status;
	}


	void saveData()
	{
		AmdUtils.displayMsg("saveData()",1);
		ResultSet    rs;
		String       sqlStmt;
		Nsn          nsnR;
		Nsn          nsnItem;
		String       currDate="";
		String       currUser="";

		AmdUtils.setConnection(conn);
		AmdUtils.displayPageSet(pageSet);

		db.createStatement();
		rs = db.execQuery("select user,to_char(sysdate,'" + AmdUtils.DT_FORMAT+
				"') from dual");
		try
		{
			rs.next();
			currUser = rs.getString(1);
			currDate = rs.getString(2);
			pageSet.setUpdateDate(currDate);
			pageSet.setUpdateId(currUser);
	
			for(int i=0;i<nsnList.size();i++)
			{
				nsnItem = nsnList.getItem(String.valueOf(i));
				nsnR    = pageSet.getItem(nsnItem.getNsn());
				nsnR.setUpdateDate(currDate);
				nsnR.setUpdateId(currUser);
	
				//
				// Update Effect_by and asset_mgmt_status
				//
				sqlStmt = "update amd_national_stock_items set " +
						"  asset_mgmt_status = 'COMPLETE', " +
						"  effect_by = '" + nsnR.getEffectBy() + "', " +
						"  effect_last_update_id = substr(user,1,8), " +
						"  effect_last_update_dt = to_date('" + nsnR.getUpdateDate()+
						"','" + AmdUtils.DT_FORMAT+"')" +
						"where nsi_sid = " + nsnR.getNsiSid();
				db.execUpdate(sqlStmt);
	
				if (nsnR.getEffectBy().equals("S"))
				{
					// Save AsFlying and AsCapable selections to AMD_NSI_EFFECTS
					AmdUtils.saveByShip(nsnR);
				}
				else if (nsnR.getEffectBy().equals("F"))
				{
					// Saving data to AMD_CUR_LOC_DISTRIBS
					AmdUtils.saveByFleet(nsnR);
				}
	
				db.execUpdate("declare begin amd_effectivity_pkg.rebuildChildren('"+nsnR.getNsiSid()+"'); end;");
			}
		}
		catch (Exception e)
		{
			AmdUtils.displayMsg("saveData(exception):"+e);
		}

		db.closeStatement();
		pageSet.setErrorMsg("Data successfully updated.");
	}




	public String genHtml()
	{
		AmdUtils.displayMsg("genHtml()");

		Nsn         nsnItem;
		Nsn         nsn = new Nsn();
		String      retStr="";
		boolean     firstPass=true;
		String      nsnDisplay="";

		if (pageSet.count() == 0)
		{
			retStr = "Please select a Planner and an NSN.<br>" +
				"<input type=hidden name=nsn>";
			return retStr;
		}

		// Set up the Aircraft-Display-By control
		try
		{
			acDisplay.setOnChange("DoAction('UpdateAcDisplay');");
			acDisplay.setBy(acBy);
			acDisplay.genHtml();
		}
		catch (Exception e)
		{
		}

		retStr = "<table cellspacing=0 cellpadding=0><tr><td colspan=2 align=center><hr>" +
				"<table cellspacing=0 cellpadding=0>" +
				"<tr><td valign=center>" + acDisplay.getHtml() + "</td>" +
				"  <td valign=center>&nbsp;&nbsp; " + buildViewCntl() + "</td>" +
				"  <td align=right valign=center>" +
				"    &nbsp;&nbsp;&nbsp;Fleet&nbsp;size:&nbsp;"+fleetSize+"&nbsp;&nbsp;</td>" +
				"  <td valign=center>&nbsp;&nbsp;&nbsp;Delivered:&nbsp;"+numShips+
				"    &nbsp;&nbsp; </td>" +
				"  <td bgcolor=pink valign=center>&nbsp;&nbsp; " +
				"    <b>Unaccounted&nbsp;for:</b> " +
				"    <input type=textbox name=acRemainderQty maxsize=3 " +
				"    size=3 value="+ numShips +">&nbsp;&nbsp; </td>" +
				"  <td>" +
				"    <table cellspacing=0 cellpadding=0>" +
				"      <tr><td align=right><font size=-2>&nbsp;Updated:</td>" +
				"        <td><font size=-2>&nbsp;" + pageSet.getUpdateDate()+"</td></tr>"+
				"      <tr><td align=right><font size=-2>By:</td>" +
				"        <td><font size=-2>&nbsp;" + pageSet.getUpdateId()+"</td></tr>" +
				"    </table>"+
				"  </td>"+
				"</tr>" +
				"</table><hr></td></tr>";

		retStr = retStr+"<input type=hidden name=numShips value="+numShips+ ">\n";
		retStr = retStr+"<input type=hidden name=action value=\""+action+ "\">\n";
		retStr = retStr+"<tr><td colspan=2>" + pageSet.getErrorMsg()+"</td></tr>";

		for(int i=0;i<nsnList.size();i++)
		{
			nsnItem= nsnList.getItem(String.valueOf(i));
			nsn = pageSet.getItem(nsnItem.getNsn());

			if (firstPass)
			{
				nsnDisplay = nsn.getErrorMsg()+"<table><tr><td><input type=hidden name=nsn value=\"" + nsn.getNsn() + "\">NSN:</td><td><b>" + nsn.getNsn() + "</b></td></tr><tr><td>Prime part:</td><td>"+nsn.getPrimePart()+"</td></tr><tr><td>Nomenclature:</td><td>"+nsn.getNomen()+"</td></tr>" +
					"</table><br><br>\n";
				firstPass = false;
			}
			else
			{
				nsnDisplay = nsn.getErrorMsg()+"<table><tr><td><input type=hidden name=nsn value=\"" + nsn.getNsn() + "\">Related NSN:</td><td><b>" + nsn.getNsn() + "</b></td></tr><tr><td>Prime part:</td><td>"+nsn.getPrimePart()+"</td></tr><tr><td>Nomenclature:</td><td>"+nsn.getNomen()+"</td></tr>" +
					"</table><br><br>\n";
			}

			if (pageSet.count() > 1 && pageSet.getSplitEffect().equals("Y"))
			{
				// Display enabled/disabled SAVE button
				if (getView().equals("U"))
					nsnDisplay = nsnDisplay + 
						"<input type=button value=Save onClick=\"DoAction('SAVE');\">";
				else
					nsnDisplay = nsnDisplay + 
						"<input type=button value=Save onClick=\"ReadOnly();\">";
			}
	

			retStr = retStr + "<tr><td>"+nsnDisplay+"</td><td align=right><table bgcolor=#9bbad6 border=1 cellspacing=0 cellpadding=0><tr>" +
				"<td><input type=checkbox name=effShip  " + isChecked(nsn.getEffectBy(),"S") + " value=" + i + " onClick=\"simRadioButton(" + i + ",0);\">Effectivity&nbsp;by&nbsp;ship&nbsp;number</td>" +
				"<td><input type=checkbox name=effFleet " + isChecked(nsn.getEffectBy(),"F") + " value=" + i + " onClick=\"simRadioButton(" + i + ",1);\">Effectivity by % of fleet</td>" +
				"<tr><td>" +
				"<table cellspacing=0 cellpadding=0><tr><td>Installed On:<td>&nbsp;</td><td>Useable On:" +
				"<tr><td align=right>" +
				"<select name=asFlying multiple size=10 onChange=\"setAsCapable(" + i + ",0);\">\n" + buildSelectList(i,nsn.getAircraftList(),"F") +
				"</select></td>" +
				"<td>&nbsp;&nbsp;&nbsp;</td>" + 
				"<td align=right>" +
				"<select name=asCapable multiple size=10 onClick=\"OptionChecked(" + i + ",0);\">\n" + buildSelectList(i,nsn.getAircraftList(),"C") +
				"</select></td></tr>" +
				"</table></td>" +
				"<td>\n" + buildLocationList(nsn.getLocations(), i) +
				"</td></tr></table></td></tr><tr><td align=center colspan=2><hr></td></tr>";
		}

		retStr = retStr + "</table>";
//			retStr = retStr + "<input type=button value=\"Calculate Basic NSN Values\" onClick=\"DoAction('RECALC');\">";

		//
		// Javascript has a strange behavior that if it finds more than one 
		// control with the same name it treats it as an array but if there is 
		// only one control with a given name you can't turn
		// it into an array.
		// Defining these names as hidden fields will always force the name
		// to be an array so that the javascript that is acting on arrays
		// won't generate an error.
		//
		retStr = retStr +
			"<input type=hidden name=nsn>" +
			"<input type=hidden name=effShip value=-1>" +
			"<input type=hidden name=effFleet value=-1>" +
			"<input type=hidden name=asFlying>" +
			"<input type=hidden name=asCapable>" +
			"<input type=hidden name=sTotal>" +
			"<input type=hidden name=qty>";

		return retStr;
	}


	private Aircrafts loadAllAircraft(String pNsn)
	{
		AmdUtils.displayMsg("loadAllAircraft()",1);

		String       sqlStmt;
		ResultSet    rs;
		int          ix=0;
		Aircrafts    objAircrafts = new Aircrafts();
		AmdAircraft  ac;

		sqlStmt = "select aa.p_no,aa.ac_no,aa.tail_no,aa.fus,aa.bun,aa.fsn " +
				"from amd_nsns an, " +
				"   amd_national_stock_items ansi, amd_nsi_groups ang, " +
				"   amd_ltd_fleet_size_member alfsm, amd_aircrafts aa " +
				"where " +
				"   an.nsn = '" + pNsn + "' " +
				"   and an.nsi_sid = ansi.nsi_sid " +
				"   and ansi.nsi_group_sid = ang.nsi_group_sid " +
				"   and ang.fleet_size_name = alfsm.fleet_size_name " +
				"   and alfsm.tail_no = aa.tail_no " +
				"   and aa.tail_no != 'DUMMY' " +
				"order by " + acBy;

		AmdUtils.displayMsg(sqlStmt);
		db.createStatement();
		rs = db.execQuery(sqlStmt);
		try
		{
			while (rs.next())
			{
				ac = new AmdAircraft();
				ac.setPno(rs.getString(1));
				ac.setAcNo(rs.getString(2));
				ac.setTailNo(rs.getString(3));
				ac.setFus(rs.getString(4));
				ac.setBun(rs.getString(5));
				ac.setFsn(rs.getString(6));
				ac.setAsFlying(false);
				ac.setAsCapable(false);
				objAircrafts.add(String.valueOf(ix),ac);
				ix++;
			}
		}
		catch (java.sql.SQLException e)
		{
			AmdUtils.displayMsg("loadAllAircraft: exception");
		}

		db.closeStatement();

		return objAircrafts;
	}


	Locations loadAllLocations()
	{
		AmdUtils.displayMsg("loadAllLocations()",1);

		String    sqlStmt;
		ResultSet rs;
		int       ix=0;
		Location  loc;
		Locations objLocations = new Locations();

		sqlStmt = "select distinct asn.loc_sid,asn.loc_id,asn.location_name,0 qty " +
				"from amd_spare_networks asn " +
				"where asn.loc_type = 'MOB' " +
				"order by asn.loc_sid";

		db.createStatement();
		rs = db.execQuery(sqlStmt);
		try
		{
			while (rs.next())
			{
				loc = new Location();
				loc.setLocSid(rs.getString(1));
				loc.setLocId(rs.getString(2));
				loc.setLocationName(rs.getString(3));
				loc.setQty(rs.getInt(4));
				objLocations.add(String.valueOf(ix),loc);
				ix++;
			}
		}
		catch (java.sql.SQLException e)
		{
			AmdUtils.displayMsg("loadAllLocations: exception");
		}

		db.closeStatement();

		return objLocations;
	}

	
	String buildSelectList(int ix,Aircrafts pObject,String pType)
	{
		AmdUtils.displayMsg("buildSelectList("+pObject+","+pType+")");

		AmdAircraft acCurr;
		AmdAircraft ac;
		String  strHtml="";
		String  selected;
		String  key;

		for (int i=0;i<allAircraft.count();i++)
		{
			selected = "";
			ac     = allAircraft.getItem(String.valueOf(i));
			key    = ac.getTailNo();

	
			if (pObject != null)
			{
				acCurr = pObject.getItem(key);
				if (acCurr != null)
				{
					if (pType.equals("F") && acCurr.isAsFlying())
						selected = " selected";
					if (pType.equals("C") && acCurr.isAsCapable())
						selected = " selected";
						
					acCurr.setDisplay(acBy);
					strHtml = strHtml + "<option value=" + ix + ":" + acCurr.getTailNo() + selected + ">" + acCurr.toString() + "</option>\n";
				}
				else
				{
					ac.setDisplay(acBy);
					strHtml = strHtml + "<option value=" + ix + ":" + ac.getTailNo() + selected + ">" + ac.toString() + "</option>\n";
				}
			}
			else
			{
				ac.setDisplay(acBy);
				strHtml = strHtml + "<option value=" + ix + ":" + ac.getTailNo() + selected + ">" + ac.toString() + "</option>\n";
			}
		}

		return strHtml;
	}


	String buildLocationList(Locations pObject, int pRow)
	{
		AmdUtils.displayMsg("buildLocationList("+pObject+","+pRow+")");

		String strHtml;
		Location locCurr;
		Location loc;
		int      qty;

		strHtml = "<table><th colspan=2>Distribution of Aircraft/NSN Configuration</th><tr>\n";

		for (int i=0;i<allLocations.count();i++)
		{
			locCurr = allLocations.getItem(String.valueOf(i));
			qty = locCurr.getQty();

			if (pObject != null)
			{
				loc = pObject.getItem(locCurr.getLocSid());
				if (loc != null)
				{
					if ( (acView.equals("U") && loc.isUserDefined()) ||
							(acView.equals("D") && loc.isDerived()) ||
							(acView.equals("B")) )
						qty = loc.getQty();
				}
			}

			strHtml = strHtml + "<td align=right>" + locCurr.getLocationName() +
				" - " + locCurr.getLocId() + "</td>\n";
			strHtml = strHtml + "<td><input type=hidden name=location value=" + locCurr.getLocSid() + "><input type=text name=qty value=" + qty + " size=3 maxlength=3 onClick=\"OptionChecked(" + pRow + ",1);\" onChange=\"subTotal("+ pRow +"," + i +");\">ships</td></tr><tr>\n";
		}
		strHtml = strHtml + "<td colspan=2><hr></tr><tr>\n";
		strHtml = strHtml + "<td align=right>Subtotal</td>\n";
		strHtml = strHtml + "<td><input type=text name=sTotal size=3 maxlength=3>ships</td></tr></table>\n";

		return strHtml;
	}


	public boolean assembleData()
	{
		AmdUtils.displayMsg("assembleData()",1);

		boolean   status=true;
		int       ix;
		Nsn       nsn;
		String    pNo;
		Aircrafts myAsFlying;
		Locations myLocations;
		Location  currLoc;
		int       numLocs;
		int       offset;
		String    effectBy;
		AmdAircraft aircraft,ac;
		String      key;
		boolean     firstPass=true;


		allLocations = loadAllLocations();

AmdUtils.displayMsg("Entering assemby loop.");
		for (int row=0;row<nsnList.size();row++)
		{
			myAsFlying  = new Aircrafts();
			myLocations = new Locations();
			nsn = nsnList.getItem(String.valueOf(row));
			
			if (firstPass)
			{
				allAircraft  = loadAllAircraft(nsn.getNsn());
				firstPass = false;
			}

			if (isByShipChecked(row))
				nsn.setEffectBy("S");
			else
				nsn.setEffectBy("F");

			AmdUtils.displayMsg("Assembling asFlying and asCapable selections for nsn " + nsn.getNsn());

			for (int i=0;i<allAircraft.count();i++)
			{
				aircraft = allAircraft.getItem(String.valueOf(i));
				ac       = new AmdAircraft();
				ac.setPno(aircraft.getPno());
				ac.setAcNo(aircraft.getAcNo());
				ac.setTailNo(aircraft.getTailNo());
				ac.setFus(aircraft.getFus());
				ac.setBun(aircraft.getBun());
				ac.setFsn(aircraft.getFsn());
				ac.setAsFlying(false);
				ac.setAsCapable(false);
				key = row+":"+ac.getTailNo();

				if (asFlying.getItem(key) != null)
				{
AmdUtils.displayMsg("	setAsFlying():"+key);
					ac.setAsFlying(true);
					ac.setAsCapable(true);
				}
				else if (asCapable.getItem(key) != null)
				{
					ac.setAsCapable(true);
				}

AmdUtils.displayMsg("	effectType set to:"+ac.getEffectType());
				ac.setDisplay(acBy);
				myAsFlying.add(ac.getTailNo(),ac);
			}
	
			if (nsn.getEffectBy().equals("F"))
			{
				AmdUtils.displayMsg("Assembling locations...");
				numLocs = locations.length/nsnList.size();
				offset  = numLocs * row;
	
				for (int j=0;j<(locations.length/nsnList.size());j++)
				{
					ix = j+offset;
					currLoc = getLocation(locations[ix]);
					currLoc.setQty(qty[ix]);
					myLocations.add(currLoc.getLocSid(),currLoc);
				}
			}

			nsn.setAircraftList(myAsFlying);
			nsn.setLocations(myLocations);
			
			pageSet.add(nsn.getNsn(),nsn);
		}
AmdUtils.displayMsg("Exiting assembly loop.");
		pageSet.setUpdateDate(AmdUtils.getLastUpdateDate(nsnList.getItem("0").getNsn()));
		pageSet.setUpdateId(AmdUtils.getLastUpdateId(nsnList.getItem("0").getNsn()));
		pageSet.setSplitEffect(AmdUtils.getSplitEffect(nsnList.getItem("0").getNsiSid()));

		return status;
	}


	String isChecked(String pEffectType, String pType)
	{
		AmdUtils.displayMsg("isChecked()");

		if (pType.equals(pEffectType))
			return "checked";
		else
			return null;
	}


	boolean isByShipChecked(int pRow)
	{
		AmdUtils.displayMsg("isByShipChecked()");

		return effShip[pRow];
	}



	Location getLocation(String pLocSid)
	{
		AmdUtils.displayMsg("getLocation()");

		String    sqlStmt;
		ResultSet rs;
		Location  objLocation = new Location ();

		sqlStmt = "select loc_sid,loc_id,location_name " +
				"from amd_spare_networks " +
				"where loc_sid = " + pLocSid;

		db.createStatement();
		rs = db.execQuery(sqlStmt);
		try
		{
			while (rs.next())
			{
				objLocation.setLocSid(rs.getString(1));
				objLocation.setLocId(rs.getString(2));
				objLocation.setLocationName(rs.getString(3));
			}
		}
		catch (java.sql.SQLException e)
		{
			AmdUtils.displayMsg("getLocation: exception");
		}

		db.closeStatement();

		return objLocation;
	}


	private String buildViewCntl()
	{
		String retStr;

		retStr = "View: <select name=view onClick=\"saveIndex(this.form)\" onChange=\"ChangeView('UpdateView','"+pageSet.getSplitEffect()+"');\">" +
				"<option value=U " + isSelected("U",getView()) + ">User-defined" +
				"<option value=D " + isSelected("D",getView()) + ">Derived" +
				"<option value=B " + isSelected("B",getView()) + ">Both</select>";

		return retStr;
	}


	private String isSelected(String pStr1, String pStr2)
	{
		if (pStr1.equals(pStr2))
			return "selected";
		else
			return "";
	}



	static void main(String args[])
	{
		FormBean formHandler = new FormBean();
		String username;
		String password;
		String hostname;
		String connStr;
		String nsn = "NSL$0067764";
		String nsiSid = "739162";
		Connection conn;
		AmdDB      conObj;

		conObj = AmdDB.instance();
		conn = conObj.getConnection("amd_owner");

		formHandler.setConnection(conn);
		formHandler.retrieveData(nsn);
		formHandler.genHtml();
	}
	
} 

