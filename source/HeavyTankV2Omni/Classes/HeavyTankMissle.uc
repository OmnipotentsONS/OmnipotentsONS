class HeavyTankMissle extends Projectile;

#exec OBJ LOAD FILE=..\Sounds\VMVehicleSounds-S.uax

var Actor HomingTarget;
var vector InitialDir;
var float AccelRate;

var Emitter SmokeTrailEffect;
var Effects Corona;

var Emitter		TrailEmitter;
var class<Emitter>	TrailClass;

var() float NextFire;

replication
{
    reliable if (bNetInitial && Role == ROLE_Authority)
        InitialDir, HomingTarget;
}

simulated function Destroyed()
{
	if ( TrailEmitter != None )
		TrailEmitter.Destroy();

	Super.Destroyed();
}

simulated function PostBeginPlay()
{
	super.PostBeginPlay();

	InitialDir = vector(Rotation);
	Velocity = InitialDir * Speed;

	if ( PhysicsVolume.bWaterVolume )
		Velocity = 0.6 * Velocity;

	if (Level.NetMode != NM_DedicatedServer)
	{
		TrailEmitter = Spawn(TrailClass, self,, Location - 15 * InitialDir);
		TrailEmitter.SetBase(self);
	}

	SetTimer(0.1, true);
}

simulated function PostNetBeginPlay()
{
	Super.PostNetBeginPlay();

	Acceleration = Normal(Velocity) * AccelRate;
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

simulated function Landed( vector HitNormal )
{
	Explode(Location,HitNormal);
}

simulated function ProcessTouch (Actor Other, Vector HitLocation)
{
	if ( (Other != instigator) && (!Other.IsA('Projectile') || Other.bProjTarget) )
	{
		Explode(HitLocation, vect(0,0,1));
	}
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
    }

	BlowUp(HitLocation);
	Destroy();
}

function TakeDamage(int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, class<DamageType> damageType)
{
    if (Damage > 0)
        Explode(HitLocation, vect(0,0,0));
}


simulated function Tick(float DeltaTime)
{

    local HeavyTankFlak NewChunk;
    local rotator rot;
	local PlayerController PC;
    	PC = Level.GetLocalPlayerController();
	Super.Tick(DeltaTime);

if ( (Level.TimeSeconds - NextFire) > 0)
  {

   rot = rotator(Velocity);
   NewChunk = Spawn( class 'HeavyTankFlak',PC, '', Location, rot);
   NextFire = Level.TimeSeconds + 0.2;
  }

}

defaultproperties
{
     TrailClass=Class'XEffects.RedeemerTrail'
     AccelRate=2200.000000
     Speed=4000.000000
     MaxSpeed=10000.000000
     //Damage=60.000000
     Damage=175
     DamageRadius=550.000000
     MomentumTransfer=10000.000000
     MyDamageType=Class'HeavyTankV2Omni.DamTypeHeavyTankDrone'
     ExplosionDecal=Class'Onslaught.ONSRocketScorch'
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'WeaponStaticMesh.RedeemerMissile'
     AmbientSound=Sound'WeaponSounds.RocketLauncher.RocketLauncherProjectile'
     LifeSpan=3.000000
     DrawScale=1.10000
     DrawScale3D=(Y=0.400000,Z=0.400000)
     AmbientGlow=96
     FluidSurfaceShootStrengthMod=10.000000
     SoundVolume=255
     bFixedRotationDir=True
     RotationRate=(Roll=50000)
     DesiredRotation=(Roll=900000)
     ForceType=FT_Constant
     ForceRadius=100.000000
     ForceScale=5.000000
}
