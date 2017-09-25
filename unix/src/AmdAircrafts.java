// vim: ts=2:sw=2=sts=2:expandtab:
// AmdAircrafts.java
// Author: Douglas S. Elder
// Date: 11/9/2015
// Desc: Test connecting to Oracle and
// retrieving data from the amd_aircrafts 
// table.
import java.sql.*;

public class AmdAircrafts {
   // JDBC driver name and database URL
   static final String JDBC_DRIVER = "com.mysql.jdbc.Driver";  
   static String DB_URL = "jdbc:oracle:thin:@ussedp767778grp.cs.boeing.com:1521:db0094t1.boeingdb";

   //  Database credentials
   static String USER = "bsrm_loader";
   static String PASS = "badpassword";
   
   public static void usage() {
     System.out.println("Usage: java -cp .;ojdbc14.jar AmdAircraft [ -c connection_string ] [ -u userid ] [ -p password ]") ;
     System.out.println("  For PC: use semicolon for the -cp option to separate directories and jar files") ;
     System.out.println("  For Unix: use colon for the -cp option to separate directories and jar files") ;
     System.out.println("  -c connection_string where the connectring for Oracle is jdbc:oracle.thin:server:port:sid") ;
     System.out.println("  -u userid is the Oracle id") ;
     System.out.println("  -p password is the Oracle id's password") ;
   }

   public static void main(String[] args) {
   Connection conn = null;
   Statement stmt = null;
   // Allow for connection url, user, and password to be entered via the command line
   if ( args.length > 0 ) {
     for ( int i = 0; i < args.length; i++ )     { 
       if ( args[i].equals("-c") ) {
         if (i+1 < args.length) {
           DB_URL = args[i+1] ;
           i++;
         } else {
           usage() ;
           System.exit(4) ;
         }
       } else if (args[i].equals("-u")) {
         if (i+1 < args.length) {
           USER = args[i+1] ;
           i++;
         } else {
           usage() ;
           System.exit(4) ;
         }
       } else if (args[i].equals("-p")) {
         if (i+1 < args.length) {
           PASS = args[i+1] ;
           i++;
         } else {
           usage() ;
           System.exit(4) ;
         }
       } else if (args[i].equals("-h")) {
          usage() ;
          System.exit(0) ;
       }
     }
   }

   try{
      //STEP 2: Register JDBC driver
      Class.forName("oracle.jdbc.driver.OracleDriver");

      //STEP 3: Open a connection
      System.out.println("Connecting to database...");
      conn = DriverManager.getConnection(DB_URL,USER,PASS);

      //STEP 4: Execute a query
      System.out.println("Creating statement...");
      stmt = conn.createStatement();
      String sql;
      sql = "select bun, tail_no,fsn from amd_aircrafts";
      ResultSet rs = stmt.executeQuery(sql);

      //STEP 5: Extract data from result set
      while(rs.next()){
         //Retrieve by column name
         int fsn = rs.getInt("fsn");
         String bun = rs.getString("bun");
         String tail_no = rs.getString("tail_no");

         //Display values
         System.out.print(", FSN: " + fsn);
         System.out.print(", BUN: " + bun);
         System.out.println(", TAIL_NO: " + tail_no);
      }
      //STEP 6: Clean-up environment
      rs.close();
      stmt.close();
      conn.close();
   }catch(SQLException se){
      //Handle errors for JDBC
      System.out.println("DB_URL: " + DB_URL) ;
      System.out.println("USER: " + USER) ;
      System.out.println("PASS: " + PASS) ;
      System.out.println("") ;
      se.printStackTrace();
   }catch(Exception e){
      //Handle errors for Class.forName
      e.printStackTrace();
   }finally{
      //finally block used to close resources
      try{
         if(stmt!=null)
            stmt.close();
      }catch(SQLException se2){
      }// nothing we can do
      try{
         if(conn!=null)
            conn.close();
      }catch(SQLException se){
         se.printStackTrace();
      }//end finally try
   }//end try
   System.out.println("Goodbye!");
}
}
