package Substitution;
/*
 *  $Revision:   1.4  $
 *  $Author:   c402417  $
 *  $Workfile:   EquivalentNsn.java  $
 *  $Log:   \\www-amssc-01\pds\archives\SDS-AMD\Components-ClientServer\AmdConfig\Substitution\EquivalentNsn.java-arc  $
/*
/*   Rev 1.4   24 Sep 2002 16:28:20   c402417
/*check the file back in, no change
/*
/*   Rev 1.3   04 Sep 2002 13:30:44   c970183
/*Added get methods for PVCS revision variables.
 *  *
 *  *   Rev 1.2   04 Sep 2002 12:17:16   c970183
 *  *Fixed Keywords at top of class
 *
 *  Rev 1.1   04 Sep 2002 12:06:58   c970183
 *  Reformatted with JEdit and added PVCS keyword variables + a main routine that can access those variables.
 */
import Configuration.AmdDB;

import java.sql.*;
import java.util.*;
import javax.servlet.http.*;
import javax.servlet.jsp.*;
import org.apache.log4j.Logger;

/**
 *  Description of the Class
 *
 *@author     c970183
 *@created    September 4, 2002
 */
public class EquivalentNsn {

	private EquivalentNsns equivalentNsns;
	private String error;
	private boolean errorOccured = false;
	private String latestConfig;

	private String msg = "";
	private String nomenclature;
	private String nsiSid;
	private String nsn;
	private ProductStructure parentNsnCount;
	private String partNo;
	private String startDate;

	private static String author = "$Author:   c402417  $";

	private static Logger logger = Logger.getLogger(EquivalentNsn.class.getName());
	private static String revision = "$Revision:   1.4  $";
	private static String workfile = "$Workfile:   EquivalentNsn.java  $";


	/**
	 *  Constructor for the EquivalentNsn object
	 */
	EquivalentNsn() {
		super();
		equivalentNsns = new EquivalentNsns();
	}


	/**
	 *  Sets the equivalentNsns attribute of the EquivalentNsn object
	 *
	 *@param  equivalentNsns  The new equivalentNsns value
	 */
	public void setEquivalentNsns(EquivalentNsns equivalentNsns) {
		this.equivalentNsns = equivalentNsns;
	}


	/**
	 *  Sets the latestConfig attribute of the EquivalentNsn object
	 *
	 *@param  latestConfig  The new latestConfig value
	 */
	public void setLatestConfig(String latestConfig) {
		this.latestConfig = latestConfig;
	}


	/**
	 *  Sets the nomenclature attribute of the EquivalentNsn object
	 *
	 *@param  nomenclature  The new nomenclature value
	 */
	public void setNomenclature(String nomenclature) {
		this.nomenclature = nomenclature;
	}


	/**
	 *  Sets the nsiSid attribute of the EquivalentNsn object
	 *
	 *@param  nsiSid  The new nsiSid value
	 */
	public void setNsiSid(String nsiSid) {
		this.nsiSid = nsiSid;
	}


	/**
	 *  Sets the nsn attribute of the EquivalentNsn object
	 *
	 *@param  nsn  The new nsn value
	 */
	public void setNsn(String nsn) {
		this.nsn = nsn;
	}


	/**
	 *  Sets the partNo attribute of the EquivalentNsn object
	 *
	 *@param  partNo  The new partNo value
	 */
	public void setPartNo(String partNo) {
		this.partNo = partNo;
	}


	/**
	 *  Gets the equivalentNsns attribute of the EquivalentNsn object
	 *
	 *@return    The equivalentNsns value
	 */
	public EquivalentNsns getEquivalentNsns() {
		return equivalentNsns;
	}


	/**
	 *  Gets the latestConfig attribute of the EquivalentNsn object
	 *
	 *@return    The latestConfig value
	 */
	public String getLatestConfig() {
		return this.latestConfig;
	}


	/**
	 *  Gets the msg attribute of the EquivalentNsn object
	 *
	 *@return    The msg value
	 */
	public String getMsg() {
		return this.msg;
	}


	/**
	 *  Gets the nomenclature attribute of the EquivalentNsn object
	 *
	 *@return    The nomenclature value
	 */
	public String getNomenclature() {
		return nomenclature;
	}


	/**
	 *  Gets the nsiSid attribute of the EquivalentNsn object
	 *
	 *@return    The nsiSid value
	 */
	public String getNsiSid() {
		return nsiSid;
	}


	/**
	 *  Gets the nsn attribute of the EquivalentNsn object
	 *
	 *@return    The nsn value
	 */
	public String getNsn() {
		return nsn;
	}


	/**
	 *  Gets the partNo attribute of the EquivalentNsn object
	 *
	 *@return    The partNo value
	 */
	public String getPartNo() {
		return partNo;
	}


	/**
	 *  Description of the Method
	 *
	 *@param  nsiSid                   Description of the Parameter
	 *@param  userid                   Description of the Parameter
	 *@return                          Description of the Return Value
	 *@exception  SQLException         Description of the Exception
	 *@exception  java.io.IOException  Description of the Exception
	 */
	public boolean load(String nsiSid, String userid)
			 throws SQLException, java.io.IOException {
		boolean result = false;
		Statement s = AmdDB.instance().getConnection(userid).createStatement();
		ResultSet nsnInfo;

		String sqlStmt = "Select items.nsn, parts.part_no, parts.nomenclature "
				 + "from  amd_national_stock_items items, "
				 + "amd_spare_parts parts "
				 + "where nsi_sid = " + nsiSid + " and items.prime_part_no = parts.part_no";

		logger.info(sqlStmt);
		nsnInfo = s.executeQuery(sqlStmt);
		if (nsnInfo.next()) {
			result = true;
			this.nsiSid = nsiSid;
			nsn = nsnInfo.getString("nsn");

			this.partNo = nsnInfo.getString("part_no");
			logger.debug("ThisPartNo = ('" + this.partNo + "')");
			this.nomenclature = nsnInfo.getString("nomenclature");
			logger.debug("ThisNomenclature = ('" + this.nomenclature + "')");
			equivalentNsns.load(userid, nsiSid);
		}
		nsnInfo.close();
		return result;
	}


	/**
	 *  Description of the Method
	 *
	 *@param  userid                   Description of the Parameter
	 *@exception  SQLException         Description of the Exception
	 *@exception  java.io.IOException  Description of the Exception
	 */
	public void save(String userid) throws SQLException, java.io.IOException {
		ProductStructure productStructure = new ProductStructure();
		Set keys = equivalentNsns.keySet();
		Iterator iterator = keys.iterator();
		while (iterator.hasNext()) {
			EquivalentNsn equivalentNsn = (EquivalentNsn) equivalentNsns.get(iterator.next());
			if (!nsiSid.equals(equivalentNsn.getNsiSid())) {
				// DSE 9/03/02 Added test so that parent does not add itself as a child
				productStructure.setAssyNsiSid(nsiSid);
				productStructure.setCompNsiSid(equivalentNsn.getNsiSid());
				productStructure.save(userid);
				msg = productStructure.getMsg().toString();
				logger.debug("Equivalent NSN ERROR MESSAGE ..." + msg.toString());
			}
		}
	}


	/**
	 *  Gets the author attribute of the EquivalentNsn class
	 *
	 *@return    The author value
	 */
	public static String getAuthor() {
		return author;
	}


	/**
	 *  Gets the revision attribute of the EquivalentNsn class
	 *
	 *@return    The revision value
	 */
	public static String getRevision() {
		return revision;
	}


	/**
	 *  Gets the workfile attribute of the EquivalentNsn class
	 *
	 *@return    The workfile value
	 */
	public static String getWorkfile() {
		return workfile;
	}


	/**
	 *  The main program for the ControlerSub class
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

