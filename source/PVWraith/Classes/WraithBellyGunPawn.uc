/******************************************************************************
BansheeBellyGunPawn

Creation date: 2010-10-05 19:45
Last change: $Id$
Copyright © 2010, Wormbo
Website: http://www.koehler-homepage.de/Wormbo/
Feel free to reuse this code. Send me a note if you found it helpful or want
to report bugs/provide improvements.
Please ask for permission first, if you intend to make money off reused code.

Extended to Wraith
******************************************************************************/

class WraithBellyGunPawn extends ONSDualACGatlingGunPawn CacheExempt;


//simulated function ProjectilePostRender2D(Projectile P, Canvas C, float ScreenLocX, float ScreenLocY);
function IncomingMissile(Projectile P);

function ShouldTargetMissile(Projectile P)
{
	if (VSize(P.Location - Location) < Gun.TraceRange && AIController(Controller) != None && AIController(Controller).Skill >= 2.5 + 2.5 * Sqrt(FRand()))
		ShootMissile(P);
}


function VehicleCeaseFire(bool bWasAltFire)
{
	Super.VehicleCeaseFire(bWasAltFire);
	if (Gun != None)
	{
		Gun.WeaponCeaseFire(Controller, bWasAltFire); // WTF was this missing in ONSWeaponPawn?
	}
}


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
     GunClass=Class'PVWraith.WraithBellyGun'
     FPCamPos=(X=0.000000)
     VehiclePositionString="in a Wraith turret"
     VehicleNameString="Wraith Turret"
}
