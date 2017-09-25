import java.sql.* ;
import java.io.* ;
import java.util.Properties ;
/*   $Author:   zf297a  $
   $Revision:   1.2  $
       $Date:   Dec 12 2006 11:41:34  $
   $Workfile:   AmdConnection.java  $
        $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Components-ClientServer\TmpA2A2Xml\AmdConnection.java-arc  $
/*
/*   Rev 1.2   Dec 12 2006 11:41:34   zf297a
/*Get the jdbc driver name from a properties file + default to the Oracle jdbc driver.
/*
/*   Rev 1.1   Nov 11 2005 11:36:02   zf297a
/*Changed the getConnection method to use a properties file which can contain instructions to use encryption.
   
      Rev 1.4   17 Sep 2002 07:47:38   c970183
   Accepts an ini file containing the connection string, userid, and password via a setIniFile method
   
      Rev 1.3   26 Aug 2002 11:08:44   c970183
   Added PVCS keywords
   
  */

public class AmdConnection
{
        static private AmdConnection instance_ = new AmdConnection() ; 
        public Connection c  ;
        
        private Properties p        = new Properties();
        private String iniFile ;
        
        public void setIniFile(String iniFile) {
            String dbUrl = "" ;
	    String driverName = "oracle.jdbc.driver.OracleDriver" ;
            String uid = "";
            String pwd = "" ;
            this.iniFile = iniFile ;

            if (iniFile != null && !iniFile.equals("")) {
                File f = new File(iniFile) ;
                if (!f.exists()) {
                    System.out.println(f + " does not exist") ;
                    System.exit(4) ;
                }
                try {
                    FileInputStream fis = new FileInputStream(f);
                    p.load(fis);
                    fis.close();
                    driverName = p.getProperty("DriverName", driverName) ;
                    dbUrl = p.getProperty("ConnectionString") ;
                    uid = p.getProperty("UID") ;
                    pwd = p.getProperty("PWD") ;
		    p.setProperty("user",uid) ; // use Oracle's property names
		    p.setProperty("password",pwd) ; // use Oracle's property names
                } catch (Exception e) {
                    System.out.println("Unable to process file: " + iniFile) ;
                    System.out.println(e.getMessage()) ;
                    System.exit(4) ;
                }            

                try {
                    Class.forName(driverName) ;
                }
                catch (java.lang.ClassNotFoundException e) {
                    System.out.println(e.getMessage()) ;
                    System.exit(4) ;
                }
                try {
                    c = DriverManager.getConnection(dbUrl, p) ;
                }
                catch (java.sql.SQLException e) {
                    System.out.println(e.getMessage()) ;
                    System.exit(4) ;
                }
            } else {
                System.out.println("Invalid ini file.") ;
                System.exit(4) ;                
            }
        }
        
        public  String getIniFile() {
            return iniFile ;
        }

        private AmdConnection() {
        }
        
        static public AmdConnection instance() {
                return instance_ ;
        }

}
