
class FireBladeOmniNapalmGlob extends Projectile;


//=============================================================================
// Properties
//=============================================================================

var() float RestTime;
var() float DripTime;


//=============================================================================
// Variables
//=============================================================================

var vector SurfaceNormal;
var bool bCheckedSurface;
var bool bDrip;
var bool bOnMover;
var AvoidMarker Fear;
var FBONapalmFlames Trail;
var float LastDamageTime;
var vector OldLocation;
var vector RelativeVelocity;
	var bool bCanHitOwner, bHitWater;


event PreBeginPlay()
{
	// due to a crappy spawn collision check, submunition can't spawn inside
	// the simple collision of a static mesh, even though the parent projectile
	// moved there perfectly fine
	bCollideWorld = True;
	Velocity = Sqrt(FRand()) * Speed * vector(Rotation);
	LifeSpan += 2 * FRand();

	Super.PreBeginPlay();
}

/*
simulated function PostNetBeginPlay()
{
	SetOwner(None);
    LoopAnim('flying', 1.0);
	
    if (Role < ROLE_Authority && Physics == PHYS_None)
    {
        Landed(Vector(Rotation));
    }
	
	if (Level.NetMode != NM_DedicatedServer)
	{
		Trail = Spawn(class'FBONapalmFlames', Self);
	}
}
*/
simulated function PostBeginPlay()
{
	local PlayerController PC;

    Super.PostBeginPlay();

    if ( Level.NetMode != NM_DedicatedServer)
    {
		PC = Level.GetLocalPlayerController();
		if ( (PC.ViewTarget != None) && VSize(PC.ViewTarget.Location - Location) < 5500 )
			Trail = Spawn(class'FBONapalmFlames', self,, Location, Rotation);
    }

    if ( Role == ROLE_Authority )
    {
        Velocity = Speed * Vector(Rotation);
        //RandSpin(25000);
        RandSpin(50000);
        bCanHitOwner = false;
        if (Instigator.HeadVolume.bWaterVolume)
        {
            bHitWater = true;
            Velocity = 0.6*Velocity;
        }
    }
}


simulated function Destroyed()
{
	if (Fear != None)
		Fear.Destroy();
	
	if (Trail != None)
	{
		Trail.Kill();
		Trail = None;
	}
    Super.Destroyed();
}

simulated function Tick(float DeltaTime)
{
	local Actor A;
	
	RelativeVelocity = (Location - OldLocation) / DeltaTime;
	OldLocation = Location;
	
	if (Level.TimeSeconds - LastDamageTime < 0.2 || PhysicsVolume.bWaterVolume)
		return;
	
	foreach TouchingActors(class'Actor', A)
	{
		A.SetDelayedDamageInstigatorController(InstigatorController);
		A.TakeDamage(Damage, Instigator, Location, vect(0,0,0), MyDamageType);
	}
	if (Base != None)
	{
		if (Base.bBlockActors)
		{
			Base.SetDelayedDamageInstigatorController(InstigatorController);
			Base.TakeDamage(Damage, Instigator, Location, vect(0,0,0), MyDamageType);
		}
		else if (!Base.bWorldGeometry) // base no longer valid
		{
			Drop(vect(0,0,0));
		}
	}
	LastDamageTime = Level.TimeSeconds + FRand() * 0.05;
}

simulated function ProcessTouch(Actor Other, Vector HitLocation)
{
	Other.SetDelayedDamageInstigatorController(InstigatorController);
	Other.TakeDamage(Damage, Instigator, Location, vect(0,0,0), MyDamageType);
}

simulated function BaseChange()
{
	if (Base != None)
	{
		Base.SetDelayedDamageInstigatorController(InstigatorController);
		Base.TakeDamage(Damage, Instigator, Location, vect(0,0,0), MyDamageType);
	}
}

simulated function Drop(vector DropVelocity);

simulated function bool CanSplash()
{
	return bReadyToSplash && VSize(Velocity) > 100.0;
}

auto simulated state Flying
{
	simulated function Landed(vector HitNormal)
	{
		local rotator NewRot;
		
        if (Level.NetMode != NM_DedicatedServer)
        {
            PlaySound(ImpactSound, SLOT_Misc);
            // explosion effects
        }
        SurfaceNormal = HitNormal;

		//Spawn(class'DracoNapalmScorch',,,, rotator(-HitNormal));

        bCollideWorld = false;
        SetCollisionSize(30.0, 30.0);
		MakeNoise(0.3);

	    NewRot = Rotator(HitNormal);
	    NewRot.Roll += 32768;
        SetRotation(NewRot);
        SetPhysics(PHYS_None);
        bCheckedSurface = false;
		if (Level.Game != None && Level.Game.NumBots > 0 && SurfaceNormal.Z > 0.7)
			Fear = Spawn(class'AvoidMarker');
        GotoState('OnGround');
	}
	
	simulated function HitWall(vector HitNormal, Actor Wall)
	{
		Landed(HitNormal);
		if (!Wall.bStatic && !Wall.bWorldGeometry)
        {
            bOnMover = true;
            SetBase(Wall);
            if (Base == None)
                BlowUp(Location);
        }
	}
	
    function TakeDamage(int Damage, Pawn InstigatedBy, Vector HitLocation, Vector Momentum, class<DamageType> DamageType)
	{
		Velocity += 0.1 * Momentum / Mass;
	}
	
    simulated function ProcessTouch(Actor Other, Vector HitLocation)
    {
        if (Other != None && Other.bBlockActors)
			HitWall(Normal(HitLocation - Location), Other);
    }
	
	simulated function BeginState()
	{
		if (Trail != None)
			Trail.SetFlying();
	}
}

state OnGround
{
    simulated function BeginState()
    {
        PlayAnim('Hit', 0.9 + 0.1 * FRand());
        SetTimer(LifeSpan - 0.3, false);
		Velocity = vect(0,0,0);
		
		if (Trail != None)
			Trail.SetOnGround();
    }
	
	simulated function Drop(vector DropVelocity)
	{
		SetCollisionSize(default.CollisionHeight, default.CollisionRadius);
		SetPhysics(PHYS_Falling);
		Velocity = DropVelocity;
		bCollideWorld = true;
		bCheckedSurface = false;
		LoopAnim('Flying', 1.0);
		GotoState('Flying');
	}

    simulated function Timer()
    {
		if (bDrip)
		{
			bDrip = False;
			if (PhysicsVolume.bWaterVolume)
				Drop(PhysicsVolume.Gravity * -0.1);
			else
				Drop(PhysicsVolume.Gravity * 0.2);
		}
		else
		{
			BlowUp(Location);
		}
    }
	
	function PawnBaseDied()
	{
		Drop(RelativeVelocity);
	}
	
	simulated function BaseChange()
	{
		if (Base == None)
		{
			Drop(RelativeVelocity);
		}
	}

    simulated function AnimEnd(int Channel)
    {
		local float DripScale;
		local float SurfaceNormalZ;
		
        if (!bCheckedSurface)
        {
			SurfaceNormalZ = SurfaceNormal.Z;
			if (PhysicsVolume.bWaterVolume)
				SurfaceNormalZ *= -1;
			
            if (SurfaceNormalZ < -0.7)
            {
				DripScale = 0.8 + FRand() * 0.2;
                PlayAnim('Drip', 0.66 * DripScale);
				bDrip = True;
                SetTimer(DripTime / DripScale, false);
            }
            else if (SurfaceNormalZ < 0.5)
            {
                PlayAnim('Slide', 0.9 + FRand() * 0.1);
            }
            bCheckedSurface = true;
        }
    }
}

function BlowUp(Vector HitLocation)
{
    GotoState('Shrivelling');
}

state Shrivelling
{
    simulated function BeginState()
    {
        SetCollision(false, false, false);
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


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
     RestTime=3.000000
     DripTime=1.800000
     Speed=250.000000
     MaxSpeed=400.000000
     bOrientToVelocity=True
     TossZ=0
     Damage=3.500000
     MyDamageType=Class'FireBladeOmni.DamTypeFBONapalmGlob'
     ImpactSound=SoundGroup'WeaponSounds.BioRifle.BioRifleGoo2'
     bNetTemporary=False
     Physics=PHYS_Falling
     LifeSpan=3.000000
     Mesh=VertMesh'XWeapons_rc.GoopMesh'
     DrawScale=1.500000
     Skins(0)=Texture'EpicParticles.Smoke.FlameWave3'
     AmbientGlow=254
     bCollideWorld=False
     Mass=10.000000
     Buoyancy=12.000000
     CullDistance=10000
     MomentumTransfer=0.0
}
