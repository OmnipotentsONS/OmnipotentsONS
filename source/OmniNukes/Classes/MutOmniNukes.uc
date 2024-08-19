class MutOmniNukes extends Mutator config;
// this replaces stanard Redeemer and the buggy WGSNuke Redeemer II with the Omni versions
var() config bool bDebug;
var bool bInitialized;

function Initialize()
{

    bInitialized = true;
	  Log("Mutator "@ FriendlyName@" Initialized",'OmniNukes');
}

function bool CheckReplacement( Actor Other, out byte bSuperRelevant )
{
	local int i;
	local WeaponLocker L;
	

  if ( !bInitialized )  Initialize();
	bSuperRelevant = 0;
	

  if ( xWeaponBase(Other) != None )
  {
  	if (bDebug) log("Replacing Nukes in Weaponbases",'OmniNukes');
		if ( xWeaponBase(Other).WeaponType.name == 'RedeemerII' )
		{
			xWeaponBase(Other).WeaponType = class'OmniNukes.OmniRedeemerII';
			if (bDebug) log(" replacing weaponbase name = RedeemerII",'MutOmniNukes');
		}	
		else if	( xWeaponBase(Other).WeaponType == class'Redeemer' )
		{
			xWeaponBase(Other).WeaponType = class'OmniNukes.OmniRedeemer';
			if (bDebug) log(" replacing weaponbase class = Redeemer",'MutOmniNukes');
			if (bDebug) log("  replaced with"@xWeaponBase(Other).WeaponType,'MutOmniNukes');
		}	
	}
  
  else if ( (WeaponPickup(Other) != None) && (string(Other.Class) == "RedeemerPickup") )
        {
           ReplaceWith( Other, "OmniNukes.OmniRedeemerPickup");
           if (bDebug) log(" replacing weaponpickup = Redeemer",'MutOmniNukes');
        }
  else if ( (WeaponPickup(Other) != None) && (string(Other.Class) == "RedeemerIIPickup") )
        {
            ReplaceWith( Other, "OmniNukes.OmniRedeemerIIPickup");        
            if (bDebug)  log(" replacing weaponpickup = RedeemerII",'MutOmniNukes');
	      }   
	      
	else if ( WeaponLocker(Other) != None ) //Who the hell puts the Nuke in a weapon locker?
	{
		L = WeaponLocker(Other);
		for (i = 0; i < L.Weapons.Length; i++) {
			if (L.Weapons[i].WeaponClass.Name == 'RedeemerII' )
			{
				L.Weapons[i].WeaponClass = class'OmniRedeemerII';	
				if (bDebug) log(" replacing weaponlocker name = RedeemerII",'MutOmniNukes');
			}	
			else if (L.Weapons[i].WeaponClass == class'Redeemer' )	 
			{
				if (bDebug) log(" replacing weaponlocker class = Redeemer",'MutOmniNukes');
				L.Weapons[i].WeaponClass = class'OmniRedeemer';
				
			} 
			
		}		
		return true;
	}
	else
		return true;
	
	return true;
}

defaultproperties
{
     FriendlyName="Omni Nukes 1.01"
     Description="Replaces the regular Redeemer with Omni Version, buggy WGSNuke/RedeemerII with OmniRedeemerII"
     bAddToServerPackages=True
     bDebug=False
   
}
