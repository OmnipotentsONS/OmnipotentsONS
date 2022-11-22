/******************************************************************************
Projectile for NetworkProjectileSpawner. This implementation relies only on the
replication of the owning spawner actor and grabs its properties clientsidely.

Creation date: 2010-06-07 11:31
Last change: $Id$
Copyright © 2010, Wormbo
Website: http://www.koehler-homepage.de/Wormbo/
Feel free to reuse this code. Send me a note if you found it helpful or want
to report bugs/provide improvements.
Please ask for permission first, if you intend to make money off reused code.
******************************************************************************/

class UTNetworkSpawnerProjectile extends Projectile;


var UTNetworkProjectileSpawner Spawner;
var Actor TrailEffect;
var int BouncesLeft;
var float DampenFactor, DampenFactorParallel;
var bool bCanHitInstigator;

replication
{
    reliable if (bNetInitial)
        Spawner, bCanHitInstigator;
}


event PostBeginPlay()
{
    Spawner = UTNetworkProjectileSpawner(Owner);

    Velocity     = Spawner.InitialVelocity >> Rotation;
    Acceleration = Spawner.AccelRate * vector(Rotation);
    if (Spawner.bApplyGravity)
        SetPhysics(PHYS_Falling);
    bIgnoreTerminalVelocity = !Spawner.bApplyTerminalVelocity;

    // ambient sound (also determines net relevance)
    AmbientSound = Spawner.FlightAmbientSound;
    SoundRadius  = Spawner.FlightAmbientSoundRadius;
}


simulated function Destroyed()
{
    if (LifeSpan < 0)
        Explode(vect(0,0,1), Location);
    KillTrail();
    Super.Destroyed();
}

simulated function KillTrail()
{
    if (Emitter(TrailEffect) != None)
        Emitter(TrailEffect).Kill();
    else if (xEmitter(TrailEffect) != None && xEmitter(TrailEffect).mRegen)
        xEmitter(TrailEffect).mRegen = False;
    else if (TrailEffect != None)
        TrailEffect.Destroy();
    TrailEffect = None;
}

simulated function PostNetBeginPlay()
{
    local PlayerController PC;

    if (Spawner != None) {
        if (!Spawner.bFaceMovementDirection)
            Disable('Tick');

        MaxSpeed     = Spawner.MaxSpeed;
        RotationRate = Spawner.ProjectileRotationRate;

        BouncesLeft          = Spawner.MaxNumBounces;
        DampenFactor         = Spawner.BounceDampenFactor;
        DampenFactorParallel = Spawner.BounceDampenFactorParallel;

        Damage           = Spawner.Damage;
        DamageRadius     = Spawner.DamageRadius;
        MyDamageType     = Spawner.DamageType;
        MomentumTransfer = Spawner.DamageMomentum;

        LifeSpan = Spawner.ProjectileLifeSpan;
    }
    if (Level.NetMode != NM_DedicatedServer) {
        if (Spawner != None) {
            SetDrawScale(Spawner.ProjectileScale);
            SetDrawScale3D(Spawner.ProjectileScale3D);
            PrePivot    = Spawner.ProjectilePrePivot;
            bUnlit      = Spawner.bProjectileUnlit;
            Style       = Spawner.ProjectileRenderStyle;
            AmbientGlow = Spawner.ProjectileAmbientGlow;
            if (Spawner.ProjectileStaticMesh != None) {
                SetDrawType(DT_StaticMesh);
                SetStaticMesh(Spawner.ProjectileStaticMesh);
                Skins = Spawner.ProjectileSkins;
            }
            else if (Spawner.ProjectileMesh != None) {
                SetDrawType(DT_Mesh);
                LinkMesh(Spawner.ProjectileMesh);
                Skins = Spawner.ProjectileSkins;
            }
            else if (Spawner.ProjectileSprite != None) {
                SetDrawType(DT_Sprite);
                Texture = Spawner.ProjectileSprite;
            }
            if (Spawner.TrailEffectClass != None) {
                TrailEffect = Spawn(Spawner.TrailEffectClass, Self, '', Location, Rotation);
                if (TrailEffect != None) {
                    TrailEffect.RemoteRole = ROLE_None; // so clients don't have duplicate trails on listen servers
                    TrailEffect.SetPhysics(PHYS_Trailer);
                }
            }
            ExplosionDecal = Spawner.ExplosionDecal;
        }
        if (Spawner.ProjectileLightRadius > 0) {
            PC = Level.GetLocalPlayerController();
            if (PC != None && PC.ViewTarget != None && VSize(PC.ViewTarget.Location - Location) < 4000) {
                bDynamicLight   = true;
                LightType       = LT_Steady;
                LightEffect     = Spawner.ProjectileLightEffect;
                LightRadius     = Spawner.ProjectileLightRadius;
                LightBrightness = Spawner.ProjectileLightBrightness;
                LightHue        = Spawner.ProjectileLightHue;
                LightSaturation = Spawner.ProjectileLightSaturation;
            }
        }
    }
    bReadyToSplash = true;
    SetTimer(0.1, false);
}


simulated function Tick(float DeltaTime)
{
    local rotator NewRot;

    if (Velocity != vect(0,0,0)) {
        NewRot = rotator(Velocity);
        NewRot.Roll = Rotation.Roll;
        SetRotation(NewRot);
    }
}


simulated function Timer()
{
    bCanHitInstigator = True;
}


simulated function ProcessTouch(Actor Other, vector HitLocation)
{
    local vector RefNormal, RefDir;

    if (Spawner != None && Spawner.bReflectableProjectile) {
        if (Other == Instigator)
            return;

        if (xPawn(Other) != None && xPawn(Other).CheckReflect(HitLocation, RefNormal, Spawner.ReflectionCost)) {
            if (Role == ROLE_Authority) {
                RefDir = MirrorVectorByNormal(Velocity, RefNormal);
                Other.Spawn(Class, Spawner, Tag, HitLocation + Normal(RefDir) * 20, rotator(RefDir));
                Other.Velocity = RefDir; // override spawner's initial velocity
            }
            Destroy();
            return;
        }
    }
    Super.ProcessTouch(Other, HitLocation);
}

simulated function HitWall(vector HitNormal, Actor Wall)
{
    local vector VNorm;
    local Actor BounceEffect;

    if (Pawn(Wall) == None && GameObjective(Wall) == None && BouncesLeft-- != 0) {
        VNorm = (Velocity dot HitNormal) * HitNormal;
        Velocity = -VNorm * DampenFactor + (Velocity - VNorm) * DampenFactorParallel;

        if (Spawner != None) {
            if (Spawner.BounceSound != None)
                PlaySound(Spawner.BounceSound,, Spawner.BounceSoundVolume,, Spawner.BounceSoundRadius, Spawner.BounceSoundPitch);
            if (Spawner.BounceEffectClass != None && EffectIsRelevant(Location, false)) {
                BounceEffect = Spawn(Spawner.BounceEffectClass,,,, rotator(HitNormal));
                if (BounceEffect != none)
                    BounceEffect.RemoteRole = ROLE_None;
            }
            if (VSize(Velocity) < Spawner.MinBounceSpeed && HitNormal.Z > 0.7)
                SetPhysics(PHYS_None);
            else if (Spawner.bApplyGravityAfterBounce)
                SetPhysics(PHYS_Falling);
        }
        return;
    }
    Super.HitWall(HitNormal, Wall);
}


simulated function Explode(vector HitLocation, vector HitNormal)
{
    local Actor ExplosionEffect;

    BlowUp(HitLocation);

    if (Spawner != None) {
        if (Spawner.ExplosionSound != None)
            PlaySound(Spawner.ExplosionSound,, Spawner.ExplosionSoundVolume,, Spawner.ExplosionSoundRadius, Spawner.ExplosionSoundPitch);
        if (Spawner.ExplosionEffectClass != None && EffectIsRelevant(Location, false)) {
            ExplosionEffect = Spawn(Spawner.ExplosionEffectClass,,,, rotator(HitNormal));
            if (ExplosionEffect != none)
                ExplosionEffect.RemoteRole = ROLE_None;
        }
    }
    if (!bPendingDelete)
        Destroy();
}


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
     DrawType=DT_None
     LifeSpan=30.000000
     bBounce=True
     bFixedRotationDir=True
}
