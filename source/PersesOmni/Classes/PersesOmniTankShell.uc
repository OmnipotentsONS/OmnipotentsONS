/******************************************************************************
PersesTankShell

Creation date: 2011-08-19 16:16
Last change: $Id$
Copyright © 2011, Wormbo
Website: http://www.koehler-homepage.de/Wormbo/
Feel free to reuse this code. Send me a note if you found it helpful or want
to report bugs/provide improvements.
Please ask for permission first, if you intend to make money off reused code.
******************************************************************************/

class PersesOmniTankShell extends ONSRocketProjectile;


simulated function Touch(Actor Other)
{
	if (ShouldCollideWith(Other))
		Super.Touch(Other);
}


simulated function HitWall(vector HitNormal, actor Wall)
{
	if (ShouldCollideWith(Wall))
		Super.HitWall(HitNormal, Wall);
}


simulated function bool ShouldCollideWith(Actor Other)
{
	if (Other == None || Instigator == None)
		return true;

	if (Other == Instigator)
		return false;

	if (ONSWeaponPawn(Instigator) != None)
		return Other != ONSWeaponPawn(Instigator).VehicleBase;

	return true;
}


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
     MyDamageType=Class'PersesOmni.DamTypePersesOmniTankShell'
     LifeSpan=1.500000
}
