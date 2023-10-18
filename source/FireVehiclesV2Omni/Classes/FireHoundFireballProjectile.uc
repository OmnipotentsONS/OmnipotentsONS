class FireHoundFireballProjectile extends Projectile;

var bool		bHitWater, bWaterStart;
var vector		Dir;

// FX
var Emitter			TrailEmitter;
var class<Emitter>	TrailClass;
var Emitter SmokeTrailEffect;
var Effects Corona;
//Homing
var Actor HomingTarget;
var vector			InitialDir;
var float AccelRate;
var xEmitter Flame;
var() class<xEmitter> FlameClass;
var() class<DamageType> DamageType, BurnDamageType;
var bool bDoTouch;

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
	if ( TrailEmitter != None )
		TrailEmitter.Destroy();
    if ( SmokeTrailEffect != None )
		SmokeTrailEffect.Kill();
	if ( Corona != None )
		Corona.Destroy();
	Super.Destroyed();
}

simulated function PostNetBeginPlay()
{
	Super.PostNetBeginPlay();

	Acceleration = Normal(Velocity) * AccelRate;
if (Level.NetMode != NM_DedicatedServer)
	{
		TrailEmitter = Spawn(TrailClass, self,, Location - 1 * InitialDir);
		TrailEmitter.SetBase(self);
	}
 if (Level.NetMode != NM_DedicatedServer)
	{
		SmokeTrailEffect = Spawn(class'FireHoundFireballStream',self);
	}

}



simulated function Timer()
{
	local float VelMag;
	local vector ForceDir;
	local Pawn P;
	local FireHoundBurner Inv;

	if (HomingTarget == None)
		return;

	ForceDir = Normal(HomingTarget.Location - Location);
	if (ForceDir dot InitialDir > 0)
	{
	    	VelMag = VSize(Velocity);

	    	ForceDir = Normal(ForceDir * 0.7 * VelMag + Velocity);
		Velocity =  VelMag * ForceDir;
    		Acceleration = Normal(Velocity) * AccelRate;

		SetRotation(rotator(Velocity));
	}

	if(Role == ROLE_Authority && bDoTouch)
	{
		foreach TouchingActors(class'Pawn', P)
		{
			If(P != class'ONSPowerCore'&& P.Controller != None)
                        {
                        if(P.Health > 0 && (!Level.Game.bTeamGame || !P.Controller.SameTeamAs(InstigatorController)))
			{
				P.CreateInventory("FireHoundBurner");
				Inv = FireHoundBurner(P.FindInventoryType(class'FireHoundBurner'));

				if(Inv != None)
				{
					Inv.DamageType = BurnDamageType;
					Inv.Chef = Instigator;
					Inv.DamageDealt = 0;
					Inv.Temperature += 1.5;  //was 0.6
					Inv.WaitTime = 0;
				}
			}
			
			}
		}
	}

	bDoTouch = !bDoTouch;
}

simulated function ProcessTouch (Actor Other, Vector HitLocation)
{
	if ( (Other != instigator) && (!Other.IsA('Projectile') || Other.bProjTarget) )
	{
		Explode(HitLocation,Vect(0,0,1));
	}
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
	local PlayerController PC;

	PlaySound(sound'WeaponSounds.BExplosion5',, 2.5*TransientSoundVolume);

	if ( TrailEmitter != None )
	{
		TrailEmitter.Kill();
		TrailEmitter = None;
	}

    if ( EffectIsRelevant(Location, false) )
    {
    	Spawn(class'FireHoundFireballBlowup',,, HitLocation + HitNormal*16, rotator(HitNormal));
    	PC = Level.GetLocalPlayerController();
		if ( (PC.ViewTarget != None) && VSize(PC.ViewTarget.Location - Location) < 5000 )
	        Spawn(class'ExplosionCrap',,, HitLocation, rotator(HitNormal));

		if ( (ExplosionDecal != None) && (Level.NetMode != NM_DedicatedServer) )
			Spawn(ExplosionDecal,self,,Location, rotator(-HitNormal));
    }

	BlowUp( HitLocation + HitNormal * 2.f );
	Destroy();
}

simulated function PostBeginPlay()
{
	super.PostBeginPlay();

	InitialDir = vector(Rotation);
	Velocity = InitialDir * Speed;

	if ( PhysicsVolume.bWaterVolume )
		Velocity = 0.6 * Velocity;



	SetTimer(0.1, true);
}

defaultproperties
{
     TrailClass=Class'FireVehiclesV2Omni.FireHoundFireBallTrail'
     AccelRate=1500.000000
     DamageType=Class'FireVehiclesV2Omni.FireHoundKill'
     BurnDamageType=Class'FireVehiclesV2Omni.FireHoundBurned'
     Speed=7000.000000
     MaxSpeed=9599.000000
     Damage=150.000000
     DamageRadius=750.000000
     MomentumTransfer=1000.000000
     MyDamageType=Class'FireVehiclesV2Omni.FireHoundFireBall'
     ExplosionDecal=Class'XEffects.RocketMark'
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'WeaponStaticMesh.FlakChunk'
     AmbientSound=Sound'WeaponSounds.RocketLauncher.RocketLauncherProjectile'
     LifeSpan=5.500000
     AmbientGlow=32
     SoundVolume=255
     SoundRadius=100.000000
     bFixedRotationDir=True
     RotationRate=(Roll=50000)
     DesiredRotation=(Roll=30000)
     ForceType=FT_Constant
     ForceRadius=100.000000
     ForceScale=5.000000
}
