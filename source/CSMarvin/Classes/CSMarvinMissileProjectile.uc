class CSMarvinMissileProjectile extends Projectile;

#exec OBJ LOAD FILE=..\Sounds\VMVehicleSounds-S.uax
#exec AUDIO IMPORT FILE=Sounds\orangeexplosion.wav
#exec AUDIO IMPORT FILE=Sounds\orangeprojectile.wav
#exec AUDIO IMPORT FILE=Sounds\missileambient.wav

var Actor HomingTarget;
var vector InitialDir;

var Emitter SmokeTrailEffect;
var Emitter Spinner1, Spinner2, Spinner3;
var float AccelerationAddPerSec;
var float startTime;
var float velFactor;


replication
{
    reliable if (bNetInitial && Role == ROLE_Authority)
        InitialDir, HomingTarget;
}

simulated function Destroyed()
{
	if ( SmokeTrailEffect != None )
		SmokeTrailEffect.Kill();

	if ( Spinner1 != None )
		Spinner1.Kill();

	if ( Spinner2 != None )
		Spinner2.Kill();

	if ( Spinner3 != None )
		Spinner3.Kill();

    HomingTarget = none;

	Super.Destroyed();
}

simulated function PostBeginPlay()
{
	local vector Dir;
	Dir = vector(Rotation);

	if (Level.NetMode != NM_DedicatedServer)
	{
		//SmokeTrailEffect = Spawn(class'CSMarvin.CSMarvinMissileEffect',,,Location - 15 * Dir);
		//SmokeTrailEffect.Setbase(self);

		//Spinner1 = Spawn(class'ONSDualMissileSmokeTrail',,,vect(90,-80,50) + Location - 15 * Dir);
		Spinner1 = Spawn(class'CSMarvinMissileTrailEffectBlue',,,vect(0,70,0) + Location - 15 * Dir);
		Spinner1.Setbase(self);
		Spinner1.SetRelativeLocation(dir * vect(0,70,0));

		Spinner2 = Spawn(class'CSMarvinMissileTrailEffectGreen',,,vect(0,-35,61) + Location - 15 * Dir);
		Spinner2.Setbase(self);
		Spinner2.SetRelativeLocation(dir * vect(0,-35,61));

		Spinner3 = Spawn(class'CSMarvinMissileTrailEffectRed',,,vect(0,-35,-61) + Location - 15 * Dir);
		Spinner3.Setbase(self);
		Spinner3.SetRelativeLocation(dir * vect(0,-35,-61));

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
	local float VelMag;
	local vector ForceDir;
    local CSMarvinLaserWeapon cannon;
    local float dist;

    cannon = CSMarvinLaserWeapon(Owner);
    if(Instigator != None && cannon != None && VSize(Instigator.Location - Location) > cannon.MaxLockRange)
        HomingTarget = None;

    if(Instigator == None || (Instigator != None && Instigator.Health <= 0))
        HomingTarget = None;

	if (HomingTarget == None)
		return;

    /*
    if(Level.TimeSeconds - startTime < 6.0)
        ForceDir = Normal(HomingTarget.Location - Location);
    else
        ForceDir = HomingTarget.Location - Location;
        */
    ForceDir = Normal(HomingTarget.Location - Location);

    dist = VSize(HomingTarget.Location - Location);
    if(dist < 5000)
    {
        RotationRate.Roll += (5000 - dist / 5000) * 20;

    }

    //missilepitch = 64.0 + VSize(Velocity)/MaxPitchSpeed * 32.0;
    //SoundPitch = FClamp(SoundPitch+2, 64, 2048);

    VelMag = VSize(Velocity);

    //VelFactor = FClamp(VelFactor+0.01,0,0.7);

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

	PlaySound(sound'CSMarvin.orangeexplosion',,4.0*TransientSoundVolume);

    if ( EffectIsRelevant(Location,false) )
    {
    	Spawn(class'CSMarvinMissileHitEffect',,,HitLocation + HitNormal*20,rotator(HitNormal));
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

    AccelerationAddPerSec=750.0
    //Speed=3000.000000
    //MaxSpeed=6000.000000
    Speed=2500.000000
    MaxSpeed=2900.000000
    VelFactor=0.6


    Damage=70.000000
    DamageRadius=250.000000
    MomentumTransfer=20000.000000
    Lifespan=16.0
    MyDamageType=Class'CSMarvin.CSMarvinMissileDamType'
    ExplosionDecal=Class'Onslaught.ONSRocketScorch'
    DrawType=DT_None
    //AmbientSound=Sound'CSMarvin.missileambient'
    SoundVolume=255
    //SoundVolume=80
    //TransientSoundVolume=0.01
    //TransientSoundRadius=200
    //AmbientSound=Sound'2K4MenuSounds.Generic.msfxMouseOver'
    DrawScale=1.500000
    DrawScale3D=(Y=0.400000,Z=0.400000)
    AmbientGlow=255
    FluidSurfaceShootStrengthMod=10.000000
    bFixedRotationDir=True
    //RotationRate=(Roll=100000)
    //RotationRate=(Roll=400000)
    RotationRate=(Roll=30000)
    DesiredRotation=(Roll=9000)
    ForceType=FT_Constant
    ForceRadius=100.000000
    ForceScale=5.000000

    RemoteRole=ROLE_SimulatedProxy
    bNetTemporary=false
}
