import java.sql.* ;
public class BackOrder {
	
	public BackOrder()  {
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
		BackOrder sa = new BackOrder() ;
		AmdConnection amd = AmdConnection.instance() ;
		amd.setIniFile(args[0]) ;
        	Statement s = amd.c.createStatement() ;
        	s.setFetchSize(100) ;
        	ResultSet rs = s.executeQuery("SELECT " 
				+ AmdUtils.tranColumns(2,7,"BACKORDER_INFO")
				+ AmdUtils.partHeaderColumns
				+ "SITE_LOCATION, "
				+ "QTY, "
				+ "'General' as BACKORDER_TYPE "
				+ "FROM  "
				+ "amd_part_header_v, tmp_a2a_backorder_info "
				+ "WHERE "
				+ "ph_part_no = part_no "
				+ "and qty is not null ");
		while (rs.next()) {
			System.out.println("<BACKORDER>") ;
			AmdUtils.tranHeader(rs) ;
			AmdUtils.partHeader(rs) ;
			System.out.println("\t<DATA>") ;
			System.out.println("\t\t" + getElement(rs,"SITE_LOCATION","SITE") ) ;
			System.out.println("\t\t" + getElement(rs,"QTY","QTY") ) ;
			System.out.println("\t\t" + getElement(rs,"BACKORDER_TYPE","BOTYPE") ) ;
			System.out.println("\t</DATA>") ;
			System.out.println("</BACKORDER>") ;
		}
	}
}
