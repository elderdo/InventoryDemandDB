package effectivity;

import java.util.*;
import java.sql.*;
import Configuration.*;

public class AmdUtils
{
	static protected int         debugLevel=0;
	static private   Connection  conn;
	static protected String      DT_FORMAT="mm/dd/yyyy hh:mi am";
	static private   String      nsnList[];

	static public void setConnection(Connection pConn)
	{
		displayMsg("setConnection()");
		conn = pConn;
	}

	static private void setNsnList(String pList[])
	{
		displayMsg("setNsnList()");
		nsnList = pList;
	}

	static public String[] getNsnList()
	{
		displayMsg("getNsnList()");
		return nsnList;
	}

	static public void deriveAsCapable(PageSet pPageSet)
	{
		displayMsg("deriveAsCapable()");
		ResultSet    rs;
		String       sqlStmt;
		Aircrafts    srcAc,dstAc;
		AmdAircraft  acR,acL;
		Set          keys;
		Iterator     iter;
		String       key;
		Nsn          nsnR, nsnL;
		Nsn          dstNsnObj;
		String       workNsn, interType;
		DBQuery      db;
		Set          psKeys;
		Iterator     psIter;
		String       psKey;

		db = new DBQuery(conn);
		db.createStatement();
		psKeys = pPageSet.keySet();
		psIter = psKeys.iterator();

		while (psIter.hasNext())
		{
			psKey = (String)psIter.next();
			nsnR  = pPageSet.getItem(psKey);

			try
			{
				//
				// Cycle through 'by-ship' data
				//
				// In amd_related_nsi_pairs a relationship is represented as
				// (Left Nsn,Right Nsn,interchange_type)
				// This denotes that the "Right Nsn" is interchangeable with 
				// the "Left Nsn" in the manner defined by the "interchange_type".
				// 
				// "nsnR" or "acR" represents object pertaining to the "Right Nsn"
				// "nsnL" or "acL" represents object pertaining to the "Left Nsn"
				//
				if (nsnR.getEffectBy().equals("S"))
				{
					// Cycle through all relationships
					sqlStmt = "select an.nsn,arnp.interchange_type " +
							"from amd_related_nsi_pairs arnp, " +
							"   amd_nsns an " +
							"where arnp.replaced_nsi_sid = an.nsi_sid " +
							"   and an.nsn_type = 'C' " +
							"   and arnp.replaced_by_nsi_sid = " + nsnR.getNsiSid();
					rs = db.execQuery(sqlStmt);

					// Cycle through all relationships
					while (rs.next())
					{
						workNsn   = rs.getString(1);
						interType = rs.getString(2);

						dstNsnObj = pPageSet.getItem(workNsn);
						srcAc   = nsnR.getAircraftList();
						dstAc   = dstNsnObj.getAircraftList();
						keys    = srcAc.keySet();
						iter    = keys.iterator();
			
						if (dstNsnObj.getEffectBy().equals("S"))
						{
							// Cycle through all aircraft in each relationship
							while(iter.hasNext())
							{
								key = (String)iter.next();
								acR = srcAc.getItem(key);
								acL = dstAc.getItem(key);
	
								if (!acR.isAsFlying())
								{
									if (interType.equals("limited") && 
											acR.isAsCapable() && 
											!acL.isAsFlying())
									{
										acR.setAsCapable(false);
									}
									else if ( interType.equals("Not") &&
											acL.isAsFlying() )
									{
										acR.setAsCapable(false);
										
									}
									else if ( !interType.equals("Not") &&
											!interType.equals("limited") &&
											acL.isAsFlying() )
									{
										acR.setAsCapable(true);
									}
								}
							}
						}
					}
				}
			}
			catch (Exception e)
			{
			}
		}
		db.closeStatement();
	}


	//
	// Compare new changes against the old data and update only the records
	// that changed.
	//
	static public void saveByShip(Nsn pNsn)
	{
		displayMsg("saveByShip("+pNsn+")");
		Set          keys;
		Iterator     iter;
		String       key;
		String       sqlStmt;
		ResultSet    rs;
		Aircrafts    acList,oldList;
		AmdAircraft  ac,oldAc;
		DBQuery      db;

		db = new DBQuery(conn);
		db.createStatement();
		oldList = loadAircraft(pNsn.getNsiSid(),"U");

		acList = pNsn.getAircraftList();
		keys   = acList.keySet();
		iter   = keys.iterator();

		while(iter.hasNext())
		{
			key = (String)iter.next();
			ac = acList.getItem(key);
			oldAc = oldList.getItem(key);
			if ( ac.isAsFlying() != oldAc.isAsFlying() || 
					ac.isAsCapable() != oldAc.isAsCapable() )
			{
				sqlStmt = "update amd_nsi_effects set " +
						"   effect_type   = '"+ ac.getEffectType() + "'," +
						"   user_defined  = '"+ ac.getUserDefined() + "' " +
						"where nsi_sid = " + pNsn.getNsiSid() +
						"   and tail_no = '" + ac.getTailNo() + "'";

				db.execUpdate(sqlStmt);
			}
		}
		db.closeStatement();
	}


	static public void saveByFleet(Nsn pNsn)
	{
		AmdUtils.displayMsg("saveByFleet("+pNsn.getNsn()+")");
		Locations    locList,oldList;
		Location     loc,oldLoc;
		Set          keys;
		Iterator     iter;
		String       key;
		String       sqlStmt;
		int          numRows;
		DBQuery      db;

		db = new DBQuery(conn);
		db.createStatement();
		oldList = loadLocations(pNsn.getNsiSid());

		// Save location quantities
		locList = pNsn.getLocations();
		keys   = locList.keySet();
		iter   = keys.iterator();

AmdUtils.displayMsg("locList.count("+locList.count()+")");
		while(iter.hasNext())
		{
			key     = (String)iter.next();
			loc     = locList.getItem(key);
			oldLoc  = oldList.getItem(key);
			AmdUtils.displayMsg("location("+key+")");

			if ( (!oldLoc.getUserDefined().equals(loc.getUserDefined())) ||
					(oldLoc.getUserDefined().equals("Y") &&
						loc.getQty() != oldLoc.getQty()) ||
					(loc.getQty() != oldLoc.getQty() &&
						loc.getQty() != 0) )
			{
				sqlStmt = 
					"update amd_cur_nsi_loc_distribs set " +
					"   quantity       =  " + loc.getQty()         + " ," +
					"   user_defined   = '" + loc.getUserDefined() + "'," +
					"   derived        = '" + loc.getDerived()     + "'," +
					"   last_update_id = substr(user,1,8)," +
					"   last_update_dt = sysdate " +
					"where nsi_sid  = " + pNsn.getNsiSid() + 
					"   and loc_sid = " + loc.getLocSid();
				AmdUtils.displayMsg(sqlStmt);
				numRows = db.execUpdate(sqlStmt);
				if (numRows == 0)
				{
					sqlStmt = 
						"insert into amd_cur_nsi_loc_distribs " +
						"(nsi_sid, loc_sid,user_defined,derived,quantity, " +
						" last_update_id, last_update_dt) values " +
						"( " + pNsn.getNsiSid()     + " ," +
						"  " + loc.getLocSid()      + " ," +
						" '" + loc.getUserDefined() + "'," +
						" '" + loc.getDerived()     + "'," +
						"  " + loc.getQty()         + " ," +
						" substr(user,1,8),sysdate)";
					AmdUtils.displayMsg(sqlStmt);
					db.execUpdate(sqlStmt);
				}
				AmdUtils.displayMsg("numRows("+numRows+")");
			}
		}
		db.closeStatement();
	}


	static public void pruneAsCapable(int pNsiGroupSid)
	{
		displayMsg("pruneAsCapable("+pNsiGroupSid+")");
		ResultSet   rs;
		DBQuery     db;
		String      nsn;

		db = new DBQuery(conn);
		db.createStatement();

		// Gets nsn to pass to overloaded pruneAsCapable()
		//
		rs = db.execQuery("select nsn from amd_national_stock_items " +
				"where nsi_group_sid = " + pNsiGroupSid + " and rownum = 1");
		try
		{
			rs.next();
			nsn = rs.getString(1);
			pruneAsCapable(nsn);
		}
		catch (Exception e)
		{
			displayMsg("exception:"+e);
		}

		db.closeStatement();
	}


	// pruneAsCapable(String)
	//
	// Accepts an nsn but acts on the entire group.  loadEffectivity() will
	// load the entire group of nsns where the nsi_group_sid matches that
	// of the nsn passed in.
	//
	static public void pruneAsCapable(String pNsn)
	{
		displayMsg("pruneAsCapable()");
		ResultSet    rs;
		String       sql;
		Nsn          currNsnObj,nsnObjL;
		Aircrafts    acListR,acListL;
		AmdAircraft  acR, acL;
		Set          psKeySet,keys;
		Iterator     psIter, iter;
		String       psKey,key;
		ArrayList    relatedNsns;
		String       relKey="";
		Set          relatedSet;
		ListIterator relatedIter;
		boolean      found;
		String       errorTail="";
		String       relatedNsn, interType;
		DBQuery      db;
		PageSet      ps;
		String       currDate="";

		db = new DBQuery(conn);
		db.createStatement();

		// Get system date
		//
		displayMsg("determining sysdate");
		rs = db.execQuery("select to_char(sysdate,'"+DT_FORMAT+"') from dual");
		try
		{
			rs.next();
			currDate = rs.getString(1);
		}
		catch (Exception e)
		{
			displayMsg("exception:"+e);
		}

		ps = loadEffectivity(pNsn);
		displayPageSet(ps);
		psKeySet = ps.keySet();
		psIter   = psKeySet.iterator();

		while(psIter.hasNext())
		{
			psKey = (String)psIter.next();
			currNsnObj = ps.getItem(psKey);

			if (! currNsnObj.getEffectBy().equals("S")) continue;

			currNsnObj.setUpdateDate(currDate);
			displayMsg("pruning nsn "+ currNsnObj.getNsn());

			// Cycle through all relationships
			sql = "select an.nsn,arnp.replaced_nsi_sid,arnp.interchange_type " +
					"from amd_related_nsi_pairs arnp, " +
					"   amd_nsns an " +
					"where " +
					"   arnp.replaced_nsi_sid = an.nsi_sid " +
					"   and an.nsn_type = 'C' " +
					"   and arnp.replaced_by_nsi_sid = " + currNsnObj.getNsiSid();
			rs = db.execQuery(sql);

			relatedNsns = new ArrayList();

			try
			{
				while (rs.next())
				{
					relatedNsns.add(rs.getString(1)+":"+rs.getString(3));
				}
			}
			catch (Exception e)
			{
				displayMsg("pruneAsCapable(): exception"+ e);
			}

			if (relatedNsns.size() > 0)
			{
				acListR = currNsnObj.getAircraftList();
				keys    = acListR.keySet();
				iter    = keys.iterator();

				while(iter.hasNext())
				{
					found = false;
					key = (String)iter.next();
					acR = acListR.getItem(key);
					if (!acR.isAsFlying())
					{
						relatedIter = relatedNsns.listIterator();
			
						while (relatedIter.hasNext())
						{
							relKey = (String)relatedIter.next();
							relatedNsn = relKey.substring(0,relKey.indexOf(":"));
							interType  = relKey.substring(relKey.indexOf(":")+1);
							displayMsg("Processing relationship ("+relKey+","+currNsnObj.getNsn()+")");
							nsnObjL = ps.getItem(relatedNsn);
							if (nsnObjL.getEffectBy().equals("S"))
							{
								acListL = nsnObjL.getAircraftList();
								acL = acListL.getItem(key);
				
								if (acL.isAsFlying() && 
								(interType.equals("1-way") || interType.equals("2-way")))
								{
									found = true;
								}
								else if (acL.isAsFlying() && acR.isAsCapable() && 
										interType.equals("limited"))
								{
									found = true;
								}
							}
							errorTail = acR.getTailNo();
						}

						if (found)
							acR.setAsCapable(true);
						else
						{
							acR.setAsCapable(false);
//	System.out.println("Not found ("+relKey +","+currNsnObj.getNsn()+") tail_no("+errorTail+")");
						}
					}
				}
			}
		}


		// Cycle through each Nsn object in the PageSet and save its ship data.
		//
		psKeySet = ps.keySet();
		psIter   = psKeySet.iterator();

		while(psIter.hasNext())
		{
			psKey = (String)psIter.next();
			currNsnObj = ps.getItem(psKey);
			if (currNsnObj.getEffectBy().equals("S"))
			{
				displayMsg("saving data for nsn " + currNsnObj.getNsn());
				sql = "update amd_national_stock_items set " +
						"  effect_by = '" + currNsnObj.getEffectBy() + "', " +
						"  effect_last_update_id = substr(user,1,8), " +
						"  effect_last_update_dt = to_date('" +
							currNsnObj.getUpdateDate() +
						"','"+DT_FORMAT+"')" +
						"where nsi_sid = " + currNsnObj.getNsiSid();
				db.execUpdate(sql);
				saveByShip(currNsnObj);
			}
		}
		db.closeStatement();
	}


	static public void updateAssetMgmtStatus(int pGroupSid)
	{
		displayMsg("updateAssetMgmtStatus("+pGroupSid+")");
		ResultSet   rs;
		DBQuery     db;
		String      nsn;

		db = new DBQuery(conn);
		db.createStatement();

		// Gets nsn to pass to overloaded pruneAsCapable()
		//
		db.execUpdate("declare begin " +
				"amd_effectivity_pkg.updateAssetMgmtStatus("+pGroupSid+"); " +
				"end; ");
		db.closeStatement();
	}


	static public Nsn getNsn(String pNsn)
	{
//		System.out.println("getNsn()");
		displayMsg("getNsn("+pNsn+")");

		String    sqlStmt;
		ResultSet rs;
		Nsn       objNsn = new Nsn();
		DBQuery   db;

		db = new DBQuery(conn);
		db.createStatement();
		sqlStmt = "select ansi.nsn,ansi.nsi_sid,nvl(ang.split_effect,'N')," +
				"   nvl(ansi.effect_by,'S'),asp.part_no,asp.nomenclature," +
				"   alfsm.fleet_size, " +
				"   to_char(ansi.effect_last_update_dt,'"+DT_FORMAT+"') updateDate, " +
				"   lower(ansi.effect_last_update_id) " +
				"from amd_national_stock_items ansi, " +
				"   amd_nsi_groups ang, " +
				"   amd_nsi_parts anp, " +
				"   amd_spare_parts asp, " +
				"   (select fleet_size_name, count(*) fleet_size " +
				"   from amd_ltd_fleet_size_member " +
				"   where tail_no != 'DUMMY' " +
				"   group by fleet_size_name) alfsm " +
				"where ansi.nsn = '" + pNsn + "'" +
				"   and ansi.nsi_sid = anp.nsi_sid " +
				"   and anp.part_no  = asp.part_no " +
				"   and anp.unassignment_date is null " +
				"   and anp.prime_ind = 'Y' " +
				"   and ansi.nsi_group_sid = ang.nsi_group_sid(+) " +
				"   and ang.fleet_size_name = alfsm.fleet_size_name ";

		rs = db.execQuery(sqlStmt);
		try
		{
			while (rs.next())
			{
				objNsn.setNsn(rs.getString(1));
				objNsn.setNsiSid(rs.getString(2));
				objNsn.setConfigType(rs.getString(3));
				objNsn.setEffectBy(rs.getString(4));
				objNsn.setPrimePart(rs.getString(5));
				objNsn.setNomen(rs.getString(6));
				objNsn.setFleetSize(rs.getString(7));
				objNsn.setUpdateDate(rs.getString(8));
				objNsn.setUpdateId(rs.getString(9));
			}
		}
		catch (java.sql.SQLException e)
		{
//			System.out.println("getNsn: exception");
		}
		finally
		{
			displayMsg("closing statement");
		}
		db.closeStatement();

		return objNsn;
	}


	static Aircrafts loadAircraft(String pNsiSid, String pView)
	{
		displayMsg("loadAircraft("+pNsiSid+","+pView+")");

		String    sqlStmt;
		ResultSet rs;
		Aircrafts objAircraft = new Aircrafts();
		AmdAircraft  ac;
		String       viewStmt="";
		DBQuery   db;

		db = new DBQuery(conn);
		db.createStatement();

		if (pView.equals("U"))
			viewStmt = " and user_defined in ('Y','S') ";
		else if (pView.equals("D"))
			viewStmt = " and derived = 'Y' ";
		else if (pView.equals("B"))
			viewStmt = " and (user_defined in ('Y','S') or derived = 'Y') ";

		sqlStmt = 
			"select  " +
			"	aa.p_no, " +
			"	aa.ac_no, " +
			"	aa.tail_no, " +
			"	aa.fsn, " +
			"	aa.fus, " +
			"	aa.bun, " +
			"	nvl(af.asFlying,0), " +
			"	nvl(ac.asCapable,0) " +
			"from " +
			"  amd_national_stock_items ansi, " +
			"  amd_nsi_groups ang, " +
			"  amd_ltd_fleet_size_member alfsm, " +
			"	amd_aircrafts aa, " +
			"	(select tail_no,count(*) asFlying " +
			"	from amd_nsi_effects " +
			"	where nsi_sid = " + pNsiSid +
			"		and effect_type = 'B' " + viewStmt +
			"	group by tail_no) af, " +
			"	(select tail_no,count(*) asCapable " +
			"	from amd_nsi_effects " +
			"	where nsi_sid = " + pNsiSid +
			"		and effect_type in ('B','C') " + viewStmt +
			"	group by tail_no) ac " +
			"where " +
			"  ansi.nsi_sid = " + pNsiSid +
			"  and ansi.nsi_group_sid = ang.nsi_group_sid " +
			"  and ang.fleet_size_name = alfsm.fleet_size_name " +
			"  and alfsm.tail_no = aa.tail_no " +
			"  and alfsm.tail_no != 'DUMMY' " +
			"	and aa.tail_no = af.tail_no(+) " +
			"	and aa.tail_no = ac.tail_no(+) " +
			"order by to_date(substr(aa.tail_no,1,2),'rr'),aa.tail_no";

		displayMsg(sqlStmt);
		rs = db.execQuery(sqlStmt);
		if (rs != null) 
		{
			try
			{
				while (rs.next())
				{
					ac = new AmdAircraft();

					ac.setPno(rs.getString(1));
					ac.setAcNo(rs.getString(2));
					ac.setTailNo(rs.getString(3));
					ac.setBun(rs.getString(6));
					ac.setFsn(rs.getString(4));
					ac.setFus(rs.getString(5));
					ac.setAsFlying(false);
					ac.setAsCapable(false);

					if (rs.getInt(7) != 0)
						ac.setAsFlying(true);

					if (rs.getInt(8) != 0)
						ac.setAsCapable(true);

					objAircraft.add(ac.getTailNo(),ac);
				}
			}
			catch (java.sql.SQLException e)
			{
				displayMsg("loadAircraft: exception");
			}
			finally
			{
			}
		}
		db.closeStatement();

		return objAircraft;
	}


	static Locations loadLocations(String pNsiSid)
	{
		displayMsg("loadLocations()");

		String    sqlStmt;
		ResultSet rs;
		Locations objLocations = new Locations();
		Location  loc;
		DBQuery   db;

		db = new DBQuery(conn);
		db.createStatement();

		sqlStmt = "select distinct " +
				"   asn.loc_sid,asn.loc_id," +
				"   asn.location_name," +
				"   acnld.quantity, " +
				"   nvl(user_defined,'N'), " +
				"   nvl(derived,'N') " +
				"from amd_spare_networks asn, " +
				" amd_cur_nsi_loc_distribs acnld " +
				"where asn.loc_type = 'MOB' " +
				" and asn.loc_sid = acnld.loc_sid(+) " +
				" and " + pNsiSid + " = acnld.nsi_sid(+) " +
				"order by asn.loc_sid";

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
				loc.setUserDefined(rs.getString(5));
				loc.setDerived(rs.getString(6));
				objLocations.add(loc.getLocSid(),loc);
			}
		}
		catch (java.sql.SQLException e)
		{
//			System.out.println("loadLocations: exception");
		}
		db.closeStatement();

		return objLocations;
	}

	static public PageSet loadEffectivity(String pNsn)
	{
		displayMsg("loadEffectivity()");
		return loadEffectivity(pNsn,"U");
	}

	static public PageSet loadEffectivity(String pNsn,String pView)
	{
		displayMsg("loadEffectivity()");

		String    sqlStmt;
		String    nsnItem;
		ResultSet rs;
		int       ix=0;
		String    nsnArr[];
		int       nsnCnt=0;
		Nsn       nsn = new Nsn();
		PageSet   ps = new PageSet();
		DBQuery   db;

		db = new DBQuery(conn);
		db.createStatement();

		sqlStmt = "select count(*) from amd_national_stock_items " +
				"where nsi_group_sid = (select nsi_group_sid from " +
				"amd_national_stock_items where nsn = '" + pNsn + "')";

		rs = db.execQuery(sqlStmt);
		try
		{
			rs.next();
			nsnCnt = rs.getInt(1);
			if (nsnCnt == 0) nsnCnt++;
		}
		catch (Exception e)
		{
			displayMsg("exception: " + e);
		}

		// Need to create extra index since setNsn() will strip off last one.
		// This is needed because client javascript code works on arrays but
		// arrays aren't created unless there are at least two items with the 
		// same name. This will guarantee that there are at least two items.
		nsnArr = new String[nsnCnt+1];

		sqlStmt = "select '1' sortOrder,an.nsn " +
				"from amd_nsns an, amd_national_stock_items ansi " +
				"where an.nsn = '" + pNsn + "' " +
				"  and an.nsi_sid = ansi.nsi_sid " +
				"union " +
				"select '2' sortOrder,nsn " +
				"from amd_national_stock_items " +
				"where nsn != '" + pNsn + "' " +
				"  and nsi_group_sid = " +
				"  (select nsi_group_sid " +
				"  from amd_national_stock_items " +
				"  where nsn = '" + pNsn + "') " +
				"     and nsn != '" + pNsn + "' " +
				"order by sortOrder, nsn";

		rs = db.execQuery(sqlStmt);
		try
		{
			while (rs.next())
			{
				nsn = getNsn(rs.getString("nsn"));
				if (nsn.getEffectBy().equals("S"))
					nsn.setAircraftList(loadAircraft(nsn.getNsiSid(),pView));
				else
					nsn.setLocations(loadLocations(nsn.getNsiSid()));
			
				ps.add(nsn.getNsn(), nsn);
				ps.setUpdateDate(nsn.getUpdateDate());
				ps.setUpdateId(nsn.getUpdateId());
				ps.setSplitEffect(getSplitEffect(nsn.getNsiSid()));
				nsnArr[ix] = nsn.getNsn();
				ix++;
			}
		}
		catch (java.sql.SQLException e)
		{
//			System.out.println("loadEffectivity: exception");
		}
		finally
		{
		}
		db.closeStatement();

		// Since the splitEffect is retrieved for all nsns and is the same, set
		// the last one at the pageSet level.
		ps.setSplitEffect(getSplitEffect(nsn.getNsiSid()));
		nsnArr[ix] = "DUMMY";
		setNsnList(nsnArr);

		return ps;
	}


	static public String getLastUpdateDate(String pNsn)
	{
		displayMsg("getLastUpdateDate()");
		String     updateDate="";
		ResultSet  rs;
		DBQuery    db;

		db = new DBQuery(conn);
		db.createStatement();
		rs = db.execQuery("select to_char(effect_last_update_dt,'"+DT_FORMAT+"') " +
					"from amd_nsns an, " +
					"   amd_national_stock_items ansi " +
					"where an.nsn = '" + pNsn + "' " +
					"   and an.nsi_sid = ansi.nsi_sid");

		try 
		{
			rs.next();
			updateDate = rs.getString(1);
		}
		catch (Exception e)
		{
		}
		db.closeStatement();
		return updateDate;

	}

	static public String getLastUpdateId(String pNsn)
	{
		displayMsg("getLastUpdateId()");
		String     updateId="";
		ResultSet  rs;
		DBQuery    db;

		db = new DBQuery(conn);
		db.createStatement();
		rs = db.execQuery("select lower(effect_last_update_id) " +
					"from amd_nsns an, " +
					"   amd_national_stock_items ansi " +
					"where an.nsn = '" + pNsn + "' " +
					"   and an.nsi_sid = ansi.nsi_sid");

		try 
		{
			rs.next();
			updateId = rs.getString(1);
		}
		catch (Exception e)
		{
		}
		db.closeStatement();
		return updateId;
	}


	static public String getSplitEffect(String pNsiSid)
	{
		displayMsg("getSplitEffect("+pNsiSid+")");

		String     splitEffect="";
		ResultSet  rs;
		DBQuery    db;

		db = new DBQuery(conn);
		db.createStatement();
		rs = db.execQuery("select ang.split_effect " +
					"from amd_nsi_groups ang, " +
					"   amd_national_stock_items ansi " +
					"where ansi.nsi_sid = " + pNsiSid +
					"   and ansi.nsi_group_sid = ang.nsi_group_sid");

		try 
		{
			rs.next();
			splitEffect = rs.getString(1);
		}
		catch (Exception e)
		{
		}
		db.closeStatement();
		return splitEffect;

	}


	static void displayPageSet(PageSet pPs)
	{
//		System.out.println("displayPageSet()");
		displayMsg("displayPageSet()");
		Aircrafts    acList;
		AmdAircraft  ac;
		String       key;
		Set          keys;
		Iterator     iter;
		Nsn          nsnItem;
		Nsn          nsn;
		String       asFlyingInd;
		String       asCapableInd;
		Set          psKeys;
		Iterator     psIter;
		String       psKey;

		psKeys = pPs.keySet();
		psIter = psKeys.iterator();

		while (psIter.hasNext())
		{
			psKey = (String)psIter.next();
			nsn   = pPs.getItem(psKey);

			if (nsn.getEffectBy().equals("S"))
			{
				acList = nsn.getAircraftList();
				keys     = acList.keySet();
				iter     = keys.iterator();

				while(iter.hasNext())
				{
					asFlyingInd = "N";
					asCapableInd = "N";

					key = (String)iter.next();
					ac  = acList.getItem(key);

					if (ac.isAsFlying())
						asFlyingInd = "Y";
					if (ac.isAsCapable())
						asCapableInd = "Y";

//					System.out.println("nsn("+nsn.getNsn()+") tail_no("+ac.getTailNo()+") isAsFlying("+asFlyingInd+") isAsCapable("+asCapableInd+") user_defined("+ac.getUserDefined()+")");
				}
			}
		}
	}


	static void resetAc(Aircrafts pAc)
	{
		displayMsg("resetAc()");
		Set          keys;
		Iterator     iter;
		String       key;
		AmdAircraft  ac;

		keys   = pAc.keySet();
		iter   = keys.iterator();

		while(iter.hasNext())
		{
			key = (String)iter.next();
			ac  = pAc.getItem(key);
			ac.setAsFlying(false);
			ac.setAsCapable(false);
		}
	}


	static void resetLocations(Locations pLocs)
	{
		displayMsg("unsetLocations()");
		Set          keys;
		Iterator     iter;
		String       key;
		Location     loc;

		keys   = pLocs.keySet();
		iter   = keys.iterator();

		while(iter.hasNext())
		{
			key = (String)iter.next();
			loc = pLocs.getItem(key);
			loc.setQty(0);
		}
	}


	static public void setDebugLevel(int pLevel)
	{
		displayMsg("setDebugLevel()");
		debugLevel = pLevel;
	}

	static void displayMsg(String pString)
	{
		displayMsg(pString,3);
	}
	
	static void displayMsg(String pString,int pLevel)
	{
		if (pLevel <= debugLevel)
			System.out.println(pString);
	}


	static public boolean valAsCapable(PageSet pPageSet)
	{
		displayMsg("valAsCapable()");
		ResultSet    rs;
		String       sqlStmt;
		Aircrafts    srcAc,dstAc;
		AmdAircraft  acR,acL;
		Set          keys;
		Iterator     iter;
		String       key;
		Nsn          nsnR, nsnL;
		String       workNsn, interType;
		DBQuery      db;
		Set          psKeys;
		Iterator     psIter;
		String       psKey;
		boolean      status=true;

		db = new DBQuery(conn);
		db.createStatement();
		psKeys = pPageSet.keySet();
		psIter = psKeys.iterator();

		while (psIter.hasNext())
		{
			psKey = (String)psIter.next();
			nsnR  = pPageSet.getItem(psKey);

			try
			{
				//
				// Cycle through 'by-ship' data
				//
				// In amd_related_nsi_pairs a relationship is represented as
				// (Left Nsn,Right Nsn,interchange_type)
				// This denotes that the "Right Nsn" is interchangeable with 
				// the "Left Nsn" in the manner defined by the "interchange_type".
				// 
				// "nsnR" or "acR" represents object pertaining to the "Right Nsn"
				// "nsnL" or "acL" represents object pertaining to the "Left Nsn"
				//
				if (nsnR.getEffectBy().equals("S"))
				{
					// Cycle through all relationships
					sqlStmt = "select an.nsn,arnp.replaced_nsi_sid,arnp.interchange_type " +
							"from amd_related_nsi_pairs arnp, " +
							"   amd_nsns an " +
							"where arnp.replaced_nsi_sid = an.nsi_sid " +
							"   and an.nsn_type = 'C' " +
							"   and arnp.replaced_by_nsi_sid = " + nsnR.getNsiSid();
					rs = db.execQuery(sqlStmt);

					// Cycle through all relationships
					while (rs.next())
					{
						workNsn   = rs.getString(1);
						interType = rs.getString(3);

						nsnL = pPageSet.getItem(workNsn);
						srcAc   = nsnR.getAircraftList();
						dstAc   = nsnL.getAircraftList();
						keys    = srcAc.keySet();
						iter    = keys.iterator();
			
						if (nsnL.getEffectBy().equals("S"))
						{
							// Cycle through all aircraft in each relationship
							while(iter.hasNext())
							{
								key = (String)iter.next();
								acR = srcAc.getItem(key);
								acL = dstAc.getItem(key);
	
								if (!acR.isAsFlying())
								{
									if (interType.equals("limited") && 
											acR.isAsCapable() && 
											!acL.isAsFlying())
									{
										nsnR.setErrorMsg("You have selected an invalid aircraft as being \"Useable On\".");
										pPageSet.setErrorMsg("Errors have been found.  Please see below.");
										status = false;
									}
									else if ( interType.equals("Not") &&
											acR.isAsCapable() &&
											acL.isAsFlying() )
									{
										nsnR.setErrorMsg("You have selected an invalid aircraft as being \"Useable On\".");
										pPageSet.setErrorMsg("Errors have been found.  Please see below.");
										status = false;
									}
								}
							}
						}
					}
				}
			}
			catch (Exception e)
			{
			}
		}
		db.closeStatement();

		return status;
	}


	static void main(String args[])
	{
		displayMsg("main()");
		Connection conn;
		AmdDB      conObj;
		DBQuery    db;
		ResultSet  rs;
		String     currDate;
		int        i=0;

		conObj = AmdDB.instance();
		conn   = conObj.getConnection("amd_owner","sdsproject");
		setDebugLevel(5);
		db = new DBQuery(conn);
		db.createStatement();

		if (conn == null)
			System.out.println("conn is null");
		else
		{
			setConnection(conn);
			pruneAsCapable("5998219209173");
		}
		db.closeStatement();
	}
}
