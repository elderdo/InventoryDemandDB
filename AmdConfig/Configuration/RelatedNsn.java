package Configuration;
/*
 *  $Revision:   1.4  $
 *  $Author:   c970183  $
 *  $Workfile:   RelatedNsn.java  $
 *  $Log:   \\www-amssc-01\pds\archives\SDS-AMD\Components-ClientServer\AmdConfig\Configuration\RelatedNsn.java-arc  $
/*
/*   Rev 1.4   20 Aug 2002 08:44:32   c970183
/*Reformatted using JEdit's JavaStyle plugin.  Added the effect_last_update_dt and effect_last_update_id to the dump method.
 *  *
 *  *   Rev 1.3   19 Aug 2002 14:55:20   c970183
 *  *Added effect_last_update_dt and effect_last_update_id attributes
 *  *
 *  *   Rev 1.1   23 May 2002 06:57:54   c970183
 *  *Test Release
 */
import java.sql.*;
import java.util.*;
import org.apache.log4j.Logger;

/**
 *  This class represents an nsn that belongs to a group - an instance of the
 *  NsiGroup class.
 *
 *@author     Douglas S. Elder
 *@created    August 20, 2002
 *@since      06/20/02
 */
public class RelatedNsn {
	private String assetMgmtStatus;
	private String depleteBy;
	private String effectLastUpdateDt;
	private String effectLastUpdateId;
	private String error;
	private String latestConfig;
	private String nomenclature;
	private NsiGroup nsiGroup;
	private String nsiSid;

	private String nsn;

	private String partNo;
	private String startDate;
	private static String author = "$Author:   c970183  $";
	private static Logger logger = Logger.getLogger(RelatedNsn.class.getName());

	private static String revision = "$Revision:   1.4  $";
	private static String workfile = "$Workfile:   RelatedNsn.java  $";
	/**
	 *  Value assigned to amd_national_stock_items.asset_mgmt_status after the NSN has been
	 *  procesed by an asset manager
	 */
	public final static String STATUS_COMPLETE = "COMPLETE";
	/**
	 *  When a row from the amd_national_stock_items is retrieved and the value is null, then
	 *  an empty string is assigned to the assetMgmtStatus attribute
	 */
	public final static String STATUS_NEW = "";


	/**
	 *  Construct a RelatedNsn with the following defaults: depleteBy = ""
	 *  startDate = "" latestConfig = "N" assetMgmtStatus = STATUS_NEW
	 */
	public RelatedNsn() {
		depleteBy = "";
		startDate = "";
		latestConfig = "N";
		assetMgmtStatus = STATUS_NEW;
	}


	/**
	 *  Sets the assetMgmtStatus attribute of the RelatedNsn object
	 *
	 *@param  assetMgmtStatus  The new assetMgmtStatus value
	 */
	public void setAssetMgmtStatus(String assetMgmtStatus) {
		this.assetMgmtStatus = assetMgmtStatus;
	}


	/**
	 *  Sets the depleteBy attribute of the RelatedNsn object
	 *
	 *@param  depleteBy  The new depleteBy value
	 */
	public void setDepleteBy(String depleteBy) {
		this.depleteBy = depleteBy;
	}


	/**
	 *  Sets the effectLastUpdateDt attribute of the RelatedNsn object
	 *
	 *@param  effectLastUpdateDt  The new effectLastUpdateDt value
	 */
	public void setEffectLastUpdateDt(String effectLastUpdateDt) {
		this.effectLastUpdateDt = effectLastUpdateDt;
	}


	/**
	 *  Sets the effectLastUpdateId attribute of the RelatedNsn object
	 *
	 *@param  effectLastUpdateId  The new effectLastUpdateId value
	 */
	public void setEffectLastUpdateId(String effectLastUpdateId) {
		this.effectLastUpdateId = effectLastUpdateId;
	}


	/**
	 *@param  latestConfig  Either an "N" or a "Y"
	 */
	public void setLatestConfig(String latestConfig) {
		this.latestConfig = latestConfig;
	}


	/**
	 *  Sets the nomenclature attribute of the RelatedNsn object
	 *
	 *@param  nomenclature  The new nomenclature value
	 */
	public void setNomenclature(String nomenclature) {
		this.nomenclature = nomenclature;
	}


	/**
	 *@param  nsiGroup  The parent NsiGroup that this relatedNsn belongs to.
	 */
	public void setNsiGroup(NsiGroup nsiGroup) {
		this.nsiGroup = nsiGroup;
	}


	/**
	 *  Sets the nsiSid attribute of the RelatedNsn object
	 *
	 *@param  nsiSid  The new nsiSid value
	 */
	public void setNsiSid(String nsiSid) {
		this.nsiSid = nsiSid;
	}


	/**
	 *  Sets the nsn attribute of the RelatedNsn object
	 *
	 *@param  nsn  The new nsn value
	 */
	public void setNsn(String nsn) {
		this.nsn = nsn;
	}


	/**
	 *@param  partNo  The primary_part_no associated with this nsn.
	 */
	public void setPartNo(String partNo) {
		this.partNo = partNo;
	}


	/**
	 *  Sets the splitEffect attribute of the RelatedNsn object
	 *
	 *@param  splitEffect                The new splitEffect value
	 *@exception  java.sql.SQLException  This exception can occur, since the class
	 *      saves data to the Oracle data base via JDBC.
	 */
	public void setSplitEffect(String splitEffect)
			 throws java.sql.SQLException {
		nsiGroup.setSplitEffect(splitEffect);
	}


	/**
	 *  Sets the startDate attribute of the RelatedNsn object
	 *
	 *@param  startDate  The new startDate value
	 */
	public void setStartDate(String startDate) {
		this.startDate = startDate;
	}


	/**
	 *  Gets the assetMgmtStatus attribute of the RelatedNsn object
	 *
	 *@return    The assetMgmtStatus value
	 */
	public String getAssetMgmtStatus() {
		return assetMgmtStatus;
	}


	/**
	 *  Gets the author attribute of the RelatedNsn object
	 *
	 *@return    The author value
	 */
	public String getAuthor() {
		return author;
	}


	/**
	 *  Gets the depleteBy attribute of the RelatedNsn object
	 *
	 *@return    The depleteBy value
	 */
	public String getDepleteBy() {
		return depleteBy;
	}


	/**
	 *  Gets the effectLastUpdateDt attribute of the RelatedNsn object
	 *
	 *@return    The effectLastUpdateDt value
	 */
	public String getEffectLastUpdateDt() {
		return this.effectLastUpdateDt;
	}


	/**
	 *  Gets the effectLastUpdateId attribute of the RelatedNsn object
	 *
	 *@return    The effectLastUpdateId value
	 */
	public String getEffectLastUpdateId() {
		return this.effectLastUpdateId;
	}


	/**
	 *  A group can have only one RelatedNsn that has its latestConfig set to a
	 *  "Y".
	 *
	 *@return    Either a "N" or a "Y".
	 */
	public String getLatestConfig() {
		return this.latestConfig;
	}


	/**
	 *@return    The nomenclature value
	 */
	public String getNomenclature() {
		return nomenclature;
	}


	/**
	 *@return    The parent NsiGroup that this relatedNsn belongs to.
	 */
	public NsiGroup getNsiGroup() {
		return nsiGroup;
	}


	/**
	 *  Gets the nsiSid attribute of the RelatedNsn object
	 *
	 *@return    The nsiSid value
	 */
	public String getNsiSid() {
		return nsiSid;
	}


	/**
	 *@return    The nsn
	 */
	public String getNsn() {
		return nsn;
	}


	/**
	 *@return    The primary_part_no associated with this nsn.
	 */
	public String getPartNo() {
		return partNo;
	}


	/**
	 *  Gets the revision attribute of the RelatedNsn object
	 *
	 *@return    The revision value
	 */
	public String getRevision() {
		return revision;
	}


	/**
	 *  Gets the splitEffect attribute of the RelatedNsn object
	 *
	 *@return    The splitEffect value
	 */
	public String getSplitEffect() {
		if (nsiGroup != null) {
			if (nsiGroup.getSplitEffect().equals("Y")) {
				return "Split";
			} else {
				return "Single";
			}
		} else {
			return null;
		}

	}


	/**
	 *  Gets the startDate attribute of the RelatedNsn object
	 *
	 *@return    The startDate value
	 */
	public String getStartDate() {
		return this.startDate;
	}


	/**
	 *  Gets the workfile attribute of the RelatedNsn object
	 *
	 *@return    The workfile value
	 */
	public String getWorkfile() {
		return workfile;
	}


	/**
	 *  This is for debugging only. It dumps all the properties to a log.
	 */
	public void dump() {
		if (logger.isDebugEnabled()) {
			logger.debug("nsn=" + nsn
					 + " partNo=" + partNo
					 + " nsiSid=" + nsiSid
					 + " startDate=" + startDate
					 + " depleteBy=" + depleteBy
					 + " latestConfig=" + latestConfig
					 + " nsiGroupSid=" + nsiGroup.getNsiGroupSid()
					 + " assetMgmtStatus=" + assetMgmtStatus
					 + " effectLastUpdateDt=" + effectLastUpdateDt
					 + " effectLastUpdateId=" + effectLastUpdateId) ;
		}
	}


	/**
	 *  This method checks to see the group has a RelatedNsn that has the
	 *  latestConfig property set to "Y". If it does not, then there is a system
	 *  error.
	 *
	 *@return    Description of the Return Value
	 */
	public boolean hasLatestConfig() {
		return nsiGroup.getRelatedNsns().hasLatestConfig();
	}


	/**
	 *  Persist an instance of this class to the data base.
	 *
	 *@param  userid                     The current Oracle userid for the session.
	 *      This is required in order to retrieve the correct connection object
	 *      from the AmdDB connection pool.
	 *@exception  Exception              Description of the Exception
	 *@exception  SQLException           Description of the Exception
	 */
	public void save(String userid) throws
			SQLException, Exception {
		if (!nsiGroup.getRelatedNsns().containsKey(nsiSid)) {
			nsiGroup.getRelatedNsns().add(nsiSid, this);
		}
		if (nsiGroup != null) {
			nsiGroup.save(userid);
		}
	}


	/**
	 *  Retrieve the RelatedNsn from the database.  Since all related NSN's belong to
	 *  a group the job of collecting all the NSN's for that group is delated to an 
	 *  NsiGroup object.
	 *
	 *@param  nsiSid                     The data base key for the RelatedNsn
	 *@param  userid                     The current Oracle userid for the session.
	 *      This is required in order to retrieve the correct connection object
	 *      from the AmdDB connection pool.
	 *@return                            Description of the Return Value
	 *@exception  SQLException           Description of the Exception
	 */
	public static RelatedNsn load(String nsiSid, String userid)
			 throws SQLException {
		logger.debug("loading related nsn");
		if (logger.isDebugEnabled()) {
			logger.debug("nsiSid=" + nsiSid);
		}
		Statement s = AmdDB.instance().getConnection(userid).createStatement();
		ResultSet nsnInfo;
		String sqlStmt = "Select nsn, nsi_sid, nsi_group_sid from  amd_national_stock_items items where nsi_sid = " + nsiSid;
		logger.info(sqlStmt);
		nsnInfo = s.executeQuery(sqlStmt);
		if (nsnInfo.next()) {
			if (logger.isDebugEnabled()) {
				logger.debug("nsnInfo.getString('nsn')=" + nsnInfo.getString("nsn"));
			}
			if (logger.isDebugEnabled()) {
				logger.debug("nsnInfo.getString('nsi_sid')=" + nsnInfo.getString("nsi_sid"));
			}
			if (logger.isDebugEnabled()) {
				logger.debug("nsnInfo.getString('nsi_group_sid')=" + nsnInfo.getString("nsi_group_sid"));
			}
			String nsiGroupSid = nsnInfo.getString("nsi_group_sid");
			if (logger.isDebugEnabled()) {
				logger.debug("nsiGroupSid=" + nsiGroupSid);
			}
			nsnInfo.close();
			s.close();
			NsiGroup nsiGroup = new NsiGroup();
			if (logger.isDebugEnabled()) {
				logger.debug("RelatedNsn.load: nsiGroupSid=" + nsiGroupSid);
			}
			nsiGroup.load(nsiGroupSid, userid);
			return (RelatedNsn) nsiGroup.getRelatedNsns().get(nsiSid);
		}
		logger.error("Unable to retrieve nsi_group_sid for nsi_sid=" + nsiSid);
		nsnInfo.close();
		s.close();
		return null;
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

		RelatedNsn relatedNsn = new RelatedNsn();
		try {
			relatedNsn.load("808933", "amd_owner");
		} catch (java.sql.SQLException e) {
			System.out.println(e.getMessage());
			e.printStackTrace();
		} catch (java.lang.Exception e) {
			System.out.println(e.getMessage());
			e.printStackTrace();
		}

		NsiGroup nsiGroup = relatedNsn.getNsiGroup();
		System.out.println("Effectivity=" + relatedNsn.getSplitEffect());
		System.out.println("DelpleteBy=" + relatedNsn.getDepleteBy());
		FleetSize fleetSize = nsiGroup.getFleetSize();
		System.out.println("FleetSizeName=" + fleetSize.getFleetSizeName());
		//System.out.println("FleetSizeDesc=" + fleetSize.getFleetSizeDesc() ) ;
		System.out.println("PredefinedFleetSize=" + fleetSize.getPredefinedFleetSize());

		RelatedNsn relatedNsn2 = new RelatedNsn();
		relatedNsn2.setNsn("1560013703136");
		relatedNsn2.setNsiSid("807387");
		relatedNsn2.setPartNo("17P2A6004-126");
		relatedNsn2.setNomenclature("PANEL,STRUCTURAL,AIRCRAFT");
		nsiGroup.add(relatedNsn2);

		try {
			relatedNsn.save("amd_owner");
		} catch (Exception e) {
			System.out.println("Save error: " + e.getMessage());
			e.printStackTrace();
		}
		RelatedNsn dbPrimary = new RelatedNsn();
		try {
			dbPrimary.load("770226", "amd_owner");
		} catch (SQLException e) {
			System.out.println(e.getMessage());
			e.printStackTrace();
		} catch (java.lang.Exception e) {
			System.out.println(e.getMessage());
			e.printStackTrace();
		}

	}

}

