/******************************************************************************
Flame Turret Projectiole from FlamerProjectile - USED in Firebug

Used in 2nd turret firetank/flametank
******************************************************************************/

class FireHoundFlameProjectile extends Projectile;


#exec obj load file="GeneralAmbience.uax"
//#exec audio import file=Sounds\FlameFire.wav


var() float StartSize;
var() float TargetSize;
var() float TargetSizeTime;
var() float HeightRatio;
var() float AddVelocityScale;


var array<Actor> AlreadyDamaged;


function PostBeginPlay()
{
	Super.PostBeginPlay();

	Velocity = vector(Rotation) * Speed;
	if (Instigator != None)
		Velocity += AddVelocityScale * Instigator.Velocity;
}

//No fire underwater.
simulated function PhysicsVolumeChange(PhysicsVolume NewVolume)
{
	if(NewVolume.bWaterVolume)
	{
		PlaySound(sound'GeneralAmbience.steamfx4', SLOT_Interact);

		if(Level.Netmode != NM_DedicatedServer && !Level.bDropDetail && FRand() > 0.4)
			Spawn(class'SteamEmitter');

		Destroy();
	}
}


function bool CanSplash()
{
	return false;
}

static function float GetRange()
{
	return 0.6 * default.Speed * default.LifeSpan;
}

simulated function Tick(float DeltaTime)
{
	local float RelativeTime;
	local float NewSize;

	Velocity *= 1.0 - DeltaTime;

	RelativeTime = (default.LifeSpan - LifeSpan) / default.LifeSpan;
	if (CollisionRadius < TargetSize)
	{
		NewSize = Lerp(FMin(RelativeTime / TargetSizeTime, 1.0), StartSize, TargetSize);
		SetCollisionSize(NewSize, HeightRatio * NewSize);
		ForceRadius = 1.2 * NewSize;
		//SetLocation(Location);
	}
}


simulated singular function HitWall(vector HitNormal, actor Wall)
{
	if (Wall != None && Wall.bWorldGeometry)
	{
		Velocity = MirrorVectorByNormal(Velocity, HitNormal) * 0.15;
	}

	if (Wall != None && (Wall.bWorldGeometry || Wall.bProjTarget || Wall.bBlockActors))
	{
		ProcessTouch(Wall, Location);
	}
}


simulated singular function Touch(Actor Other)
{
	if (Other != None && (Other.bWorldGeometry || Other.bProjTarget || Other.bBlockActors))
	{
		ProcessTouch(Other, Location);
		if (Role < ROLE_Authority && Other.Role == ROLE_Authority && Pawn(Other) != None)
			ClientSideTouch(Other, Location);
	}
}

simulated function ProcessTouch(Actor Victim, vector HitLocation)
{
	local float DamageScale;
	local int i, FirstEmpty;

	if (Victim == Instigator)
		return;

	FirstEmpty = AlreadyDamaged.Length;
	for (i = AlreadyDamaged.Length - 1; i >= 0; i--)
	{
		if (AlreadyDamaged[i] == Victim)
			return;
		if (AlreadyDamaged[i] == None)
			FirstEmpty = i;
	}
	AlreadyDamaged[FirstEmpty] = Victim;

	if (Instigator == None || Instigator.Controller == None)
		Victim.SetDelayedDamageInstigatorController(InstigatorController);

	DamageScale = (LifeSpan / default.LifeSpan) ** 0.25;
	Victim.TakeDamage(DamageScale * Damage, Instigator, Location, MomentumTransfer * DamageScale * Normal(Velocity), MyDamageType);
}


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
     StartSize=10.000000
     TargetSize=180.000000
     TargetSizeTime=0.700000
     HeightRatio=1.000000
     AddVelocityScale=0.900000
     Speed=3000.000000
     MaxSpeed=5000.000000
     //Damage=37.500000
     //DamageRadius=80.000000
     Damage=50.00000
     DamageRadius=175.000000
     MomentumTransfer=10000.000000
     MyDamageType=Class'FireVehiclesV2Omni.DamTypeTurretFlames'
     LightType=LT_FadeOut
     LightHue=25
     LightSaturation=30
     LightBrightness=60.000000
     LightRadius=35.000000
     DrawType=DT_None
     CullDistance=4000.000000
     //bDynamicLight=True  Causes huge FPS drop
     bIgnoreVehicles=True
     AmbientSound=Sound'GeneralAmbience.firefx14'
     //LifeSpan=1.000000
     LifeSpan=1.200000
     Acceleration=(Z=200.000000)
     bCanBeDamaged=False
     SoundVolume=255
     SoundRadius=500.000000
     CollisionRadius=5.000000
     CollisionHeight=5.000000
     bBounce=True
     ForceType=FT_DragAlong
     ForceRadius=100.000000
     ForceScale=2.500000
}

