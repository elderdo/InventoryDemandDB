import java.sql.* ;
public class FlightActyForecast {
	
	public FlightActyForecast()  {
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
		FlightActyForecast sa = new FlightActyForecast() ;
		AmdConnection amd = AmdConnection.instance() ;
		amd.setIniFile(args[0]) ;
        	Statement s = amd.c.createStatement() ;
        	s.setFetchSize(100) ;
        	ResultSet rs = s.executeQuery("SELECT " 
				+ AmdUtils.tranColumns(1,8,"ORG_FLIGHT_ACTY_FORECAST")
				+ "upper(buno) buno, "
				+ "mdl, "
				+ "customer, "
				+ "causal_type, "
				+ "to_char(period, 'YYYYMMDDHH24MISS') as period, "
				+ "causal_value, "
				+ "base_name "
				+ "FROM tmp_a2a_org_flight_acty_frecst ") ;

		while (rs.next()) {
			System.out.println("<FLIGHTACTYFORECAST>") ;
			AmdUtils.tranHeader(rs) ;
			System.out.println("\t<DATA>") ;
			System.out.println("\t\t" + getElement(rs,"buno","BUNO") ) ;
			System.out.println("\t\t" + getElement(rs,"mdl","MDL") ) ;
			System.out.println("\t\t" + getElement(rs,"customer","CUSTOMER") ) ;
			System.out.println("\t\t" + getElement(rs,"causal_type","CAUSTYP") ) ;
			System.out.println("\t\t" + getElement(rs,"period","PERIOD") ) ;
			System.out.println("\t\t" + getElement(rs,"causal_value","CAUSVAL") ) ;
			System.out.println("\t\t" + getElement(rs,"base_name","BASENAME") ) ;
			System.out.println("\t</DATA>") ;
			System.out.println("</FLIGHTACTYFORECAST>") ;
		}
	}
}
