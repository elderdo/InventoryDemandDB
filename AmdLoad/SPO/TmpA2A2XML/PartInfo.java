import java.sql.* ;
public class PartInfo {
	
	public PartInfo()  {
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
		PartInfo sa = new PartInfo() ;
		AmdConnection amd = AmdConnection.instance() ;
		amd.setIniFile(args[0]) ;
        	Statement s = amd.c.createStatement() ;
        	s.setFetchSize(100) ;
        	ResultSet rs = s.executeQuery("SELECT " 
				+ AmdUtils.tranColumns(3,6,"PART_INFO")
				+ AmdUtils.partHeaderColumns
				+ "SOURCE_SYSTEM, "
				+ "CAGE_CODE, "
				+ "PART_NO, "
				+ "UNIT_ISSUE, "
				+ "NOUN, "
				+ "RCM_IND, "
				+ "HAZMAT_CODE, "
				+ "SHELF_LIFE, "
				+ "EQUIPMENT_TYPE, "
				+ "NSN_COG, "
				+ "NSN_MCC, "
				+ "NSN_FSC, "
				+ "NSN_NIIN, "
				+ "NSN_SMIC_MMAC, "
				+ "NSN_ACTY, "
				+ "ESSENTIALITY_CODE, "
				+ "RESP_ASSET_MGR, "
				+ "UNIT_PACK_CUBE, "
				+ "UNIT_PACK_QTY, "
				+ "UNIT_PACK_WEIGHT, "
				+ "UNIT_PACK_WEIGHT_MEASURE, "
				+ "ELECTRO_STATIC_DISCHARGE, "
				+ "PERF_BASED_LOG_INFO, "
				+ "PLANNED_PART, "
				+ "THIRD_PARTY_FLAG, "
				+ "MTBF, "
				+ "Nvl(MTBF_TYPE,'Engineering') mtbf_type, "
				+ "SHELF_LIFE_ACTION_CODE, "
				+ "PREFERRED_SMRCODE, "
				+ "DECAY_RATE, "
				+ "INDENTURE, "
				+ "IS_EXEMPT, "
				+ "IGNORE_WEIGHT_AND_VOLUME, "
				+ "IS_ORDER_POLICY_REQ_BASE "
				+ "FROM tmp_a2a_part_info, amd_part_header_v "
				+ "where part_no = ph_part_no ");
		while (rs.next()) {
			System.out.println("<PARTINFO>") ;
			AmdUtils.tranHeader(rs) ;
			AmdUtils.partHeader(rs) ;
			System.out.println("\t<DATA>") ;
			System.out.println("\t\t<SRCSYS>" + rs.getString("SOURCE_SYSTEM") + "</SRCSYS>") ;
			System.out.println("\t\t<CAGE>" + rs.getString("CAGE_CODE") + "</CAGE>") ;
			System.out.println("\t\t<PART>" + rs.getString("PART_NO") + "</PART>") ;
			System.out.println("\t\t<UI>" + rs.getString("UNIT_ISSUE") + "</UI>") ;
			System.out.println("\t\t<NOUN>" + rs.getString("NOUN") + "</NOUN>") ;
			System.out.println("\t\t<RCMIND>" + rs.getString("RCM_IND") + "</RCMIND>") ;
			System.out.println("\t\t" + getElement(rs,"HAZMAT_CODE","HAZMAT") ) ;
			System.out.println("\t\t" + getElement(rs,"SHELF_LIFE","SHELF") ) ;
			System.out.println("\t\t" + getElement(rs,"EQUIPMENT_TYPE","EQUIPTYPE") ) ;
			System.out.println("\t\t" + getElement(rs,"NSN_COG","COG") ) ;
			System.out.println("\t\t" + getElement(rs,"NSN_MCC","MCC") ) ;
			System.out.println("\t\t" + getElement(rs,"NSN_FSC","FSC") ) ;
			System.out.println("\t\t" + getElement(rs,"NSN_NIIN","NIIN") ) ;
			System.out.println("\t\t" + getElement(rs,"NSN_SMIC_MMAC", "SMIC") ) ;
			System.out.println("\t\t" + getElement(rs,"NSN_ACTY","ACTY") ) ;
			System.out.println("\t\t" + getElement(rs,"ESSENTIALITY_CODE","ESSENTIAL") ) ;
			System.out.println("\t\t" + getElement(rs,"RESP_ASSET_MGR","ASSETMGR") ) ;
			System.out.println("\t\t" + getElement(rs,"UNIT_PACK_CUBE","UPCUBE") ) ;
			System.out.println("\t\t" + getElement(rs,"UNIT_PACK_WEIGHT","UPWT") ) ;
			System.out.println("\t\t" + getElement(rs,"UNIT_PACK_WEIGHT_MEASURE","UPWTM") ) ;
			System.out.println("\t\t" + getElement(rs,"ELECTRO_STATIC_DISCHARGE", "ESD") ) ;
			System.out.println("\t\t" + getElement(rs,"PERF_BASED_LOG_INFO", "PBL") ) ;
			System.out.println("\t\t" + getElement(rs,"PLANNED_PART","PLAN") ) ;
			System.out.println("\t\t" + getElement(rs,"THIRD_PARTY_FLAG","TP") ) ;
			System.out.println("\t\t" + getElement(rs,"MTBF","MTBF") ) ;
			System.out.println("\t\t" + getElement(rs,"MTBF_TYPE", "MTBFTYPE") ) ;
			System.out.println("\t\t" + getElement(rs,"SHELF_LIFE_ACTION_CODE","SHELFACT") ) ;
			System.out.println("\t\t" + getElement(rs,"PREFERRED_SMRCODE","PREFSMRC") ) ;
			System.out.println("\t\t" + getElement(rs,"DECAY_RATE","DECAYRATE") ) ;
			System.out.println("\t\t" + getElement(rs,"INDENTURE","INDENT") ) ;
			System.out.println("\t\t" + getElement(rs,"IS_EXEMPT","EXEMPT") ) ;
			System.out.println("\t\t" + getElement(rs,"IGNORE_WEIGHT_AND_VOLUME", "IGWEIGHTVOLUME") ) ;
			System.out.println("\t\t" + getElement(rs,"IS_ORDER_POLICY_REQ_BASE","ORDPOLROQBASED") ) ;
			System.out.println("\t</DATA>") ;
			System.out.println("</PARTINFO>") ;
		}
	}
}
