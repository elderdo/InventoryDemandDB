package Configuration;
import java.io.FileInputStream;
import java.sql.*;
import java.util.Properties;

/**
 *  This class controls access to the Oracle data base.
 *
 *@author     Douglas S. Elder
 *@version    1.0
 *@since      06/11/02
 */
/*
 *  $Revision:   1.1  $
 *  $Author:   c970183  $
 *  $Workfile:   User.java  $
 *  $Log:   \\www-amssc-01\pds\archives\SDS-AMD\Components-ClientServer\AmdConfig\User.java-arc  $
/*
/*   Rev 1.1   06 Aug 2002 11:46:34   c970183
/*Latest Version on hs1189
 *  Author: Douglas S. Elder
 *  Date: 02/28/02
 *  Function: Validate an Oracle user
 */
public class User {

	/**
	 *  Gets set to true if the user's account is locked, otherwise it is false.
	 */
	private boolean accountLocked;

	/**
	 *  The JDBC connection object.
	 */
	private Connection connection;

	/**
	 *  The JDBC url used to connect to Oracle.
	 */
	private String connectionString;

	/**
	 *  Will contain the current directory. This is used to read a run time ini
	 *  file.
	 */
	private String curDirectory = "./";

	/**
	 *  The Oracle data source (host string).
	 */
	private String dataSource;

	/**
	 *  The error text associated with a failed logon.
	 */
	private String error = "";

	/**
	 *  The file name of the run time ini file.
	 */
	private String iniFile = "User.ini";

	/**
	 *  Gets set to true if the user/password combination is not a valid Oracle
	 *  account.
	 */
	private boolean invalidUseridPassword;

	/**
	 *  Set to true when Oracle is down.
	 */
	private boolean oracleIsDown;

	/**
	 *  The user's password.
	 */
	private String password;

	/**
	 *  Set to true when the password has expired.
	 */
	private boolean passwordExpired;

	/**
	 *  Set to true when the password will expire.
	 */
	private boolean passwordWillExpire;

	/**
	 *  The Oracle userid.
	 */
	private String userid;
	private static String author = "$Author:   c970183  $";

	private static String revision = "$Revision:   1.1  $";
	private static String workfile = "$Workfile:   User.java  $";

	/**
	 *  The Oracle return code for an account being locked.
	 */
	private final static int ACCOUNT_LOCKED = 28000;

	/**
	 *  An Oracle return code for an invalid userid and password.
	 */
	private final static int INVALID_USERID_PASSWORD = 1017;

	/**
	 *  An Oracle return code idicating that it is down.
	 */
	private final static int ORACLE_IS_DOWN = 1034;

	/**
	 *  An Oracle return code for an expired password.
	 */
	private final static int PASSWORD_EXPIRED = 28001;

	/**
	 *  An Oracle return code for a password that will expire.
	 */
	private final static int PASSWORD_WILL_EXPIRE = 28002;


	/**
	 *@param  connectionString  The Oralce JDBC url - minus the data source.
	 */
	public void setConnectionString(String connectionString) {
		this.connectionString = connectionString;
	}


	/**
	 *@param  curDirectory  Sets the current directory.
	 */
	public void setCurDirectory(String curDirectory) {
		this.curDirectory = curDirectory;
	}


	/**
	 *@param  dataSource  An Oracle data source string similar to u10damc.
	 */
	public void setDataSource(String dataSource) {
		this.dataSource = dataSource;
	}


	/**
	 *@param  iniFile  The ini file that contains run time parameters such as data
	 *      source.
	 */

	public void setIniFile(String iniFile) {
		this.iniFile = iniFile;
	}


	/**
	 *@param  password  The password associated with the userid
	 */
	public void setPassword(String password) {
		this.password = password;
	}


	/**
	 *@param  userid  An Oracle userid.
	 */
	public void setUserid(String userid) {
		this.userid = userid;
	}


	/**
	 *  An Oracle account can be locked after several login failures.
	 *
	 *@return    True if the user account is locked.
	 */
	public boolean getAccountLocked() {
		return accountLocked;
	}


	/**
	 *  Gets the author attribute of the User object
	 *
	 *@return    The author value
	 */
	public String getAuthor() {
		return author;
	}


	/**
	 *@return    The JDBC connection object, provided isValidUser has returned
	 *      true.
	 */
	public Connection getConnection() {
		return connection;
	}


	/**
	 *@return    The Oralce JDBC url.
	 */
	public String getConnectionString() {
		return connectionString;
	}


	/**
	 *@return    The current directory.
	 */
	public String getCurDirectory() {
		return this.curDirectory;
	}


	/**
	 *  Oracle JDBC takes a data source to indicate what host is being used. For
	 *  example u10damc.
	 *
	 *@return    The dataSource value
	 */
	public String getDataSource() {
		return dataSource;
	}


	/**
	 *  Returns the error text associated with the logon failure.
	 *
	 *@return    The error value
	 */
	public String getError() {
		return error;
	}


	/**
	 *@return    The ini file that contains run time parameters such as data
	 *      source.
	 */
	public String getIniFile() {
		return iniFile;
	}


	/**
	 *  Provided as a public method, since the User.ini may not be found in the
	 *  "./" directory when the application is invoked via a UNC path
	 *  \\hostname\Sharename. Consequently, to make sure the data from the ini
	 *  information gets loaded correctly, the curDirectory can be overriden and
	 *  this method can be invoked again prior to doing user validation.
	 */
	public void getIniFileInfo() {
		Properties p = new Properties();
		try {
			FileInputStream fis = new FileInputStream(curDirectory + iniFile);
			p.load(fis);
			fis.close();
			connectionString = p.getProperty("ConnectionString");
			dataSource = p.getProperty("DataSource");
			userid = p.getProperty("Userid");
			password = p.getProperty("Password");
		} catch (Exception e) {
			// default to development
			connectionString = "jdbc:oracle:thin:@hs1188.lgb.cal.boeing.com:1521:";
			dataSource = "u10damc";
			// production connectionString = "jdbc:oracle:thin:@amssc-ora13.lgb.cal.boeing.com:1913:" ;
			// production dataSource = "u10pamc" ;
			userid = "c970183";
			password = "********";
			// Bad password
		}
	}


	/**
	 *@return    True if the userid and password are invalid.
	 */
	public boolean getInvalidUseridPassword() {
		return invalidUseridPassword;
	}


	/**
	 *@return    True is Oracle is down.
	 */
	public boolean getOracleIsDown() {
		return oracleIsDown;
	}


	/**
	 *@return    The password that was used to perform the login.
	 */
	public String getPassword() {
		return password;
	}


	/**
	 *@return    True if the password expired.
	 */
	public boolean getPasswordExpired() {
		return passwordExpired;
	}


	/**
	 *@return    True if password will expire.
	 */
	public boolean getPasswordWillExpire() {
		return passwordWillExpire;
	}


	/**
	 *  Gets the revision attribute of the User object
	 *
	 *@return    The revision value
	 */
	public String getRevision() {
		return revision;
	}


	/**
	 *@return    The Oracle userid used to login.
	 */
	public String getUserid() {
		return userid;
	}


	/**
	 *  Gets the workfile attribute of the User object
	 *
	 *@return    The workfile value
	 */
	public String getWorkfile() {
		return workfile;
	}


	/**
	 *@return    True if the userid/password is a valid Oracle account.
	 */
	public boolean isValidUser() {
		String dbUrl;
		dbUrl = connectionString + dataSource;

		try {
			// This class will be found in classes12.zip, which
			// is provided with JDeveloper
			Class.forName("oracle.jdbc.driver.OracleDriver");
		} catch (java.lang.ClassNotFoundException e) {
			System.out.println("Class not found: " + e.getMessage());
			System.exit(4);
		}
		try {
			connection = DriverManager.getConnection(dbUrl, userid, password);
			return true;
		} catch (java.sql.SQLException e) {
			connection = null;
			error = e.getMessage();
			if (e.getErrorCode() == ACCOUNT_LOCKED) {
				accountLocked = true;
			} else if (e.getErrorCode() == INVALID_USERID_PASSWORD) {
				invalidUseridPassword = true;
			} else if (e.getErrorCode() == ORACLE_IS_DOWN) {
				oracleIsDown = true;
			} else if (e.getErrorCode() == PASSWORD_EXPIRED) {
				passwordExpired = true;
			} else if (e.getErrorCode() == PASSWORD_WILL_EXPIRE) {
				passwordWillExpire = true;
			}
			return false;
		}
	}


	/**
	 *@param  role  An Oracle role.
	 *@return       True if the user has the specified role.
	 */
	public boolean hasRole(String role) {
		if (connection == null) {
			return false;
		}
		try {
			Statement s = connection.createStatement();
			ResultSet rs = s.executeQuery("Select * from session_roles where role ='" + role.toUpperCase() + "'");
			if (rs.next()) {
				rs.close();
				s.close();
				return true;
			} else {
				rs.close();
				s.close();
				return false;
			}
		} catch (java.sql.SQLException e) {
			return false;
		}
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

		User theUser = new User();
		//theUser.setUserid("b017465") ;
		theUser.setUserid("mickeymouse");
		if (theUser.isValidUser() && theUser.hasRole("DTOS_USER_ROLE")) {
			System.out.println(theUser.getUserid() + " is a good User.");
		} else {
			System.out.println(theUser.getUserid() + " is a bad User.");
		}
	}
}
