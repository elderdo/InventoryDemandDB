/*   $Author:   zf297a  $
   $Revision:   1.2  $
       $Date:   Sep 07 2006 08:59:32  $
   $Workfile:   Table2Xml.java  $
        $Log:   I:\Program Files\Merant\vm\win32\bin\pds\archives\SDS-AMD\Components-ClientServer\TmpA2A2Xml\Table2Xml.java.-arc  $
/*
/*   Rev 1.2   Sep 07 2006 08:59:32   zf297a
/*Added PVCS keywords
*/
import java.sql.* ;
import java.util.Properties ;
import java.util.StringTokenizer ;
import java.util.Enumeration ;
import java.util.Stack ;
import java.io.FileInputStream ;
import java.io.IOException ;
import java.io.File ;
public class Table2Xml {
	
	Stack xmlStack ;
	int stackLvl = 0 ;


	boolean debug = false ;
	int debugCnt = 0 ;
	public Table2Xml()  {

		xmlStack = new Stack() ;
	}
	 void emptyTagStack() {
		while (!xmlStack.empty()) {
			System.out.print("</" + (String) xmlStack.pop() + ">") ;
		}
		stackLvl = 0 ;
	}
	
	String getElement(ResultSet rs, String field, String  xmlTag, boolean sanitizeIt) {
		StringTokenizer tags = new StringTokenizer(xmlTag,"/") ;
		StringBuffer tagBuffer = new StringBuffer() ;
		int totalTags = tags.countTokens() ;
		int tagCnt = 0 ;

		while (tags.hasMoreTokens() ) {
			String tag = (String) tags.nextElement() ;
			tagCnt++ ;

			if (debug) System.out.println() ;
			if (debug) System.out.println("tag=" + tag + " tagCnt=" + tagCnt + " stackLvl=" + stackLvl) ;

			if (tagCnt != totalTags) {
				if (xmlStack.empty()) {
					// System.out.println("start stack") ;
					xmlStack.push(tag) ;
					tagBuffer.append("<" + tag + ">") ;
					stackLvl = 1 ;
				} else {
					int tagLvl = xmlStack.search(tag) ;
					if (debug) System.out.println("tag " + tag + " tagLvl=" + tagLvl) ;
					if (tagLvl > 0) {
						stackLvl = tagLvl ; /* tag is already on the stack */
					} else {
						if (stackLvl == tagCnt) {
							String pop = (String) xmlStack.pop() ;
							if (debug) System.out.println("pop " + pop) ;
							xmlStack.push(tag) ;
							if (debug) System.out.println("push " + tag) ;
							tagBuffer.append("</" + pop + ">") ;
							tagBuffer.append("<" + tag + ">") ;
						} else if (stackLvl < tagCnt) {
							xmlStack.push(tag) ;
							tagBuffer.append("<" + tag + ">") ;
							stackLvl++ ;
							if (debug) System.out.println("push stackLvl=" + stackLvl) ;
						} else {
							/*
							System.err.println("Unexpected condition: stackLvL(" 
									+ stackLvl + ") < tagCnt(" + tagCnt + ")" ) ;
							System.exit(4) ;
							*/
						}
					}
				} ;
			} else {
				try {
					String value = rs.getString(field) ;
					if (rs.wasNull()) {
						tagBuffer.append( "<" + tag + "/>") ;
					} else {
						if (sanitizeIt) {
							value = XmlUtil.sanitizeText(value) ;
						}
						tagBuffer.append( "<" + tag + ">" + value +  "</" + tag + ">") ;
					}
				} catch (SQLException e) {
					System.err.println("column name = " + field) ;
					System.err.println(e.getMessage()) ;
					e.printStackTrace() ;
					System.exit(4) ;
				}
			}
		}
		if (debug) System.out.println("returing tagBuffer=" + tagBuffer.toString()) ;
		if (debug) debugCnt++ ;
		if (debug && debugCnt >= 1000) System.exit(4) ;
		return tagBuffer.toString() ;
	}
	public static void main(String[] args) throws SQLException {
		Table2Xml partInfo = new Table2Xml() ;
		Properties col2tag = new Properties() ;
		try {
			col2tag.load(new FileInputStream(args[1] + ".properties")) ;
		} catch (IOException e) {
		}
		Properties sanitizeColumns = new Properties() ;
		try {
			sanitizeColumns.load(new FileInputStream(args[1] + ".sanitize")) ;
		} catch (IOException e) {
		}
		Table2Xml sa = new Table2Xml() ;
		AmdConnection amd = AmdConnection.instance() ;
		amd.setIniFile(args[0]) ;
        	Statement s = amd.c.createStatement() ;
        	s.setFetchSize(100) ;
		ResultSet rs = s.executeQuery(AmdUtils.getSQL(new File( args[1] + ".sql"))) ;
		ResultSetMetaData rsmd = rs.getMetaData() ;
		int numberOfColumns = rsmd.getColumnCount() ;
		while (rs.next()) {
			for (int i = 1;i <= numberOfColumns; i++) {
				String column_name = rsmd.getColumnName(i) ;
				String xmlTags = col2tag.getProperty(column_name) ;
				if (xmlTags != null) {
					System.out.print(partInfo.getElement(rs, column_name, xmlTags, sanitizeColumns.getProperty(column_name) != null) ) ;
				}
			}
			partInfo.emptyTagStack() ;
			System.out.println() ;
		}
	}
}

