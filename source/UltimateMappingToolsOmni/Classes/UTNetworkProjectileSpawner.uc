/******************************************************************************
Advanced network-compatible projectile spawner.

Creation date: 2010-06-07 11:32
Last change: $Id$
Copyright © 2010, Wormbo
Website: http://www.koehler-homepage.de/Wormbo/
Feel free to reuse this code. Send me a note if you found it helpful or want
to report bugs/provide improvements.
Please ask for permission first, if you intend to make money off reused code.
******************************************************************************/

class UTNetworkProjectileSpawner extends Actor placeable;


const DEG_TO_RAD  = 0.0174532925;
const DEG_TO_UROT = 182.04444444;

var() const editconst string Build;

/** Initial enabled state for TriggerToggle and TriggerControl states. */
var() bool  bInitiallyEnabled;
/** Time between projectile spawns. */
var() range SpawnInterval;
/** Maximum number of projectiles to spawn in TriggerBurst state. */
var() int   MaxBurstAmount;
/** Maximum duration to spawn projectiles in TriggerBurst state. */
var() float MaxBurstDuration;
/**
Triggering immediately starts spawning.
Otherwise wait for spawn interval to pass.
*/
var() bool bStartSpawningImmediately;

/** Set the player who (un)triggered the spawner as projectile instigator. */
var(ProjectileProperties) bool bUseTriggerInstigator;
/**
A Tag value to assign to spawned projectiles,
e.g. if you want to destroy them via scripted actions. */
var(ProjectileProperties) name  ProjectileTag;
/** Whether projectiles should be net-temporary. */
var(ProjectileProperties) bool bProjectileNetTemporary;
/** Projectile life time. */
var(ProjectileProperties) float ProjectileLifeSpan;

var(ProjectileLook) float        ProjectileScale;
var(ProjectileLook) vector       ProjectileScale3D;
var(ProjectileLook) StaticMesh   ProjectileStaticMesh;
var(ProjectileLook) Mesh         ProjectileMesh;
var(ProjectileLook) Material     ProjectileSprite;
var(ProjectileLook) class<Actor> TrailEffectClass;
var(ProjectileLook) byte         ProjectileAmbientGlow;
var(ProjectileLook) array<Material> ProjectileSkins;
var(ProjectileLook) vector       ProjectilePrePivot;
var(ProjectileLook) ERenderStyle ProjectileRenderStyle;
var(ProjectileLook) bool         bProjectileUnlit;

var(ProjectileEffects) class<Actor>     BounceEffectClass;
var(ProjectileEffects) class<Actor>     ExplosionEffectClass;
var(ProjectileEffects) class<Projector> ExplosionDecal;
var(ProjectileEffects) float            ExploWallOut;
var(ProjectileEffects) ELightEffect     ProjectileLightEffect;
var(ProjectileEffects) float            ProjectileLightRadius;
var(ProjectileEffects) float            ProjectileLightBrightness;
var(ProjectileEffects) byte             ProjectileLightHue;
var(ProjectileEffects) byte             ProjectileLightSaturation;

/** Projectile spawn sound. */
var(ProjectileSounds) Sound SpawnSound;
var(ProjectileSounds) float SpawnSoundVolume;
var(ProjectileSounds) float SpawnSoundRadius;
var(ProjectileSounds) float SpawnSoundPitch;
/** Projectile impact sound. */
var(ProjectileSounds) Sound ExplosionSound;
var(ProjectileSounds) float ExplosionSoundVolume;
var(ProjectileSounds) float ExplosionSoundRadius;
var(ProjectileSounds) float ExplosionSoundPitch;
/** Projectile impact sound. */
var(ProjectileSounds) Sound BounceSound;
var(ProjectileSounds) float BounceSoundVolume;
var(ProjectileSounds) float BounceSoundRadius;
var(ProjectileSounds) float BounceSoundPitch;
/** Projectile ambient sound. */
var(ProjectileSounds) Sound FlightAmbientSound;
var(ProjectileSounds) byte  FlightAmbientSoundVolume;
var(ProjectileSounds) byte  FlightAmbientSoundPitch;
var(ProjectileSounds) float FlightAmbientSoundRadius;

/**
Tag or name of a destination actor for spawned projectiles.
If not specified, spawner rotation is used instead.
*/
var(ProjectileDestination) name  DestinationTag;
/** Amount of randomness added to direction. (0.0-1.0) */
var(ProjectileDestination) float DirectionRandomness;
var(ProjectileDestination) bool  bRandomDestination;
var(ProjectileDestination) bool  bStartWithFirstDestination;


/**
Initial projectile speed, relative to spawner rotation.
Negative X means move backwards, Y/Z move sideways.
*/
var(ProjectileMovement) vector InitialVelocity;
/** Projectile's maximum movement speed. */
var(ProjectileMovement) float  MaxSpeed;
/** Projectile acceleration. Negative means backwards. */
var(ProjectileMovement) float  AccelRate;
var(ProjectileMovement) bool   bApplyGravity;
var(ProjectileMovement) bool   bApplyTerminalVelocity;
var(ProjectileMovement) bool   bFaceMovementDirection;
var(ProjectileMovement) int    MaxNumBounces;
var(ProjectileMovement) bool   bApplyGravityAfterBounce;
var(ProjectileMovement) float  MinBounceSpeed;
var(ProjectileMovement) rotator ProjectileRotationRate;
var(ProjectileMovement) float  BounceDampenFactor;
var(ProjectileMovement) float  BounceDampenFactorParallel;


var(ProjectileDamage) class<DamageType> DamageType;
var(ProjectileDamage) int               Damage;
var(ProjectileDamage) float             DamageRadius;
var(ProjectileDamage) float             DamageMomentum;
var(ProjectileDamage) bool              bReflectableProjectile;
var(ProjectileDamage) int               ReflectionCost;


var array<Actor> DestinationActors;
var int CurrentDestination;
var int BurstAmount;
var float BurstDuration;
var bool bEnabled, bStopped;


function BeginPlay()
{
    local Actor Dest;

    // sanity checks
    DirectionRandomness = FClamp(DirectionRandomness, 0.0, 1.0);
    MaxSpeed            = FMax(MaxSpeed, VSize(InitialVelocity));

    if (DestinationTag != '') {
        foreach AllActors(class'Actor', Dest) {
            if (Dest.Name == destinationTag || Dest.Tag == DestinationTag)
                DestinationActors[DestinationActors.Length] = Dest;
        }
    }
}


function Reset()
{
    GotoState(, 'Begin');
}


function SpawnProjectile()
{
    local class<UTNetworkSpawnerProjectile> ProjClass;
    local UTNetworkSpawnerProjectile Proj;
    local int RandomIndex;
    local vector Dest, RandomV;
    local rotator Dir;

    Dest = vector(Rotation);
    if (bRandomDestination) {
        // pick a random destination
        while (DestinationActors.Length > 0) {
            RandomIndex = Rand(DestinationActors.Length);
            if (DestinationActors[RandomIndex] != None) {
                Dest = Normal(DestinationActors[RandomIndex].Location - Location);
                break;
            }
            // remove invalid destination actor
            DestinationActors.Remove(RandomIndex, 1);
        }
    }
    else {
        while (DestinationActors.Length > 0) {
            if (CurrentDestination >= DestinationActors.Length)
                CurrentDestination = 0;
            if (DestinationActors[CurrentDestination] != None) {
                Dest = Normal(DestinationActors[CurrentDestination].Location - Location);
                break;
            }
            // remove invalid destination actor
            DestinationActors.Remove(CurrentDestination, 1);
        }
        CurrentDestination++;
    }

    if (DirectionRandomness > 0.0) {
        RandomV = VRand();
        if (RandomV dot Dest < 0)
            RandomV *= -1;
        RandomV += Dest * (1.0 / DirectionRandomness - 1.0);
        Dir = rotator(RandomV);
    }
    else {
        Dir = rotator(Dest);
    }
    Dir.Roll = Rotation.Roll;

    if (bProjectileNetTemporary)
        ProjClass = class'UTNetworkSpawnerProjectile';
    else
        ProjClass = class'UTNetworkPersistentSpawnerProjectile';

    Proj = Spawn(ProjClass, self, ProjectileTag, Location, Dir);
    if (Proj != None) {
        Proj.bCanHitInstigator = True;
    }
    if (SpawnSound != None)
        PlaySound(SpawnSound,, SpawnSoundVolume,, SpawnSoundRadius, SpawnSoundPitch);
}


function SetEnabled(bool bEnable)
{
    bEnabled = bEnable;
    if (bEnable && bStopped)
        GotoState(, 'Start');
}


state Spawning
{
Begin:
    bStopped = True;
    SetEnabled(bInitiallyEnabled);
    Stop;

Start:
    bStopped = False;
    if (bStartWithFirstDestination)
        CurrentDestination = 0;
    if (bStartSpawningImmediately)
        Goto 'Spawn';
Wait:
    Sleep(RandRange(SpawnInterval.Min, SpawnInterval.Max));
    if (!bEnabled) {
        bStopped = True;
        Stop;
    }
Spawn:
    SpawnProjectile();
    if (BurstAmount > 0 && --BurstAmount == 0) {
        bEnabled = False;
    }
    Goto 'Wait';
}

/**
Keep on spawning projectiles.
*/
auto state ConstantlySpawning extends Spawning
{
    function BeginState()
    {
        bInitiallyEnabled = True;
    }
}


/**
Triggering toggles spawning on/off.
*/
state() TriggerToggle extends Spawning
{
    function Trigger(Actor Other, Pawn EventInstigator)
    {
        if (bUseTriggerInstigator)
            Instigator = EventInstigator;
        SetEnabled(!bEnabled);
    }
}


/**
Triggering enables or disables if initially disabled or enabled respectively,
untriggering resets to initial enabled state.
*/
state() TriggerControl extends Spawning
{
    function Trigger(Actor Other, Pawn EventInstigator)
    {
        if (bUseTriggerInstigator)
            Instigator = EventInstigator;
        SetEnabled(!bInitiallyEnabled);
    }

    function UnTrigger(Actor Other, Pawn EventInstigator)
    {
        if (bUseTriggerInstigator)
            Instigator = EventInstigator;
        SetEnabled(bInitiallyEnabled);
    }
}


/**
Initially disabled. Triggering enables and spawns projectiles until either
maximum burst amount or duration is hit, then disables. Retriggering during
the burst restarts burst spawning with initial amount and duration.
*/
state() TriggerBurst extends Spawning
{
    function BeginState()
    {
        bInitiallyEnabled = False;
    }

    function Trigger(Actor Other, Pawn EventInstigator)
    {
        BurstAmount   = MaxBurstAmount;
        BurstDuration = MaxBurstDuration;

        if (bUseTriggerInstigator)
            Instigator = EventInstigator;
        SetEnabled(True);
    }

    function Tick(float DeltaTime)
    {
        if (BurstDuration > 0) {
            BurstDuration -= DeltaTime;
            if (BurstDuration <= 0)
                SetEnabled(false);
        }
    }
}


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
     Build="2010-06-08 17:38"
     SpawnInterval=(Min=1.000000,Max=1.000000)
     MaxBurstAmount=1
     MaxBurstDuration=1.000000
     bProjectileNetTemporary=True
     ProjectileLifeSpan=10.000000
     ProjectileScale=1.000000
     ProjectileScale3D=(X=1.000000,Y=1.000000,Z=1.000000)
     ProjectileRenderStyle=STY_Normal
     bProjectileUnlit=True
     SpawnSoundVolume=0.300000
     SpawnSoundRadius=300.000000
     SpawnSoundPitch=1.000000
     ExplosionSoundVolume=0.300000
     ExplosionSoundRadius=300.000000
     ExplosionSoundPitch=1.000000
     BounceSoundVolume=0.300000
     BounceSoundRadius=300.000000
     BounceSoundPitch=1.000000
     FlightAmbientSoundVolume=128
     FlightAmbientSoundPitch=64
     FlightAmbientSoundRadius=64.000000
     bRandomDestination=True
     InitialVelocity=(X=1000.000000)
     MaxSpeed=2000.000000
     bApplyTerminalVelocity=True
     bFaceMovementDirection=True
     BounceDampenFactor=0.500000
     BounceDampenFactorParallel=0.800000
     DamageType=Class'Engine.DamageType'
     ReflectionCost=10
     bStopped=True
     bNoDelete=True
     bAlwaysRelevant=True
     Texture=Texture'Engine.S_Emitter'
     bDirectional=True
}
