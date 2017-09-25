import java.sql.* ;
public class InTransit {
	
	public InTransit()  {
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
		InTransit sa = new InTransit() ;
		AmdConnection amd = AmdConnection.instance() ;
		amd.setIniFile(args[0]) ;
        	Statement s = amd.c.createStatement() ;
        	s.setFetchSize(100) ;
        	ResultSet rs = s.executeQuery("SELECT " 
				+ AmdUtils.tranColumns(2,7,"IN_TRANSIT")
				+ AmdUtils.partHeaderColumns
				+ "SITE_LOCATION, "
				+ "QTY, "
				+ "decode(TYPE, 'Y','General','N','Defective', TYPE) TYPE "
				+ "FROM  "
				+ "tmp_a2a_in_transits , amd_part_header_v "
				+ "WHERE "
				+ "part_no = ph_part_no ");
		while (rs.next()) {
			System.out.println("<INTRANSIT>") ;
			AmdUtils.tranHeader(rs) ;
			AmdUtils.partHeader(rs) ;
			System.out.println("\t<DATA>") ;
			System.out.println("\t\t" + getElement(rs,"SITE_LOCATION","SITE") ) ;
			System.out.println("\t\t" + getElement(rs,"QTY","QTY") ) ;
			System.out.println("\t\t" + getElement(rs,"TYPE","TYPE") ) ;
			System.out.println("\t</DATA>") ;
			System.out.println("</INTRANSIT>") ;
		}
	}
}
