package Configuration;
import java.sql.*;
/*
 *  $Revision:   1.5  $
 *  $Author:   c970183  $
 *  $Workfile:   RelatedNsns.java  $
 *  $Log:   \\www-amssc-01\pds\archives\SDS-AMD\Components-ClientServer\AmdConfig\Configuration\RelatedNsns.java-arc  $
/*
/*   Rev 1.5   20 Aug 2002 08:52:36   c970183
/*Reformated using JEdit's JavaStyle plugin.  Added some descrition for the effect_last_update_dt param and the effect_last_update_id parm for the load method
 *  *
 *  *   Rev 1.4   19 Aug 2002 15:57:44   c970183
 *  *Added formating of the effect_last_update_dt (mm/dd/yy hh:mm am/pm.  Set the effect_last_update_id to the userid, so this value gets displayed by the Controller class.
 *  *
 *  *   Rev 1.3   19 Aug 2002 14:55:22   c970183
 *  *Added effect_last_update_dt and effect_last_update_id attributes
 *  *
 *  *   Rev 1.1   23 May 2002 06:57:56   c970183
 *  *Test Release
 */
import java.util.*;
import javax.servlet.jsp.*;
import org.apache.log4j.Logger;

/**
 *  Description of the Class
 *
 *@author     Douglas S. Elder
 *@created    August 20, 2002
 *@since      06/20/02
 */
public class RelatedNsns extends java.util.HashMap {
	private int completeCount = 0;
	private String lastSqlStmt;
	private static String author = "$Author:   c970183  $";
	private static Logger logger = Logger.getLogger(RelatedNsns.class.getName());

	private static String revision = "$Revision:   1.5  $";
	private static String workfile = "$Workfile:   RelatedNsns.java  $";


	/**
	 *  Sets the completeCount attribute of the RelatedNsns object
	 *
	 *@param  completeCount  The new completeCount value
	 */
	public void setCompleteCount(int completeCount) {
		this.completeCount = completeCount;
	}


	/**
	 *  Sets the latestConfig attribute of the RelatedNsns object
	 *
	 *@param  latestConfig  The new latestConfig value
	 */
	public void setLatestConfig(String latestConfig) {
		Set keys = this.keySet();
		Iterator iterator = keys.iterator();
		while (iterator.hasNext()) {
			RelatedNsn relatedNsn = (RelatedNsn) this.get(iterator.next());
			if (logger.isDebugEnabled()) {
				logger.debug("setting latest config to " + latestConfig + " for part " + relatedNsn.getPartNo() + " nsi_sid=" + relatedNsn.getNsiSid() + " in group " + relatedNsn.getNsiGroup().getNsiGroupSid());
			}
			relatedNsn.setLatestConfig(latestConfig);
		}
	}


	/**
	 *  Gets the author attribute of the RelatedNsns object
	 *
	 *@return    The author value
	 */
	public String getAuthor() {
		return author;
	}


	/**
	 *  Gets the completeCount attribute of the RelatedNsns object
	 *
	 *@return    The completeCount value
	 */
	public int getCompleteCount() {
		return completeCount;
	}


	/**
	 *  Gets the count attribute of the RelatedNsns object
	 *
	 *@return    The count value
	 */
	public int getCount() {
		return this.size();
	}


	/**
	 *  Gets the item attribute of the RelatedNsns object
	 *
	 *@param  key  Description of the Parameter
	 *@return      The item value
	 */
	public RelatedNsn getItem(String key) {
		if (this.containsKey(key)) {
			return (RelatedNsn) this.get(key);
		} else {
			return null;
		}
	}


	/**
	 *  Gets the lastSqlStmt attribute of the RelatedNsns object
	 *
	 *@return    The lastSqlStmt value
	 */
	public String getLastSqlStmt() {
		return lastSqlStmt;
	}


	/**
	 *  Gets the revision attribute of the RelatedNsns object
	 *
	 *@return    The revision value
	 */
	public String getRevision() {
		return revision;
	}


	/**
	 *  Gets the workfile attribute of the RelatedNsns object
	 *
	 *@return    The workfile value
	 */
	public String getWorkfile() {
		return workfile;
	}


	/**
	 *  Description of the Method
	 *
	 *@param  nsiSid              Description of the Parameter
	 *@param  nsn                 Description of the Parameter
	 *@param  depleteBy           Description of the Parameter
	 *@param  startDate           Description of the Parameter
	 *@param  latestConfig        Description of the Parameter
	 *@param  partNo              Description of the Parameter
	 *@param  nomenclature        Description of the Parameter
	 *@param  nsiGroup            Description of the Parameter
	 *@param  key                 Description of the Parameter
	 *@param  assetMgmtStatus     Description of the Parameter
	 *@param  effectLastUpdateDt  the date and time the row nsn was last updated
	 *@param  effectLastUpdateId  the userid of the person that perform an update
	 *@return                     Description of the Return Value
	 */
	public RelatedNsn add(String nsiSid, String nsn,
			String depleteBy, String startDate, String latestConfig, String partNo, String nomenclature,
			NsiGroup nsiGroup,
			String assetMgmtStatus,
			String effectLastUpdateDt,
			String effectLastUpdateId,
			String key) {
		logger.debug("adding related nsn.");
		if (logger.isDebugEnabled()) {
			logger.debug("nsiSid=" + nsiSid);
		}
		RelatedNsn objNewMember = new RelatedNsn();
		objNewMember.setNsiGroup(nsiGroup);
		objNewMember.setNsiSid(nsiSid);
		objNewMember.setNsn(nsn);
		objNewMember.setDepleteBy(depleteBy);
		objNewMember.setNomenclature(nomenclature);
		objNewMember.setPartNo(partNo);
		objNewMember.setStartDate(startDate);
		objNewMember.setLatestConfig(latestConfig);
		objNewMember.setAssetMgmtStatus(assetMgmtStatus);
		objNewMember.setEffectLastUpdateDt(effectLastUpdateDt);
		objNewMember.setEffectLastUpdateId(effectLastUpdateId.toUpperCase());
		if (!key.equals(nsiSid)) {
			logger.error("key!=nsiSid: " + key);
		}
		this.put(key, objNewMember);
		return objNewMember;
	}


	/**
	 *  Description of the Method
	 *
	 *@param  nsiSid      Description of the Parameter
	 *@param  relatedNsn  Description of the Parameter
	 */
	protected void add(String nsiSid, RelatedNsn relatedNsn) {
		logger.debug("adding related nsn.");
		if (logger.isDebugEnabled()) {
			logger.debug("nsiSid=" + nsiSid);
		}
		this.put(nsiSid, relatedNsn);
		if (logger.isDebugEnabled()) {
			dump();
		}
	}


	/**
	 *  Description of the Method
	 */
	public void dump() {

		Set keys = this.keySet();
		Iterator it = keys.iterator();
		while (it.hasNext()) {
			String theKey = (String) it.next();
			if (logger.isDebugEnabled()) {
				logger.debug("theKey=" + theKey);
			}
			RelatedNsn relatedNsn = (RelatedNsn) this.get(theKey);
			relatedNsn.dump();
		}
	}


	/**
	 *  Description of the Method
	 *
	 *@return    Description of the Return Value
	 */
	public boolean hasLatestConfig() {
		Set keys = this.keySet();
		Iterator it = keys.iterator();
		while (it.hasNext()) {
			RelatedNsn relatedNsn = (RelatedNsn) this.get(it.next());
			String latestConfig = relatedNsn.getLatestConfig();
			if (latestConfig == null) {
				latestConfig = "N";
			}
			if (latestConfig.equals("Y")) {
				return true;
			}
		}
		return false;
	}


	/**
	 *  Description of the Method
	 *
	 *@param  nsiGroup                   Description of the Parameter
	 *@param  userid                     Description of the Parameter
	 *@exception  java.sql.SQLException  This exception can occur, since the class
	 *      loads data from the Oracle data base via JDBC.
	 */
	public void load(NsiGroup nsiGroup, String userid) throws java.sql.SQLException {
		Statement s = AmdDB.instance().getConnection(userid).createStatement();
		String sqlStmt = "select items.nsn, items.nsi_sid, to_char(items.depletion_start_date,'MM/DD/YY') depletion_start_date, to_char(items.spare_start_date,'MM/DD/YY') spare_start_date, items.latest_config, parts.part_no, parts.nomenclature, items.asset_mgmt_status, to_char(items.effect_last_update_dt,'MM/DD/YY HH:MM AM') effect_last_update_dt, effect_last_update_id from amd_national_stock_items items, amd_spare_parts parts where items.nsi_group_sid = " + nsiGroup.getNsiGroupSid() + " and items.prime_part_no = part_no";
		logger.info(sqlStmt);
		ResultSet relatedNsns = s.executeQuery(sqlStmt);
		String nsi_sid = "";
		completeCount = 0;
		while (relatedNsns.next()) {
			String depleteBy = relatedNsns.getString("depletion_start_date");
			if (depleteBy == null) {

				depleteBy = "";
			}
			String startDate = relatedNsns.getString("spare_start_date");
			if (startDate == null) {
				startDate = "";
			}
			String latestConfig = relatedNsns.getString("latest_config");
			if (latestConfig == null) {
				latestConfig = "N";
			} else {
				latestConfig = latestConfig.toUpperCase();
			}

			String assetMgmtStatus = relatedNsns.getString("asset_mgmt_status");
			if (assetMgmtStatus == null) {
				assetMgmtStatus = RelatedNsn.STATUS_NEW;
			} else if (assetMgmtStatus.equals(RelatedNsn.STATUS_COMPLETE)) {
				completeCount++;
			}

			String effect_last_update_dt = relatedNsns.getString("effect_last_update_dt");
			if (effect_last_update_dt == null) {
				effect_last_update_dt = "";
			}
			String effect_last_update_id = relatedNsns.getString("effect_last_update_id");
			if (effect_last_update_id == null) {
				effect_last_update_id = "";
			}

			if (logger.isDebugEnabled()) {
				logger.debug("loading nsiSid=" + relatedNsns.getString("nsi_sid") + " assetMgmtStatus=" + assetMgmtStatus);
			}
			nsi_sid = relatedNsns.getString("nsi_sid");
			RelatedNsn relatedNsn = this.add(nsi_sid,
					relatedNsns.getString("nsn"),
					depleteBy,
					startDate,
					latestConfig,
					relatedNsns.getString("part_no"),
					relatedNsns.getString("nomenclature"),
					nsiGroup,
					assetMgmtStatus,
					effect_last_update_dt,
					effect_last_update_id,
					nsi_sid);
		}
		relatedNsns.close();
		sqlStmt = "select user_defined from amd_nsi_effects where nsi_sid = " + nsi_sid;
		logger.info(sqlStmt);
		ResultSet nsiEffects = s.executeQuery(sqlStmt);
		if (nsiEffects.next()) {
			nsiGroup.setUserDefined(nsiEffects.getString("user_defined").toUpperCase());
		}
		nsiEffects.close();
		s.close();
	}


	/**
	 *  Description of the Method
	 *
	 *@return    Description of the Return Value
	 */
	public int numberOfBlankDepleteBy() {
		logger.debug("counting depleteBy's");

		Set keys = this.keySet();
		Iterator it = keys.iterator();
		int cnt = 0;
		if (logger.isDebugEnabled()) {
			logger.debug("keys.size()=" + keys.size());
		}
		if (logger.isDebugEnabled()) {
			logger.debug("this.size()=" + this.size());
		}
		while (it.hasNext()) {
			RelatedNsn relatedNsn = (RelatedNsn) this.get(it.next());
			String depleteBy = relatedNsn.getDepleteBy();
			if (logger.isDebugEnabled()) {
				logger.debug("relatedNsn.getNsiSid()=" + relatedNsn.getNsiSid() + " depleteBy=" + depleteBy);
			}
			if (depleteBy == null || depleteBy.equals("")) {
				cnt++;
			}
		}
		return cnt;
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
		if (logger.isDebugEnabled()) {
			logger.debug(userid + " is removing " + nsiSid);
		}
		RelatedNsn relatedNsn;
		if (this.containsKey(nsiSid)) {
			relatedNsn = (RelatedNsn) this.get(nsiSid);
			if (logger.isDebugEnabled()) {
				logger.debug("partNo = " + relatedNsn.getPartNo() + "[" + relatedNsn.getNomenclature() + "] from group " + relatedNsn.getNsiGroup().getNsiGroupSid());
			}
			super.remove(nsiSid);
			// Assign the Nsn to a new group with a default of ALL_AIRCRAFT
			NsiGroup nsiGroup = new NsiGroup();
			logger.debug("Assigning to a new group.");
			if (logger.isDebugEnabled()) {
				logger.debug("nsiGroupSid=" + nsiGroup.getNsiGroupSid());
			}
			// ???????????
			FleetSize fleetSize = nsiGroup.getFleetSize();

			fleetSize.load(FleetSize.ALL_AIRCRAFT, userid);
			relatedNsn.setNsiGroup(nsiGroup);
			relatedNsn.setLatestConfig("Y");
			relatedNsn.setAssetMgmtStatus(RelatedNsn.STATUS_NEW);
			nsiGroup.getRelatedNsns().add(nsiSid, relatedNsn);
			nsiGroup.save(userid);

			if (logger.isDebugEnabled()) {
				logger.debug("nsiSid " + nsiSid + " saved to db with new group " + nsiGroup.getNsiGroupSid());
			}
		} else {
			logger.error("Execpted to find " + nsiSid + " in the related Nsns collection.");
			dump();
		}
	}


	/**
	 *  Description of the Method
	 *
	 *@param  nsiGroupSid                Description of the Parameter
	 *@param  userid                     Description of the Parameter
	 *@exception  java.sql.SQLException  This exception can occur, since the class
	 *      saves data to the Oracle data base via JDBC.
	 */
	public void save(String nsiGroupSid, String userid)
			 throws java.sql.SQLException {
		Statement s = AmdDB.instance().getConnection(userid).createStatement();
		Set keys = this.keySet();
		Iterator it = keys.iterator();
		while (it.hasNext()) {
			RelatedNsn relatedNsn = (RelatedNsn) this.get(it.next());
			String depleteBy = relatedNsn.getDepleteBy();
			String latestConfig = relatedNsn.getLatestConfig();
			int LengthOflatestConfig = latestConfig.length();

			String startDate = relatedNsn.getStartDate();
			String depleteBySQL = "";
			if (depleteBy == null) {
				depleteBySQL = "depletion_start_date = null, ";
			} else if (depleteBy.equals("")) {
				depleteBySQL = "depletion_start_date = null, ";
			} else {
				depleteBySQL = "depletion_start_date = to_date('" + depleteBy + "','MM/DD/YY'), ";
			}
			String startDateSQL = "";
			if (startDate == null) {
				startDateSQL = "spare_start_date = null, ";
			} else if (startDate.equals("")) {
				startDateSQL = "spare_start_date = null, ";
			} else {
				startDateSQL = "spare_start_date = to_date('" + startDate + "','MM/DD/YY'), ";
			}
			String assetMgmtStatusSQL = "";
			String assetMgmtStatus = relatedNsn.getAssetMgmtStatus();
			if (assetMgmtStatus != null) {
				if (assetMgmtStatus.equals(RelatedNsn.STATUS_NEW)) {
					assetMgmtStatusSQL = "asset_mgmt_status = null, ";
				} else {
					assetMgmtStatusSQL = "asset_mgmt_status = '" + assetMgmtStatus + "', ";
				}
			}

			int LengthOfnsiGroupSid = nsiGroupSid.length();
			// will throw an exception if null

			lastSqlStmt = "Update amd_national_stock_items set "
					 + "effect_last_update_id = substr(user,1,8), "
					 + "effect_last_update_dt = sysdate, "
					 + startDateSQL
					 + depleteBySQL
					 + assetMgmtStatusSQL
					 + "nsi_group_sid = "
					 + nsiGroupSid
					 + ", latest_config = '"
					 + latestConfig
					 + "', last_update_dt = sysdate where nsi_sid = "
					 + relatedNsn.getNsiSid();
			if (userid.length() > 8) {
				relatedNsn.setEffectLastUpdateId(userid.substring(0, 8).toUpperCase());
			} else {
				relatedNsn.setEffectLastUpdateId(userid.toUpperCase());
			}
			relatedNsn.setEffectLastUpdateDt(Utils.now());
			if (logger.isDebugEnabled()) {
				logger.debug("RelatedNsns.save: " + lastSqlStmt);
				logger.debug("effectLastUpdateDt=" + relatedNsn.getEffectLastUpdateDt());
			}
			logger.info(lastSqlStmt);
			s.executeUpdate(lastSqlStmt);
			if (relatedNsn.getNsiGroup().getSplitEffect().equals(NsiGroup.SINGLE_EFFECTIVITY)) {
				String tailNo[] = relatedNsn.getNsiGroup().getFleetSize().getTailNumbers();
				String tailNoQualifier = "";
				if (tailNo.length > 0) {
					tailNoQualifier = " and tail_no in (";
					for (int i = 0; i < tailNo.length; i++) {
						tailNoQualifier += "'" + tailNo[i] + "',";
					}
					tailNoQualifier = tailNoQualifier.substring(0, tailNoQualifier.length() - 1) + ")";
				}

				if (relatedNsn.getLatestConfig().equals("Y")) {
					lastSqlStmt = "update amd_nsi_effects set effect_type = 'B', user_defined = '" + NsiGroup.SYSTEM_DEFAULT + "' where nsi_sid = " + relatedNsn.getNsiSid() + " and user_defined in ('" + NsiGroup.CANNOT_FLY + "','" + NsiGroup.SYSTEM_DEFAULT + "','" + NsiGroup.USER_DEFINED + "')" + tailNoQualifier;
					logger.info(lastSqlStmt);
					s.executeUpdate(lastSqlStmt);
				} else {
					lastSqlStmt = "update amd_nsi_effects set effect_type = 'C', user_defined = '" + NsiGroup.USER_DEFINED + "' where nsi_sid = " + relatedNsn.getNsiSid() + " and user_defined in ('" + NsiGroup.CANNOT_FLY + "','" + NsiGroup.SYSTEM_DEFAULT + "','" + NsiGroup.USER_DEFINED + "')" + tailNoQualifier;
					logger.info(lastSqlStmt);
					s.executeUpdate(lastSqlStmt);
				}
			}
		}
		s.close();
	}


	/**
	 *  The main program for the RelatedNsns class
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

