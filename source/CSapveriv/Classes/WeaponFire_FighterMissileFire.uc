//=============================================================================
// WeaponFire_FighterMissileFire
//=============================================================================

class WeaponFire_FighterMissileFire extends ProjectileFire;


function DoFireEffect()
{
	// Get Rocket spawn location
	if ( AirPower_Fighter(Instigator) != None )
		ProjSpawnOffset = AirPower_Fighter(Instigator).GetRocketSpawnLocation();

	MyDoFireEffect();
}
function MyDoFireEffect()
{
	local Vector Start, X,Y,Z;
	Instigator.MakeNoise(1.0);
	GetAxes(Instigator.Rotation, X, Y, Z);
	Start = MyGetFireStart(X, Y, Z);
	SpawnProjectile(Start, Instigator.Controller.Rotation);
}


function Projectile SpawnProjectile(Vector Start, Rotator Dir)
{
    local Projectile p;

    p = Weapon_Missiles(Weapon).SpawnProjectile(Start, Dir);
    if ( p != None )
		p.Damage *= DamageAtten;
    return p;
}

simulated function vector MyGetFireStart(vector X, vector Y, vector Z)
{
    return Instigator.Location + X*ProjSpawnOffset.X + Y*ProjSpawnOffset.Y + Z*ProjSpawnOffset.Z;
}



simulated function bool AllowFire()
{
    return true;
}


//=============================================================================
// defaultproperties
//=============================================================================

defaultproperties
{
     ProjSpawnOffset=(Z=-25.000000)
     bSplashDamage=True
     bSplashJump=True
     bRecommendSplashDamage=True
     bModeExclusive=False
     TweenTime=0.000000
     FireSound=Sound'AssaultSounds.HumanShip.HnShipFire02'
     FireForce="RocketLauncherFire"
     FireRate=1.200000
     AmmoClass=Class'UT2k4Assault.Ammo_Dummy'
     ProjectileClass=Class'CSAPVerIV.PROJ_Fighter_Missile'
     BotRefireRate=0.500000
     WarnTargetPct=0.900000
}
