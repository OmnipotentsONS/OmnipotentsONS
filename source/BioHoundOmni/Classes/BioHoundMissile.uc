class BioHoundMissile extends Projectile;

var bool		bHitWater, bWaterStart;
var vector		Dir;

var Emitter			TrailEmitter;
var class<Emitter>	TrailClass;
var Emitter SmokeTrailEffect;
var Effects Corona;

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
	if ( TrailEmitter != None )
		TrailEmitter.Destroy();
    if ( SmokeTrailEffect != None )
		SmokeTrailEffect.Kill();
	if ( Corona != None )
		Corona.Destroy();
	Super.Destroyed();
}


function SetHomingTarget()
{
	if (HomingTarget != None)
	    {
	     if(HomingTarget.IsA('Vehicle'))
		  Vehicle(HomingTarget).NotifyEnemyLostLock();
        }
	if (HomingTarget != None)
	    {
	     if(HomingTarget.IsA('Vehicle'))
		     Vehicle(HomingTarget).NotifyEnemyLockedOn();
	    }
}

simulated function PostNetBeginPlay()
{
	Super.PostNetBeginPlay();

	Acceleration = Normal(Velocity) * AccelRate;
if (Level.NetMode != NM_DedicatedServer)
	{
		TrailEmitter = Spawn(TrailClass, self,, Location - 15 * InitialDir);
		TrailEmitter.SetBase(self);
	}
 if (Level.NetMode != NM_DedicatedServer)
	{
		SmokeTrailEffect = Spawn(class'ONSMASRocketTrailEffect',self);
		Corona = Spawn(class'RocketCorona',self);
		Corona.SetDrawScale(5.5 * Corona.default.DrawScale);
	}

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
	    	VelMag = VSize(Velocity);

	    	ForceDir = Normal(ForceDir * 0.7 * VelMag + Velocity);
		Velocity =  VelMag * ForceDir;
    		Acceleration = Normal(Velocity) * AccelRate;

		SetRotation(rotator(Velocity));
	}
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
    local vector start;
    local rotator rot;
    local int i;
    local BioHoundMissileGlob BioBLOB;

	PlaySound(sound'WeaponSounds.BExplosion3',, 2.5*TransientSoundVolume);

	if ( TrailEmitter != None )
	{
		TrailEmitter.Kill();
		TrailEmitter = None;
	}

    if ( EffectIsRelevant(Location, false) )
    {
    	Spawn(class'BioHoundMissileExplosion',,, HitLocation + HitNormal*16, rotator(HitNormal));
    	PC = Level.GetLocalPlayerController();
		if ( (PC.ViewTarget != None) && VSize(PC.ViewTarget.Location - Location) < 5000 )
	        Spawn(class'ExplosionCrap',,, HitLocation, rotator(HitNormal));

		if ( (ExplosionDecal != None) && (Level.NetMode != NM_DedicatedServer) )
			Spawn(ExplosionDecal,self,,Location, rotator(-HitNormal));
    }
	start = Location + 10 * HitNormal;
	if ( Role == ROLE_Authority )
	{
		HurtRadius(damage, 220, MyDamageType, MomentumTransfer, HitLocation);	
		for (i=0; i<12; i++)
		{
			rot = Rotation;
			rot.yaw += FRand()*32000-16000;
			rot.pitch += FRand()*32000-16000;
			rot.roll += FRand()*32000-16000;
			BioBLOB = Spawn( class 'BioHoundMissileGlob',, '', Start, rot);
		}
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
     TrailClass=Class'Onslaught.ONSAvrilSmokeTrail'
     AccelRate=1800.000000
     Speed=2800.000000
     MaxSpeed=4200.000000
     Damage=225.000000
     DamageRadius=450.000000
     MomentumTransfer=20000.000000
     MyDamageType=Class'BioHoundOmni.DamTypeBioHoundMissile'
     ExplosionDecal=Class'XEffects.RocketMark'
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'VMWeaponsSM.AVRiLGroup.AVRiLprojectileSM'
     AmbientSound=Sound'WeaponSounds.RocketLauncher.RocketLauncherProjectile'
     LifeSpan=12.000000
     DrawScale=0.300000
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
