package Configuration;
/*
 *  $Revision:   1.2  $
 *  $Author:   c970183  $
 *  $Workfile:   Aircraft.java  $
 *  $Log:   \\www-amssc-01\pds\archives\SDS-AMD\Components-ClientServer\AmdConfig\Configuration\Aircraft.java-arc  $
/*
/*   Rev 1.2   06 Aug 2002 11:46:26   c970183
/*Latest Version on hs1189
 *  *
 *  *   Rev 1.1   23 May 2002 06:57:48   c970183
 *  *Test Release
 */
import java.beans.*;

/**
 * This class represents an individual Aircraft.
 * 
 * @author Douglas S. Elder
 * @since 06/20/02
 */
public class Aircraft {
	private String ac_no;
	private String bun;
	private String fsn;
	private String fus;
	private String p_no;
	private String tail_no;
	private static String author = "$Author:   c970183  $";

	private static String revision = "$Revision:   1.2  $";
	private static String workfile = "$Workfile:   Aircraft.java  $";


	/**
	 *  Constructor for the Aircraft object
	 */
	public Aircraft() { }


	/**
	 * Constructor for the Aircraft object
	 * 
	 * @param theData A string consisting of the P_NO (plane number) and
	 * ac_no (aircraft number) separated by a zero.
	 */
	public Aircraft(String theData) {
		p_no = theData.substring(0, theData.indexOf(String.valueOf(0)));
		ac_no = theData.substring(theData.indexOf(String.valueOf(0)) + 1);
	}


	/**
	 * Sets the acNo attribute of the Aircraft object
	 * 
	 * @param ac_no  The new acNo value
	 */
	public void setAcNo(String ac_no) {
		this.ac_no = ac_no;
	}


	/**
	 * Sets the bun attribute of the Aircraft object
	 * 
	 * @param bun The new bun value
	 */
	public void setBun(String bun) {
		this.bun = bun;
	}


	/**
	 * Sets the fsn attribute of the Aircraft object
	 * 
	 * @param fsn The new fsn value
	 */
	public void setFsn(String fsn) {
		this.fsn = fsn;
	}


	/**
	 * Sets the fus attribute of the Aircraft object
	 * 
	 * @param fus The new fus value
	 */
	public void setFus(String fus) {
		this.fus = fus;
	}


	/**
	 * Sets the pno attribute of the Aircraft object
	 * 
	 * @param p_no The new pno value
	 */
	public void setPno(String p_no) {
		this.p_no = p_no;
	}


	/**
	 * Sets the tailNo attribute of the Aircraft object
	 * 
	 * @param tailNo The new tailNo value
	 */
	public void setTailNo(String tailNo) {
		this.tail_no = tailNo;
	}


	/**
	 * Gets the acNo attribute of the Aircraft object
	 * 
	 * @return The acNo value
	 */
	public String getAcNo() {
		return ac_no;
	}


	/**
	 * Gets the author attribute of the Aircraft object
	 * 
	 * @return The author value
	 */
	public String getAuthor() {
		return author;
	}


	/**
	 * Gets the bun attribute of the Aircraft object
	 * 
	 * @return The bun value
	 */
	public String getBun() {
		return this.bun;
	}


	/**
	 * Gets the fsn attribute of the Aircraft object
	 * 
	 * @return The fsn value
	 */
	public String getFsn() {
		return this.fsn;
	}


	/**
	 * Gets the fus attribute of the Aircraft object
	 * 
	 * @return The fus value
	 */
	public String getFus() {
		return this.fus;
	}


	/**
	 * Gets the pno attribute of the Aircraft object
	 * 
	 * @return The pno value
	 */
	public String getPno() {
		return p_no;
	}


	/**
	 * Gets the revision attribute of the Aircraft object
	 * 
	 * @return The revision value
	 */
	public String getRevision() {
		return revision;
	}


	/**
	 * Gets the tailNo attribute of the Aircraft object
	 * 
	 * @return The tailNo value
	 */
	public String getTailNo() {
		return tail_no;
	}


	/**
	 * Gets the workfile attribute of the Aircraft object
	 * 
	 * @return The workfile value
	 */
	public String getWorkfile() {
		return workfile;
	}


	/**
	 * Converts the p_no and ac_no into a string
	 * 
	 * @return The pn_no and ac_no concatenated into a string
	 * and separated by a zero.
	 */
	public String toString() {
		return p_no 
		    + String.valueOf(0) 
		    + ac_no;
	}


	/**
	 *  The main program for the Aircraft class
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
