class MutOmniNukes extends Mutator;
// this replaces stanard Redeemer and the buggy WGSNuke Redeemer II with the Omni versions

function bool CheckReplacement( Actor Other, out byte bSuperRelevant )
{
	local int i;
	local WeaponLocker L;

	bSuperRelevant = 1;
  if ( xWeaponBase(Other) != None )
  {
  	//log("Replacing Nukes in Weaponbases");
		if ( xWeaponBase(Other).WeaponType.name == 'RedeemerII'  )
		{
			xWeaponBase(Other).WeaponType = class'OmniNukes.OmniRedeemerII';
			//log(" replacing weaponbase name = RedeemerII");
		}	
		else if	( xWeaponBase(Other).WeaponType == class'Redeemer' )
		{
			xWeaponBase(Other).WeaponType = class'OmniNukes.OmniRedeemer';
//			log(" replacing weaponbase class = Redeemer");
//			log("  replaced with"@xWeaponBase(Other).WeaponType);
		}	
	}

	         
	else if ( WeaponLocker(Other) != None ) //Who the hell puts the Nuke in a weapon locker?
	{
		L = WeaponLocker(Other);
		for (i = 0; i < L.Weapons.Length; i++) {
			if (L.Weapons[i].WeaponClass.Name == 'RedeemerII' )
			{
				L.Weapons[i].WeaponClass = class'OmniRedeemerII';	
				//log(" replacing weaponlocker name = RedeemerII");
			}	
			else if (L.Weapons[i].WeaponClass == class'Redeemer' )	 
			{
				//log(" replacing weaponlocker class = Redeemer");
				L.Weapons[i].WeaponClass = class'OmniRedeemer';
				
			} 
			
		}		
		return true;
	}
	else
		return true;
	return false;
}

defaultproperties
{
     FriendlyName="Omni Nukes 1.00"
     Description="Replaces the regular Redeemer with Omni Version, buggy WGSNuke/RedeemerII with OmniRedeemerII"
     bAddToServerPackages=True
}
