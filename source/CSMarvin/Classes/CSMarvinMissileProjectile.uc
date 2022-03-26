class CSMarvinMissileProjectile extends Projectile;

#exec OBJ LOAD FILE=..\Sounds\VMVehicleSounds-S.uax
#exec AUDIO IMPORT FILE=Sounds\orangeexplosion.wav
#exec AUDIO IMPORT FILE=Sounds\orangeprojectile.wav
#exec AUDIO IMPORT FILE=Sounds\missileambient.wav

var vector InitialDir;

var Emitter SmokeTrailEffect;
var Emitter Spinner1, Spinner2, Spinner3;
var float AccelerationAddPerSec;
var float startTime;
var float velFactor;
var class<Emitter> TrailEffectClass[2];
var class<Emitter> TrailHitEffectClass[2];


replication
{
    reliable if (bNetInitial && Role == ROLE_Authority)
        InitialDir;
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

	Super.Destroyed();
}

simulated function PostBeginPlay()
{
    /*
	local vector Dir;
    local int Team;
	Dir = vector(Rotation);

	if (Level.NetMode != NM_DedicatedServer)
	{
        Team = ONSWeapon(Owner).Team;
		Spinner1 = Spawn(TrailEffectClass[Team],,,0.5*vect(0,70,0) + Location - 15 * Dir);
		Spinner1.Setbase(self);
		Spinner1.SetRelativeLocation(dir * 0.5*vect(0,70,0));

		Spinner2 = Spawn(TrailEffectClass[Team],,,0.5*vect(0,-35,61) + Location - 15 * Dir);
		Spinner2.Setbase(self);
		Spinner2.SetRelativeLocation(dir * 0.5*vect(0,-35,61));

		Spinner3 = Spawn(TrailEffectClass[Team],,,0.5*vect(0,-35,-61) + Location - 15 * Dir);
		Spinner3.Setbase(self);
		Spinner3.SetRelativeLocation(dir * 0.5*vect(0,-35,-61));

	}
    */

	InitialDir = vector(Rotation);
	Velocity = InitialDir * Speed;

	if (PhysicsVolume.bWaterVolume)
		Velocity = 0.6 * Velocity;

    startTime = Level.TimeSeconds;
	SetTimer(0.2, true);

	Super.PostBeginPlay();
}

simulated function PostNetBeginPlay()
{
	local vector Dir;
    local int Team;

    super.PostNetBeginPlay();
	if (Level.NetMode != NM_DedicatedServer)
	{
        Dir = vector(Rotation);
        Team = ONSWeapon(Owner).Team;
		Spinner1 = Spawn(TrailEffectClass[Team],,,0.5*vect(0,70,0) + Location - 15 * Dir);
		Spinner1.Setbase(self);
		Spinner1.SetRelativeLocation(dir * 0.5*vect(0,70,0));

		Spinner2 = Spawn(TrailEffectClass[Team],,,0.5*vect(0,-35,61) + Location - 15 * Dir);
		Spinner2.Setbase(self);
		Spinner2.SetRelativeLocation(dir * 0.5*vect(0,-35,61));

		Spinner3 = Spawn(TrailEffectClass[Team],,,0.5*vect(0,-35,-61) + Location - 15 * Dir);
		Spinner3.Setbase(self);
		Spinner3.SetRelativeLocation(dir * 0.5*vect(0,-35,-61));
	}
}

simulated function Timer()
{
    local float dist;

    dist = VSize(Owner.Location - Location);
    if(dist > 1000)
    {
        RotationRate.Roll += (3000 - dist / 3000) * 40;
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
    local int Team;
    Team = ONSWeapon(Owner).Team;

	PlaySound(sound'CSMarvin.orangeexplosion',,4.0*TransientSoundVolume);

    if ( EffectIsRelevant(Location,false) )
    {
    	//Spawn(class'CSMarvinMissileHitEffect',,,HitLocation + HitNormal*20,rotator(HitNormal));
    	Spawn(TrailHitEffectClass[Team],,,HitLocation + HitNormal*20,rotator(HitNormal));
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

    AccelerationAddPerSec=5000.0
    //Speed=3000.000000
    //MaxSpeed=6000.000000

    Damage=32
    DamageRadius=300.0
    Speed=8000
    MaxSpeed=13000

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
    TrailEffectClass(0)=class'CSMarvinMissileTrailEffectRed'
    TrailEffectClass(1)=class'CSMarvinMissileTrailEffectBlue'
    TrailHitEffectClass(0)=class'CSMarvinPlasmaHitRed'
    TrailHitEffectClass(1)=class'CSMarvinPlasmaHitBlue'
}
