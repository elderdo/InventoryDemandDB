package Substitution;
/*
 *  $Revision:   1.5  $
 *  $Author:   c402417  $
 *  $Workfile:   WorkingSet.java  $
 *  $Log:   \\www-amssc-01\pds\archives\SDS-AMD\Components-ClientServer\AmdConfig\Substitution\WorkingSet.java-arc  $
/*
/*   Rev 1.5   24 Sep 2002 16:25:30   c402417
/*check file back in
/*
/*   Rev 1.4   04 Sep 2002 13:58:52   c970183
/*Removed System.out and replaced with logger.........
/*
/*   Rev 1.3   04 Sep 2002 13:30:46   c970183
/*Added get methods for PVCS revision variables.
 *  *
 *  *   Rev 1.2   04 Sep 2002 12:17:18   c970183
 *  *Fixed Keywords at top of class
 */
import java.sql.SQLException;

import java.util.*;
import org.apache.log4j.Logger;

/**
 *  Description of the Class
 *
 *@author     c970183
 *@created    June 26, 2002
 */
public class WorkingSet extends java.util.HashMap {

	private static Logger logger = Logger.getLogger(ProductStructure.class.getName());
	private static String author = "$Author:   c402417  $";

	private static String revision = "$Revision:   1.5  $";
	private static String workfile = "$Workfile:   WorkingSet.java  $";


	/**
	 *  Gets the item attribute of the WorkingSet object
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
	 *  Description of the Method
	 *
	 *@param  nsn                      Description of the Parameter
	 *@param  nsiSid                   Description of the Parameter
	 *@param  partNo                   Description of the Parameter
	 *@param  nomenclature             Description of the Parameter
	 *@param  key                      Description of the Parameter
	 *@return                          Description of the Return Value
	 *@exception  SQLException         Description of the Exception
	 *@exception  java.io.IOException  Description of the Exception
	 */
	public EquivalentNsn add(String nsn, String nsiSid, String partNo, String nomenclature, String key)
			 throws SQLException, java.io.IOException {

		EquivalentNsn objNewMember = new EquivalentNsn();
		objNewMember.setNsn(nsn);
		if (logger.isDebugEnabled()) {
		    logger.debug("nsn=" + nsn);
		}
		objNewMember.setNsiSid(nsiSid);
		objNewMember.setPartNo(partNo);
		objNewMember.setNomenclature(nomenclature);
		this.put(key, objNewMember);
		return objNewMember;
	}


	/**
	 *  Description of the Method
	 *
	 *@return    Description of the Return Value
	 */
	int count() {
		return this.size();
	}


	/**
	 *  Description of the Method
	 *
	 *@param  key                        Description of the Parameter
	 *@param  userid                     Description of the Parameter
	 *@return                            Description of the Return Value
	 *@exception  java.sql.SQLException  Description of the Exception
	 *@exception  java.io.IOException    Description of the Exception
	 */
	public EquivalentNsn load(String key, String userid)
			 throws java.sql.SQLException, java.io.IOException {
		if (this.containsKey(key)) {
			return (EquivalentNsn) this.get(key);
		}
		EquivalentNsn primaryNsn = new EquivalentNsn();
		if (primaryNsn.load(key, userid)) {
			this.put(key, primaryNsn);
			return primaryNsn;
		}
		return null;
	}


	/**
	 *  Description of the Method
	 *
	 *@param  key                        Description of the Parameter
	 *@param  userid                     Description of the Parameter
	 *@return                            Description of the Return Value
	 *@exception  java.sql.SQLException  Description of the Exception
	 *@exception  java.io.IOException    Description of the Exception
	 */
	public EquivalentNsn refresh(String key, String userid)
			 throws java.sql.SQLException, java.io.IOException {
		if (this.containsKey(key)) {
			this.remove(key);
		}
		return this.load(key, userid);
	}


	/**
	 *  Description of the Method
	 *
	 *@param  key                        Description of the Parameter
	 *@param  userid                     Description of the Parameter
	 *@exception  java.sql.SQLException  Description of the Exception
	 *@exception  java.io.IOException    Description of the Exception
	 */
	public void save(String key, String userid) throws
			java.sql.SQLException, java.io.IOException {
		if (this.containsKey(key)) {
			EquivalentNsn equivalentNsn = (EquivalentNsn) this.get(key);
			equivalentNsn.save(userid);
		}
	}


	/**
	 *  Gets the author attribute of the WorkingSet class
	 *
	 *@return    The author value
	 */
	public static String getAuthor() {
		return author;
	}


	/**
	 *  Gets the revision attribute of the WorkingSet class
	 *
	 *@return    The revision value
	 */
	public static String getRevision() {
		return revision;
	}


	/**
	 *  Gets the workfile attribute of the WorkingSet class
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

