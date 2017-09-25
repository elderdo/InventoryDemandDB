import java.sql.* ;
public class OrderInfo {
	
	public OrderInfo()  {
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
		OrderInfo sa = new OrderInfo() ;
		AmdConnection amd = AmdConnection.instance() ;
		amd.setIniFile(args[0]) ;
        	Statement s = amd.c.createStatement() ;
        	s.setFetchSize(100) ;
        	ResultSet rs = s.executeQuery("SELECT " 
				+ AmdUtils.tranColumns(2,7,"ORDER_INFO")
				+ AmdUtils.partHeaderColumns
				+ "ORDER_NO, "
				+ "SITE_LOCATION, "
				+ "to_char(CREATED_DATE, 'YYYYMMDDHH24MISS') as CREATED_DATE, "
				+ "STATUS "
				+ "FROM tmp_a2a_order_info, amd_part_header_v "
				+ "where part_no = ph_part_no ");
		while (rs.next()) {
			System.out.println("<ORDER>") ;
			AmdUtils.tranHeader(rs) ;
			AmdUtils.partHeader(rs) ;
			System.out.println("\t<DATA>") ;
			System.out.println("\t\t" + getElement(rs,"ORDER_NO","ORDERNO") ) ;
			System.out.println("\t\t" + getElement(rs,"SITE_LOCATION","SITE") ) ;
			System.out.println("\t\t" + getElement(rs,"CREATED_DATE","CREATED") ) ;
			System.out.println("\t\t" + getElement(rs,"STATUS","STATUS") ) ;
			System.out.println("\t</DATA>") ;
			System.out.println("</ORDER>") ;
		}
	}
}
