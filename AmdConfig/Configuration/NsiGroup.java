package Configuration;
import java.sql.*;
/*
 *  $Revision:   1.7  $
 *  $Author:   c970183  $
 *  $Workfile:   NsiGroup.java  $
 *  $Log:   \\www-amssc-01\pds\archives\SDS-AMD\Components-ClientServer\AmdConfig\Configuration\NsiGroup.java-arc  $
/*
/*   Rev 1.7   20 Aug 2002 08:20:52   c970183
/*Reformatted file with JEdit's JavaStyle plugin
 *  *
 *  *   Rev 1.6   19 Aug 2002 15:56:06   c970183
 *  *Added code to set the user_defined column of the amd_nsi_effects table according to the following rules:
 *  *
 *  *if Split_config = Y
 *  *Set the amd_nsi_effects.user_defined value to N for any aircraft NOT in the fleet size (tail_no NOT in fleet_size_member.tail_no)
 *  *Display message to identify specific aircraft in the Effective Aircraft screen
 *  *
 *  *if Split_config = N
 *  *Set the amd_nsi_effects.user_defined value to N for any aircraft NOT in the fleet size (tail_no NOT in fleet_size_member.tail_no)
 *  *
 *  *AND
 *  *Set the amd_nsi_effects.user_defined value to S for all aircraft in the fleet size (tail_no IN fleet_size_member.tail_no)
 *  *
 *  *
 *  *
 *  *   Rev 1.5   19 Aug 2002 10:47:00   c970183
 *  *Moved rebuildChildren so it is invoked after all other code in the save method has been executed.
 *  *
 *  *   Rev 1.4   19 Aug 2002 09:43:04   c970183
 *  *Reset fleetSizeChanged flag to false after rebuildChildren is invoked.
 *  *
 *  *   Rev 1.3   19 Aug 2002 09:17:54   c970183
 *  *Added invocation of execQuery("declare begin amd_effectivity.rebuildChildren("+ parentNsiSid +"); end;"); for all nsi_sid's in the group
 *  *
 *  *   Rev 1.1   23 May 2002 06:57:52   c970183
 *  *Test Release
 */
import java.util.*;
import org.apache.log4j.Logger;

/**
 *  This class is used to group the nsn's and fleets.
 *
 *@author     Douglas S. Elder
 *@created    August 20, 2002
 *@since      06/20/02
 */
public class NsiGroup {
	private boolean additionsOccured = false;

	private FleetSize fleetSize;
	private boolean fleetSizeChanged;
	private String nsiGroupSid;
	private Pairs pairs;
	private RelatedNsns relatedNsns;
	private String[] removedAC;
	private String splitEffect;
	private boolean splitEffectChanged;

	private String userDefined;
	private static String author = "$Author:   c970183  $";
	private static Logger logger = Logger.getLogger(NsiGroup.class.getName());

	private static String revision = "$Revision:   1.7  $";
	private static String workfile = "$Workfile:   NsiGroup.java  $";
	/**
	 *  Description of the Field
	 */
	public final static String CANNOT_FLY = "N";
	/**
	 *  Description of the Field
	 */
	public final static String CAPABLE = "C";
	/**
	 *  Description of the Field
	 */
	public final static String SINGLE_EFFECTIVITY = "N";

	/**
	 *  Description of the Field
	 */
	public final static String SPLIT_EFFECTIVITY = "Y";
	/**
	 *  Description of the Field
	 */
	public final static String SYSTEM_DEFAULT = "S";
	/**
	 *  Description of the Field
	 */
	public final static String USER_DEFINED = "Y";


	/**
	 *  Constructor for the NsiGroup object
	 */
	public NsiGroup() {
		fleetSize = new FleetSize();
		splitEffect = SINGLE_EFFECTIVITY;
		userDefined = this.SYSTEM_DEFAULT;
		if (logger.isDebugEnabled()) {
			logger.info("Set userDefined to " + userDefined);
		}
		relatedNsns = new RelatedNsns();
		pairs = new Pairs();
	}


	/**
	 *  Sets the allSystemDefaultToCannotFly attribute of the NsiGroup object
	 *
	 *@param  userid                     The new allSystemDefaultToCannotFly value
	 *@param  theSet                     The new allSystemDefaultToCannotFly value
	 *@exception  java.sql.SQLException  Description of the Exception
	 */
	protected void setAllSystemDefaultToCannotFly(String userid, String theSet)
			 throws java.sql.SQLException {
		logger.debug("setAllSystemDefaultToCannotFly");
		Statement s = AmdDB.instance().getConnection(userid).createStatement();

		String sqlStmt = "update amd_nsi_effects set user_defined = '" + this.CANNOT_FLY + "' where nsi_sid in " + theSet;
		sqlStmt += " and user_defined = '" + this.SYSTEM_DEFAULT + "'";
		logger.info(sqlStmt);
		s.executeUpdate(sqlStmt);
		s.close();
	}


	/**
	 *  Sets the fleetSize attribute of the NsiGroup object
	 *
	 *@param  fleetSize  The new fleetSize value
	 */
	public void setFleetSize(FleetSize fleetSize) {
		if (!this.fleetSize.equals(fleetSize)) {
			if (fleetSize.getPredefinedFleetSize()) {
				if (fleetSize.getFleetSizeName().equalsIgnoreCase(FleetSize.ALL_AIRCRAFT)) {
					userDefined = this.SYSTEM_DEFAULT;
				} else {
					userDefined = this.CANNOT_FLY;
				}
			} else {
				userDefined = this.CANNOT_FLY;
			}
			fleetSizeChanged = true;
		}
		removedAC = this.fleetSize.diff(fleetSize);
		this.fleetSize = fleetSize;
		if (logger.isDebugEnabled()) {
			logger.debug("fleetSizeChanged=" + fleetSizeChanged);
		}
	}


	/**
	 *  Sets the fleetSizeName attribute of the NsiGroup object
	 *
	 *@param  fleetSizeName  The new fleetSizeName value
	 */
	public void setFleetSizeName(String fleetSizeName) {
		fleetSize.setFleetSizeName(fleetSizeName);
	}


	/**
	 *  Sets the latestConfigToSystemDefaultForNsiEffects attribute of the NsiGroup
	 *  object
	 *
	 *@param  userid                     The new
	 *      latestConfigToSystemDefaultForNsiEffects value
	 *@exception  java.sql.SQLException  Description of the Exception
	 */
	protected void setLatestConfigToSystemDefaultForNsiEffects(String userid)
			 throws java.sql.SQLException {
		logger.debug("setLatestConfigToSystemDefaultForNsiEffects");
		Statement s = AmdDB.instance().getConnection(userid).createStatement();
		String sqlStmt = "update amd_nsi_effects set user_defined = '" + NsiGroup.SYSTEM_DEFAULT + "' where nsi_sid = ";
		Set keys = relatedNsns.keySet();
		Iterator iterator = keys.iterator();
		while (iterator.hasNext()) {
			RelatedNsn relatedNsn = (RelatedNsn) relatedNsns.get(iterator.next());
			if (relatedNsn.getLatestConfig().equals("Y")) {
				sqlStmt += relatedNsn.getNsiSid();
				break;
			}
		}
		logger.info(sqlStmt);
		s.executeUpdate(sqlStmt);
		s.close();
	}


	/**
	 *  Sets the nsiGroupSid attribute of the NsiGroup object
	 *
	 *@param  nsiGroupSid  The new nsiGroupSid value
	 */
	public void setNsiGroupSid(String nsiGroupSid) {
		this.nsiGroupSid = nsiGroupSid;
	}


	/**
	 *  Sets the pairs attribute of the NsiGroup object
	 *
	 *@param  pairs  The new pairs value
	 */
	public void setPairs(Pairs pairs) {
		this.pairs = pairs;
	}


	/**
	 *  Sets the relatedNsns attribute of the NsiGroup object
	 *
	 *@param  relatedNsns  The new relatedNsns value
	 */
	public void setRelatedNsns(RelatedNsns relatedNsns) {
		this.relatedNsns = relatedNsns;
	}


	/**
	 *  Sets the splitEffect attribute of the NsiGroup object
	 *
	 *@param  splitEffect  The new splitEffect value
	 */
	public void setSplitEffect(String splitEffect) {
		if (!this.splitEffect.equals(splitEffect)) {
			this.splitEffectChanged = true;
			if (logger.isDebugEnabled()) {
				logger.info("splitEffect being changed to " + splitEffect);
			}
			if (splitEffect.equals(SPLIT_EFFECTIVITY)) {
				if (logger.isDebugEnabled()) {
					logger.info("userDefined is being changed from " + userDefined + " to " + this.CANNOT_FLY);
				}
				userDefined = this.CANNOT_FLY;
			} else {
				if (fleetSize.getPredefinedFleetSize()
						 && fleetSize.getFleetSizeName().equalsIgnoreCase(FleetSize.ALL_AIRCRAFT)) {
					if (logger.isDebugEnabled()) {
						logger.info("userDefined is being changed from " + userDefined + " to " + this.SYSTEM_DEFAULT);
					}
					userDefined = this.SYSTEM_DEFAULT;
				}
			}
		}
		if (this.splitEffect.equals(this.SINGLE_EFFECTIVITY)
				 && splitEffect.equals(this.SPLIT_EFFECTIVITY)
				 && relatedNsns.size() > 1) {
			this.splitEffect = splitEffect;
			if (logger.isDebugEnabled()) {
				logger.debug("splitEffect=" + splitEffect);
			}
			this.addPairs();
		} else {
			this.splitEffect = splitEffect;
		}
	}


	/**
	 *  Sets the userDefined attribute of the NsiGroup object
	 *
	 *@param  userDefined  The new userDefined value
	 */
	public void setUserDefined(String userDefined) {
		if (!this.userDefined.equals(userDefined)) {
			if (logger.isDebugEnabled()) {
				logger.info("Changing userDefined from " + this.userDefined + " to " + userDefined);
			}
		}
		this.userDefined = userDefined;
	}


	/**
	 *  Gets the author attribute of the NsiGroup object
	 *
	 *@return    The author value
	 */
	public String getAuthor() {
		return author;
	}


	/**
	 *  Gets the fleetSize attribute of the NsiGroup object
	 *
	 *@return    The fleetSize value
	 */
	public FleetSize getFleetSize() {
		return fleetSize;
	}


	/**
	 *  Gets the fleetSizeName attribute of the NsiGroup object
	 *
	 *@return    The fleetSizeName value
	 */
	public String getFleetSizeName() {
		return fleetSize.getFleetSizeName();
	}


	/**
	 *  Gets the groupComplete attribute of the NsiGroup object
	 *
	 *@return    The groupComplete value
	 */
	public boolean getGroupComplete() {
		return relatedNsns.size() == relatedNsns.getCompleteCount();
	}


	/**
	 *  Gets the nsiGroupSid attribute of the NsiGroup object
	 *
	 *@return    The nsiGroupSid value
	 */
	public String getNsiGroupSid() {
		return nsiGroupSid;
	}


	/**
	 *  Gets the pairs attribute of the NsiGroup object
	 *
	 *@return    The pairs value
	 */
	public Pairs getPairs() {
		return this.pairs;
	}


	/**
	 *  Gets the relatedNsns attribute of the NsiGroup object
	 *
	 *@return    The relatedNsns value
	 */
	public RelatedNsns getRelatedNsns() {
		return this.relatedNsns;
	}


	/**
	 *  Gets the revision attribute of the NsiGroup object
	 *
	 *@return    The revision value
	 */
	public String getRevision() {
		return revision;
	}


	/**
	 *  Gets the setOfNsiSids attribute of the NsiGroup object
	 *
	 *@return    The setOfNsiSids value
	 */
	protected String getSetOfNsiSids() {
		Set keys = relatedNsns.keySet();
		Iterator iterator = keys.iterator();
		String theSet = "(";
		while (iterator.hasNext()) {
			theSet += iterator.next() + ",";
		}
		theSet = theSet.substring(0, theSet.length() - 1) + ")";
		return theSet;
	}


	/**
	 *  Gets the splitEffect attribute of the NsiGroup object
	 *
	 *@return    The splitEffect value
	 */
	public String getSplitEffect() {
		return this.splitEffect;
	}


	/**
	 *  Gets the userDefined attribute of the NsiGroup object
	 *
	 *@return    The userDefined value
	 */
	public String getUserDefined() {
		return userDefined;
	}


	/**
	 *  Gets the workfile attribute of the NsiGroup object
	 *
	 *@return    The workfile value
	 */
	public String getWorkfile() {
		return workfile;
	}


	/**
	 *  Description of the Method
	 *
	 *@param  relatedNsn  Description of the Parameter
	 */
	public void add(RelatedNsn relatedNsn) {
		logger.debug("adding related nsn.");
		relatedNsn.setNsiGroup(this);
		if (logger.isDebugEnabled()) {
			logger.debug("relatedNsn.getLatestConfig()=" + relatedNsn.getLatestConfig() + " " + relatedNsn.getNsiSid() + " for group for part " + relatedNsn.getPartNo() + " with nsiSid " + relatedNsn.getNsiGroup().getNsiGroupSid());
		}
		if (relatedNsn.getLatestConfig().equals("Y")) {
			logger.debug("setting latestConfig to N for all relatednsn's");
			relatedNsns.setLatestConfig("N");
		}
		relatedNsns.add(relatedNsn.getNsiSid(), relatedNsn);
		if (logger.isDebugEnabled()) {
			logger.debug("splitEffect=" + splitEffect);
		}
		if (relatedNsns.size() > 1) {
			addPairs(relatedNsn.getNsn(), relatedNsn.getNsiSid());
		}
	}


	/**
	 *  Adds a feature to the Pairs attribute of the NsiGroup object
	 *
	 *@param  nsn     The feature to be added to the Pairs attribute
	 *@param  nsiSid  The feature to be added to the Pairs attribute
	 */
	protected void addPairs(String nsn, String nsiSid) {
		if (logger.isDebugEnabled()) {
			logger.debug("adding pairs for nsn " + nsiSid + " with nsiSid=" + nsiSid);
			logger.debug("splitEffect=" + splitEffect);
			logger.debug("splitEffect.equals(SINGLE_EFFECTIVITY)=" + splitEffect.equals(SINGLE_EFFECTIVITY));
			logger.debug("(splitEffect.equals(SINGLE_EFFECTIVITY) ? Pair.TWO_WAY : Pair.NOT_INTERCHANGEABLE)=" + (splitEffect.equals(SINGLE_EFFECTIVITY) ? Pair.TWO_WAY : Pair.NOT_INTERCHANGEABLE));
		}
		Pair dummy;
		int cnt = 0;
		Set objKeys = relatedNsns.keySet();
		Object theKeys[] = objKeys.toArray();
		for (int i = 0; i < theKeys.length; i++) {
			cnt++;
			RelatedNsn relatedNsn = (RelatedNsn) relatedNsns.get(theKeys[i]);
			if (!nsn.equals(relatedNsn.getNsn())) {
				if (!pairs.containsKey(nsn + relatedNsn.getNsn())) {
					dummy = pairs.add(nsn, relatedNsn.getNsn(),
							(splitEffect.equals(SINGLE_EFFECTIVITY) ? Pair.TWO_WAY : Pair.NOT_INTERCHANGEABLE), false,
							nsiSid, relatedNsn.getNsiSid(),
							nsn + relatedNsn.getNsn());
					dummy.dump();
				} else {
					Pair pair = (Pair) pairs.get(nsn + relatedNsn.getNsn());
					pair.setInterChangeType((splitEffect.equals(SINGLE_EFFECTIVITY) ? Pair.TWO_WAY : Pair.NOT_INTERCHANGEABLE));
				}
				if (!pairs.containsKey(relatedNsn.getNsn() + nsn)) {
					dummy = pairs.add(relatedNsn.getNsn(), nsn,
							(splitEffect.equals(SINGLE_EFFECTIVITY) ? Pair.TWO_WAY : Pair.NOT_INTERCHANGEABLE), false,
							relatedNsn.getNsiSid(), nsiSid,
							relatedNsn.getNsn() + nsn);
					dummy.dump();
				} else {
					Pair pair = (Pair) pairs.get(relatedNsn.getNsn() + nsn);
					pair.setInterChangeType((splitEffect.equals(SINGLE_EFFECTIVITY) ? Pair.TWO_WAY : Pair.NOT_INTERCHANGEABLE));
				}
			}
		}
	}


	/**
	 *  Adds a feature to the Pairs attribute of the NsiGroup object
	 */
	protected void addPairs() {
		logger.debug("adding pairs.");
		Set keys = relatedNsns.keySet();
		Iterator iterator = keys.iterator();
		if (iterator.hasNext()) {
			RelatedNsn relatedNsn = (RelatedNsn) relatedNsns.get(iterator.next());
			this.addPairs(relatedNsn.getNsn(), relatedNsn.getNsiSid());
		}
	}


	/**
	 *  Description of the Method
	 *
	 *@param  userid                     Description of the Parameter
	 *@exception  java.sql.SQLException  This exception can occur, since the class
	 *      loads data from the Oracle data base via JDBC.
	 */
	protected void delete(String userid)
			 throws java.sql.SQLException {
		Statement s = AmdDB.instance().getConnection(userid).createStatement();
		if (logger.isDebugEnabled()) {
			logger.debug("deleting group " + nsiGroupSid);
		}
		String sqlStmt = "delete amd_nsi_groups  where nsi_group_sid = " + nsiGroupSid;
		if (logger.isDebugEnabled()) {
			logger.debug("relatedNsns.size()=" + relatedNsns.size());
		}
		logger.info(sqlStmt);
		s.executeUpdate(sqlStmt);
		s.close();
	}


	/**
	 *  Description of the Method
	 *
	 *@param  nsiGroupSid       Description of the Parameter
	 *@param  userid            Description of the Parameter
	 *@exception  SQLException  Description of the Exception
	 */
	public void load(String nsiGroupSid, String userid)
			 throws SQLException {
		logger.debug("loading");
		Statement s = AmdDB.instance().getConnection(userid).createStatement();
		String sqlStmt = "select nsi_group_sid, fleet_size_name, split_effect from amd_nsi_groups where nsi_group_sid  = " + nsiGroupSid;
		logger.info(sqlStmt);
		ResultSet group = s.executeQuery(sqlStmt);
		if (group.next()) {
			this.nsiGroupSid = group.getString("nsi_group_sid");
			this.splitEffect = group.getString("split_effect").toUpperCase();
			String fleetSizeName = group.getString("fleet_size_name");
			group.close();
			s.close();
			fleetSize.load(fleetSizeName, userid);
			this.relatedNsns.load(this, userid);
			this.pairs.load(nsiGroupSid, userid);
		}
		group.close();
		s.close();
	}


	/**
	 *  Description of the Method
	 *
	 *@param  srcNsiGroup  Description of the Parameter
	 */
	public void move(NsiGroup srcNsiGroup) {
		String latestConfig = "Y";
		RelatedNsns srcRelatedNsns = srcNsiGroup.getRelatedNsns();

		this.setUserDefined(this.CANNOT_FLY);
		additionsOccured = true;
		Set objKeys = srcRelatedNsns.keySet();
		Object theKeys[] = objKeys.toArray();
		for (int i = 0; i < theKeys.length; i++) {
			RelatedNsn newRelatedNsn = (RelatedNsn) srcRelatedNsns.get(theKeys[i]);
			if (srcRelatedNsns.size() == 1) {
				if (logger.isDebugEnabled()) {
					logger.debug("Setting latestConfig to Y for " + newRelatedNsn.getPartNo() + " with nsiSid " + newRelatedNsn.getNsiSid() + " for group " + newRelatedNsn.getNsiGroup().getNsiGroupSid());
				}
				logger.debug("latestConfig RETURN value set to N.");
				newRelatedNsn.setLatestConfig("Y");
			} else {
				if (logger.isDebugEnabled()) {
					logger.debug("Setting latestConfig to N for " + newRelatedNsn.getNsiSid() + " for group " + newRelatedNsn.getNsiGroup().getNsiGroupSid());
				}
				newRelatedNsn.setLatestConfig("N");
				if (logger.isDebugEnabled()) {
					newRelatedNsn.dump();
				}
			}
			this.add(newRelatedNsn);
		}
		return;
	}


	/**
	 *  Description of the Method
	 *
	 *@param  userid  Description of the Parameter
	 */
	protected void rebuildChildren(String userid) {
		logger.debug("rebuildChildren");

		Set keys = relatedNsns.keySet();
		Iterator iterator = keys.iterator();
		effectivity.DBQuery db = new effectivity.DBQuery();
		db.setConnection(AmdDB.instance().getConnection(userid));
		db.createStatement();
		while (iterator.hasNext()) {
			RelatedNsn relatedNsn = (RelatedNsn) relatedNsns.get(iterator.next());
			db.execQuery("declare begin amd_effectivity_pkg.rebuildChildren(" + relatedNsn.getNsiSid() + "); end;");
		}
		db.closeStatement();
	}


	/**
	 *  Description of the Method
	 *
	 *@param  userid                     Description of the Parameter
	 *@exception  java.sql.SQLException  Description of the Exception
	 */
	protected void refreshAssetMgmtStatus(String userid)
			 throws java.sql.SQLException {

		logger.debug("refreshAssetMgmtStatus");

		Statement s = AmdDB.instance().getConnection(userid).createStatement();
		Set keys = relatedNsns.keySet();
		Iterator iterator = keys.iterator();

		int complete = 0;

		while (iterator.hasNext()) {
			RelatedNsn relatedNsn = (RelatedNsn) relatedNsns.get(iterator.next());
			String sqlStmt = "select asset_mgmt_status from amd_national_stock_items where nsi_sid = " + relatedNsn.getNsiSid();
			logger.info(sqlStmt);
			ResultSet rs = s.executeQuery(sqlStmt);
			while (rs.next()) {
				String assetMgmtStatus = rs.getString("asset_mgmt_status");
				if (assetMgmtStatus == null) {
					relatedNsn.setAssetMgmtStatus(RelatedNsn.STATUS_NEW);
				} else {
					relatedNsn.setAssetMgmtStatus(assetMgmtStatus);
					complete++;
				}
				if (logger.isDebugEnabled()) {
					logger.debug("nsiSid=" + relatedNsn.getNsiSid() + " nsn=" + relatedNsn.getNsn() + " part_no=" + relatedNsn.getPartNo() + " asset_mgmt_status=" + relatedNsn.getAssetMgmtStatus());
				}
			}
			rs.close();
		}
		relatedNsns.setCompleteCount(complete);
		s.close();
	}


	/**
	 *  Description of the Method
	 *
	 *@param  nsiSid            Description of the Parameter
	 *@param  userid            Description of the Parameter
	 *@exception  Exception     Description of the Exception
	 *@exception  SQLException  Description of the Exception
	 */
	public void remove(String nsiSid, String userid) throws SQLException,
			Exception {
		logger.debug("remove");
		if (relatedNsns != null) {
			relatedNsns.remove(nsiSid, userid);
		}
		if (relatedNsns.size() == 1) {
			logger.debug("Only one nsn - resetting LatestConfig to Y");
			Set keys = relatedNsns.keySet();
			Iterator iterator = keys.iterator();
			while (iterator.hasNext()) {
				RelatedNsn relatedNsn = (RelatedNsn) relatedNsns.get(iterator.next());
				relatedNsn.setLatestConfig("Y");
			}
		}
		if (logger.isDebugEnabled()) {
			logger.debug("pairs != null: " + (pairs != null));
		}
		if (pairs != null) {
			logger.debug("removing pairs");
			pairs.remove(nsiSid, userid);
		}
		if (relatedNsns.size() <= 1) {
			this.setSplitEffect(NsiGroup.SINGLE_EFFECTIVITY);
		}
	}


	/**
	 *  Description of the Method
	 *
	 *@param  userid                     Description of the Parameter
	 *@exception  java.sql.SQLException  This exception can occur, since the class
	 *      loads data from the Oracle data base via JDBC.
	 */
	public void removeAllPairs(String userid)
			 throws java.sql.SQLException {
		logger.debug("removing all pairs");
		if (logger.isDebugEnabled()) {
			logger.debug("nsiGroupSid=" + nsiGroupSid);
		}

		if (pairs != null) {
			pairs.removeAll(userid);
		}
	}


	/**
	 *  Description of the Method
	 *
	 *@param  userid                     Description of the Parameter
	 *@return                            Description of the Return Value
	 *@exception  java.sql.SQLException  This exception can occur, since the class
	 *      loads data from the Oracle data base via JDBC.
	 *@exception  Exception              Description of the Exception
	 */
	public String save(String userid)
			 throws java.sql.SQLException, Exception {
		logger.debug("saving");
		if (!fleetSize.getPredefinedFleetSize()) {
			fleetSize.save(userid);
		}
		if (logger.isDebugEnabled()) {
			logger.debug("fleetSizeChanged=" + fleetSizeChanged);
		}
		Statement s = AmdDB.instance().getConnection(userid).createStatement();

		if (nsiGroupSid == null) {
			String sqlStmt = "Insert into amd_nsi_groups (fleet_size_name, split_effect) values('" + fleetSize.getFleetSizeName() + "', '" + splitEffect + "')";
			logger.info(sqlStmt);
			s.executeUpdate(sqlStmt);
			sqlStmt = "Select amd_owner.amd_nsi_group_sid_seq.currval nsi_group_sid from dual";
			logger.info(sqlStmt);
			ResultSet group = s.executeQuery(sqlStmt);
			if (group.next()) {
				nsiGroupSid = group.getString("nsi_group_sid");
			}
			group.close();
		} else {
			String sqlStmt = "update amd_nsi_groups set fleet_size_name = '" + fleetSize.getFleetSizeName() + "', split_effect = '" + splitEffect + "' where nsi_group_sid = " + nsiGroupSid;
			logger.info(sqlStmt);
			s.executeUpdate(sqlStmt);
		}
		s.close();
		relatedNsns.save(nsiGroupSid, userid);
		updateNsiEffects(userid);
		if (pairs.size() > 0) {
			pairs.save(userid);
		}

		effectivity.AmdUtils.setConnection(AmdDB.instance().getConnection(userid));
		if (logger.isDebugEnabled()) {
			logger.debug("effectivity.AmdUtils.pruneAsCapable(" + this.nsiGroupSid + ")");
		}
		effectivity.AmdUtils.pruneAsCapable(Integer.parseInt(this.nsiGroupSid));
		refreshAssetMgmtStatus(userid);

		if (fleetSizeChanged) {
			rebuildChildren(userid);
			fleetSizeChanged = false;
		}
		this.splitEffectChanged = false;
		return nsiGroupSid;
	}


	/**
	 *  Description of the Method
	 *
	 *@param  userid                     Description of the Parameter
	 *@exception  java.sql.SQLException  This exception can occur, since the class
	 *      loads data from the Oracle data base via JDBC.
	 *@exception  Exception              Description of the Exception
	 */
	protected void updateNsiEffects(String userid)
			 throws java.sql.SQLException,
			Exception {

		logger.debug("updating nsi effects.");
		String theSet = getSetOfNsiSids();
		if (this.additionsOccured) {
			this.additionsOccured = false;
			setAllSystemDefaultToCannotFly(userid, theSet);
			if (splitEffect.equals(NsiGroup.SINGLE_EFFECTIVITY)) {
				setLatestConfigToSystemDefaultForNsiEffects(userid);
			}
		}
		if (fleetSizeChanged) {
			if (removedAC != null && removedAC.length > 0) {
				updateNsiEffectsForRemovedAircraft(userid, theSet);
			}

			updateNsiEffectsForRemainingAircraft(userid, theSet);
			if (splitEffect.equals(NsiGroup.SINGLE_EFFECTIVITY)) {
				setLatestConfigToSystemDefaultForNsiEffects(userid);
			}
		}
	}


	/**
	 *  Description of the Method
	 *
	 *@param  userid                   Description of the Parameter
	 *@param  theSet                   Description of the Parameter
	 *@exception  java.lang.Exception  Description of the Exception
	 */
	protected void updateNsiEffectsForRemainingAircraft(String userid, String theSet)
			 throws java.lang.Exception {
		if (splitEffect.equals(NsiGroup.SINGLE_EFFECTIVITY)) {

			String sqlStmt = "update amd_nsi_effects set user_defined = '" + NsiGroup.SYSTEM_DEFAULT + "' where nsi_sid in " + theSet;
			sqlStmt += " and user_defined = '" + CANNOT_FLY + "'";

			String tailNo[] = fleetSize.getTailNumbers();
			if (tailNo != null && tailNo.length > 0) {
				sqlStmt += " and tail_no in (";
				for (int i = 0; i < tailNo.length; i++) {
					sqlStmt += "'" + tailNo[i] + "',";
				}
				sqlStmt = sqlStmt.substring(0, sqlStmt.length() - 1) + ")";
				logger.info(sqlStmt);
				Statement s = AmdDB.instance().getConnection(userid).createStatement();
				s.executeUpdate(sqlStmt);
				s.close();
			}
		}
	}


	/**
	 *  Description of the Method
	 *
	 *@param  userid                     Description of the Parameter
	 *@param  theSet                     Description of the Parameter
	 *@exception  java.sql.SQLException  Description of the Exception
	 */
	protected void updateNsiEffectsForRemovedAircraft(String userid, String theSet)
			 throws java.sql.SQLException {

		if (removedAC != null && removedAC.length > 0) {
			Statement s = AmdDB.instance().getConnection(userid).createStatement();
			String sqlStmt = "update amd_nsi_effects set user_defined = '" + this.CANNOT_FLY + "' where nsi_sid in " + theSet;
			sqlStmt += " and tail_no in (";
			for (int i = 0; i < removedAC.length; i++) {
				sqlStmt += "'" + removedAC[i] + "',";
			}
			sqlStmt = sqlStmt.substring(0, sqlStmt.length() - 1) + ")";
			logger.info(sqlStmt);
			s.executeUpdate(sqlStmt);
			s.close();
		}
	}


	/**
	 *  Description of the Method
	 *
	 *@param  args  Description of the Parameter
	 */
	public static void main(String args[]) {

		if (args.length > 0 && args[0].equals("-version")) {
			System.out.println(revision + "\n" +
					author + "\n" +
					workfile);
			System.exit(0);
		}

		NsiGroup nsiGroup = new NsiGroup();
		FleetSize fleetSize = nsiGroup.getFleetSize();
		fleetSize.setFleetSizeName("All Aircraft");
		fleetSize.setFleetSizeDesc("All Aircraft");
		fleetSize.setPredefinedFleetSize(true);
		try {
			nsiGroup.save("amd_owner");
		} catch (Exception e) {
			System.out.println("Save error: " + e.getMessage());
		}

	}
}

