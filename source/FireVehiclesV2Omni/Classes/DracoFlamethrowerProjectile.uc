/******************************************************************************
DracoFlamethrowerProjectile

Creation date: 2012-10-12 11:48
Last change: $Id$
Copyright © 2012, Wormbo
Website: http://www.koehler-homepage.de/Wormbo/
Feel free to reuse this code. Send me a note if you found it helpful or want
to report bugs/provide improvements.
Please ask for permission first, if you intend to make money off reused code.
******************************************************************************/

class DracoFlamethrowerProjectile extends Projectile;


//=============================================================================
// Imports
//=============================================================================

#exec obj load file="GeneralAmbience.uax"


//=============================================================================
// Properties
//=============================================================================

var() float StartSize;
var() float TargetSize;
var() float TargetSizeTime;
var() float HeightRatio;
var() float AddVelocityScale;


//=============================================================================
// Variables
//=============================================================================

var array<Actor> AlreadyDamaged;
var transient bool bResizing;


simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	Velocity = vector(Rotation) * Speed;
	if (Instigator != None)
		Velocity += AddVelocityScale * Instigator.Velocity;
}

function bool CanSplash()
{
	return false;
}

static function float GetRange()
{
	return 0.7 * default.Speed * default.LifeSpan;
}

simulated function Tick(float DeltaTime)
{
	local float RelativeTime;
	local float NewSize;

	Velocity -= Velocity * DeltaTime;

	RelativeTime = (default.LifeSpan - LifeSpan) / default.LifeSpan;
	if (CollisionRadius < TargetSize)
	{
		NewSize = Lerp(FMin(RelativeTime / TargetSizeTime, 1.0), StartSize, TargetSize);
		bResizing = True;
		SetCollisionSize(NewSize, HeightRatio * NewSize);
		SetLocation(Location);
		bResizing = False;
		ForceRadius = 1.2 * NewSize;
	}
}


simulated singular function HitWall(vector HitNormal, actor Wall)
{
	if (bResizing)
		return;
	
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
     StartSize=5.000000
     TargetSize=600.000000
     TargetSizeTime=2.000000
     HeightRatio=0.800000
     AddVelocityScale=0.900000
     Speed=3200.000000
     MaxSpeed=5000.000000
     Damage=45.000000
     DamageRadius=200.000000
     MomentumTransfer=20000.000000
     MyDamageType=Class'FireVehiclesV2Omni.DamTypeDracoFlamethrower'
     LightType=LT_FadeOut
     LightHue=25
     LightSaturation=30
     LightBrightness=60.000000
     LightRadius=30.000000
     DrawType=DT_None
     CullDistance=3000.000000
     bDynamicLight=True
     bIgnoreVehicles=True
     AmbientSound=Sound'GeneralAmbience.firefx14'
     LifeSpan=1.250000
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
