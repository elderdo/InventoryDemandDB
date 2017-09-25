package Configuration;
import java.sql.SQLException;
/*
 *  $Revision:   1.2  $
 *  $Author:   c970183  $
 *  $Workfile:   WorkingSet.java  $
 *  $Log:   \\www-amssc-01\pds\archives\SDS-AMD\Components-ClientServer\AmdConfig\Configuration\WorkingSet.java-arc  $
/*
/*   Rev 1.2   06 Aug 2002 11:46:04   c970183
/*Latest Version on hs1189
 *  *
 *  *   Rev 1.1   23 May 2002 06:57:56   c970183
 *  *Test Release
 */
import java.util.*;
import org.apache.log4j.Logger;

/**
 *  This class is used to maintain a collection of all the data in memory for
 *  the Config.jsp page during a session. The key
 *
 *@author     Douglas S. Elder
 *@version    1.0
 *@since      06/09/02
 */
public class WorkingSet extends java.util.HashMap {

	Logger logger = Logger.getLogger(WorkingSet.class.getName());
	private static String author = "$Author:   c970183  $";
	private static String revision = "$Revision:   1.2  $";
	private static String workfile = "$Workfile:   WorkingSet.java  $";


	/**
	 *  For a given nsiSid return all the aircraft in its group.
	 *
	 *@param  nsiSid
	 *@return                          A string with the following format:
	 *      p_no-ac_no-tail_no
	 */
	public String[] getAircraft(String nsiSid) {
		if (logger.isDebugEnabled()) {
			logger.debug("WorkingSet.getAircraft(" + nsiSid + ") ");
		}

		RelatedNsn topNsn = this.getItem(nsiSid);
		if (topNsn == null) {
			return null;
		}

		NsiGroup nsiGroup = topNsn.getNsiGroup();
		if (nsiGroup != null) {
			FleetSize fleetSize = nsiGroup.getFleetSize();
			if (fleetSize != null) {
				if (fleetSize.getPredefinedFleetSize()) {
					return null;
				} else {
					FleetSizeMembers fleetSizeMembers = fleetSize.getFleetSizeMembers();
					if (fleetSizeMembers != null) {
						if (logger.isDebugEnabled()) {
							logger.debug("fleetSizeMembers.size()=" + fleetSizeMembers.size());
						}
						String aircraft[] = new String[fleetSizeMembers.size()];
						Set keys = fleetSizeMembers.keySet();
						Iterator iterator = keys.iterator();
						int i = 0;
						while (iterator.hasNext()) {
							FleetSizeMember fleetSizeMember = (FleetSizeMember) fleetSizeMembers.get(iterator.next());
							if (fleetSizeMember != null) {
								Aircraft ac = fleetSizeMember.getAircraft();
								String pNo = ac.getPno();
								String acNo = ac.getAcNo();
								String tailNo = ac.getTailNo();
								aircraft[i++] = pNo + "-" + acNo + "-" + tailNo;
							}
						}
						return aircraft;
					} else {
						return null;
					}
				}
			} else {
				return null;
			}
		} else {
			return null;
		}
	}


	/**
	 *  Gets the author attribute of the WorkingSet object
	 *
	 *@return    The author value
	 */
	public String getAuthor() {
		return author;
	}


	/**
	 *  Each nsn belongs to one group. Each group has one fleet. Only fleets that
	 *  are predefined have a genuine fleet size name: All Aircraft, USAF, or UK.
	 *  The fleets that are user defined have an Oracle sequence number assigned as
	 *  the name.
	 *
	 *@param  nsiSid
	 *@return         If a predefined fleet size exists, it returns the name,
	 *      otherwise it returns a null.
	 */
	public String getFleetSizeName(String nsiSid) {
		RelatedNsn topNsn = this.getItem(nsiSid);
		if (topNsn == null) {
			return null;
		}

		NsiGroup nsiGroup = topNsn.getNsiGroup();
		if (nsiGroup != null) {
			FleetSize fleetSize = nsiGroup.getFleetSize();
			if (fleetSize != null) {
				if (fleetSize.getPredefinedFleetSize()) {
					return fleetSize.getFleetSizeName();
				} else {
					return null;
				}
			} else {
				return null;
			}
		} else {
			return null;
		}

	}


	/**
	 *  Gets the item attribute of the WorkingSet object
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
	 *  Gets the revision attribute of the WorkingSet object
	 *
	 *@return    The revision value
	 */
	public String getRevision() {
		return revision;
	}


	/**
	 *  Gets the workfile attribute of the WorkingSet object
	 *
	 *@return    The workfile value
	 */
	public String getWorkfile() {
		return workfile;
	}


	/**
	 *  Description of the Method
	 *
	 *@param  key                        Description of the Parameter
	 *@param  userid                     Description of the Parameter
	 *@return                            Description of the Return Value
	 * @exception java.sql.SQLException This exception can occur, since the class loads
	 * data from the Oracle data base via JDBC.
	 */
	public RelatedNsn load(String key, String userid)
			 throws java.sql.SQLException {
		if (this.containsKey(key)) {
			return (RelatedNsn) this.get(key);
		}
		if (logger.isDebugEnabled()) {
			logger.debug("WorkingSet.load: key=" + key);
		}
		RelatedNsn topNsn = RelatedNsn.load(key, userid);
		if (topNsn != null) {
			this.put(key, topNsn);
			return topNsn;
		}
		logger.debug("WorkingSet: topNsn is null");
		return null;
	}


	/**
	 *  Since an nsn can move from one group to another during a session, the data
	 *  in memory can get out of sync with the data base. The current top nsn's
	 *  data should, be in sync with the data base. This method reloads all data
	 *  except the current top nsn from the data base.
	 *
	 *@param  curNsiSid                  The nsiSid of the top nsn.
	 *@param  relatedNsns                All the nsn's that are in the group with
	 *      the top nsn.
	 *@param  userid                     The Oracle userid needed to get the
	 *      connection object from the AmdDB connection pool.
	 * @exception java.sql.SQLException This exception can occur, since the class loads
	 * data from the Oracle data base via JDBC.
	 */
	public void refresh(String curNsiSid, RelatedNsns relatedNsns, String userid)
			 throws java.sql.SQLException {
		Set keys = relatedNsns.keySet();
		Iterator iterator = keys.iterator();
		while (iterator.hasNext()) {
			RelatedNsn relatedNsn = (RelatedNsn) relatedNsns.get(iterator.next());
			String nsiSid = relatedNsn.getNsiSid();
			if (!nsiSid.equals(curNsiSid)) {
				if (this.containsKey(relatedNsn.getNsiSid())) {
					refresh(relatedNsn.getNsiSid(), userid);
				}
			}
		}
	}


	/**
	 *  For a given nsiSid, remove it from the working set and re-load it from the
	 *  data base.
	 *
	 *@param  nsiSid
	 *@param  userid                     The Oracle userid needed to get the
	 *      connection object from the AmdDB connection pool.
	 *@return                            the refreshed related nsn.
	 * @exception java.sql.SQLException This exception can occur, since the class loads
	 * data from the Oracle data base via JDBC.
	 */
	protected RelatedNsn refresh(String nsiSid, String userid)
			 throws java.sql.SQLException {
		if (this.containsKey(nsiSid)) {
			this.remove(nsiSid);
		}
		return this.load(nsiSid, userid);
	}


	/**
	 *  The main program for the WorkingSet class
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
