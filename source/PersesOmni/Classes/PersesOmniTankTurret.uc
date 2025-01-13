/******************************************************************************
PersesTankTurret

Creation date: 2011-08-18 22:17
Last change: $Id$
Copyright © 2011, Wormbo
Website: http://www.koehler-homepage.de/Wormbo/
Feel free to reuse this code. Send me a note if you found it helpful or want
to report bugs/provide improvements.
Please ask for permission first, if you intend to make money off reused code.
******************************************************************************/

class PersesOmniTankTurret extends ONSHoverTankCannon;


function Tick(float DeltaTime)
{
	// center turret if unoccupied
	if (Instigator != None && Instigator.Controller != None)
	{
		bForceCenterAim = False;
	}
	else if (!bActive && CurrentAim != rot(0,0,0))
	{
		bForceCenterAim = True;
		bActive = True;
	}
	else if (bActive && CurrentAim == rot(0,0,0))
	{
		bActive = False;
	}
	
	// "wipe" enemies off with the turning tank turret
	Super.Tick(DeltaTime);
}

function Projectile SpawnProjectile(class<Projectile> ProjClass, bool bAltFire)
{
	local coords BarrelCoords;
	local vector HitLocation, HitNormal;
	
	BarrelCoords = GetBoneCoords(PitchBone);
	if (Base.Trace(HitLocation, HitNormal, WeaponFireLocation, BarrelCoords.Origin, false, vect(0,0,0)) != None)
		return None; // barrel clipping through something
		
	return Super.SpawnProjectile(ProjClass, bAltFire);
}

	
//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
     bDoOffsetTrace=True
     RotationsPerSecond=0.240000  // 0.180000 Tank
     Spread=0.007500  // GII is 0, normal G is 0.015
     FireInterval=2.20000 // little faster than goliath.
     DrawScale=0.900000
     
     //PitchUpLimit=6000
//     PitchDownLimit=61500
          
     PitchUpLimit=16300
     PitchDownLimit=59500
}
