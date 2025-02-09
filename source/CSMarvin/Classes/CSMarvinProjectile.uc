class CSMarvinProjectile extends Projectile;

#exec AUDIO IMPORT File="Sounds\PortalProjectileDestroyed.wav" Name="PortalProjectileDestroyed"

var bool bForceMinimumGrowth;
var float DefaultPortalSize;
var float StartingPortalSize;

// Distance to put portal out from wall (affects the impact emitter too)
var float PortalDistance;

var class<Emitter> ProjectileEffectClass;
var class<Emitter> ProjectileImpactEffectClass;
var Emitter ProjEffect;

simulated function PostBeginPlay()
{
	Velocity = vector(Rotation) * Speed;
	Super.PostBeginPlay();
}

simulated function PostNetBeginPlay()
{
	if (Level.Netmode != NM_DedicatedServer)
	{
        ProjEffect = Spawn(ProjectileEffectClass, self);
	}

	Acceleration = Normal(Velocity) * 3000.0;
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
	local Emitter ImpactEffect;

	if (EffectIsRelevant(Location, False))
	{
		ImpactEffect = Spawn(ProjectileImpactEffectClass,,,HitLocation + (HitNormal * (PortalDistance + 10.0)));
	}

	PlaySound(Sound'PortalProjectileDestroyed');
	Destroy();
}

simulated function Destroyed()
{
	if (ProjEffect != none)
		ProjEffect.Destroy();

	Super.Destroyed();
}

defaultproperties
{
    bForceMinimumGrowth=true
    //PortalDistance=8.000000
    PortalDistance=16.000000
    Speed=4000.000000
    MaxSpeed=4000.000000
    DamageRadius=0.000000
    MaxEffectDistance=7000.000000
    LightType=LT_Steady
    LightEffect=LE_QuadraticNonIncidence
    LightHue=100
    LightSaturation=100
    LightBrightness=255.000000
    LightRadius=3.000000
    DrawType=DT_None
    CullDistance=10000.000000
    bDynamicLight=True
    AmbientSound=Sound'WeaponSounds.LinkGun.LinkGunProjectile'
    LifeSpan=6.000000
    AmbientGlow=217
    FluidSurfaceShootStrengthMod=6.000000
    SoundVolume=255
    SoundRadius=50.000000
    bNetNotify=True
}
