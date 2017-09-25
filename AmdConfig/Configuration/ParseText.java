package Configuration;
/*
 *  $Revision:   1.2  $
 *  $Author:   c970183  $
 *  $Workfile:   ParseText.java  $
 *  $Log:   \\www-amssc-01\pds\archives\SDS-AMD\Components-ClientServer\AmdConfig\Configuration\ParseText.java-arc  $
/*
/*   Rev 1.2   06 Aug 2002 11:46:16   c970183
/*Latest Version on hs1189
 *  *
 *  *   Rev 1.1   23 May 2002 06:57:54   c970183
 *  *Test Release
 */
/**
 *  Description of the Class
 *
 *@author     Douglas S. Elder
 *@since      06/20/02
 */
public class ParseText {
	private static String author = "$Author:   c970183  $";
	private static String revision = "$Revision:   1.2  $";
	private static String workfile = "$Workfile:   ParseText.java  $";


	/**
	 *  Gets the author attribute of the ParseText object
	 *
	 *@return    The author value
	 */
	public String getAuthor() {
		return author;
	}


	/**
	 *  Gets the revision attribute of the ParseText object
	 *
	 *@return    The revision value
	 */
	public String getRevision() {
		return revision;
	}


	/**
	 *  Gets the workfile attribute of the ParseText object
	 *
	 *@return    The workfile value
	 */
	public String getWorkfile() {
		return workfile;
	}


	/**
	 *  The main program for the ParseText class
	 *
	 *@param  args  The command line arguments
	 */
	public static void main(String[] args) {
		if (args.length > 0 && args[0].equals("-version")) {
			System.out.println(revision + "\n" +
					author + "\n" +
					workfile);
			System.exit(0);
		}
	}


	/**
	 *  Description of the Method
	 *
	 *@param  in  Description of the Parameter
	 *@return     Description of the Return Value
	 */
	public static String stringParse(String in) {
		if (in == null) {
			return null;
		}
		try {
			int charAmount = in.length();
			StringBuffer buffer = new StringBuffer();
			for (int i = 0; i < charAmount; i++) {
				char c = in.charAt(i);
				switch (c) {
								case ' ':
									buffer.append("%20");
									break;
								case '<':
									buffer.append("%3C");
									break;
								case '>':
									buffer.append("%3E");
									break;
								case '#':
									buffer.append("%23");
									break;
								case '%':
									buffer.append("%25");
									break;
								case '{':
									buffer.append("%7B");
									break;
								case '}':
									buffer.append("%7D");
									break;
								case '|':
									buffer.append("%7C");
									break;
								case '\\':
									buffer.append("%5C");
									break;
								case '^':
									buffer.append("%5E");
									break;
								case '~':
									buffer.append("%7E");
									break;
								case '[':
									buffer.append("%5B");
									break;
								case ']':
									buffer.append("%5D");
									break;
								case '`':
									buffer.append("%60");
									break;
								case ';':
									buffer.append("%3B");
									break;
								case '/':
									buffer.append("%2F");
									break;
								case '?':
									buffer.append("%3F");
									break;
								case ':':
									buffer.append("%3A");
									break;
								case '@':
									buffer.append("%40");
									break;
								case '=':
									buffer.append("%3D");
									break;
								case '&':
									buffer.append("%26");
									break;
								default:
									buffer.append(c);
									break;
				}
			}
			in = buffer.toString();
			return (in);
		} catch (Exception e) {
			System.err.println("Error in stringParse(): " + e);
			return (null);
		}
	}
}
