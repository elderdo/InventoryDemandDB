package Configuration;
import java.sql.*;
/*
 *  $Revision:   1.2  $
 *  $Author:   c970183  $
 *  $Workfile:   Pairs.java  $
 *  $Log:   \\www-amssc-01\pds\archives\SDS-AMD\Components-ClientServer\AmdConfig\Configuration\Pairs.java-arc  $
/*
/*   Rev 1.2   06 Aug 2002 11:46:16   c970183
/*Latest Version on hs1189
 *  *
 *  *   Rev 1.1   23 May 2002 06:57:54   c970183
 *  *Test Release
 */
import java.util.*;
import org.apache.log4j.Logger;

/**
 *  A collection of all the pairs of nsn's that belong to a group.
 *
 *@author     Douglas S. Elder
 *@since      06/20/02
 */
public class Pairs extends java.util.HashMap {
	private static String author = "$Author:   c970183  $";

	private static Logger logger = Logger.getLogger(Pairs.class.getName());

	private static String revision = "$Revision:   1.2  $";
	private static String workfile = "$Workfile:   Pairs.java  $";


	/**
	 *  Gets the author attribute of the Pairs object
	 *
	 *@return    The author value
	 */
	public String getAuthor() {
		return author;
	}


	/**
	 *  Retrieve a specific pair from the collection.
	 *
	 *@param  key  The concatenated lhs and rhs (nsns) for the pair.
	 *@return      The item value
	 */
	public Pair getItem(String key) {
		if (this.containsKey(key)) {
			return (Pair) this.get(key);
		} else {
			return null;
		}
	}


	/**
	 *  Gets the nsn attribute of the Pairs object
	 *
	 *@param  nsiSid            Description of the Parameter
	 *@param  userid            Description of the Parameter
	 *@return                   The nsn value
	 * @exception java.sql.SQLException This exception can occur, since the class loads
	 * data from the Oracle data base via JDBC.
	 */
	protected String getNsn(String nsiSid, String userid) throws SQLException {
		Statement s = AmdDB.instance().getConnection(userid).createStatement();
		String sqlStmt = "select nsn from amd_national_stock_items where nsi_sid = " + nsiSid;
		logger.info(sqlStmt);
		ResultSet nsn = s.executeQuery(sqlStmt);
		if (nsn.next()) {
			String nsnStr = nsn.getString("nsn");
			nsn.close();
			s.close();
			return nsnStr;
		} else {
			nsn.close();
			s.close();
			return null;
		}
	}


	/**
	 *  Gets the revision attribute of the Pairs object
	 *
	 *@return    The revision value
	 */
	public String getRevision() {
		return revision;
	}


	/**
	 *  Gets the workfile attribute of the Pairs object
	 *
	 *@return    The workfile value
	 */
	public String getWorkfile() {
		return workfile;
	}


	/**
	 *  Add a pair to the collection
	 *
	 *@param  lhs              The left hand side nsn of a pair.
	 *@param  rhs              The right hand side nsn of a pair.
	 *@param  interChangeType  One of the following values: Pair.NOT_INTERCHANGABLE
	 *      Pair.ONE_WAY Pair.TWO_WAY Pair.LIMITED
	 *@param  upgradable       a Yes or No value
	 *@param  lhsNsiSid        The left hand side nsiSid of a pair.
	 *@param  rhsNsiSid        The right hand side nsiSid of a pair.
	 *@param  key              The concatenated lhs and rhs.
	 *@return                  Description of the Return Value
	 */
	public Pair add(String lhs, String rhs, String interChangeType, boolean upgradable, String lhsNsiSid, String rhsNsiSid, String key) {
		Pair objNewPair = new Pair();
		if (this.containsKey(key)) {
			return null;
		}
		objNewPair.setLhs(lhs);
		objNewPair.setRhs(rhs);
		if (logger.isDebugEnabled()) {
		    logger.debug("lhs=" + lhs + " rhs=" + rhs) ;
		    logger.debug("interChangeType=" + interChangeType) ;
		}
		objNewPair.setInterChangeType(interChangeType);
		objNewPair.setUpgradable(upgradable);
		objNewPair.setLhsNsiSid(lhsNsiSid);
		objNewPair.setRhsNsiSid(rhsNsiSid);
		this.put(key, objNewPair);
		return objNewPair;
	}


	/**
	 *  Adds a feature to the Pairs attribute of the Pairs object
	 *
	 *@param  nsiSid            The feature to be added to the Pairs attribute
	 *@param  userid            The feature to be added to the Pairs attribute
	 * @exception java.sql.SQLException This exception can occur, since the class inserts
	 * data into the Oracle data base via JDBC.
	 */
	protected void addPairs(String nsiSid, String userid) throws SQLException {
		Statement s = AmdDB.instance().getConnection(userid).createStatement();
		String sqlStmt = "select replaced_nsi_sid, replaced_by_nsi_sid, upgradeable, interchange_type from amd_related_nsi_pairs where replaced_nsi_sid = " + nsiSid + " or replaced_by_nsi_sid = " + nsiSid;
		logger.info(sqlStmt);
		ResultSet pairs = s.executeQuery(sqlStmt);
		while (pairs.next()) {
			String lhs = getNsn(pairs.getString("replaced_nsi_sid"), userid);
			String rhs = getNsn(pairs.getString("replaced_by_nsi_sid"), userid);
			this.add(lhs,
					rhs,
					pairs.getString("interchange_type"),
					pairs.getString("upgradeable").equals("Y"),
					pairs.getString("replaced_nsi_sid"),
					pairs.getString("replaced_by_nsi_sid"),
					lhs + rhs);
		}
		pairs.close();
		s.close();
	}


	/**
	 *@return    The number of pairs in the collection
	 */
	public int count() {
		return this.size();
	}


	/**
	 *  Loads all the pairs from the data base for the given group.
	 *
	 *@param  nsiGroupSid
	 *@param  userid                     The Oracle userid needed to get the
	 *      connection object from the AmdDB connection pool.
	 * @exception java.sql.SQLException This exception can occur, since the class loads
	 * data from the Oracle data base via JDBC.
	 */
	public void load(String nsiGroupSid, String userid) throws java.sql.SQLException {
		Statement s = AmdDB.instance().getConnection(userid).createStatement();
		String sqlStmt = "select nsi_sid from amd_national_stock_items where nsi_group_sid = " + nsiGroupSid;
		logger.info(sqlStmt);
		ResultSet relatedNsns = s.executeQuery(sqlStmt);
		if (logger.isDebugEnabled()) {
		    logger.debug("Paris.load: nsiGroupSid=" + nsiGroupSid) ;
		}
		while (relatedNsns.next()) {
		    if (logger.isDebugEnabled()) {
			    logger.debug("nsi_sid=" + relatedNsns.getString("nsi_sid")) ;
			}
			addPairs(relatedNsns.getString("nsi_sid"), userid);
		}
		relatedNsns.close();
		s.close();
	}


	/**
	 *  For a given nsiSid removes any pair in the collection that uses the nsn
	 *  associated with that nsiSid. It removes the corresponding pair from the
	 *  data base.
	 *
	 *@param  nsiSid
	 *@param  userid                     The Oracle userid needed to get the
	 *      connection object from the AmdDB connection pool.
	 * @exception java.sql.SQLException This exception can occur, since the class deletes
	 * data from the Oracle data base via JDBC.
	 */
	public void remove(String nsiSid, String userid)
			 throws SQLException {
		Object keys[] = this.keySet().toArray();
		Pair anItem = null;
		Connection conn = AmdDB.instance().getConnection(userid);
		Statement s = conn.createStatement();
		String sqlStmt = "";
		for (int i = 0; i < keys.length; i++) {
			anItem = (Pair) this.get(keys[i]);
			if (anItem.getLhsNsiSid().equals(nsiSid) || anItem.getRhsNsiSid().equals(nsiSid)) {
				sqlStmt = "delete from amd_related_nsi_pairs where replaced_nsi_sid = " + nsiSid + " or replaced_by_nsi_sid = " + nsiSid;
				logger.info(sqlStmt);
				s.executeUpdate(sqlStmt);
				super.remove(keys[i]);
			}
		}
		s.close();
	}


	/**
	 *  Empties the collection and removes all pairs from the data base.
	 *
	 *@param  userid                     The Oracle userid needed to get the
	 *      connection object from the AmdDB connection pool.
	 * @exception java.sql.SQLException This exception can occur, since the class deletes
	 * data from the Oracle data base via JDBC.
	 */
	public void removeAll(String userid) throws java.sql.SQLException {
		AmdDB amd = AmdDB.instance();
		Connection conn = amd.getConnection(userid);
		Statement s = conn.createStatement();
		Object keys[] = this.keySet().toArray();
		Pair anItem = null;
		String sqlStmt = "";
		for (int i = 0; i < keys.length; i++) {
			anItem = (Pair) this.get(keys[i]);
			sqlStmt = "delete from amd_related_nsi_pairs where replaced_nsi_sid = " + anItem.getLhsNsiSid() + " and replaced_by_nsi_sid = " + anItem.getRhsNsiSid();
			logger.info(sqlStmt);
			s.executeUpdate(sqlStmt);
			this.remove(keys[i]);
		}
		s.close();
	}


	/**
	 *  Persists all the pairs to the data base.
	 *
	 *@param  userid                     The Oracle userid needed to get the
	 *      connection object from the AmdDB connection pool.
	 * @exception java.sql.SQLException This exception can occur, since the class saves
	 * data to the Oracle data base via JDBC.
	 */
	public void save(String userid) throws java.sql.SQLException {
		Statement s = AmdDB.instance().getConnection(userid).createStatement();
		Set keys = this.keySet();
		Iterator it = keys.iterator();
		String sqlStmt;
		while (it.hasNext()) {
			Pair pair = (Pair) this.get(it.next());
			sqlStmt = "select * from amd_related_nsi_pairs where replaced_nsi_sid = " + pair.getLhsNsiSid() + " and replaced_by_nsi_sid = " + pair.getRhsNsiSid();
			logger.info(sqlStmt);
			ResultSet rs = s.executeQuery(sqlStmt);
			if (rs.next()) {
				sqlStmt = "update amd_related_nsi_pairs "
						 + "set upgradeable = " + (pair.getUpgradable() ? "'Y'" : "'N'")
						 + ", interchange_type = '" + pair.getInterChangeType() + "' "
						 + "  where replaced_nsi_sid = " + pair.getLhsNsiSid() + " and replaced_by_nsi_sid = " + pair.getRhsNsiSid();
				logger.info(sqlStmt);
				s.executeUpdate(sqlStmt);
			} else {
				sqlStmt = "Insert into amd_related_nsi_pairs (replaced_nsi_sid, replaced_by_nsi_sid, upgradeable, interchange_type) " +
						"values(" + pair.getLhsNsiSid() + ", " + pair.getRhsNsiSid() + ", " + (pair.getUpgradable() ? "'Y'" : "'N'") + ", '" + pair.getInterChangeType() + "')";
				logger.info(sqlStmt);
				s.executeUpdate(sqlStmt);
			}
			rs.close();
		}
		s.close();
	}


	/**
	 *  Used for testing purposes.
	 *
	 *@param  args
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
