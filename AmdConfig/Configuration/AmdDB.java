package Configuration;
/*
 *  $Revision:   1.2  $
 *  $Author:   c970183  $
 *  $Workfile:   AmdDB.java  $
 *  $Log:   \\www-amssc-01\pds\archives\SDS-AMD\Components-ClientServer\AmdConfig\Configuration\AmdDB.java-arc  $
/*
/*   Rev 1.2   06 Aug 2002 11:46:26   c970183
/*Latest Version on hs1189
 *  *
 *  *   Rev 1.1   23 May 2002 06:57:48   c970183
 *  *Test Release
 */
import java.sql.*;
import java.util.HashMap;

/**
 * This class mananges a JDBC connection pool for Oracle. This class uses a
 *  Singleton Pattern.
 * 
 * @author Douglas S. Elder
 * @version 1.0
 * @since 06/20/02
 */
public class AmdDB {

	/**
	 *  A hash table used manage the connection pool.
	 */
	private HashMap connectionPool;

	/**
	 *  The JDBC url used to create all the connection objects with the
	 *  getConnection(userid, password) method.
	 */
	private String connectionString;

	/**
	 *  The Oracle data source: for example u10damc. This is used to dynamically
	 *  create a connection with the getConnection(userid, password) mehtod.
	 */
	private String dataSource;

	/**
	 *  Contains a message if the Oracle JDBC class driver was not found. The
	 *  CLASSPATH must be set to the jar or zip file containing this class.
	 */
	private String error;

	/**
	 *  The PVCS author
	 */
	private static String author = "$Author:   c970183  $";

	/**
	 *  This is a Singleton Pattern class. This variable contains the only instance
	 *  of the class.
	 */
	private static AmdDB instance_ = null ;
	/**
	 *  The PVCS revision
	 */

	private static String revision = "$Revision:   1.2  $";

	/**
	 *  The PVCS workfile
	 */
	private static String workfile = "$Workfile:   AmdDB.java  $";


	/**
	 *  This method is protected, since the class is a Singleton. It sets the
	 *  datasource property to u10damc. This property can be overriden using the
	 *  setDataSource method.
	 */
	protected AmdDB() {
		dataSource = "u10damc";
		connectionString = "jdbc:oracle:thin:@hs1188.lgb.cal.boeing.com:1521:";
		connectionPool = new HashMap();
	}


	/**
	 * Adds a connection to the connection pool.
	 * 
	 * @param conn The connection to be added to the connection pool.
	 * @param userid The userid that will be used as the unique KEY to retrieve
	 *      the connection from the connection pool.
	 */
	public void setConnection(Connection conn, String userid) {
		if (!connectionPool.containsKey(userid)) {
			connectionPool.put(userid, conn);
		}
	}


	/**
	 *  Set the JDBC connection string (URL) used to create all the connection
	 *  objects in the connection pool.
	 *
	 *@param  connectionString  A valid JDBC Oracle connection string - minus the
	 *      data source, which can be set with the setDataSource method.
	 */
	public void setConnectionString(String connectionString) {
		this.connectionString = connectionString;
	}


	/**
	 *  Sets the Oracle data source to be used for all Oracle connections.
	 *
	 *@param  dataSource  The Oracle data source to be used for all connection
	 *      object: for example u10damc.
	 */
	public void setDataSource(String dataSource) {
		this.dataSource = dataSource;
	}


	/**
	 *  Gets the read only PVCS Author
	 *
	 *@return    The PVCS Author
	 */
	public String getAuthor() {
		return author;
	}


	/**
	 * For a given KEY, retrieve a connection from the connection pool.
	 * 
	 * @param userid The userid (KEY) that was used to add the connection to the
	 *      connection pool
	 * @return The connection object associated with this userid.
	 */
	public Connection getConnection(String userid) {
		if (connectionPool.containsKey(userid)) {
			return (Connection) connectionPool.get(userid);
		} else {
			return null;
		}
	}


	/**
	 *  Add a new connection to the connection pool for the given userid (KEY) and
	 *  password. Then return the connection.
	 *
	 *@param  userid    A valid Oracle userid: this will be used as the key for the
	 *      connection pool.
	 *@param  password  A valid Oracle password associated with the userid.
	 *@return           A JDBC connection object.
	 */
	public Connection getConnection(String userid, String password) {
		String dbUrl;
		dbUrl = connectionString + dataSource;

		try {
			Class.forName("oracle.jdbc.driver.OracleDriver");
		} catch (java.lang.ClassNotFoundException e) {
			error = "Class not found: " + e.getMessage();
			return null;
		}
		try {
			Connection conn;
			conn = DriverManager.getConnection(dbUrl, userid, password);
			if (!connectionPool.containsKey(userid)) {
				connectionPool.put(userid, conn);
			}
			return conn;
		} catch (java.sql.SQLException e) {
			return null;
		}
	}


	/**
	 *  This returns the JDBC connection string used to create all the connections
	 *  in the connection pool.
	 *
	 *@return    A JDBC connection string (URL).
	 */
	public String getConnectionString() {
		return connectionString;
	}


	/**
	 *  Get the current Oracle data source used to dynamically create a connection
	 *  in the connection pool via the getConnection(userid, password) method.
	 *
	 *@return    The Oracle data source used for all the connection objects.
	 */
	public String getDataSource() {
		return dataSource;
	}


	/**
	 *  Returns a message associated with not finding the Oracle JDBC class driver.
	 *
	 *@return    A string containing a message indicating that the Oracle JDBC
	 *      class driver was not found.
	 */
	public String getError() {
		return error;
	}


	/**
	 *  Returns the number of connections that are in the connection pool.
	 *
	 *@return    an int containing the number of connections in the connection
	 *      pool.
	 */
	public int getNumberOfConnections() {
		return connectionPool.size();
	}


	/**
	 *  Gets the read only current PVCS revision for this file.
	 *
	 *@return    The PVCS Revison.
	 */
	public String getRevision() {
		return revision;
	}


	/**
	 *  Gets the read only PVCS workfile.
	 *
	 *@return    The PVCS workfile.
	 */
	public String getWorkfile() {
		return workfile;
	}


	/**
	 *  Use this method to see if the Oracle JDBC driver class could not be found.
	 *
	 *@return    true if the Oracle JDBC driver class was not found. Make sure the
	 *      CLASSPATH points the the jar file for the Oracle JDBC driver.
	 */
	public boolean isError() {
		return (error != null);
	}


	/**
	 *  This is a typical implementation of a Singleton Pattern.
	 *
	 *@return    The only instance of this class.
	 */
	public static synchronized AmdDB instance() {
	    if (instance_ == null) {
	        instance_ = new AmdDB() ;
	    }
		return instance_;
	}
	
	/**
	 *  For the given userid remove the connection
	 *  from the connection pool.
	 */
	public void remove(String userid)  {
	    if (connectionPool.containsKey(userid)) {
	        Connection conn = this.getConnection(userid) ;
	        connectionPool.remove(userid) ;
	        try {
	            conn.close() ;
	        } catch (Exception e) {
	        } finally {
	            conn = null ;
	        }
        }	        
	}


	/**
	 *  This is used to test the AmdDB class.
	 *
	 *@param  args  OracleUserid OraclePassword
	 */
	public static void main(String args[]) {

		if (args.length > 0 && args[0].equals("-version")) {
			System.out.println(revision + "\n" +
					author + "\n" +
					workfile);
			System.exit(0);
		}

		AmdDB amd = AmdDB.instance();
		Connection conn = amd.getConnection(args[0], args[1]);
		if (amd.isError()) {
			System.out.println(amd.getError());
		} else {
			System.out.println("Connection made to AMDD.");
		}
	}
}
