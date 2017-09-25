package effectivity;

import java.sql.*;
import org.apache.log4j.Logger;

public class DBQuery
{
	private Connection  conn;
	private String      sqlStmt;
	private Statement   s;
	Logger  logr = Logger.getLogger(DBQuery.class.getName());

	public DBQuery()
	{
	}

	public DBQuery(Connection pConn)
	{
		conn = pConn;
	}

	public void setConnection(Connection pConn)
	{
		conn = pConn;
	}

	public void createStatement()
	{
		AmdUtils.displayMsg("createStatement()");
		try
		{
			s = conn.createStatement();
		}
		catch (Exception e)
		{
			AmdUtils.displayMsg("createStatement: exception: " + e);
		}
	}

	public ResultSet execQuery(String pStmt)
	{
		AmdUtils.displayMsg("execQuery()");
		ResultSet   rs;

		try
		{
			logr.debug(pStmt);

			rs = s.executeQuery(pStmt);
			return rs;
		}
		catch (java.sql.SQLException e)
		{
			AmdUtils.displayMsg(DBQuery.class.getName() + ":exception("+e+")");
			return null;
		}
	}

	public int execUpdate(String pStmt)
	{
		int   rc;

		try
		{
			logr.debug(pStmt);
//			s  = conn.createStatement();
			rc = s.executeUpdate(pStmt);
			return rc;
		}
		catch (java.sql.SQLException e)
		{
			AmdUtils.displayMsg(DBQuery.class.getName() + ":exception("+e+")");
			return -1;
		}
	}

	public void closeStatement()
	{
		AmdUtils.displayMsg("closeStatement()");

		if (s != null)
		{
			try
			{
				s.close();
			}
			catch (Exception e)
			{
			}
		}
	}
}
