//=============================================================================
// PROJ_Falcon_Laser_Red
//=============================================================================

class PROJ_Falcon_Laser_Red extends PROJ_Falcon_Laser;


simulated function SetupProjectile()
{
	super.SetupProjectile();

	if ( Laser != None )
		Laser.SetRedColor();
}

simulated function SpawnExplodeFX(vector HitLocation, vector HitNormal)
{
	local	FX_PlasmaImpact			FX_Impact;

    if ( EffectIsRelevant(Location, false) )
	{
		FX_Impact = Spawn(class'FX_PlasmaImpact',,, HitLocation + HitNormal * 2, rotator(HitNormal));
		FX_Impact.SetRedColor();
	}
}

defaultproperties
{
}
