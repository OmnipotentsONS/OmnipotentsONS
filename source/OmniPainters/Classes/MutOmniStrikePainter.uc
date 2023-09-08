class MutOmniStrikePainter extends Mutator;

function bool CheckReplacement( Actor Other, out byte bSuperRelevant )
{
	local int i;
	local WeaponLocker L;

	bSuperRelevant = 1;
    if ( xWeaponBase(Other) != None )
    {
		if ( xWeaponBase(Other).WeaponType == class'OnslaughtFull.ONSPainter' )
			xWeaponBase(Other).WeaponType = class'OmniPainters.StrikePainterOmni';
	}
	else if ( ONSPainterPickup(Other) != None )
		ReplaceWith( Other, "OmniPainters.StrikePainterPickup");
	else if ( WeaponLocker(Other) != None ) //Who the hell puts the Target Painter in a weapon locker?
	{
		L = WeaponLocker(Other);
		for (i = 0; i < L.Weapons.Length; i++)
			if (L.Weapons[i].WeaponClass == class'ONSPainter')
				L.Weapons[i].WeaponClass = class'StrikePainterOmni';
		return true;
	}
	else
		return true;
	return false;
}

defaultproperties
{
     FriendlyName="Nuclear Strike Painter Omni"
     Description="Replaces the unpopular Target Painter with the Nuclear Strike Painter (Omni Version)||v1.0 ~ by MiracleMatter"
}
