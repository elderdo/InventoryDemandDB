package effectivity;

import java.util.*;
import Configuration.*;

public class AmdAircraft extends Aircraft
{
	private String  bun;
	private String  fsn;
	private String  fus;
	private String  tailNo;
	private String  selected;
	private String  display = "";
	private boolean asFlyingInd;
	private boolean asCapableInd;
	private String  derived="";

	public AmdAircraft()
	{
		super();
		selected = "";
	}

	public void setBun(String pBun)
	{
		bun = pBun;
	}

	public String getBun()
	{
		return bun;
	}

	public void setFsn(String pFsn)
	{
		fsn = pFsn;
	}

	public String getFsn()
	{
		return fsn;
	}

	public void setFus(String pFus)
	{
		fus = pFus;
	}

	public String getFus()
	{
		return fus;
	}

	public void setTailNo(String pTailNo)
	{
		tailNo = pTailNo;
	}

	public String getTailNo()
	{
		return tailNo;
	}

	public String getEffectType()
	{
		if (isAsFlying())
			return "B";
		else
			return "C";
	}

	public String getUserDefined()
	{
		if (isAsFlying() || isAsCapable())
			return "Y";
		else
			return "N";
	}

	public void setDerived(String pValue)
	{
		derived = pValue;
	}

	public String getDerived()
	{
		return derived;
	}


	public void setSelected(boolean pSelected)
	{
		if (pSelected)
			selected = "selected";
		else
			selected = "";
	}

	public void setAsFlying(boolean pInd)
	{
		asFlyingInd = pInd;

		if (isAsFlying())
			setAsCapable(true);
	}

	public void setAsCapable(boolean pInd)
	{
		asCapableInd = pInd;
	}

	public boolean isAsFlying()
	{
		return asFlyingInd;
	}

	public boolean isAsCapable()
	{
		return asCapableInd;
	}

	public void setDisplay(String pDisplay)
	{
		display = pDisplay;
	}

	public String toString()
	{
		String retStr=super.toString();

		if (display.equals("ac_no"))
			retStr = getAcNo();
		else if (display.equals("bun"))
			retStr = bun;
		else if (display.equals("fsn"))
			retStr = fsn;
		else if (display.equals("fus"))
			retStr = fus;
		else if (display.equals("p_no"))
			retStr = getPno(); 
		else if (display.equals("tail_no"))
			retStr = getTailNo(); 

		return retStr;
	}
}
