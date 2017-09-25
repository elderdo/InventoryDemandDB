import java.sql.* ;
import java.io.* ;
import java.util.Properties ;

public class AmdConnection
{
        public Connection c ;
        private Properties p        = new Properties();

        public AmdConnection() throws SQLException, ClassNotFoundException {
            // String dbUrl = "jdbc:odbc:amd" ;
            String dbUrl ;
            String uid ;
            String pwd ;
            try {
                FileInputStream fis = new FileInputStream("WindowAlgo.ini");
                p.load(fis);
                fis.close();
                dbUrl = p.getProperty("ConnectionString") ;
                uid = p.getProperty("UID") ;
                pwd = p.getProperty("PWD") ;
            }
            catch (Exception e) {
                dbUrl = "jdbc:oracle:thin:@hs1053.lgb.cal.boeing.com:1521:dev3" ;
                uid = "amd_owner" ;
                pwd = "sdsproject" ; 
            }            
            // String dbUrl = "jdbc:oracle:thin:@hs1053.lgb.cal.boeing.com:1521:dev3" ;
            // Class.forName("sun.jdbc.odbc.JdbcOdbcDriver") ;
            Class.forName("oracle.jdbc.driver.OracleDriver") ;
            c = DriverManager.getConnection(dbUrl, uid, pwd) ;
        }

}