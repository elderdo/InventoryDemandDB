import java.io.* ;
/*
 Read an SQL SELECT statement from a file
 */
public class BuildQuery
{
    public String theQuery = new String();
    // Test class
    public static void main(String args[]) {
        BuildQuery bq = new BuildQuery(".\\Queries\\11.sql") ;
        System.out.println(bq.theQuery) ;
        
    }
    BuildQuery(String Filename) {
        try {
            BufferedReader in = new BufferedReader(new FileReader(Filename)) ;
            String thisLine ;
            boolean startedQuery = false ;
            while ((thisLine = in.readLine()) != null) {
                if (startedQuery)                    
                  theQuery += thisLine + " ";
                else
                    if (thisLine.toLowerCase().indexOf("select") > -1) {
                        theQuery += thisLine ;
                        startedQuery = true ;
                    }
            }
            //System.out.println(theQuery) ;
        }
        catch (IOException e) {
            System.out.println(Filename + ": " + e.getMessage()) ;
            System.exit(4) ;
        }
    }
}