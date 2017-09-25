import java.sql.* ;
public class PartEff {
	
	public PartEff()  {
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
		PartEff sa = new PartEff() ;
		AmdConnection amd = AmdConnection.instance() ;
		amd.setIniFile(args[0]) ;
        	Statement s = amd.c.createStatement() ;
        	s.setFetchSize(100) ;
        	ResultSet rs = s.executeQuery("SELECT " 
				+ AmdUtils.tranColumns(2,7,"PART_EFFECTIVITY")
				+ AmdUtils.partHeaderColumns
				+ "MDL, "
				+ "SERIES, "
				+ "EFFECTIVITY_TYPE, "
				+ "TRIM(RANGE_FROM) RANGE_FROM, "
				+ "TRIM(RANGE_TO) RANGE_TO, "
				+ "RANGE_FLAG, "
				+ "QPEI, "
				+ "CUSTOMER "
				+ "FROM "
				+ "tmp_a2a_part_effectivity , amd_part_header_v "
				+ "WHERE "
				+ "part_no = ph_part_no ") ;

		while (rs.next()) {
			System.out.println("<PARTEFF>") ;
			AmdUtils.tranHeader(rs) ;
			AmdUtils.partHeader(rs) ;
			System.out.println("\t<DATA>") ;
			System.out.println("\t\t" + getElement(rs,"MDL","MDL") ) ;
			System.out.println("\t\t" + getElement(rs,"SERIES","SERIES") ) ;
			System.out.println("\t\t" + getElement(rs,"EFFECTIVITY_TYPE","EFFTYPE") ) ;
			System.out.println("\t\t" + getElement(rs,"RANGE_FROM","FROM") ) ;
			System.out.println("\t\t" + getElement(rs,"RANGE_TO","TO") ) ;
			System.out.println("\t\t" + getElement(rs,"RANGE_FLAG","FLAG") ) ;
			System.out.println("\t\t" + getElement(rs,"QPEI","QPEI") ) ;
			System.out.println("\t\t" + getElement(rs,"CUSTOMER","CUSTOMER") ) ;
			System.out.println("\t</DATA>") ;
			System.out.println("</PARTEFF>") ;
		}
	}
}
