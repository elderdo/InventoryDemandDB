import java.sql.* ;
import java.io.* ;
/*
 Run a series of sql queries and sends their results to output
 files based on a simple control file, which contains the name 
 of the sql files and its output files
 -- Assumptions: All sql files are located in a .\Queries
 -- directory, all data files are located in a .\Data
 now query dir and data dir passed in
 directory, and the current directory contains this Java Class
 */
public class Query {
    protected ResultSet rs ;

    // Test class
    public static void main(String args[]) {
        if (args.length == 0) {
            System.out.println("Usage: java Query controlFile queryDir dataDir") ;
            System.exit(0) ;
        }
        try {      
            AmdConnection amd = new AmdConnection() ;
            BufferedReader in = new BufferedReader(new FileReader(args[0])) ;            
            String thisLine ;
            while ((thisLine = in.readLine()) != null) {            
                int blank = thisLine.indexOf(" ") ;
                String sql = thisLine.substring(0,blank) ;
                String fileout = thisLine.substring(blank+1) ;
                System.out.print("Processing sql file " + sql + " and creating " + fileout + " ") ;
                System.out.flush() ;
        /*        Query q = new Query(amd, new BuildQuery("..\\queries\\" + sql).theQuery, "..\\data\\" + fileout) ; */
                Query q = new Query(amd, new BuildQuery(args[1] + "/" + sql).theQuery, args[2] + "/" + fileout) ; 
            }
        }
        catch (ClassNotFoundException e) {
            System.out.println(e.getMessage()) ;
        }
        catch (SQLException e) {
            System.out.println(e.getMessage()) ;
        }
        catch (FileNotFoundException e) {
            System.out.println(e.getMessage()) ;
        }
        catch (IOException e) {
            System.out.println(e.getMessage()) ;
        }
    }
    Query(AmdConnection amd, String sql, String fileout) throws SQLException, ClassNotFoundException {
        Statement s = amd.c.createStatement() ;
        s.setFetchSize(100) ;
        rs = s.executeQuery(sql) ;
        ResultSetMetaData meta = rs.getMetaData() ;
        int columns = meta.getColumnCount() ;
        
        try {
            int reccnt = 0 ;
            BufferedWriter out = new BufferedWriter(new FileWriter(fileout)) ;            
            while (rs.next()) {
                for (int i = 1;i < columns+1;i++) {
                    rs.getString(i) ;
                    if (rs.wasNull()) {
                        continue ;
                    }
                    else
                        out.write(rs.getString(i)) ;
                }
                out.newLine() ;
                reccnt++ ;
            }
            rs.close() ;
            s.close() ;
            out.close() ;
            System.out.println("wrote " + reccnt + " records.") ;
        }
        catch (IOException e) {
            System.out.println(e.getMessage()) ;
        }
    }

}
