class CSPlasmaFighterSecondaryProjectile extends Projectile;

#exec OBJ LOAD FILE=..\Sounds\VMVehicleSounds-S.uax
#exec AUDIO IMPORT FILE=Sounds\orangeexplosion.wav
#exec AUDIO IMPORT FILE=Sounds\orangeprojectile.wav

var Actor HomingTarget;
var vector InitialDir;

var Emitter SmokeTrailEffect;
var float AccelerationAddPerSec;
var float startTime, seekTime;
var bool bSeekTimer;


replication
{
    reliable if (bNetInitial && Role == ROLE_Authority)
        InitialDir, HomingTarget;
}

simulated function Destroyed()
{
	if ( SmokeTrailEffect != None )
		SmokeTrailEffect.Kill();

    HomingTarget = none;

	Super.Destroyed();
}

simulated function PostBeginPlay()
{
	local vector Dir;
	Dir = vector(Rotation);

	if (Level.NetMode != NM_DedicatedServer)
	{
		SmokeTrailEffect = Spawn(class'CSBomber.CSPlasmaFighterSecondaryEffect',,,Location - 15 * Dir);
		SmokeTrailEffect.Setbase(self);
	}

	InitialDir = vector(Rotation);
	Velocity = InitialDir * Speed;

	if (PhysicsVolume.bWaterVolume)
		Velocity = 0.6 * Velocity;

    startTime = Level.TimeSeconds;
	SetTimer(0.1, true);

	Super.PostBeginPlay();
}

simulated function Timer()
{
	local float VelMag, VelFactor;
	local vector ForceDir;
    local CSPlasmaFighterWeapon cannon;


    cannon = CSPlasmaFighterWeapon(Owner);
    if(Instigator != None && cannon != None && VSize(Instigator.Location - Location) > cannon.MaxLockRange)
        HomingTarget = None;

    if(Instigator == None || (Instigator != None && Instigator.Health <= 0))
        HomingTarget = None;

	if (HomingTarget == None)
		return;

	ForceDir = Normal(HomingTarget.Location - Location);

    if(VSize(HomingTarget.Location - Location) < 500 && !bSeekTimer)
    {
        bSeekTimer = true;
        seekTime = Level.TimeSeconds;
    }

    VelMag = VSize(Velocity);
    VelFactor = 0.80;
    if(bSeekTimer && Level.TimeSeconds - seekTime > 2.0)
    {
        VelFactor=1.0;
        ForceDir = HomingTarget.Location - Location;
    }

    ForceDir = Normal(ForceDir * VelFactor * VelMag + Velocity);

    Velocity =  VelMag * ForceDir; //change direction
    //Acceleration += 5 * ForceDir;
    SetRotation(rotator(ForceDir)); //rotate to match direction
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

	PlaySound(sound'CSBomber.orangeexplosion',,2.5*TransientSoundVolume);

    if ( EffectIsRelevant(Location,false) )
    {
    	Spawn(class'CSPlasmaFighterSecondaryHitEffect',,,HitLocation + HitNormal*20,rotator(HitNormal));
    	PC = Level.GetLocalPlayerController();
		if ( (PC.ViewTarget != None) && VSize(PC.ViewTarget.Location - Location) < 5000 )
	        Spawn(class'ExplosionCrap',,, HitLocation + HitNormal*20, rotator(HitNormal));
    }

	BlowUp(HitLocation);
	Destroy();
}

simulated function Tick(float deltaTime)
{
    if (VSize(Velocity) >= MaxSpeed)
	{
		Acceleration = Normal(Acceleration) * MaxSpeed;
	}
	else
		Acceleration += Normal(Velocity) * (AccelerationAddPerSec * deltaTime);
    
    Velocity = Velocity + deltaTime * Acceleration;
}

defaultproperties
{
    //pallasv2
     //AccelerationAddPerSec=2000.000000
     //Speed=5000.000000
     //MaxSpeed=15000.000000

    //avril
    //AccelerationAddPerSec=750.0
    //Speed=550.000000
    //MaxSpeed=2800.000000

    AccelerationAddPerSec=1750.0
    Speed=2800.000000
    MaxSpeed=8000.000000


    Damage=30.000000
    DamageRadius=150.000000
    MomentumTransfer=20000.000000
    Lifespan=10.0
    MyDamageType=Class'CSBomber.CSPlasmaFighterDamTypeSecondary'
    ExplosionDecal=Class'Onslaught.ONSRocketScorch'
    DrawType=DT_None
    AmbientSound=Sound'WeaponSounds.LinkGun.LinkGunProjectile'
    DrawScale=1.500000
    DrawScale3D=(Y=0.400000,Z=0.400000)
    AmbientGlow=255
    FluidSurfaceShootStrengthMod=10.000000
    SoundVolume=255
    bFixedRotationDir=True
    RotationRate=(Roll=100000)
    DesiredRotation=(Roll=900000)
    ForceType=FT_Constant
    ForceRadius=100.000000
    ForceScale=5.000000

    RemoteRole=ROLE_SimulatedProxy
    bNetTemporary=false
}
