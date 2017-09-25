import java.sql.* ;
public class DemandInfo {
	
	public DemandInfo()  {
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
		DemandInfo sa = new DemandInfo() ;
		AmdConnection amd = AmdConnection.instance() ;
		amd.setIniFile(args[0]) ;
        	Statement s = amd.c.createStatement() ;
        	s.setFetchSize(100) ;
        	ResultSet rs = s.executeQuery("SELECT " 
				+ AmdUtils.tranColumns(2,7,"DEMAND_INFO")
				+ AmdUtils.partHeaderColumns
				+ "site_location, "
				+ "doc_no,  "
				+ "to_char(demand_date, 'YYYYMMDDHH24MISS') as demand_date, "
				+ "qty,  "
				+ "status, "
				+ "demand_level, "
				+ "demand_type, "
				+ "buno, "
				+ "demand_field01, "
				+ "demand_field02, "
				+ "demand_field03, "
				+ "demand_field04, "
				+ "demand_field05, "
				+ "pass_to_spo "
				+ "FROM tmp_a2a_demand_info, amd_part_header_v "
				+ "where part_no = ph_part_no ") ;

		while (rs.next()) {
			System.out.println("<DEMAND>") ;
			AmdUtils.tranHeader(rs) ;
			AmdUtils.partHeader(rs) ;
			System.out.println("\t<DATA>") ;
			System.out.println("\t\t" + getElement(rs,"site_location","SITE") ) ;
			System.out.println("\t\t" + getElement(rs,"doc_no","DOCNO") ) ;
			System.out.println("\t\t" + getElement(rs,"demand_date","DATE") ) ;
			System.out.println("\t\t" + getElement(rs,"qty","QTY") ) ;
			System.out.println("\t\t" + getElement(rs,"status","STATUS") ) ;
			System.out.println("\t\t" + getElement(rs,"demand_level","LEVEL") ) ;
			System.out.println("\t\t" + getElement(rs,"demand_type","TYPE") ) ;
			System.out.println("\t\t" + getElement(rs,"buno","BUNO") ) ;
			System.out.println("\t\t" + getElement(rs,"demand_field01","DEMAND01") ) ;
			System.out.println("\t\t" + getElement(rs,"demand_field02","DEMAND02") ) ;
			System.out.println("\t\t" + getElement(rs,"demand_field03","DEMAND03") ) ;
			System.out.println("\t\t" + getElement(rs,"demand_field04","DEMAND04") ) ;
			System.out.println("\t\t" + getElement(rs,"demand_field05","DEMAND05") ) ;
			System.out.println("\t\t" + getElement(rs,"pass_to_spo","PASS") ) ;
			System.out.println("\t</DATA>") ;
			System.out.println("</DEMAND>") ;
		}
	}
}
