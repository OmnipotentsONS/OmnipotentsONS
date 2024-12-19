//=============================================================================
// PROJ_Falcon_Laser
//=============================================================================

class PROJ_Falcon_Laser extends Projectile;
//class PROJ_Falcon_Laser extends ONSPlasmaProjectile;
// they copied most of ONSPlasmaProj here, execpt ignored PlasmaEffect
// this spammed client logs.

var()   class<Emitter>  HitEffectClass;
var()   float           AccelerationMagnitude;

var		FX_Laser_Blue			Laser;
var		class<FX_Laser_Blue>	LaserClass;		// Human



simulated function PostBeginPlay()
{ // from ONSPlasmaProjectile
    Super.PostBeginPlay();

    Velocity = Speed * Vector(Rotation);

	  SetupProjectile();
	  // below covered in SetupProjectile
	  /*
    if (Level.NetMode != NM_DedicatedServer)
    {
        Plasma = spawn(PlasmaEffectClass, self,, Location, Rotation);
        Plasma.SetBase(self);
    }
    */
}


simulated function PostNetBeginPlay()
{
	super.PostNetBeginPlay();

	//Velocity		= Speed * Vector(Rotation);
	//Acceleration	= Velocity;
	Acceleration = AccelerationMagnitude * Normal(Velocity);
	//SetupProjectile();
}

simulated function ProcessTouch( actor Other, vector HitLocation )
{
    if (Other != Instigator && (Vehicle(Instigator) == None || Vehicle(Instigator).Driver != Other))
    Explode(HitLocation, Normal(HitLocation-Other.Location));
}


simulated function Destroyed()
{
    if ( Laser != None )
        Laser.Destroy();

	super.Destroyed();
}

simulated function SetupProjectile()
{
	// FX
	if ( Level.NetMode != NM_DedicatedServer )
	{
		Laser = Spawn(LaserClass, Self,, Location, Rotation);

		if ( Laser != None )
		{
			Laser.SetBase( Self );
			Laser.SetScale( 0.67, 0.67 );
		}
	}
}

function BlowUp(vector HitLocation)
{
	HurtRadius(Damage, DamageRadius, MyDamageType, MomentumTransfer, HitLocation );
	MakeNoise(1.0);
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
	local PlayerController PC;
    SpawnExplodeFX(HitLocation, HitNormal);
	PlaySound(sound'WeaponSounds.BExplosion3',,2.5*TransientSoundVolume);
    if ( EffectIsRelevant(Location,false) )
    {
    	Spawn(class'NewExplosionA',,,HitLocation + HitNormal*20,rotator(HitNormal));
    	PC = Level.GetLocalPlayerController();
		if ( (PC.ViewTarget != None) && VSize(PC.ViewTarget.Location - Location) < 5000 )
	        Spawn(class'ExplosionCrap',,, HitLocation + HitNormal*20, rotator(HitNormal));
    }

	BlowUp(HitLocation);
	Destroy();
}

simulated function SpawnExplodeFX(vector HitLocation, vector HitNormal)
{
    if ( EffectIsRelevant(Location, false) )
	{
		Spawn(class'FX_PlasmaImpact',,, HitLocation + HitNormal * 2, rotator(HitNormal));
	}
}

simulated static function float GetRange()
{
    local float AccelTime;

    if (default.LifeSpan == 0.0)
        return 15000;
    else if (default.AccelerationMagnitude == 0.0)
        return (default.Speed * default.LifeSpan);


    AccelTime = (default.MaxSpeed - default.Speed) / default.AccelerationMagnitude;
    return ((0.5 * default.AccelerationMagnitude * AccelTime * AccelTime) + (default.Speed * AccelTime) + (default.MaxSpeed * (default.LifeSpan - AccelTime)));
}

//=============================================================================
// defaultproperties
//=============================================================================

defaultproperties
{
     LaserClass=Class'UT2k4Assault.FX_Laser_Blue'
  
     //Speed=30000.000
     //Speed=24000.00
     AccelerationMagnitude=24000.000000 // from Falcon
     Speed=11000.000000
     MaxSpeed=30000.000000  //slightly faster than Falcon
     // MaxSpeed=40000.000000  // too fast Pooty 1/2024
     //Damage=40.000000
     Damage=35.000000
     DamageRadius=250.0
     MomentumTransfer=1000.000000
     //MyDamageType=Class'UT2k4Assault.DamTypeSentinelLaser'
     MyDamageType=Class'CSAPVerIV.DamType_PredatorLaserPlasma'
     // Does multiplier to vehicles.
     DrawType=DT_None
     DrawScale=1.15
     AmbientSound=Sound'WeaponSounds.LinkGun.LinkGunProjectile'
     LifeSpan=3.300000
     SoundVolume=255
     SoundRadius=50.000000
     ForceType=FT_Constant
     ForceRadius=30.000000
     ForceScale=5.000000
     
     HitEffectClass=Class'Onslaught.ONSPlasmaHitGreen'
     ExplosionDecal=Class'XEffects.LinkBoltScorch'
     AmbientGlow=100
     Style=STY_Additive
     
}
