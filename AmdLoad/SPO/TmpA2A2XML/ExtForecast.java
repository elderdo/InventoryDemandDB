import java.sql.* ;
public class ExtForecast {
	
	public ExtForecast()  {
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
		ExtForecast sa = new ExtForecast() ;
		AmdConnection amd = AmdConnection.instance() ;
		amd.setIniFile(args[0]) ;
        	Statement s = amd.c.createStatement() ;
        	s.setFetchSize(100) ;
        	ResultSet rs = s.executeQuery("SELECT " 
				+ AmdUtils.tranColumns(2,7,"EXT_FORECAST")
				+ AmdUtils.partHeaderColumns
				+ "LOCATION, "
				+ "DEMAND_FORECAST_TYPE, "
				+ "to_char(period, 'YYYYMMDDHH24MISS') as period, "
				+ "QUANTITY "
				+ "FROM tmp_a2a_ext_forecast, amd_part_header_v "
				+ "where part_no = ph_part_no ") ;

		while (rs.next()) {
			System.out.println("<EXTFORECAST>") ;
			AmdUtils.tranHeader(rs) ;
			AmdUtils.partHeader(rs) ;
			System.out.println("\t<DATA>") ;
			System.out.println("\t\t" + getElement(rs,"LOCATION","LOCATION") ) ;
			System.out.println("\t\t" + getElement(rs,"DEMAND_FORECAST_TYPE","FCSTTYPE") ) ;
			System.out.println("\t\t" + getElement(rs,"period","PERIOD") ) ;
			System.out.println("\t\t" + getElement(rs,"QUANTITY","QTY") ) ;
			System.out.println("\t</DATA>") ;
			System.out.println("</EXTFORECAST>") ;
		}
	}
}
