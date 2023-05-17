// ============================================================================
// Link Tank gunner projectile.
// ============================================================================
class VampireTank3ProjectileSmall extends  Projectile;

// much of this taken from PROJ_LinkTurretPlamsa, but only way to change colors on server is
// to subclass it here.

// ============================================================================
var Link3_PurplePlasma   Plasma;
var float                       VehicleDamageMult;
var float LinkMultiplier;
var int                         Links;

replication
{
    unreliable if (bNetInitial && Role == ROLE_Authority)
        Links;
}

simulated function Destroyed()
{
    if ( Plasma != None )
        Plasma.Destroy();

    super.Destroyed();
}

simulated function PostBeginPlay()
{
    local vector dir;

    Dir = Vector(Rotation);
    super.PostBeginPlay();

    if ( Level.NetMode != NM_DedicatedServer )
        Plasma = Spawn(class'Link3_PurplePlasma', Self,, Location - 50*Dir, Rotation);

    if ( Plasma != None )
        Plasma.SetBase( Self );

    Velocity         = Speed * Vector(Rotation);
}

simulated function LinkAdjust()
{
    local float ls;

    if ( Links > 0 )
    {
        ls = class'LinkFire'.default.LinkScale[ Min(Links, 5) ];

        if ( Plasma != None )
        {
            Plasma.SetSize( 1.f + ls );
           // Plasma.SetYellowColor();
           // keep it purple
        }

        MaxSpeed    = default.MaxSpeed + 350*Links;
        LightHue = 40;
    }
}

simulated function PostNetBeginPlay()
{
    Acceleration     = Velocity;

    if ( Role < ROLE_Authority )
        LinkAdjust();

    if ( (Level.NetMode != NM_DedicatedServer) && (Level.bDropDetail || (Level.DetailMode == DM_Low)) )
    {
        bDynamicLight = false;
        LightType = LT_None;
    }
}


simulated function Explode(vector HitLocation, vector HitNormal)
{
    if ( EffectIsRelevant(Location,false) )
    {
        
     Spawn(class'VampireTank3ProjSparksPurple',,, HitLocation, rotator(HitNormal));
        
    }
    
            
    PlaySound(Sound'WeaponSounds.BioRifle.BioRifleGoo2');
    Destroy();
}


/* HurtRadius()
 Hurt locally authoritative actors within the radius.
*/
simulated function HurtRadius( float DamageAmount, float DamageRadius, class<DamageType> DamageType, float Momentum, vector HitLocation )
{
    local actor Victims;
    local float damageScale, dist;
    local vector dir;

    if( bHurtEntry )
        return;

    bHurtEntry = true;
    foreach VisibleCollidingActors( class 'Actor', Victims, DamageRadius, HitLocation )
    {
        // don't let blast damage affect fluid - VisibleCollisingActors doesn't really work for them - jag
        if( (Victims != self) && (Hurtwall != Victims) && (Victims.Role == ROLE_Authority) && !Victims.IsA('FluidSurfaceInfo') )
        {
            dir = Victims.Location - HitLocation;
            dist = FMax(1,VSize(dir));
            dir = dir/dist;
            damageScale = 1 - FMax(0,(dist - Victims.CollisionRadius)/DamageRadius);
            if ( Victims.IsA('Vehicle') )
                damageScale *= VehicleDamageMult;

            if ( DamageType.Default.bDelayedDamage && (Instigator == None || Instigator.Controller == None) )
                Victims.SetDelayedDamageInstigatorController(InstigatorController);
            if ( Victims == LastTouched )
                LastTouched = None;
            Victims.TakeDamage
            (
                damageScale * DamageAmount,
                Instigator,
                Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
                (damageScale * Momentum * dir),
                DamageType
            );
            if (Vehicle(Victims) != None && Vehicle(Victims).Health > 0)
                Vehicle(Victims).DriverRadiusDamage(DamageAmount, DamageRadius, InstigatorController, DamageType, Momentum, HitLocation);
        }
    }
    if ( (LastTouched != None) && (LastTouched != self) && (LastTouched.Role == ROLE_Authority) && !LastTouched.IsA('FluidSurfaceInfo') )
    {
        Victims = LastTouched;
        LastTouched = None;
        dir = Victims.Location - HitLocation;
        dist = FMax(1,VSize(dir));
        dir = dir/dist;
        damageScale = FMax(Victims.CollisionRadius/(Victims.CollisionRadius + Victims.CollisionHeight),1 - FMax(0,(dist - Victims.CollisionRadius)/DamageRadius));
        if ( DamageType.Default.bDelayedDamage && (Instigator == None || Instigator.Controller == None) )
            Victims.SetDelayedDamageInstigatorController(InstigatorController);
        Victims.TakeDamage
        (
            damageScale * DamageAmount,
            Instigator,
            Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
            (damageScale * Momentum * dir),
            DamageType
        );
        if (Vehicle(Victims) != None && Vehicle(Victims).Health > 0)
            Vehicle(Victims).DriverRadiusDamage(DamageAmount, DamageRadius, InstigatorController, DamageType, Momentum, HitLocation);
    }

    bHurtEntry = false;
}

simulated function ProcessTouch (Actor Other, vector HitLocation)
{
    local float     AdjustedDamage;

    if (Other == Instigator) return;
    if (Other == Owner) return;

    if ( !Other.IsA('Projectile') || Other.bProjTarget )
    {
        if ( Role == ROLE_Authority )
        {
            AdjustedDamage = Damage * (LinkMultiplier + float(Links));

            if ( Other.IsA('Vehicle') )
                AdjustedDamage *= VehicleDamageMult;

            if ( Instigator == None || Instigator.Controller == None )
                Other.SetDelayedDamageInstigatorController( InstigatorController );

            Other.TakeDamage(AdjustedDamage,Instigator,HitLocation,MomentumTransfer * Normal(Velocity),MyDamageType);
        }

        Explode(HitLocation, -Normal(Velocity) );
    }
}

defaultproperties
{
     VehicleDamageMult=4.000000
     Speed=3000.000000
     MaxSpeed=5000.000000
     Damage=50.000000
     DamageRadius=120.000000
     MomentumTransfer=5000.000000
     MyDamageType=Class'LinkVehiclesOmni.DamTypeLink3SecondaryPlasma'
     MaxEffectDistance=7000.000000
     LightType=LT_Steady
     LightEffect=LE_QuadraticNonIncidence
     LightHue=100
     LightSaturation=100
     LightBrightness=255.000000
     LightRadius=3.000000
     DrawType=DT_None
     bDynamicLight=False
     AmbientSound=Sound'WeaponSounds.LinkGun.LinkGunProjectile'
     LifeSpan=4.000000
     DrawScale3D=(X=2.295000,Y=1.530000,Z=1.530000)
     FluidSurfaceShootStrengthMod=6.000000
     SoundVolume=255
     SoundRadius=50.000000
     ForceType=FT_Constant
     ForceRadius=30.000000
     ForceScale=5.000000
     LinkMultiplier = 1.000000
     Skins(0)=FinalBlend'LinkTank3Tex.VampireTank.LinkProjPurpleFB'
    
}
