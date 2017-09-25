package effectivity;

import java.util.*;

public class PageSet extends java.util.HashMap
{
	private String  errorMsg="";
	private String  splitEffect="";
	private String  updateDate;
	private String  updateId;
	private int     qtyByShip=0;
	private int     qtyByFleet=0;

	public int count() 
	{
		return size() ;
	}
	
	public void add(String pKey, Nsn pObject)
	{
		updateEffQty(pKey,pObject.getEffectBy());
		put(pKey, pObject);
	}

	public Nsn getItem(String pKey) 
	{
		if (containsKey(pKey)) 
		{
			return (Nsn) get(pKey);
		} 
		else 
		{
			return null;
		}
	}
	
	public void setUpdateDate(String pDate)
	{
		updateDate = pDate;
	}

	public String getUpdateDate()
	{
		return updateDate;
	}

	public void setUpdateId(String pId)
	{
		updateId = pId;
	}

	public String getUpdateId()
	{
		return updateId;
	}

	public void setErrorMsg(String pError)
	{
		errorMsg = "<font color=red><b>" + pError + "</b></font><hr>";
	}
		
	String getErrorMsg()
	{
		return errorMsg;
	}

	public void setSplitEffect(String pSplitEffect)
	{
		splitEffect = pSplitEffect;
	}

	public String getSplitEffect()
	{
		return splitEffect;
	}

	private void updateEffQty(String pKey, String pEffectBy)
	{
		if (! containsKey(pKey))
		{
			if (pEffectBy.equals("S"))
				qtyByShip++;
			else if (pEffectBy.equals("F"))
				qtyByFleet++;
		}
	}

	public int getQtyByShip()
	{
		return qtyByShip;
	}
	public int getQtyByFleet()
	{
		return qtyByFleet;
	}
}
