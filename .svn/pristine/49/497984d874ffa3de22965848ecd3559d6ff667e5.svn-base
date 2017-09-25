//	SCCSID: %M% %I% Modified: %G% %U%
//	Date      By            History
//      05/28/02  kcs	    	Initial
//	09/24/02  kcs		add roundTwo to round to 2 decimal places
//	10/02/02  kcs		no change, pvcs test
//		PVCS
//	$Revision:   1.3  $
//	$Author:   c378632  $
//	$Workfile:   Helper.java  $
package retrofit;
import java.io.*;
import java.util.*;
public class Helper{ 
	public static String nvl(String inString, String nvlValue){
		if (inString == null){
			return nvlValue;
		}else{
			return inString;
		}
	}
	public static String input(String inType, String inName, String inValue){
		String value = "";
		if (inValue != null){
			value = " value =\"" + inValue + "\"";
		}
		return "<input type=\"" + inType + "\" name=\"" + inName + "\"" + value + ">";	
	}
	public static String input(String inType, String inName, String inValue, String size){
		String value = "";
		if (inValue != null){
			value = " value =\"" + inValue + "\"";
		}
		return "<input size=\"" + size + "\" type=\"" + inType + "\" name=\"" + inName + "\"" + value + ">";	
	}
	public static String tCol(String inValue){
		return "<td>" + inValue + "</td>";
	}
	public static String split(String inSplitOn, String inSplitString, int i){
		int j = 1;
		System.out.println("i: " + i);
		String myToken = null;
		for (java.util.Enumeration e = new StringTokenizer(inSplitString, inSplitOn); e.hasMoreElements();){
			myToken = (String) e.nextElement();
			if (i == j){
				break;
			}else if (j > i){
				myToken = null;
				break;
			}
			j++;
		}
		return myToken;
	}
	public static String roundTwo(String in){
		String outString = null;
		try {
			if (in.equals("0")){
				outString = in;
			}else{
				double d = Double.parseDouble(in);
				d = (d * 100);
				outString = String.valueOf(Math.round(d)/100.00);
			}
		}catch (NumberFormatException e){
			outString = in;
		}catch (NullPointerException e2){
			outString = in;
		}
		return outString;
	}
	
}
