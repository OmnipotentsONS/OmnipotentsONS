class MutOmniIonPainter extends Mutator;

function bool CheckReplacement( Actor Other, out byte bSuperRelevant )
{
	local int i;
	local WeaponLocker L;

	bSuperRelevant = 1;
    if ( xWeaponBase(Other) != None )
    {
		if ( xWeaponBase(Other).WeaponType == class'OnslaughtFull.ONSPainter' )
			xWeaponBase(Other).WeaponType = class'OmniPainters.IonPainterOmni';
	}
	else if ( ONSPainterPickup(Other) != None )
		ReplaceWith( Other, "OmniPainters.StrikePainterPickup");
	else if ( WeaponLocker(Other) != None ) //Who the hell puts the Target Painter in a weapon locker?
	{
		L = WeaponLocker(Other);
		for (i = 0; i < L.Weapons.Length; i++)
			if (L.Weapons[i].WeaponClass == class'ONSPainter')
				L.Weapons[i].WeaponClass = class'IonPainterOmni';
		return true;
	}
	else
		return true;
	return false;
}

defaultproperties
{
     FriendlyName="Ion Painter Omni"
     Description="Replaces the Short Range Ion Painter with Omni longer range version"
}
