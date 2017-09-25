import java.sql.* ;
public class PartAltRelDel {
	
	public PartAltRelDel()  {
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
		PartAltRelDel sa = new PartAltRelDel() ;
		AmdConnection amd = AmdConnection.instance() ;
		amd.setIniFile(args[0]) ;
        	Statement s = amd.c.createStatement() ;
        	s.setFetchSize(100) ;
        	ResultSet rs = s.executeQuery("SELECT " 
				+ AmdUtils.tranColumns(1,8,"PART_ALT_REL_DEL")
				+ "CAGE_CODE, "
				+ "PART_NO, "
				+ "PRIME_CAGE, "
				+ "PRIME_PART "
				+ "FROM tmp_a2a_part_alt_rel_delete ") ;

		while (rs.next()) {
			System.out.println("<LPLEADTIME>") ;
			AmdUtils.tranHeader(rs) ;
			System.out.println("\t<DATA>") ;
			System.out.println("\t\t" + getElement(rs,"CAGE_CODE","CAGE") ) ;
			System.out.println("\t\t" + getElement(rs,"PART_NO","PART") ) ;
			System.out.println("\t\t" + getElement(rs,"PRIME_CAGE","PCAGE") ) ;
			System.out.println("\t\t" + getElement(rs,"PRIME_PART","PRIME") ) ;
			System.out.println("\t\t" + getElement(rs,"customer","TIME") ) ;
			System.out.println("\t\t" + getElement(rs,"mdl","TIME") ) ;
			System.out.println("\t\t" + getElement(rs,"begin_date","TIME") ) ;
			System.out.println("\t\t" + getElement(rs,"end_date","TIME") ) ;
			System.out.println("\t\t" + getElement(rs,"qty","TIME") ) ;
			System.out.println("\t</DATA>") ;
			System.out.println("</LPLEADTIME>") ;
		}
	}
}
