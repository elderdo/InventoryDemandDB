import java.sql.* ;
public class PartLeadTime {
	
	public PartLeadTime()  {
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
		PartLeadTime sa = new PartLeadTime() ;
		AmdConnection amd = AmdConnection.instance() ;
		amd.setIniFile(args[0]) ;
        	Statement s = amd.c.createStatement() ;
        	s.setFetchSize(100) ;
        	ResultSet rs = s.executeQuery("SELECT " 
				+ AmdUtils.tranColumns(2,7,"PART_LEAD_TIME")
				+ AmdUtils.partHeaderColumns
				+ "SOURCE_SYSTEM, "
				+ "LEAD_TIME_TYPE, "
				+ "LEAD_TIME "
				+ "FROM tmp_a2a_part_lead_time, amd_part_header_v "
				+ "where part_no = ph_part_no ");
		while (rs.next()) {
			System.out.println("<PARTLEAD>") ;
			AmdUtils.tranHeader(rs) ;
			AmdUtils.partHeader(rs) ;
			System.out.println("\t<DATA>") ;
			System.out.println("\t\t<SRCSYS>" + rs.getString("SOURCE_SYSTEM") + "</SRCSYS>") ;
			System.out.println("\t\t" + getElement(rs,"LEAD_TIME_TYPE","LEADTYPE") ) ;
			System.out.println("\t\t" + getElement(rs,"LEAD_TIME","LEADTIME") ) ;
			System.out.println("\t</DATA>") ;
			System.out.println("</PARTLEAD>") ;
		}
	}
}
