import java.sql.* ;
public class InvInfo {
	
	public InvInfo()  {
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
		InvInfo sa = new InvInfo() ;
		AmdConnection amd = AmdConnection.instance() ;
		amd.setIniFile(args[0]) ;
        	Statement s = amd.c.createStatement() ;
        	s.setFetchSize(100) ;
        	ResultSet rs = s.executeQuery("SELECT " 
				+ AmdUtils.tranColumns(2,7,"INV_INFO")
				+ AmdUtils.partHeaderColumns
				+ "site_location, "
				+ "qty_on_hand, "
				+ "reorder_point, "
				+ "stock_level "
				+ "FROM tmp_a2a_inv_info, amd_part_header_v "
				+ "where part_no = ph_part_no ");
		while (rs.next()) {
			System.out.println("<INV>") ;
			AmdUtils.tranHeader(rs) ;
			AmdUtils.partHeader(rs) ;
			System.out.println("\t<DATA>") ;
			System.out.println("\t\t" + getElement(rs,"site_location","SITE") ) ;
			System.out.println("\t\t" + getElement(rs,"qty_on_hand","QTY") ) ;
			System.out.println("\t\t" + getElement(rs,"reorder_point","ROP") ) ;
			System.out.println("\t\t" + getElement(rs,"stock_level","SL") ) ;
			System.out.println("\t</DATA>") ;
			System.out.println("</INV>") ;
		}
	}
}
