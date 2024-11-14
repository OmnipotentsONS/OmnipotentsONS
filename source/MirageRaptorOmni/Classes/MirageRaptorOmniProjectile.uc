//-----------------------------------------------------------
//
//-----------------------------------------------------------
class MirageRaptorOmniProjectile extends Projectile
    abstract;

var()   class<Emitter>  HitEffectClass;
var()   class<Emitter>  PlasmaEffectClass;
var()   float           AccelerationMagnitude;

var     Emitter         Plasma;
var sound ImpactSounds[6];

simulated function PostBeginPlay()
{
    Super.PostBeginPlay();

    Velocity = Speed * Vector(Rotation);

    if (Level.NetMode != NM_DedicatedServer)
    {
        Plasma = spawn(PlasmaEffectClass, self,, Location, Rotation);
        Plasma.SetBase(self);
    }
}

simulated function PostNetBeginPlay()
{
    Super.PostNetBeginPlay();

    Acceleration = AccelerationMagnitude * Normal(Velocity);
}

simulated function Landed( vector HitNormal )
{
	Explode(Location,HitNormal);
}

simulated function ProcessTouch( actor Other, vector HitLocation )
{
    if (Other != Instigator && (Vehicle(Instigator) == None || Vehicle(Instigator).Driver != Other))
	Explode(HitLocation, Normal(HitLocation-Other.Location));
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
    if ( Role == ROLE_Authority )
        HurtRadius(Damage, DamageRadius, MyDamageType, MomentumTransfer, HitLocation );

    if ( EffectIsRelevant(Location,false) )
        Spawn(HitEffectClass,,, HitLocation + HitNormal*5, rotator(-HitNormal));

      Playsound(ImpactSounds[Rand(6)]);
    //PlaySound(Sound'WeaponSounds.BioRifle.BioRifleGoo2');

    Destroy();
}

simulated function Destroyed()
{
    if ( Plasma != None )
        Plasma.Destroy();

    Super.Destroyed();
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

defaultproperties
{
     HitEffectClass=Class'MirageRaptorOmni.MirageRaptorOmniHitYellow'
     ImpactSounds(0)=Sound'WeaponSounds.BaseImpactAndExplosions.BBulletImpact14'
     ImpactSounds(1)=Sound'WeaponSounds.BaseImpactAndExplosions.BBulletImpact4'
     ImpactSounds(2)=Sound'WeaponSounds.BaseImpactAndExplosions.BBulletImpact6'
     ImpactSounds(3)=Sound'WeaponSounds.BaseShieldReflections.BBulletReflect1'
     ImpactSounds(4)=Sound'WeaponSounds.BaseShieldReflections.BBulletReflect2'
     ImpactSounds(5)=Sound'WeaponSounds.BaseShieldReflections.BBulletReflect3'
     Speed=40000.000000
     MaxSpeed=40000.000000
     Damage=23.000000
     DamageRadius=64.000000
     MomentumTransfer=400.000000
     ExplosionDecal=Class'XEffects.BulletDecal'
     DrawType=DT_None
     LifeSpan=1.600000
     AmbientGlow=100
     Style=STY_Additive
     MyDamageType=Class'MirageRaptorOmni.DamTypeMirageRaptorOmniPlasma'
}
