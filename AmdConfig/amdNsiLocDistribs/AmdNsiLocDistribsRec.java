package amdNsiLocDistribs;
//	SCCSID: %M% %I% Modified: %G% %U%
//	Date      By            History
//      05/28/02  kcs	    	Initial
//	09/30/02  kcs		move roundTwo to Helper
//		PVCS
//	$Revision:   1.2  $
//	$Author:   c378632  $
//	$Workfile:   AmdNsiLocDistribsRec.java  $
import java.io.*;
import java.util.*;
import retrofit.Helper;

public class AmdNsiLocDistribsRec{
	private String nsn;
	private String pn;
	private String nsiSid;
	private String locSid;
	private String locId;
	private String locName;
	private String timePeriodStart;
	private String timePeriodEnd;
	private String asFlyingCount;
	private String asFlyingPercent;
	private String asCapableCount;
	private String asCapablePercent;

	public void setNsn(String nsn){
		this.nsn = nsn;
	}
	public String getNsn(){
		return nsn;
	}
	public void setPn(String pn){
		this.pn = pn;
	}
	public String getPn(){
		return pn;
	}
	public void setNsiSid(String nsiSid){
		this.nsiSid = nsiSid;
	}
	public String getNsiSid(){
		return nsiSid;
	}
	public void setLocSid(String locSid){
		this.locSid = locSid;
	}
	public String getLocSid(){
		return locSid;
	}
	public void setLocId(String locId){
		this.locId = locId;
	}
	public String getLocId(){
		return locId;
	}
	public void setLocName(String locName){
		this.locName = locName;
	}
	public String getLocName(){
		return locName;
	}
	public void setTimePeriodStart(String timePeriodStart){
		this.timePeriodStart = timePeriodStart;
	}
	public String getTimePeriodStart(){
		return timePeriodStart;
	}
	public void setTimePeriodEnd(String timePeriodEnd){
		this.timePeriodEnd = timePeriodEnd;
	}
	public String getTimePeriodEnd(){
		return timePeriodEnd;
	}
	public void setAsFlyingCount(String asFlyingCount){
		this.asFlyingCount = asFlyingCount;
	}
	public String getAsFlyingCount(){
		return asFlyingCount;
	}
	public void setAsFlyingPercent(String asFlyingPercent){
		this.asFlyingPercent = retrofit.Helper.roundTwo(asFlyingPercent);
	}
	public String getAsFlyingPercent(){
		return asFlyingPercent;
	}
	public void setAsCapableCount(String asCapableCount){
		this.asCapableCount = asCapableCount;
	}
	public String getAsCapableCount(){
		return asCapableCount;
	}
	public void setAsCapablePercent(String asCapablePercent){
		this.asCapablePercent = retrofit.Helper.roundTwo(asCapablePercent);
	}
	public String getAsCapablePercent(){
		return asCapablePercent;
	}
	
}
