class CSPlasmaFighterPrimaryProjectile extends Projectile;

var()   class<Emitter>  HitEffectClass;
var()   class<Emitter>  PlasmaEffectClass;
var()   float           AccelerationMagnitude;

var     Emitter         Plasma;

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

    PlaySound(Sound'WeaponSounds.BioRifle.BioRifleGoo2');

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
    MyDamageType=class'CSBomber.CSPlasmaFighterDamTypePrimary'
    PlasmaEffectClass=class'CSBomber.CSPlasmaFighterPrimaryEffect'
    HitEffectClass=class'Onslaught.ONSPlasmaHitRed'
    Damage=30  // fires 6 volleys so 6*30 = 180
    DamageRadius=280.0
    Speed=5000
    MaxSpeed=12000
    AccelerationMagnitude=8000

    ExplosionDecal=class'LinkBoltScorch'
    Lifespan=1.6

    MomentumTransfer=4000
    Physics=PHYS_Projectile
    DrawType=DT_None
    Style=STY_Additive
    AmbientGlow=100
}