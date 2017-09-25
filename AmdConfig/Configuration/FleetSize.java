package Configuration;
import java.sql.*;
/*
 *  $Revision:   1.2  $
 *  $Author:   c970183  $
 *  $Workfile:   FleetSize.java  $
 *  $Log:   \\www-amssc-01\pds\archives\SDS-AMD\Components-ClientServer\AmdConfig\Configuration\FleetSize.java-arc  $
/*
/*   Rev 1.2   06 Aug 2002 11:46:26   c970183
/*Latest Version on hs1189
 *  *
 *  *   Rev 1.1   23 May 2002 06:57:50   c970183
 *  *Test Release
 */
import java.util.*;
import org.apache.log4j.Logger;

/**
 *  This class manages the fleet size for the Configuration subsystem of the
 *  Effectivity application. There are two types of FleetSize classes: one
 *  represents a predefined fleet size, whereas the other represents a custom
 *  fleet size.
 *
 *@author     Douglas S. Elder
 *@version    1.0
 *@since      06/01/02
 */
public class FleetSize {

	/**
	 *  The fleet size description.
	 */
	private String fleetSizeDesc;

	/**
	 *  A collection of the aircraft in the fleet.
	 */
	private FleetSizeMembers fleetSizeMembers;

	/**
	 *  Either the predefined fleet size name or the system generated number.
	 */
	private String fleetSizeName;

	/**
	 *  A boolean value, if true it indicates this is a predefined fleet size.
	 */
	private boolean predefinedFleetSize;

	/**
	 *  The PVCS author.
	 */
	private static String author = "$Author:   c970183  $";

	/**
	 *  A log file that uses the log4j technology from apache.
	 */
	private static Logger logger = Logger.getLogger(FleetSize.class.getName());

	/**
	 *  The PVCS revison.
	 */
	private static String revision = "$Revision:   1.2  $";

	/**
	 *  The PVCS workfile.
	 */
	private static String workfile = "$Workfile:   FleetSize.java  $";

	/**
	 *  The default predefined fleet size name used for all new fleets.
	 */
	public final static String ALL_AIRCRAFT = "All Aircraft";
	/**
	 *  A constant for the predefined fleet size "United Kingdom"
	 */
	public final static String UK = "UK";
	/**
	 *  A constant for the predefined fleet size "United States Airforce"
	 */
	public final static String USAF = "USAF";


	/**
	 *  This class is initialized with the default system fleet size for the
	 *  Configuration subsystem of the Effectivity application. The default is a
	 *  predefined fleet size for all aircraft.
	 */
	public FleetSize() {
		fleetSizeName = ALL_AIRCRAFT;
		fleetSizeDesc = ALL_AIRCRAFT;
		predefinedFleetSize = true;
		fleetSizeMembers = new FleetSizeMembers();
	}


	/**
	 *@param  fleetSizeDesc  A description of the fleet: currently mirrors the
	 *      fleet size name.
	 */
	public void setFleetSizeDesc(String fleetSizeDesc) {
		this.fleetSizeDesc = fleetSizeDesc;
	}


	/**
	 *@param  fleetSizeMembers  An object that contains all of the fleet members
	 *@see                      FleetSizeMember
	 */
	public void setFleetSizeMembers(FleetSizeMembers fleetSizeMembers) {
		this.fleetSizeMembers = fleetSizeMembers;
	}


	/**
	 *  Sets the fleet size name to one of the predefined names or a system
	 *  generated number.
	 *
	 *@param  fleetSizeName  This is either a predefined name or a system generated
	 *      number.
	 */
	public void setFleetSizeName(String fleetSizeName) {
		this.fleetSizeName = fleetSizeName;
	}


	/**
	 *  A boolean value that indicates if the fleet is predefined or user defined.
	 *
	 *@param  predefinedFleetSize  This value is true for predefined fleets and
	 *      false for user defined fleets.
	 */
	public void setPredefinedFleetSize(boolean predefinedFleetSize) {
		this.predefinedFleetSize = predefinedFleetSize;
	}


	/**
	 *  This returns an array that contains all of the fleet: the format is
	 *  p_no-ac_no-tail_no. Where p_no is the plane number, ac_no is the aircraft
	 *  number, and tail_no is the tail number. This is similar to the array
	 *  returned by the jsp request object.
	 *
	 *@return    An array that contains all the aircraft.
	 */
	public String[] getAircraftArray() {
		if (predefinedFleetSize) {
			return null;
		} else {
			Set keys = fleetSizeMembers.keySet();
			Iterator iterator = keys.iterator();
			String aircraftArray[] = new String[fleetSizeMembers.size()];
			int i = 0;
			while (iterator.hasNext()) {
				FleetSizeMember fleetSizeMember = (FleetSizeMember) fleetSizeMembers.get(iterator.next());
				Aircraft aircraft = fleetSizeMember.getAircraft();
				aircraftArray[i++] = aircraft.getPno() + "-" + aircraft.getAcNo() + "-" + aircraft.getTailNo();
			}
			return aircraftArray;
		}
	}


	/**
	 *  Gets the author attribute of the FleetSize object
	 *
	 *@return    The author value
	 */
	public String getAuthor() {
		return author;
	}


	/**
	 *  Currently this mirrors the fleet size name
	 *
	 *@return    A description of the fleet.
	 */
	public String getFleeSizeDesc() {
		return fleetSizeDesc;
	}


	/**
	 *@return    An object that contains all of the fleet members.
	 *@see       FleetSizeMember
	 */
	public FleetSizeMembers getFleetSizeMembers() {
		return fleetSizeMembers;
	}


	/**
	 *  This method returns either the predefined fleet name or a system generated
	 *  number for user defined fleets.
	 *
	 *@return    A string containing the fleet name or a system generated number
	 */
	public String getFleetSizeName() {
		return fleetSizeName;
	}


	/**
	 *  This indicates whether this is a predefined fleet or a user defined fleet.
	 *
	 *@return    A boolean value: true if it is a predefined fleet, otherwise it is
	 *      false.
	 */
	public boolean getPredefinedFleetSize() {
		return predefinedFleetSize;
	}


	/**
	 *  Gets the revision attribute of the FleetSize object
	 *
	 *@return    The revision value
	 */
	public String getRevision() {
		return revision;
	}


	/**
	 *  Gets the tailNumbers attribute of the FleetSize object
	 *
	 *@return    The tailNumbers value
	 */
	public String[] getTailNumbers() {
		Set keys = fleetSizeMembers.keySet();
		Iterator iterator = keys.iterator();
		if (logger.isDebugEnabled()) {
		    logger.debug("fleetSizeMembers.size()=" + fleetSizeMembers.size()) ;
		}
		String tailNo[] = new String[fleetSizeMembers.size()];
		int i = 0;
		while (iterator.hasNext()) {
			FleetSizeMember fleetSizeMember = (FleetSizeMember) fleetSizeMembers.get(iterator.next());
			tailNo[i++] = fleetSizeMember.getTailNo() ;
		}
		return tailNo;
	}


	/**
	 *  Gets the workfile attribute of the FleetSize object
	 *
	 *@return    The workfile value
	 */
	public String getWorkfile() {
		return workfile;
	}


	/**
	 *  Get the difference between two FleetSize objects
	 *
	 *@param  fleetSize  The FleetSize object to be subtracted
	 *                   from the current one
	 *@return            The list of aircraft that occur in
	 *                   the current (this) FleetSize object, but
	 *                   not in the other FleetSize object  
	 */
	public String[] diff(FleetSize fleetSize) {
		java.util.HashSet minuend = new HashSet();
		Set tailNo = fleetSizeMembers.keySet();
		Iterator iterator = tailNo.iterator();
		while (iterator.hasNext()) {
			String key = (String) iterator.next();
			minuend.add(key);
		}

		java.util.HashSet subtrahend = new HashSet();
		tailNo = fleetSize.getFleetSizeMembers().keySet();
		iterator = tailNo.iterator();
		while (iterator.hasNext()) {
			String key = (String) iterator.next();
			subtrahend.add(key);
		}
		minuend.removeAll(subtrahend);
		int l = minuend.size();

		Object arr[] = minuend.toArray();

		String ac[] = new String[arr.length];
		for (int i = 0; i < arr.length; i++) {
			ac[i] = (String) arr[i];
		}
		return ac;
	}


	/**
	 *  Compares two different fleet size object. They are the same when all
	 *  attributes are the same.
	 *
	 *@param  fleetSize  Another FleetSize object.
	 *@return            Description of the Return Value
	 */
	public boolean equals(FleetSize fleetSize) {
		return this.fleetSizeName.equals(fleetSize.fleetSizeName)
				 && this.predefinedFleetSize == fleetSize.predefinedFleetSize
				 && this.fleetSizeMembers.equals(fleetSize.fleetSizeMembers);
	}


	/**
	 *  Retrieve the object from the oracle data base.
	 *
	 *@param  fleetSizeName              The name of the fleet to load: either a
	 *      predefined name or a system generated number.
	 *@param  userid
	 *@exception  java.sql.SQLException  This exception can occur, since the class
	 *      loads data from the Oracle data base via JDBC.
	 */
	public void load(String fleetSizeName, String userid)
			 throws java.sql.SQLException {
		logger.debug("FleetSize.load ");
		Statement s = AmdDB.instance().getConnection(userid).createStatement();
		String sqlStmt = "select * from amd_fleet_sizes where upper(fleet_size_name) = '" + fleetSizeName.toUpperCase() + "'";
		logger.info(sqlStmt);
		ResultSet fleetSize = s.executeQuery(sqlStmt);
		if (fleetSize.next()) {
			this.fleetSizeName = fleetSizeName;
			fleetSizeDesc = fleetSize.getString("fleet_size_desc");
			predefinedFleetSize = fleetSize.getString("predefined").equals("Y");
		}
		fleetSize.close();
		s.close();
		fleetSizeMembers = new FleetSizeMembers();
		fleetSizeMembers.load(fleetSizeName, userid);
		if (logger.isDebugEnabled()) {
		    logger.debug("fleetSizeMembers.size()=" +fleetSizeMembers.size()) ;
		}
	}


	/**
	 *  Persist this object to the Oracle data base.
	 *
	 *@param  userid                     The current userid for the session. This
	 *      is required to get the connection object from the AmdDB connection
	 *      pool.
	 *@exception  java.sql.SQLException  This exception can occur, since the class
	 *      saves data to the Oracle data base via JDBC.
	 */
	public void save(String userid) throws java.sql.SQLException {

		logger.debug("FleetSize.save ");

		if (predefinedFleetSize) {
			return;
		}

		Statement s = AmdDB.instance().getConnection(userid).createStatement();
		String sqlStmt;
		sqlStmt = "select * from amd_fleet_sizes where upper(fleet_size_name) = '" + fleetSizeName.toUpperCase() + "'";
		logger.info(sqlStmt);
		ResultSet fleetSize = s.executeQuery(sqlStmt);
		if (fleetSize.next()) {
			fleetSize.close();
			sqlStmt = "update amd_fleet_sizes set fleet_size_desc = '" + fleetSizeDesc + "' where upper(fleet_size_name) = '" + fleetSizeName.toUpperCase() + "'";
			logger.info(sqlStmt);
			s.executeUpdate(sqlStmt);
		} else {
			fleetSize.close();
			if (fleetSizeName != null && fleetSizeName.equals("?")) {
				int nsi_group_sid = 0;
				sqlStmt = "select amd_fleet_sizes_seq.nextval fleet_size_name from dual";
				logger.info(sqlStmt);
				ResultSet nextFleetSizeName = s.executeQuery(sqlStmt);
				if (nextFleetSizeName.next()) {
					fleetSizeName = nextFleetSizeName.getString("fleet_size_name");
				}
				nextFleetSizeName.close();
				fleetSizeDesc = fleetSizeName;
				predefinedFleetSize = false;
			}
			sqlStmt = "insert into amd_fleet_sizes (fleet_size_name, fleet_size_desc, predefined )  values ('" + fleetSizeName + "', '" + fleetSizeDesc + "', '" + (predefinedFleetSize ? "Y" : "N") + "')";
			logger.info(sqlStmt);
			s.executeUpdate(sqlStmt);
		}
		fleetSize.close();
		s.close();
		if (fleetSizeMembers != null) {
			fleetSizeMembers.save(fleetSizeName, userid);
		}
		return;
	}


	/**
	 *  Test this object
	 *
	 *@param  args  -version
	 */
	public static void main(String[] args) {
		org.apache.log4j.BasicConfigurator.configure();

		if (args.length > 0 && args[0].equals("-version")) {
			System.out.println(revision + "\n" +
					author + "\n" +
					workfile);
			System.exit(0);
		}

		AmdDB amd = AmdDB.instance();
		amd.getConnection(args[0], args[1]);
		FleetSize f1 = new FleetSize();
		FleetSize f2 = new FleetSize();
		try {
			f1.load(FleetSize.ALL_AIRCRAFT, args[0]);
			f2.load(FleetSize.USAF, args[0]);
		} catch (Exception e) {
			System.out.println(e.getMessage());
		}
		String removedAC[] = f1.diff(f2);
	}
}

