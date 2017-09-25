import java.sql.* ;
import java.io.IOException ;
import java.io.File ;
import java.io.FileNotFoundException ;
import java.io.BufferedReader ;
import java.io.FileReader ;

/*   $Author:   zf297a  $
   $Revision:   1.1  $
       $Date:   Dec 12 2006 11:43:02  $
   $Workfile:   AmdUtils.java  $
        $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Components-ClientServer\TmpA2A2Xml\AmdUtils.java-arc  $
/*
/*   Rev 1.1   Dec 12 2006 11:43:02   zf297a
/*Added a filter for SQL comments.  Added PVCS keywords
*/

public class AmdUtils {
	
	private AmdUtils() {} 
	private static String filterComments(BufferedReader reader) throws IOException {
		// System.out.println("getSql") ;
		boolean eof = false ;
		StringBuffer sb = new StringBuffer() ;
		while (!eof) {
			String line = reader.readLine() ;
			// System.out.println(line) ;
			if (line == null) {
				eof = true ;
				continue ;
			}
			int lineComment = line.indexOf("--") ;
		//	System.out.println("lineComment=" + lineComment) ;
			if (lineComment > 0) {
					line = line.substring(0,lineComment-1) ;
				//	System.out.println("line=" + line) ;
			} else if (lineComment == 0) {
					line = "" ;
			}
			int startComment = line.indexOf("/*") ;
			int endComment = line.indexOf("*/") ;
			// System.out.println("startComment=" + startComment + " endComment=" + endComment) ;
			if (startComment >= 0) {
				if (endComment >= 0) {
					line = line.substring(0,startComment-1) +
						line.substring(endComment+1) ;
				} else while(endComment < 0  && !eof) { 
					line = reader.readLine() ;
					// System.out.println("line=" + line) ;
					if (line == null) {
						eof = true ;
						continue ;
					}
					endComment = line.indexOf("*/") ;
					// System.out.println("endComment=" + endComment) ;
					// System.out.println("endComment=" + endComment + " line.length()=" + line.length()) ;
					if (endComment >= 0 && endComment + 2 < line.length()) {
						line = line.substring(endComment+2) ;
					} else {
						line = "" ;
					}
				}
			}
			sb.append(line + " ") ;
		}
		return sb.toString().trim() ;

	}

  /**
  * Fetch the entire contents of a text file, and return it in a String.
  * This style of implementation does not throw Exceptions to the caller.
  *
  * @param aFile is a file which already exists and can be read.
  */
  static public String getSQL(File aFile) {
    //...checks on aFile are elided
    BufferedReader input = null;
    try {
	input = new BufferedReader( new FileReader(aFile) );
	return filterComments(input) ;
    }
    catch (FileNotFoundException ex) {
      ex.printStackTrace();
    }
    catch (IOException ex){
      ex.printStackTrace();
    }
    finally {
      try {
        if (input!= null) {
          //flush and close both "input" and its underlying FileReader
          input.close();
        }
      }
      catch (IOException ex) {
        ex.printStackTrace();
      }
    }
    return "" ;
  }

	public static String tranColumns(int addPriority, int deletePriority,
			String tranType) {
		return "'LBC17' as site_program, "
			+ "'BATCH' as tran_source, "
			+ "decode(action_code,'A','00" + addPriority 
			+ "','C','00" + addPriority + "'," 
			+ "'00" + deletePriority + "') as tran_priority, "
			+ "'" + tranType + "' as tran_type, "
			+ "decode(action_code, 'A', 'I', 'C', 'I', action_code) as tran_action, "
			+ "to_char(sysdate, 'YYYYMMDDHH24MISS') as tran_date, "
			+ "'N' as error_flag, " ;
 
	}

	public static String partHeaderColumns =  "PH_CAGE_CODE, "
				+ "PH_PART_NO, "
				+ "PH_PRIME_CAGE, "
				+ "PH_PRIME_PART, "
				+ "PH_LEAD_TIME, "
				+ "PH_LEAD_TIME_TYPE, " ;

	public static void main(String[] args) {
		System.out.print(AmdUtils.partHeaderColumns) ;
	}
	
	public static void tranHeader(ResultSet rs) throws SQLException {
			System.out.print("<TRANHEADER>") ;
			System.out.print("<SITE>LBC17</SITE>") ;
			System.out.print("<TRANSRC>BATCH</TRANSRC>") ;
			System.out.print("<TRANPRI>" + rs.getString("tran_priority") + "</TRANPRI>") ;
			System.out.print("<TRANTYPE>" + rs.getString("tran_type") + "</TRANTYPE>") ;
			System.out.print("<TRANACT>" + rs.getString("tran_action") + "</TRANACT>") ;
			System.out.print("<TRANDTE>" + rs.getString("tran_date") + "</TRANDTE>") ;
			System.out.print("</TRANHEADER>") ;
	}

	public static void partHeader(ResultSet rs) throws SQLException {
			System.out.print("<PARTHEADER>") ;
			System.out.print("<CAGE>" + rs.getString("PH_CAGE_CODE") + "</CAGE>") ;
			System.out.print("<PART>" + rs.getString("PH_PART_NO") + "</PART>") ;
			System.out.print("<PCAGE>" + rs.getString("PH_PRIME_CAGE") + "</PCAGE>") ;
			System.out.print("<PRIME>" + rs.getString("PH_PRIME_PART") + "</PRIME>") ;
			System.out.print("<LEADTIME>" + rs.getString("PH_LEAD_TIME") + "</LEADTIME>") ;
			System.out.print("<LEADTYPE>" + rs.getString("PH_LEAD_TIME_TYPE") + "</LEADTYPE>") ;
			System.out.print("</PARTHEADER>") ;
	}
}
