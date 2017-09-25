package effectivity;

import java.util.*;

public class Locations extends java.util.HashMap
{
	private int totalQty=0;

	public void add(String pKey, Location pObject)
	{
		updateQty(pKey, pObject.getQty());
		put(pKey, pObject);
	}

	public int count() 
	{
		return size();
	}
    
	public Location getItem(String pKey) 
	{
		if (this.containsKey(pKey)) 
		{
			return (Location) this.get(pKey);
		} 
		else 
		{
			return null;
		}
	}

	private void updateQty(String pKey, int pQty)
	{
		Location  loc;

		if (containsKey(pKey))
		{
			loc = getItem(pKey);
			totalQty = totalQty - loc.getQty();
		}

		totalQty = pQty;
	}

	public int getTotalQty()
	{
		return totalQty;
	}
}
