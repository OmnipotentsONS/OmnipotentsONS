//=============================================================================
// PROJ_LaserPulse.
//=============================================================================
class PROJ_LaserPulse extends Projectile;

#exec OBJ LOAD FILE=XEffectMat.utx

var vector Dir;
var		FX_Laser_Blue			Laser;
var		class<FX_Laser_Blue>	LaserClass;		// Human


simulated function PostNetBeginPlay()
{
	super.PostNetBeginPlay();
    Velocity		= Speed * Vector(Rotation);
    Acceleration	= Velocity;
	SetupProjectile();
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
		    Laser.SetRedColor();
        }
	}
}
simulated function Landed( vector HitNormal )
{
	Explode(Location,HitNormal);
}

simulated function ProcessTouch (Actor Other, Vector HitLocation)
{
	if ( (Other != instigator) && (!Other.IsA('Projectile') || Other.bProjTarget) )
		Explode(HitLocation, vector(rotation)*-1 );
}

function BlowUp(vector HitLocation)
{
	HurtRadius(Damage, DamageRadius, MyDamageType, MomentumTransfer, HitLocation );
	MakeNoise(1.0);
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
	PlaySound(sound'WeaponSounds.BExplosion3',,2.5*TransientSoundVolume);
    if ( EffectIsRelevant(Location,false) )
    {
    	Spawn(class'FlakExplosion',,,HitLocation + HitNormal*16,rotator(HitNormal));
        Spawn(class'FlashExplosion',,, HitLocation, rotator(HitNormal));

		if ( (ExplosionDecal != None) && (Level.NetMode != NM_DedicatedServer) )
			Spawn(ExplosionDecal,self,,Location, rotator(-HitNormal));
    }

	BlowUp(HitLocation);
	Destroy();
}
simulated function tick (float DeltaTime)
{
 if(lifespan< 0.5)
    Explode(Location,vect(0,0,1));
}

defaultproperties
{
     LaserClass=Class'UT2k4Assault.FX_Laser_Blue'
     Speed=12000.000000
     MaxSpeed=12000.000000
     Damage=45.000000
     DamageRadius=300.000000
     MyDamageType=Class'CSAPVerIV.DamType_FighterPlasma'
     LightType=LT_Steady
     LightEffect=LE_QuadraticNonIncidence
     LightHue=45
     LightBrightness=255.000000
     LightRadius=32.000000
     DrawType=DT_None
     CullDistance=7500.000000
     bDynamicLight=True
     AmbientSound=Sound'WeaponSounds.LinkGun.LinkGunProjectile'
     LifeSpan=3.500000
     FluidSurfaceShootStrengthMod=10.000000
     SoundVolume=255
     SoundRadius=50.000000
     bFixedRotationDir=True
     RotationRate=(Roll=50000)
     DesiredRotation=(Roll=30000)
     ForceType=FT_Constant
     ForceRadius=100.000000
     ForceScale=5.000000
}
