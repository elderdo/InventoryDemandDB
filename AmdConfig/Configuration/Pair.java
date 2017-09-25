package Configuration;
/*
 *  $Revision:   1.2  $
 *  $Author:   c970183  $
 *  $Workfile:   Pair.java  $
 *  $Log:   \\www-amssc-01\pds\archives\SDS-AMD\Components-ClientServer\AmdConfig\Configuration\Pair.java-arc  $
/*
/*   Rev 1.2   06 Aug 2002 11:46:16   c970183
/*Latest Version on hs1189
 *  *
 *  *   Rev 1.1   23 May 2002 06:57:52   c970183
 *  *Test Release
 */
import java.beans.*;
import org.apache.log4j.Logger;

/**
 *  For any group that has more than one nsn, those nsn's are paired with each
 *  other. A pair has a left hand side, lhs, and a right hand side, rhs.
 *  Whenever an nsn is added to a group, all its associated pairs are generated.
 *
 *@author     Douglas S. Elder
 *@version    1.0
 *@since      06/09/02
 *@see        RelatedNsns
 */
public class Pair {

	/**
	 *  One of the following values: NOT_INTERCHANGEABLE ONE_WAY TWO_WAY LIMITED
	 */
	private String interChangeType;

	/**
	 *  The left hand side nsn for an nsn pair.
	 */
	private String lhs;

	/**
	 *  The left hand side nsiSid for an nsn pair.
	 */
	private String lhsNsiSid;

	/**
	 *  The right hand side nsn for an nsn pair.
	 */
	private String rhs;

	/**
	 *  The roght hand side nsiSid for an nsn pair.
	 */
	private String rhsNsiSid;

	/**
	 *  A yes or no value
	 */
	private boolean upgradable;
	private static String author = "$Author:   c970183  $";

	/**
	 *  Used to log data for this class.
	 */
	private static Logger logger = Logger.getLogger(Pair.class.getName());

	private static String revision = "$Revision:   1.2  $";
	private static String workfile = "$Workfile:   Pair.java  $";
	/**
	 *  a value of the interchangeType
	 */
	public final static String LIMITED = "limited";

	/**
	 *  a value of the interchangeType
	 */
	public final static String NOT_INTERCHANGEABLE = "Not";
	/**
	 *  a value of the interchangeType
	 */
	public final static String ONE_WAY = "1-way";
	/**
	 *  a value of the interchangeType
	 */
	public final static String TWO_WAY = "2-way";


	/**
	 *@param  interChangeType  One of the following values: NOT_INTERCHANGEABLE
	 *      ONE_WAY TWO_WAY LIMITED
	 */
	public void setInterChangeType(String interChangeType) {
		this.interChangeType = interChangeType;
	}


	/**
	 *@param  lhs  The nsn that is on the left hand side of a pair of nsn's.
	 */
	public void setLhs(String lhs) {
		this.lhs = lhs;
	}


	/**
	 *@param  lhsNsiSid  The nsiSid associated with the left hand side of an nsn
	 *      pair.
	 */
	public void setLhsNsiSid(String lhsNsiSid) {
		this.lhsNsiSid = lhsNsiSid;
	}


	/**
	 *@param  rhs  The nsn that is on the right hand side of a pair of nsn's.
	 */
	public void setRhs(String rhs) {
		this.rhs = rhs;
	}


	/**
	 *@param  rhsNsiSid  The nsiSid associated with the right hand side of an nsn
	 *      pair.
	 */
	public void setRhsNsiSid(String rhsNsiSid) {
		this.rhsNsiSid = rhsNsiSid;
	}


	/**
	 *  Sets the upgradable attribute of the Pair object
	 *
	 *@param  upgradable  The new upgradable value
	 */
	public void setUpgradable(boolean upgradable) {
		this.upgradable = upgradable;
	}


	/**
	 *  Gets the author attribute of the Pair object
	 *
	 *@return    The author value
	 */
	public String getAuthor() {
		return author;
	}


	/**
	 *  A pair of nsn's can have one of the following interchange types:
	 *  NOT_INTERCHANGEABLE ONE_WAY TWO_WAY LIMITED The default for a new pair is
	 *  NOT_INTERCHANGEABLE.
	 *
	 *@return    The interChangeType value
	 */
	public String getInterChangeType() {
		return interChangeType;
	}


	/**
	 *@return    The nsn that is on the left hand side of a pair of nsn's.
	 */
	public String getLhs() {
		return lhs;
	}


	/**
	 *@return    The nsiSid associated with the left hand side of an nsn pair.
	 */
	public String getLhsNsiSid() {
		return lhsNsiSid;
	}


	/**
	 *  Gets the revision attribute of the Pair object
	 *
	 *@return    The revision value
	 */
	public String getRevision() {
		return revision;
	}


	/**
	 *@return    The nsn that is on the right hand side of a pair of nsn's.
	 */
	public String getRhs() {
		return rhs;
	}


	/**
	 *@return    The nsiSid associated with the right hand side of an nsn pair.
	 */
	public String getRhsNsiSid() {
		return rhsNsiSid;
	}


	/**
	 *  This is just a Yes or No value
	 *
	 *@return    Yes if the pair is upgradable, No if it is not.
	 */
	public boolean getUpgradable() {
		return upgradable;
	}


	/**
	 *  Gets the workfile attribute of the Pair object
	 *
	 *@return    The workfile value
	 */
	public String getWorkfile() {
		return workfile;
	}


	/**
	 *  This is for debug purposes only. It dumps the properties of a pair to a
	 *  log.
	 *
	 */
	public void dump() {
		if (logger.isDebugEnabled()) {
			logger.debug("lhs=" + lhs
					 + " rhs=" + rhs
					 + " interChangeType=" + interChangeType
					 + " upgradable=" + upgradable
					 + " lhsNsiSid=" + lhsNsiSid
					 + " rhsNsiSid=" + rhsNsiSid);
		}
	}


	/**
	 *  The main program for the Pair class
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
