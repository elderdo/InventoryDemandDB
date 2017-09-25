package Substitution;
/*
 *  $Revision:   1.4  $
 *  $Author:   c402417  $
 *  $Workfile:   EquivalentNsns.java  $
 *  $Log:   \\www-amssc-01\pds\archives\SDS-AMD\Components-ClientServer\AmdConfig\Substitution\EquivalentNsns.java-arc  $
/*
/*   Rev 1.4   24 Sep 2002 16:27:38   c402417
/*check the file back in, no change
/*
/*   Rev 1.3   04 Sep 2002 13:30:44   c970183
/*Added get methods for PVCS revision variables.
 *  *
 *  *   Rev 1.2   04 Sep 2002 12:17:18   c970183
 *  *Fixed Keywords at top of class
 */
import Configuration.AmdDB;
import Configuration.NavBar;
import Substitution.*;
import java.sql.*;

import java.util.*;
import javax.servlet.jsp.*;
import org.apache.log4j.Logger;

/**
 *  Description of the Class
 *
 *@author     c970183
 *@created    September 4, 2002
 */
public class EquivalentNsns extends java.util.HashMap {
	private boolean debug = false;
	private boolean errorOccured = false;

	private String lastSqlStmt;

	private Msg msg = new Msg();
	private JspWriter out;
	private NavBar topNavBar;
	private static String author = "$Author:   c402417  $";
	private static Logger logger = Logger.getLogger(EquivalentNsns.class.getName());

	private static String revision = "$Revision:   1.4  $";
	private static String workfile = "$Workfile:   EquivalentNsns.java  $";


	/**
	 *  Sets the debug attribute of the EquivalentNsns object
	 *
	 *@param  debug  The new debug value
	 */
	public void setDebug(boolean debug) {
		this.debug = debug;
	}


	/**
	 *  Sets the out attribute of the EquivalentNsns object
	 *
	 *@param  out  The new out value
	 */
	public void setOut(JspWriter out) {
		this.out = out;
	}


	/**
	 *  Gets the count attribute of the EquivalentNsns object
	 *
	 *@return    The count value
	 */
	public int getCount() {
		return this.size();
	}


	/**
	 *  Gets the item attribute of the EquivalentNsns object
	 *
	 *@param  key  Description of the Parameter
	 *@return      The item value
	 */
	public EquivalentNsn getItem(String key) {
		if (this.containsKey(key)) {
			return (EquivalentNsn) this.get(key);
		} else {
			return null;
		}
	}


	/**
	 *  Gets the lastSqlStmt attribute of the EquivalentNsns object
	 *
	 *@return    The lastSqlStmt value
	 */
	public String getLastSqlStmt() {
		return lastSqlStmt;
	}


	/**
	 *  Gets the msg attribute of the EquivalentNsns object
	 *
	 *@return    The msg value
	 */
	public String getMsg() {
		return this.msg.toString();
	}


	/**
	 *  Description of the Method
	 *
	 *@param  nsiSid                   Description of the Parameter
	 *@param  nsn                      Description of the Parameter
	 *@param  partNo                   Description of the Parameter
	 *@param  nomenclature             Description of the Parameter
	 *@param  key                      Description of the Parameter
	 *@return                          Description of the Return Value
	 *@exception  java.io.IOException  Description of the Exception
	 */
	public EquivalentNsn add(String nsiSid, String nsn, String partNo, String nomenclature, String key)
			 throws java.io.IOException {
		EquivalentNsn objNewMember = new EquivalentNsn();
		objNewMember.setNsiSid(nsiSid);
		logger.debug(" NSISID = ('" + nsiSid + "')");
		objNewMember.setNsn(nsn);
		logger.debug(" NSN = ('" + nsn + "') ");
		objNewMember.setPartNo(partNo);
		logger.debug(" PART NO = ('" + partNo + "')");
		objNewMember.setNomenclature(nomenclature);
		logger.debug(" NOMENCLATURE = ('" + nomenclature + "')");
		this.put(key, objNewMember);
		return objNewMember;
	}


	/**
	 *  Description of the Method
	 *
	 *@param  nsiSid         Description of the Parameter
	 *@param  equivalentNsn  Description of the Parameter
	 */
	void add(String nsiSid, EquivalentNsn equivalentNsn) {
		this.put(nsiSid, equivalentNsn);
	}


	/**
	 *  Description of the Method
	 *
	 *@param  userid                     Description of the Parameter
	 *@param  assyNsiSid                 Description of the Parameter
	 *@exception  java.sql.SQLException  Description of the Exception
	 *@exception  java.io.IOException    Description of the Exception
	 */
	public void load(String userid, String assyNsiSid) throws java.sql.SQLException,
			java.io.IOException {
		Statement s = AmdDB.instance().getConnection(userid).createStatement();
		String sqlStmt = "select items.nsi_sid, items.nsn, parts.part_no,  parts.nomenclature "
				 + "from amd_national_stock_items items, "
				 + "amd_spare_parts parts "
				 + "where nsi_sid in (Select comp_nsi_sid "
				 + "from amd_product_structure aps "
				 + "where aps.assy_nsi_sid = " + assyNsiSid + ") "
				 + "and items.prime_part_no = parts.part_no ";

		logger.info(sqlStmt);
		ResultSet equivalentNsns = s.executeQuery(sqlStmt);
		while (equivalentNsns.next()) {
			logger.debug(
					"nsi_sid=" + equivalentNsns.getString("nsi_sid")
					 + " nsn=" + equivalentNsns.getString("nsn")
					 + " part_no=" + equivalentNsns.getString("part_no")
					 + " nomenclature=" + equivalentNsns.getString("nomenclature")
					);
			EquivalentNsn equivalentNsn = this.add(equivalentNsns.getString("nsi_sid"),
					equivalentNsns.getString("nsn"),
					equivalentNsns.getString("part_no"),
					equivalentNsns.getString("nomenclature"),
					equivalentNsns.getString("nsi_sid"));
		}
		equivalentNsns.close();
	}


	/**
	 *  Description of the Method
	 *
	 *@param  assyNsiSid               Description of the Parameter
	 *@param  compNsiSid               Description of the Parameter
	 *@param  userid                   Description of the Parameter
	 *@exception  SQLException         Description of the Exception
	 *@exception  java.io.IOException  Description of the Exception
	 *@exception  Exception            Description of the Exception
	 */
	public void remove(String assyNsiSid, String compNsiSid, String userid) throws
			SQLException, java.io.IOException, Exception {
		if (this.containsKey(compNsiSid)) {
			super.remove(compNsiSid);
			ProductStructure productStructure = new ProductStructure();
			productStructure.setAssyNsiSid(assyNsiSid);
			productStructure.setCompNsiSid(compNsiSid);
			productStructure.remove(userid);
		} else {
			logger.fatal("Expected to find component " + compNsiSid + " for parent " + assyNsiSid + " in the EquivalentNsns HashMap, but it was not found.");
			throw new Exception("Expected to find component " + compNsiSid + " for parent " + assyNsiSid + " in the EquivalentNsns HashMap, but it was not found.");
		}
	}


	/**
	 *  Description of the Method
	 *
	 *@param  nsiGroupSid                Description of the Parameter
	 *@param  userid                     Description of the Parameter
	 *@exception  java.sql.SQLException  Description of the Exception
	 */
	public void save(String nsiGroupSid, String userid) throws java.sql.SQLException {
		Statement s = AmdDB.instance().getConnection(userid).createStatement();
		Set keys = this.keySet();
		Iterator it = keys.iterator();
		while (it.hasNext()) {
			EquivalentNsn equivalentNsn = (EquivalentNsn) this.get(it.next());
		}
	}


	/**
	 *  Gets the author attribute of the EquivalentNsns object
	 *
	 *@return    The author value
	 */
	public static String getAuthor() {
		return author;
	}


	/**
	 *  Gets the revision attribute of the EquivalentNsns object
	 *
	 *@return    The revision value
	 */
	public static String getRevision() {
		return revision;
	}


	/**
	 *  Gets the workfile attribute of the EquivalentNsns object
	 *
	 *@return    The workfile value
	 */
	public static String getWorkfile() {
		return workfile;
	}


	/**
	 *  The main program for the EquivalentNsns class
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

