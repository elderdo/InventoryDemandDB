package effectivity;

import java.beans.*;
import java.util.* ;
import Configuration.*;


public class Effectivity
{
	private Nsn         nsnObj;
	private String      nsn;
	private Aircrafts   acHash;
	private Locations   locations;
	
	public Effectivity()
	{
	}

	public void setNsn(Nsn pNsn)
	{
		nsnObj = pNsn;
	}

	public Nsn getNsn()
	{
		return nsnObj;
	}

//	public void setAircraftHash(Aircrafts pAircrafts)
//	{
//		acHash = pAircrafts;
//	}
//
//	public Aircrafts getAircraftHash()
//	{
//		return acHash;
//	}
//
//
//	public void setLocations(Locations pLocations)
//	{
//		locations = pLocations;
//	}
//
//	public Locations getLocations()
//	{
//		return locations;
//	}

}
