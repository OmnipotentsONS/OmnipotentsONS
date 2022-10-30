
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
