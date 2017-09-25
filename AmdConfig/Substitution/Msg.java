package Substitution;
/*
 *  $Revision:   1.4  $
 *  $Author:   c402417  $
 *  $Workfile:   Msg.java  $
 *  $Log:   \\www-amssc-01\pds\archives\SDS-AMD\Components-ClientServer\AmdConfig\Substitution\Msg.java-arc  $
/*
/*   Rev 1.4   24 Sep 2002 16:27:16   c402417
/*check the file back in , no change
/*
/*   Rev 1.3   04 Sep 2002 13:30:46   c970183
/*Added get methods for PVCS revision variables.
 *  *
 *  *   Rev 1.2   04 Sep 2002 12:17:16   c970183
 *  *Fixed Keywords at top of class
 */
/**
 *  Description of the Class
 *
 *@author     c970183
 *@created    June 26, 2002
 */
public class Msg {
	private String msg = "";
	private static String author = "$Author:   c402417  $";

	private static String revision = "$Revision:   1.4  $";
	private static String workfile = "$Workfile:   Msg.java  $";


	/**
	 *  Description of the Method
	 *
	 *@param  msg  Description of the Parameter
	 */
	public void append(String msg) {
		if (msg.equals("")) {
			this.msg = msg;
		} else {
			this.msg = this.msg + " " + msg;
		}
	}


	/**
	 *  Description of the Method
	 *
	 *@return    Description of the Return Value
	 */
	public int length() {
		return msg.length();
	}


	/**
	 *  Description of the Method
	 *
	 *@return    Description of the Return Value
	 */
	public String toString() {
		return msg;
	}


	/**
	 *  Gets the author attribute of the Msg class
	 *
	 *@return    The author value
	 */
	public static String getAuthor() {
		return author;
	}


	/**
	 *  Gets the revision attribute of the Msg class
	 *
	 *@return    The revision value
	 */
	public static String getRevision() {
		return revision;
	}


	/**
	 *  Gets the workfile attribute of the Msg class
	 *
	 *@return    The workfile value
	 */
	public static String getWorkfile() {
		return workfile;
	}


	/**
	 *  The main program for the ControlerSub class
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
}

