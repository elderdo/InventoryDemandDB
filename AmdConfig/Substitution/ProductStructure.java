package Substitution;
/*
 *  $Revision:   1.4  $
 *  $Author:   c402417  $
 *  $Workfile:   ProductStructure.java  $
 *  $Log:   \\www-amssc-01\pds\archives\SDS-AMD\Components-ClientServer\AmdConfig\Substitution\ProductStructure.java-arc  $
/*
/*   Rev 1.4   24 Sep 2002 16:26:56   c402417
/*check the file back in , no change
/*
/*   Rev 1.3   04 Sep 2002 13:30:50   c970183
/*Added get methods for PVCS revision variables.
 *  *
 *  *   Rev 1.2   04 Sep 2002 12:17:18   c970183
 *  *Fixed Keywords at top of class
 *
 *  Rev 1.1   04 Sep 2002 12:04:26   c970183
 *  Fixed remove method.  Eliminated extraneous update's since the rebuildchild stored procedure takes care of amd_nsi_effects and amd_national_stock_items.
 *  *
 *  *   Rev 1.0   04 Sep 2002 10:49:20   c970183
 *  *Initial revision.
 */
import Configuration.AmdDB;
import Configuration.NavBar;
import Configuration.RelatedNsn;
import java.sql.*;

import java.util.*;
import javax.servlet.http.*;
import javax.servlet.jsp.*;
import org.apache.log4j.Logger;

/**
 *  Description of the Class
 *
 *@author     c970183
 *@created    June 26, 2002
 */
public class ProductStructure {

	private String assyNsiSid;
	private String compNsiSid;
	private String effectBy;
	private boolean errorOccured = false;

	private Msg msg = new Msg();
	private String userDefined;
	private static String author = "$Author:   c402417  $";
	private static Logger logger = Logger.getLogger(ProductStructure.class.getName());

	private static String revision = "$Revision:   1.4  $";
	private static String workfile = "$Workfile:   ProductStructure.java  $";


	/**
	 *  Sets the assyNsiSid attribute of the ProductStructure object
	 *
	 *@param  assyNsiSid  The new assyNsiSid value
	 */
	public void setAssyNsiSid(String assyNsiSid) {
		this.assyNsiSid = assyNsiSid;
	}


	/**
	 *  Sets the compNsiSid attribute of the ProductStructure object
	 *
	 *@param  compNsiSid  The new compNsiSid value
	 */
	public void setCompNsiSid(String compNsiSid) {
		this.compNsiSid = compNsiSid;
	}


	/**
	 *  Gets the assyNsiSid attribute of the ProductStructure object
	 *
	 *@return    The assyNsiSid value
	 */
	public String getAssyNsiSid() {
		return assyNsiSid;
	}


	/**
	 *  Gets the compNsiSid attribute of the ProductStructure object
	 *
	 *@return    The compNsiSid value
	 */
	public String getCompNsiSid() {
		return compNsiSid;
	}


	/**
	 *  Gets the effectBy attribute of the ProductStructure object
	 *
	 *@return    The effectBy value
	 */
	public String getEffectBy() {
		return effectBy;
	}


	/**
	 *  Gets the msg attribute of the ProductStructure object
	 *
	 *@return    The msg value
	 */
	public String getMsg() {
		return this.msg.toString();
	}


	/**
	 *  Gets the userDefined attribute of the ProductStructure object
	 *
	 *@return    The userDefined value
	 */
	public String getUserDefined() {
		return userDefined;
	}


	/**
	 *  Description of the Method
	 */
	public void load() {
	}


	/**
	 *  Description of the Method
	 *
	 *@param  userid                     Description of the Parameter
	 *@exception  java.sql.SQLException  Description of the Exception
	 *@exception  java.io.IOException    Description of the Exception
	 */
	public void remove(String userid)
			 throws java.sql.SQLException, java.io.IOException {
		Statement s = AmdDB.instance().getConnection(userid).createStatement();
		String sqlStmt = "Delete from amd_product_structure where comp_nsi_sid = ('" + compNsiSid + "') and assy_nsi_sid = ('" + assyNsiSid + "')";
		logger.info(sqlStmt);
		s.executeUpdate(sqlStmt);

		ResultSet rs1;
		sqlStmt = "Select effect_by  from amd_national_stock_items where nsi_sid = ('" + compNsiSid + "')";
		logger.info(sqlStmt);
		rs1 = s.executeQuery(sqlStmt);
		if (rs1.next()) {
			effectBy = rs1.getString("effect_by");
			if (effectBy == null) {
				effectBy = "";
			}
		}
		rs1.close();
		sqlStmt = "declare begin amd_effectivity_pkg.rebuildChild (" + compNsiSid + ", '" + effectBy + "'); end;";
		logger.info(sqlStmt);
		s.executeQuery(sqlStmt);
		s.close();

	}


	/**
	 *  Description of the Method
	 *
	 *@param  userid                     Description of the Parameter
	 *@exception  java.sql.SQLException  Description of the Exception
	 *@exception  java.io.IOException    Description of the Exception
	 */
	public void save(String userid)
			 throws java.sql.SQLException, java.io.IOException {
		if (logger.isDebugEnabled()) {
			logger.debug("userid=" + userid
					 + "AmdDB.instance().getConnection(userid)="
					 + AmdDB.instance().getConnection(userid) + " ");
		}
		Statement s = AmdDB.instance().getConnection(userid).createStatement();
		ResultSet assyNsiSidCount;
		String effectBy = "";
		int cnt = 0;
		String sqlStmt = " Select count(*) as cnt from amd_product_structure aps, amd_national_stock_items ansi, amd_national_stock_items ansi2 where aps.comp_nsi_sid = ('" + compNsiSid + "') and ansi.nsi_sid = aps.assy_nsi_sid and ansi2.nsi_sid = ('" + assyNsiSid + "') and ansi.effect_by != ansi2.effect_by ";
		logger.info(sqlStmt);
		assyNsiSidCount = s.executeQuery(sqlStmt);
		if (assyNsiSidCount.next()) {
			cnt = assyNsiSidCount.getInt(1);
			if (logger.isDebugEnabled()) {
				logger.debug("cnt=" + cnt);
			}
			if (cnt == 0) {
				sqlStmt = "select assy_nsi_sid, comp_nsi_sid from amd_product_structure where assy_nsi_sid = " + assyNsiSid + " and comp_nsi_sid = " + compNsiSid;
				logger.info(sqlStmt);
				ResultSet rs = s.executeQuery(sqlStmt);

				if (!rs.next()) {
					if (!assyNsiSid.equals(compNsiSid)) {
						sqlStmt = "Insert into amd_product_structure (assy_nsi_sid, comp_nsi_sid) values('" + assyNsiSid + "','" + compNsiSid + "')";
						logger.info(sqlStmt);
						s.executeUpdate(sqlStmt);
					} else {
						errorOccured = true;
						msg.append(" Can not make a part a component of itself ");
					}

					sqlStmt = "Update amd_national_stock_items set effect_by = (select effect_by from amd_national_stock_items where nsi_sid = ('" + assyNsiSid + "')) where nsi_sid = ('" + compNsiSid + "')";
					logger.info(sqlStmt);
					s.executeUpdate(sqlStmt);

					ResultSet rs1;
					sqlStmt = "Select effect_by from amd_national_stock_items where nsi_sid = ('" + assyNsiSid + "')";
					logger.info(sqlStmt);
					rs1 = s.executeQuery(sqlStmt);
					if (rs1.next()) {
						effectBy = rs1.getString("effect_by");
						if (effectBy == null) {
							effectBy = "";
						}
					}
					rs1.close();
				}
				rs.close();

				sqlStmt = "declare begin amd_effectivity_pkg.rebuildChild ('" + compNsiSid + "', '" + effectBy + "'); end;";
				logger.info(sqlStmt);
				s.executeQuery(sqlStmt);

				sqlStmt = "Update amd_national_stock_items set asset_mgmt_status = '" + RelatedNsn.STATUS_COMPLETE + "' where nsi_sid = ('" + compNsiSid + "')";
				logger.info(sqlStmt);
				s.executeUpdate(sqlStmt);

			} else {
				errorOccured = true;
				msg.append("Component NSN can not be added to this Assembly NSN because this NSN is already a COMPONENT of other NSN with a different method of defining effective aircraft");
				if (logger.isDebugEnabled()) {
					logger.debug("ERROR MESSAGE OUTPUT .... " + msg.toString());
				}
			}
		}
		assyNsiSidCount.close();
		s.close();
	}


	/**
	 *  Gets the author attribute of the ProductStructure class
	 *
	 *@return    The author value
	 */
	public static String getAuthor() {
		return author;
	}


	/**
	 *  Gets the revision attribute of the ProductStructure class
	 *
	 *@return    The revision value
	 */
	public static String getRevision() {
		return revision;
	}


	/**
	 *  Gets the workfile attribute of the ProductStructure class
	 *
	 *@return    The workfile value
	 */
	public static String getWorkfile() {
		return workfile;
	}


	/**
	 *  The main program for the ProductStructure class
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


