class FireTankFireSmall extends Projectile;

var xEmitter Trail;
var() int BaseDamage;
var() float GloblingSpeed;
var() float RestTime;
var() float TouchDetonationDelay;
var() float DripTime;

var Vector SurfaceNormal;
var bool bCheckedSurface;
var bool bDrip;
var bool bOnMover;

var() Sound ExplodeSound;
var AvoidMarker Fear;

var float HeatDamage, DamageTime ;
var Emitter NapalmFireEffect;

simulated function PostBeginPlay()
{
    Super.PostBeginPlay();

    SetOwner(None);
    DamageTime = Level.TimeSeconds;

    LoopAnim('flying', 1.0);

    NapalmFireEffect = Spawn(class'FireTankFireNewSmall',self);
    NapalmFireEffect.SetBase(self);


    if (Role == ROLE_Authority)
    {
        Velocity = Vector(Rotation) * Speed;
        Velocity.Z += TossZ;
    }

    Instigator = None;

}

simulated function PostNetBeginPlay()
{
    if (Role < ROLE_Authority && Physics == PHYS_None)
    {
        Landed(Vector(Rotation));
    }
}

simulated function Destroyed()
{

	if ( Fear != None )
		Fear.Destroy();
    if (Trail != None)
        Trail.Destroy();
    Super.Destroyed();
}

auto state Flying
{
    simulated function Landed( Vector HitNormal )
    {
        local Rotator NewRot;
        if ( Level.NetMode != NM_DedicatedServer )
        {
            PlaySound(ImpactSound, SLOT_Misc);
        }

        SurfaceNormal = HitNormal;
        bCollideWorld = false;
        bProjTarget = true;

	    NewRot = Rotator(HitNormal);
	    NewRot.Roll += 32768;
        SetRotation(NewRot);
        SetPhysics(PHYS_None);
        bCheckedsurface = false;
        Fear = Spawn(class'AvoidMarker');
        GotoState('OnGround');
    }

    simulated function HitWall( Vector HitNormal, Actor Wall )
    {
        Landed(HitNormal);
		if ( !Wall.bStatic && !Wall.bWorldGeometry )
        {
            bOnMover = true;
            SetBase(Wall);
        }
    }

    simulated function ProcessTouch(Actor Other, Vector HitLocation)
    {
        //local FireTankSmallBlob Glob;
        //Glob = FireTankSmallBlob(Other);
        if ( Other != Instigator && Other.bBlockActors )
			HitWall( Normal(HitLocation-Location), Other );
    }
}

state OnGround
{
    simulated function BeginState()
    {
    local vector start;
    local rotator rot;
    local int i;
    //local FireTankSmallBlob NTF;

    PlaySound (Sound'WeaponSounds.BExplosion1',,3*TransientSoundVolume);
	start = Location;

    if ( Role == ROLE_Authority )
	{
		for (i=0; i<3; i++)
		{
			rot = Rotation;
			rot.yaw += FRand()*32000-16000;
			rot.pitch += FRand()*32000-16000;
			rot.roll += FRand()*32000-16000;
			//NTF = Spawn( class 'FireTankSmallBlob',, '', Start, rot);
		}
	}
    PlayAnim('hit');
    SetTimer(RestTime, false);
    }
    simulated function Timer()
    {
        if (bDrip)
        {
            bDrip = false;
            Velocity = PhysicsVolume.Gravity * 0.2;
            SetPhysics(PHYS_Falling);
            bCollideWorld = true;
            bCheckedsurface = false;
            bProjTarget = false;
            LoopAnim('flying', 1.0);
            GotoState('Flying');
        }
        else
        {
        }
    }

    simulated function ProcessTouch(Actor Other, Vector HitLocation)
    {
        if ( Other.IsA('Pawn') && (Other != Base) )
        {
            bDrip = false;
            SetTimer(TouchDetonationDelay, false);
        }
    }

    function TakeDamage( int Damage, Pawn InstigatedBy, Vector HitLocation, Vector Momentum, class<DamageType> DamageType )
    {
        if (DamageType.default.bDetonatesGoop  && DamageType.class != class'FireKill')
        {
            bDrip = false;
            SetTimer(0.1, false);
        }
    }

    simulated function AnimEnd(int Channel)
    {
        local float DotProduct;

        if (!bCheckedSurface)
        {
            DotProduct = SurfaceNormal dot Vect(0,0,-1);
            if (DotProduct > 0.7)
            {
                PlayAnim('Drip', 0.66);
                bDrip = true;
                SetTimer(DripTime, false);
                if (bOnMover)
            }
            else if (DotProduct > -0.5)
            {
                PlayAnim('Slide', 1.0);
                if (bOnMover)
            }
            bCheckedSurface = true;
        }
    }

}

function BlowUp(Vector HitLocation)
{
    Destroy();
}

state Shriveling
{
    simulated function BeginState()
    {
        bProjTarget = false;
        PlayAnim('shrivel', 1.0);
    }

    simulated function AnimEnd(int Channel)
    {
        Destroy();
    }

    simulated function ProcessTouch(Actor Other, Vector HitLocation)
    {
    }
}

simulated function Tick(float DeltaTime)
	{

	Super.Tick(DeltaTime);

	if (Level.TimeSeconds - DamageTime >= 0.200)
	{
	   HurtRadius(HeatDamage, DamageRadius, MyDamageType, MomentumTransfer, Location);
	   DamageTime = Level.TimeSeconds;
	}


	}

defaultproperties
{
     BaseDamage=1
     GloblingSpeed=200.000000
     RestTime=4.000000
     TouchDetonationDelay=1.000000
     DripTime=0.200000
     ExplodeSound=SoundGroup'WeaponSounds.BioRifle.BioRifleGoo1'
     HeatDamage=1.000000
     Speed=2000.000000
     bSwitchToZeroCollision=True
     Damage=18.000000
     DamageRadius=400.000000
     MyDamageType=Class'FireVehiclesV2Omni.FireKill'
     ImpactSound=SoundGroup'WeaponSounds.BioRifle.BioRifleGoo2'
     MaxEffectDistance=7000.000000
     LightType=LT_Steady
     LightEffect=LE_QuadraticNonIncidence
     LightHue=23
     LightSaturation=50
     LightBrightness=40.000000
     LightRadius=60.000000
     //bDynamicLight=True
     bNetTemporary=False
     bOnlyDirtyReplication=True
     Physics=PHYS_Falling
     LifeSpan=4.000000
     Mesh=VertMesh'XWeapons_rc.GoopMesh'
     Skins(0)=FinalBlend'EpicParticles.Shaders.FireFinal'
     AmbientGlow=190
     SoundVolume=255
     SoundRadius=200.000000
     CollisionRadius=10.000000
     CollisionHeight=20.000000
     bUseCollisionStaticMesh=True
}
