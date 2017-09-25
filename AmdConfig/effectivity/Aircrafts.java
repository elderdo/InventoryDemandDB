package effectivity;

import java.util.*;

public class Aircrafts extends java.util.HashMap
{
	public void add(String pKey, AmdAircraft pObject)
	{
		put(pKey, pObject);
	}

	public int count() 
	{
		return this.size() ;
	}
    
	public AmdAircraft getItem(String pKey) 
	{
		if (this.containsKey(pKey)) 
		{
			return (AmdAircraft) this.get(pKey) ;
		} 
		else 
		{
			return null ;
		}
	}
}
