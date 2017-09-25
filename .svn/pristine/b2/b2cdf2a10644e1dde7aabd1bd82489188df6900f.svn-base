import java.sql.* ;
public class RepairInfo {
	
	public RepairInfo()  {
	}
	static String getElement(ResultSet rs, String field, String xmlTag) {
		try {
			String value = rs.getString(field) ;
			if (rs.wasNull()) {
				return "<" + xmlTag + "/>" ;
			} else {
				return "<" + xmlTag + ">" + value +  "</" + xmlTag + ">" ;
			}
		} catch (SQLException e) {
			System.out.println(e.getMessage()) ;
			e.printStackTrace() ;
		}
		return "" ;
	}
	public static void main(String[] args) throws SQLException {
		RepairInfo sa = new RepairInfo() ;
		AmdConnection amd = AmdConnection.instance() ;
		amd.setIniFile(args[0]) ;
        	Statement s = amd.c.createStatement() ;
        	s.setFetchSize(100) ;
        	ResultSet rs = s.executeQuery("SELECT " 
				+ AmdUtils.tranColumns(2,7,"REPAIR_INFO")
				+ AmdUtils.partHeaderColumns
				+ "SITE_LOCATION, "
				+ "DOC_NO, "
				+ "to_char(REPAIR_DATE,'YYYYMMDDHH24MISS') as REPAIR_DATE, "
				+ "STATUS, "
				+ "to_char(EXPECTED_COMPLETION_DATE,'YYYYMMDDHH24MISS') as EXPECTED_COMPLETION_DATE, "
				+ "QUANTITY "
				+ "FROM tmp_a2a_repair_info , amd_part_header_v "
				+ "WHERE "
				+ "part_no = ph_part_no ");
		while (rs.next()) {
			System.out.println("<REPAIR>") ;
			AmdUtils.tranHeader(rs) ;
			AmdUtils.partHeader(rs) ;
			System.out.println("\t<DATA>") ;
			System.out.println("\t\t" + getElement(rs,"SITE_LOCATION","SITE") ) ;
			System.out.println("\t\t" + getElement(rs,"DOC_NO","DOCNO") ) ;
			System.out.println("\t\t" + getElement(rs,"REPAIR_DATE","REPDTE") ) ;
			System.out.println("\t\t" + getElement(rs,"STATUS","STATUS") ) ;
			System.out.println("\t\t" + getElement(rs,"EXPECTED_COMPLETION_DATE","ECDTE") ) ;
			System.out.println("\t\t" + getElement(rs,"QUANTITY","QTY") ) ;
			System.out.println("\t</DATA>") ;
			System.out.println("</REPAIR>") ;
		}
	}
}
