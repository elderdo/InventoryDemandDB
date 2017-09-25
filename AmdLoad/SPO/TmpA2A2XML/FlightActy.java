import java.sql.* ;
public class FlightActy {
	
	public FlightActy()  {
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
		FlightActy sa = new FlightActy() ;
		AmdConnection amd = AmdConnection.instance() ;
		amd.setIniFile(args[0]) ;
        	Statement s = amd.c.createStatement() ;
        	s.setFetchSize(100) ;
        	ResultSet rs = s.executeQuery("SELECT " 
				+ AmdUtils.tranColumns(1,8,"ORG_FLIGHT_ACTY")
				+ "buno, "
				+ "to_char(causal_date, 'YYYYMMDDHH24MISS') as causal_date, "
				+ "causal_type, "
				+ "causal_value, "
				+ "mdl, "
				+ "code, "
				+ "customer, "
				+ "base_name "
				+ "FROM tmp_a2a_org_flight_acty ") ;

		while (rs.next()) {
			System.out.println("<FLIGHTACTY>") ;
			AmdUtils.tranHeader(rs) ;
			System.out.println("\t<DATA>") ;
			System.out.println("\t\t" + getElement(rs,"buno","BUNO") ) ;
			System.out.println("\t\t" + getElement(rs,"causal_date","CAUSDTE") ) ;
			System.out.println("\t\t" + getElement(rs,"causal_type","CAUSTYPE") ) ;
			System.out.println("\t\t" + getElement(rs,"causal_value","CAUSVAL") ) ;
			System.out.println("\t\t" + getElement(rs,"mdl","MDL") ) ;
			System.out.println("\t\t" + getElement(rs,"code","CODE") ) ;
			System.out.println("\t\t" + getElement(rs,"customer","CUSTOMER") ) ;
			System.out.println("\t\t" + getElement(rs,"base_namne","BASENAME") ) ;
			System.out.println("\t</DATA>") ;
			System.out.println("</FLIGHTACTY>") ;
		}
	}
}
