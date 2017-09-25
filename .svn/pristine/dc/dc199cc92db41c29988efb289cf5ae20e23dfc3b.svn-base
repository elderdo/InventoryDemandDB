package Configuration;
import java.util.Calendar;
/*
 *  $Revision:   1.5  $
 *  $Author:   c970183  $
 *  $Workfile:   Utils.java  $
 *  $Log:   \\www-amssc-01\pds\archives\SDS-AMD\Components-ClientServer\AmdConfig\Configuration\Utils.java-arc  $
/*
/*   Rev 1.5   21 Aug 2002 13:28:26   c970183
/*Fixed the pad method so that it would handle a null input and return an empty string.
/*
/*   Rev 1.4   20 Aug 2002 08:57:18   c970183
/*Reformated using JEdit's JavaStyle plugin
 *  *
 *  *   Rev 1.3   19 Aug 2002 15:54:32   c970183
 *  *Added a now method that returns the current date in the following format mm/dd/yy hh:mm AM/PM.
 *  *
 *  *   Rev 1.1   23 May 2002 06:57:56   c970183
 *  *Test Release
 */
import java.util.StringTokenizer;
import java.util.TimeZone;

/**
 *  Description of the Class
 *
 *@author     Douglas S. Elder
 *@created    August 20, 2002
 *@since      06/20/02
 */
public class Utils {
	private static String author = "$Author:   c970183  $";
	private static String revision = "$Revision:   1.5  $";
	private static String workfile = "$Workfile:   Utils.java  $";


	/**
	 *  Gets the author attribute of the Utils object
	 *
	 *@return    The author value
	 */
	public String getAuthor() {
		return author;
	}


	/**
	 *  Gets the revision attribute of the Utils object
	 *
	 *@return    The revision value
	 */
	public String getRevision() {
		return revision;
	}


	/**
	 *  Gets the workfile attribute of the Utils object
	 *
	 *@return    The workfile value
	 */
	public String getWorkfile() {
		return workfile;
	}


	/**
	 *  A unit test for JUnit
	 *
	 *@param  p1  Description of the Parameter
	 */
	protected void testParam(String p1) {
		if (p1 == null) {
			p1 = "";
		}
	}


	/**
	 *  Gets the date attribute of the Utils class
	 *
	 *@param  value  Description of the Parameter
	 *@return        The date value
	 */
	static boolean isDate(String value) {
		boolean result = true;
		return result;
	}


	/**
	 *  Determines if the value passed in is a number
	 *
	 *@param  value  Description of the Parameter
	 *@return        if the String is a number true, else false
	 */
	public static boolean isNumber(String value) {
		value = value.trim();
		try {
			Long x = new Long(value);
		} catch (NumberFormatException e) {
			return false;
		}
		return true;
	}


	/**
	 *  Description of the Method
	 *
	 *@param  args  Description of the Parameter
	 */
	public static void main(String args[]) {
		if (args.length > 0 && args[0].equals("-version")) {
			System.out.println(revision + "\n" +
					author + "\n" +
					workfile);
			System.exit(0);
		}

		String test = "12345:67890";
		System.out.println(test.indexOf(":"));
		System.out.println(test.substring(0, test.indexOf(":")));
		Utils obj = new Utils();
		obj.testParam(null);
		System.out.println(Utils.now());
	}


	/**
	 *  Description of the Method
	 *
	 *@return    Description of the Return Value
	 */
	public static String now() {
		Calendar cal = Calendar.getInstance(TimeZone.getDefault());
		String DATE_FORMAT = "M/dd/yy hh:mm a";
		java.text.SimpleDateFormat sdf =
				new java.text.SimpleDateFormat(DATE_FORMAT);
		sdf.setTimeZone(TimeZone.getDefault());
		return sdf.format(cal.getTime());
	}


	/**
	 *  Description of the Method
	 *
	 *@param  str    Description of the Parameter
	 *@param  width  Description of the Parameter
	 *@return        Description of the Return Value
	 */
	public static String pad(String str, int width) {
	    if (str == null) {
	        return "";
	    } else {
		    StringBuffer buf = new StringBuffer(str);
		    int space = width - buf.length();
		    while (space-- > 0) {
			    buf.append(' ');
		    }
    		return buf.toString();
		}
	}


	/**
	 *  Description of the Method
	 *
	 *@param  text   Description of the Parameter
	 *@param  delim  Description of the Parameter
	 *@return        Description of the Return Value
	 */
	public static String[] split(String text, String delim) {
		StringTokenizer st = new StringTokenizer(text, delim);
		String result[] = new String[st.countTokens()];
		int i = 0;
		while (st.hasMoreTokens()) {
			result[i++] = st.nextToken();
		}
		return result;
	}
}

