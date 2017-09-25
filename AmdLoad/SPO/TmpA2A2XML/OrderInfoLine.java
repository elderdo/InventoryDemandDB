import java.sql.* ;
public class OrderInfoLine {
	
	public OrderInfoLine()  {
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
		OrderInfoLine sa = new OrderInfoLine() ;
		AmdConnection amd = AmdConnection.instance() ;
		amd.setIniFile(args[0]) ;
        	Statement s = amd.c.createStatement() ;
        	s.setFetchSize(100) ;
        	ResultSet rs = s.executeQuery("SELECT " 
				+ AmdUtils.tranColumns(1,8,"ORDER_INFO_LINE")
				+ AmdUtils.partHeaderColumns
				+ "ORDER_NO, "
				+ "SITE_LOCATION, "
				+ "to_char(CREATED_DATE, 'YYYYMMDDHH24MISS') as CREATED_DATE, "
				+ "STATUS, "
				+ "LINE, "
				+ "QTY_ORDERED, "
				+ "QTY_RECEIVED "
				+ "FROM tmp_a2a_order_info_line, amd_part_header_v "
				+ "where part_no = ph_part_no ");
		while (rs.next()) {
			System.out.println("<ORDERLINE>") ;
			AmdUtils.tranHeader(rs) ;
			AmdUtils.partHeader(rs) ;
			System.out.println("\t<DATA>") ;
			System.out.println("\t\t" + getElement(rs,"ORDER_NO","ORDERNO") ) ;
			System.out.println("\t\t" + getElement(rs,"SITE_LOCATION","SITE") ) ;
			System.out.println("\t\t" + getElement(rs,"CREATED_DATE","CREATED") ) ;
			System.out.println("\t\t" + getElement(rs,"STATUS","STATUS") ) ;
			System.out.println("\t\t" + getElement(rs,"LINE","LINE") ) ;
			System.out.println("\t\t" + getElement(rs,"QTY_ORDERED","QTYORDERED") ) ;
			System.out.println("\t\t" + getElement(rs,"QTY_RECEIVED","QTYREC") ) ;
			System.out.println("\t</DATA>") ;
			System.out.println("</ORDERLINE>") ;
		}
	}
}
