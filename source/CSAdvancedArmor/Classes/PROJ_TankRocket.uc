//=============================================================================
// rocket.
//=============================================================================
class PROJ_TankRocket extends Projectile;

var bool bRing,bHitWater,bWaterStart;
var	xEmitter SmokeTrail;
var Effects Corona;
var vector Dir;
//Homing
var Actor HomingTarget;
var vector			InitialDir;
var float AccelRate;

replication
{
	reliable if (bNetInitial && Role==ROLE_Authority)
		HomingTarget;
}

simulated function Destroyed()
{
     if (Role == ROLE_Authority && HomingTarget != None)
		if(HomingTarget.IsA('Vehicle'))
		  Vehicle(HomingTarget).NotifyEnemyLostLock();
	if ( SmokeTrail != None )
		SmokeTrail.mRegen = False;
	if ( Corona != None )
		Corona.Destroy();
	Super.Destroyed();
}


simulated function PostNetBeginPlay()
{
	local PlayerController PC;

	Super.PostNetBeginPlay();
    Acceleration = Normal(Velocity) * AccelRate;
    if ( Level.NetMode == NM_DedicatedServer )
		return;
	if ( Level.bDropDetail || (Level.DetailMode == DM_Low) )
	{
		bDynamicLight = false;
		LightType = LT_None;
	}
	else
	{
		PC = Level.GetLocalPlayerController();
		if ( (Instigator != None) && (PC == Instigator.Controller) )
			return;
		if ( (PC == None) || (PC.ViewTarget == None) || (VSize(PC.ViewTarget.Location - Location) > 3000) )
		{
			bDynamicLight = false;
			LightType = LT_None;
		}
	}
}

function SetHomingTarget()
{
	if (HomingTarget != None)
	    {
	     if(HomingTarget.IsA('Vehicle'))
		  Vehicle(HomingTarget).NotifyEnemyLostLock();
        }
	//HomingTarget = NewTarget;
	if (HomingTarget != None)
	    {
	     if(HomingTarget.IsA('Vehicle'))
		     Vehicle(HomingTarget).NotifyEnemyLockedOn();
	    }
}

simulated function Landed( vector HitNormal )
{
	Explode(Location,HitNormal);
}

simulated function ProcessTouch (Actor Other, Vector HitLocation)
{
	if ( (Other != instigator) && (!Other.IsA('Projectile') || Other.bProjTarget) )
		Explode(HitLocation, vector(rotation)*-1 );
}

function BlowUp(vector HitLocation)
{
	HurtRadius(Damage, DamageRadius, MyDamageType, MomentumTransfer, HitLocation );
	MakeNoise(1.0);
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
	local PlayerController PC;

	PlaySound(sound'WeaponSounds.BExplosion3',,2.5*TransientSoundVolume);
    if ( EffectIsRelevant(Location,false) )
    {
    	Spawn(class'NewExplosionA',,,HitLocation + HitNormal*20,rotator(HitNormal));
    	PC = Level.GetLocalPlayerController();
		if ( (PC.ViewTarget != None) && VSize(PC.ViewTarget.Location - Location) < 5000 )
	        Spawn(class'ExplosionCrap',,, HitLocation + HitNormal*20, rotator(HitNormal));
//		if ( (ExplosionDecal != None) && (Level.NetMode != NM_DedicatedServer) )
//			Spawn(ExplosionDecal,self,,Location, rotator(-HitNormal));
    }

	BlowUp(HitLocation);
	Destroy();
}

simulated function Timer()
{
	local float VelMag;
	local vector ForceDir;

	if (HomingTarget == None)
		return;

	ForceDir = Normal(HomingTarget.Location - Location);
	if (ForceDir dot InitialDir > 0)
	{
	    	// Do normal guidance to target.
	    	VelMag = VSize(Velocity);

	    	ForceDir = Normal(ForceDir * 0.7 * VelMag + Velocity);
		Velocity =  VelMag * ForceDir;
    		Acceleration = Normal(Velocity) * AccelRate;

	    	// Update rocket so it faces in the direction its going.
		SetRotation(rotator(Velocity));
	}
}




simulated function PostBeginPlay()
{
	super.PostBeginPlay();

    if ( Level.NetMode != NM_DedicatedServer)
	{
		SmokeTrail = Spawn(class'RocketTrailSmoke',self);
		Corona = Spawn(class'RocketCorona',self);
	}
	InitialDir = vector(Rotation);
	Velocity = InitialDir * Speed;

	if ( PhysicsVolume.bWaterVolume )
		Velocity = 0.6 * Velocity;



	SetTimer(0.1, true);
}

defaultproperties
{
     Speed=2550.000000
     MaxSpeed=2550.000000
     Damage=75.000000
     MomentumTransfer=50000.000000
     MyDamageType=Class'CSAdvancedArmor.DamType_HTankRocket'
     ExplosionDecal=Class'XEffects.RocketMark'
     LightType=LT_Steady
     LightEffect=LE_QuadraticNonIncidence
     LightHue=28
     LightBrightness=255.000000
     LightRadius=5.000000
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'WeaponStaticMesh.RocketProj'
     CullDistance=7500.000000
     bDynamicLight=True
     AmbientSound=Sound'WeaponSounds.RocketLauncher.RocketLauncherProjectile'
     LifeSpan=8.000000
     AmbientGlow=96
     FluidSurfaceShootStrengthMod=10.000000
     SoundVolume=255
     SoundRadius=100.000000
     bFixedRotationDir=True
     RotationRate=(Roll=50000)
     DesiredRotation=(Roll=30000)
     ForceType=FT_Constant
     ForceRadius=100.000000
     ForceScale=5.000000
}
