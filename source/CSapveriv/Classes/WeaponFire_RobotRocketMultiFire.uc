class WeaponFire_RobotRocketMultiFire extends ProjectileFire;


var() float TightSpread, LooseSpread;
var byte FlockIndex;
var int MaxLoad,SpawnCount;

event ModeDoFire()
{
    if ( Weapon_RobotRocketLauncher(Weapon).bTightSpread || ((Bot(Instigator.Controller) != None) && (FRand() < 0.65)) )
    {
        Spread = TightSpread;
		SpreadStyle = SS_Ring;
    }
    else
    {
		SpreadStyle = SS_Ring;
        Spread = LooseSpread;
    }
    Weapon_RobotRocketLauncher(Weapon).bTightSpread = false;
    Super.ModeDoFire();
	NextFireTime = FMax(NextFireTime, Level.TimeSeconds + FireRate);
}

simulated function vector MyGetFireStart(vector X, vector Y, vector Z)
{
     return Instigator.Location + X*ProjSpawnOffset.X + Y*ProjSpawnOffset.Y + Z*ProjSpawnOffset.Z;
}

function DoFireEffect()
{
	local Vector Start, X,Y,Z;
    local Vector FireLocation;
    local int p,q,i;
    local Rotator Aim;
	local Proj_MissileRocketProj FiredRockets[8];
	local bool bCurl;
	// Get Rocket spawn location
	if ( Excalibur_Robot(Instigator) != None )
		ProjSpawnOffset = Excalibur_Robot(Instigator).GetRocketSpawnLocation();

	Instigator.MakeNoise(1.0);
	Weapon.GetViewAxes(X,Y,Z);

	Start = MyGetFireStart(X, Y, Z);
    Aim = AdjustAim(Start, AimError);
    SpawnCount = Max(1, int(Load));

    for ( p=0; p<SpawnCount; p++ )
    {
 		Firelocation = Start - 4*((Sin(p*2*PI/MaxLoad)*8 - 7)*Y - (Cos(p*2*PI/MaxLoad)*8 - 7)*Z) - X * 8 * FRand();
        FiredRockets[p] = Proj_MissileRocketProj(SpawnProjectile(Firelocation, Aim));
    }

    if ( SpawnCount < 2 )
		return;

	FlockIndex++;
	if ( FlockIndex == 0 )
		FlockIndex = 1;

    // To get crazy flying, we tell each projectile in the flock about the others.
    for ( p = 0; p < SpawnCount; p++ )
    {
		if ( FiredRockets[p] != None )
		{
			FiredRockets[p].bCurl = bCurl;
			FiredRockets[p].FlockIndex = FlockIndex;
			i = 0;
			for ( q=0; q<SpawnCount; q++ )
				if ( (p != q) && (FiredRockets[q] != None) )
				{
					FiredRockets[p].Flock[i] = FiredRockets[q];
					i++;
				}
			bCurl = !bCurl;
			if ( Level.NetMode != NM_DedicatedServer )
				FiredRockets[p].SetTimer(0.1, true);
		}
	}

}

function ModeTick(float dt)
{
    // auto fire if loaded last rocket
    if (HoldTime > 0.0 && Load >= Weapon.AmmoAmount(ThisModeNum) && !bNowWaiting)
    {
        bIsFiring = false;
    }

    Super.ModeTick(dt);

    if (Load == 1.0 && HoldTime >= FireRate)
    {
        Load = Load + 6.0;
    }
    else if (Load == 2.0 && HoldTime >= FireRate*2.0)
    {
        Load = Load + 6.0;
    }
}


function Projectile SpawnProjectile(Vector Start, Rotator Dir)
{
    local Projectile p;
    p =Weapon_RobotRocketLauncher(Weapon).SpawnProjectile(Start, Dir);

    if ( P != None )
		p.Damage *= DamageAtten;
    return p;
}

defaultproperties
{
     TightSpread=600.000000
     LooseSpread=1000.000000
     MaxLoad=8
     ProjSpawnOffset=(X=25.000000,Z=100.000000)
     bSplashDamage=True
     bSplashJump=True
     bRecommendSplashDamage=True
     bFireOnRelease=True
     MaxHoldTime=1.000000
     FireSound=SoundGroup'WeaponSounds.RocketLauncher.RocketLauncherFire'
     FireForce="RocketLauncherFire"
     FireRate=0.950000
     AmmoClass=Class'CSAPVerIV.Ammo_Rocket'
     AmmoPerFire=1
     ProjectileClass=Class'CSAPVerIV.Proj_MissileRocketProj'
     BotRefireRate=0.600000
     WarnTargetPct=0.900000
     SpreadStyle=SS_Ring
}
