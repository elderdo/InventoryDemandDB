import java.sql.* ;
public class SiteAsset {
	
	public SiteAsset()  {
	}
	public static void main(String[] args) throws SQLException {
		SiteAsset sa = new SiteAsset() ;
		AmdConnection amd = AmdConnection.instance() ;
		amd.setIniFile(args[0]) ;
        	Statement s = amd.c.createStatement() ;
        	s.setFetchSize(100) ;

        	ResultSet rs = s.executeQuery("SELECT 'LBC17' as site_program, "
				+ "'BATCH' as tran_source,"
				+ "decode(action_code,'A','003','C','003','006') as tran_priority, "
				+ "'SITE_RESP_ASSET_MGR' as tran_type, "
				+ "decode(action_code, 'A', 'I', 'C', 'I', action_code) as tran_action, "
				+ "to_char(sysdate, 'YYYYMMDDHH24MISS') as tran_date, "
				+ "'N' as error_flag, "
				+ "SITE_RESP_ASSET_MGR, "
				+ "replace(TOOL_LOGON_ID,';','') TOOL_LOGON_ID "
				+ "FROM tmp_a2a_site_resp_asset_mgr");
		while (rs.next()) {
			System.out.println("<SITEASSET>") ;
			AmdUtils.tranHeader(rs) ;
			System.out.println("\t<DATA>") ;
			System.out.println("\t\t<ASSETMGR>" + rs.getString("SITE_RESP_ASSET_MGR") + "</ASSETMGR>") ;
			System.out.println("\t\t<LOGONID>" + rs.getString("TOOL_LOGON_ID") + "</LOGONID>") ;
			System.out.println("\t</DATA>") ;
			System.out.println("</SITEASSET>") ;
		}
	}
}
