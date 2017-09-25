import java.sql.* ;
public class OrgDep {
	
	public OrgDep()  {
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
		OrgDep sa = new OrgDep() ;
		AmdConnection amd = AmdConnection.instance() ;
		amd.setIniFile(args[0]) ;
        	Statement s = amd.c.createStatement() ;
        	s.setFetchSize(100) ;
        	ResultSet rs = s.executeQuery("SELECT " 
				+ AmdUtils.tranColumns(1,8,"ORG_DEPLOYMENT")
				+ "upper(buno) buno, "
				+ "code, "
				+ "base_name, "
				+ "customer, "
				+ "mdl, "
				+ "to_char(begin_date, 'YYYYMMDDHH24MISS') as begin_date, "
				+ "to_char(end_date, 'YYYYMMDDHH24MISS') as end_date, "
				+ "qty "
				+ "FROM tmp_a2a_org_deployment ") ;

		while (rs.next()) {
			System.out.println("<ORGDEP>") ;
			AmdUtils.tranHeader(rs) ;
			System.out.println("\t<DATA>") ;
			System.out.println("\t\t" + getElement(rs,"buno","BUNO") ) ;
			System.out.println("\t\t" + getElement(rs,"code","CODE") ) ;
			System.out.println("\t\t" + getElement(rs,"base_name","BASE") ) ;
			System.out.println("\t\t" + getElement(rs,"customer","CUSTOMER") ) ;
			System.out.println("\t\t" + getElement(rs,"mdl","MDL") ) ;
			System.out.println("\t\t" + getElement(rs,"begin_date","BEGDTE") ) ;
			System.out.println("\t\t" + getElement(rs,"end_date","ENDDTE") ) ;
			System.out.println("\t\t" + getElement(rs,"qty","QTY") ) ;
			System.out.println("\t</DATA>") ;
			System.out.println("</ORGDEP>") ;
		}
	}
}
