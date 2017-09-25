package Configuration;
import java.sql.*;
/*
 *  $Revision:   1.2  $
 *  $Author:   c970183  $
 *  $Workfile:   FleetSizeMembers.java  $
 *  $Log:   \\www-amssc-01\pds\archives\SDS-AMD\Components-ClientServer\AmdConfig\Configuration\FleetSizeMembers.java-arc  $
/*
/*   Rev 1.2   06 Aug 2002 11:46:24   c970183
/*Latest Version on hs1189
 *  *
 *  *   Rev 1.1   23 May 2002 06:57:50   c970183
 *  *Test Release
 */
import java.util.*;
import org.apache.log4j.Logger;

/**
 *  A collection of all the aircraft in the fleet.
 *
 *@author     Douglas S. Elder
 *@version    1.0
 *@since      06/01/02
 *@see        FleetSizeMember
 */
public class FleetSizeMembers extends java.util.HashMap {
	private static String author = "$Author:   c970183  $";
	private static Logger logger = Logger.getLogger(FleetSizeMembers.class.getName());

	private static String revision = "$Revision:   1.2  $";
	private static String workfile = "$Workfile:   FleetSizeMembers.java  $";


	/**
	 *  Gets the author attribute of the FleetSizeMembers object
	 *
	 *@return    The author value
	 */
	public String getAuthor() {
		return author;
	}


	/**
	 *  Gets the count attribute of the FleetSizeMembers object
	 *
	 *@return    The count value
	 */
	public int getCount() {
		return this.size();
	}


	/**
	 *  Gets the item attribute of the FleetSizeMembers object
	 *
	 *@param  key  Description of the Parameter
	 *@return      The item value
	 */
	public FleetSizeMember getItem(String key) {
		if (this.containsKey(key)) {
			return (FleetSizeMember) this.get(key);
		} else {
			return null;
		}
	}


	/**
	 *  Gets the revision attribute of the FleetSizeMembers object
	 *
	 *@return    The revision value
	 */
	public String getRevision() {
		return revision;
	}


	/**
	 *  Gets the workfile attribute of the FleetSizeMembers object
	 *
	 *@return    The workfile value
	 */
	public String getWorkfile() {
		return workfile;
	}


	/**
	 *  Add a FleetSizeMember to the collection
	 *
	 *@param  fleetSizeName  The name attribute of the FleetSizeMember
	 *@param  pNo            The 'P' number attribute of the FleetSizeMember
	 *@param  acNo           The aircraft number attribute of the FleetSizeMember
	 *@param  tailNo         The tailNo attribute of the FleetSizeMember
	 *@return                A FleetSizeMember object containing the above information
	 */
	public FleetSizeMember add(String fleetSizeName, String pNo, String acNo, String tailNo) {
		FleetSizeMember objNewMember = new FleetSizeMember();
		Aircraft aircraft = objNewMember.getAircraft();
		aircraft.setPno(pNo);
		aircraft.setAcNo(acNo);
		aircraft.setTailNo(tailNo);
		objNewMember.setFleetSizeName(fleetSizeName);
		this.put(tailNo, objNewMember);
		return objNewMember;
	}


	/**
	 *  Determine if the current FleetSizeMembers object
	 *  is the same size as another FleetSizeMembers object
	 *
	 *@param  fleetSizeMembers  
	 *@return                   true if they are the same size
	 */
	public boolean equals(FleetSizeMembers fleetSizeMembers) {
		if (fleetSizeMembers.size() != this.size()) {
			return false;
		}

		Set lhsKeys = this.keySet();
		Iterator lhsIterator = lhsKeys.iterator();
		Set rhsKeys = fleetSizeMembers.keySet();
		while (lhsIterator.hasNext()) {
			if (!rhsKeys.contains(lhsIterator.next())) {
				return false;
			}
		}
		return true;
	}


	/**
	 *  Load the data for this object from the data base.
	 *
	 *@param  fleetSizeName              The name of the fleet to load.
	 *@param  userid                     The Oracle userid that was used to logon
	 *      to the application.
	 * @exception java.sql.SQLException This exception can occur, since the class loads
	 * data from the Oracle data base via JDBC.
	 */

	public void load(String fleetSizeName, String userid)
			 throws java.sql.SQLException {
		logger.debug("loading fleetsize " + fleetSizeName + " for " + userid);
		Statement s1 = AmdDB.instance().getConnection(userid).createStatement();
		Statement s2 = AmdDB.instance().getConnection(userid).createStatement();
		String sqlStmt = "select * from amd_ltd_fleet_size_member where upper(fleet_Size_Name) = '" + fleetSizeName.toUpperCase() + "'";
		logger.info(sqlStmt);
		ResultSet fleetSizeMembers = s1.executeQuery(sqlStmt);
		while (fleetSizeMembers.next()) {
			String tailNo = fleetSizeMembers.getString("tail_no");
			/*
			if (logger.isDebugEnabled()) {
			    logger.debug("tailNo=" + tailNo );
			}
			*/
			ResultSet ac = s2.executeQuery("select p_no, ac_no from amd_aircrafts where tail_no = '" + tailNo + "'");
			if (ac.next()) {
				FleetSizeMember fleetSizeMember = this.add(fleetSizeName, ac.getString("p_no"), ac.getString("ac_no"), tailNo);
			}
			ac.close();
		}
		fleetSizeMembers.close();
		s1.close();
		s2.close();
	}


	/**
	 *  Persists all the aircraft to the data base.
	 *
	 *@param  fleetSizeName              The name of the fleet: either the
	 *      predefined name or the system generated number.
	 *@param  userid                     The Oracle userid used to logon to the
	 *      application.
	 * @exception java.sql.SQLException This exception can occur, since the class loads
	 * data from the Oracle data base via JDBC.
	 */
	public void save(String fleetSizeName, String userid)
			 throws java.sql.SQLException {
		logger.debug("saving fleetsize.. ");
		Statement s = AmdDB.instance().getConnection(userid).createStatement();
		String sqlStmt = "select * from amd_ltd_fleet_size_member where upper(fleet_size_name) = '" + fleetSizeName.toUpperCase() + "'";
		logger.info(sqlStmt);
		ResultSet members = s.executeQuery(sqlStmt);
		if (members.next()) {
			members.close();
			sqlStmt = "Delete from amd_ltd_fleet_size_member where upper(fleet_size_name) = '" + fleetSizeName.toUpperCase() + "'";
			logger.info(sqlStmt);
			s.executeUpdate(sqlStmt);
		} else {
			members.close();
		}

		Set keys = this.keySet();
		Iterator it = keys.iterator();
		while (it.hasNext()) {
			FleetSizeMember fleetSizeMember = (FleetSizeMember) this.get(it.next());
			fleetSizeMember.setFleetSizeName(fleetSizeName);
			sqlStmt = "insert into amd_ltd_fleet_size_member (fleet_size_name, tail_no) values('" + fleetSizeMember.getFleetSizeName() + "', '" + fleetSizeMember.getAircraft().getTailNo() + "')";
			logger.info(sqlStmt);
			s.execute(sqlStmt);
		}
		s.close();
	}


	/**
	 *  Write the PVCS version information to the System.out file.
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
