import java.sql.* ;
public class PartPricing {
	
	public PartPricing()  {
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
		PartPricing sa = new PartPricing() ;
		AmdConnection amd = AmdConnection.instance() ;
		amd.setIniFile(args[0]) ;
        	Statement s = amd.c.createStatement() ;
        	s.setFetchSize(100) ;
        	ResultSet rs = s.executeQuery("SELECT " 
				+ AmdUtils.tranColumns(2,7,"PART_PRICING")
				+ AmdUtils.partHeaderColumns
				+ "SOURCE_SYSTEM, "
				+ "PRICE_FISCAL_YEAR, "
				+ "PRICE_TYPE, "
				+ "PRICE, "
				+ "to_char(PRICE_DATE,'YYYYMMDDHH24MISS') as PRICE_DATE "
				+ "FROM tmp_a2a_part_pricing, amd_part_header_v "
				+ "where part_no = ph_part_no ");
		while (rs.next()) {
			System.out.println("<PARTPRICE>") ;
			AmdUtils.tranHeader(rs) ;
			AmdUtils.partHeader(rs) ;
			System.out.println("\t<DATA>") ;
			System.out.println("\t\t<SRCSYS>" + rs.getString("SOURCE_SYSTEM") + "</SRCSYS>") ;
			System.out.println("\t\t" + getElement(rs,"PRICE_FISCAL_YEAR","FISCAL") ) ;
			System.out.println("\t\t" + getElement(rs,"PRICE_TYPE","TYPE") ) ;
			System.out.println("\t\t" + getElement(rs,"PRICE","PRICE") ) ;
			System.out.println("\t\t" + getElement(rs,"PRICE_DATE","DATE") ) ;
			System.out.println("\t</DATA>") ;
			System.out.println("</PARTPRICE>") ;
		}
	}
}
