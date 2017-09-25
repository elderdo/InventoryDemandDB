import java.sql.* ;
public class LocPartLeadtime {
	
	public LocPartLeadtime()  {
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
		LocPartLeadtime sa = new LocPartLeadtime() ;
		AmdConnection amd = AmdConnection.instance() ;
		amd.setIniFile(args[0]) ;
        	Statement s = amd.c.createStatement() ;
        	s.setFetchSize(100) ;
        	ResultSet rs = s.executeQuery("SELECT " 
				+ AmdUtils.tranColumns(2,7,"LOCATION_PART_LEAD_TIME")
				+ "SITE_LOCATION, "
				+ "LEAD_TIME_TYPE, "
				+ "LEAD_TIME "
				+ "FROM tmp_a2a_loc_part_lead_time, amd_part_header_v "
				+ "where part_no = ph_part_no ") ;

		while (rs.next()) {
			System.out.println("<LPLEADTIME>") ;
			AmdUtils.tranHeader(rs) ;
			System.out.println("\t<DATA>") ;
			System.out.println("\t\t" + getElement(rs,"SITE_LOCATION","SITE") ) ;
			System.out.println("\t\t" + getElement(rs,"LEAD_TIME_TYPE","TYPE") ) ;
			System.out.println("\t\t" + getElement(rs,"LEAD_TIME","TIME") ) ;
			System.out.println("\t</DATA>") ;
			System.out.println("</LPLEADTIME>") ;
		}
	}
}
