class CSPallasMainCannonProjectile extends Projectile;

#exec OBJ LOAD FILE=..\Sounds\VMVehicleSounds-S.uax
#exec AUDIO IMPORT FILE=Sounds\pinkexplosion.wav

var Actor HomingTarget;
var vector InitialDir;

var Emitter SmokeTrailEffect;
var float AccelerationAddPerSec;


replication
{
    reliable if (bNetInitial && Role == ROLE_Authority)
        InitialDir, HomingTarget;
}

simulated function Destroyed()
{
	if ( SmokeTrailEffect != None )
		SmokeTrailEffect.Kill();

	Super.Destroyed();
}

simulated function PostBeginPlay()
{
	local vector Dir;
	Dir = vector(Rotation);

	if (Level.NetMode != NM_DedicatedServer)
	{
		SmokeTrailEffect = Spawn(class'CSPallasV2.CSPallasPlasmaEffect',,,Location - 15 * Dir);
		SmokeTrailEffect.Setbase(self);
	}

	InitialDir = vector(Rotation);
	Velocity = InitialDir * Speed;

	if (PhysicsVolume.bWaterVolume)
		Velocity = 0.6 * Velocity;

	SetTimer(0.2, true);

	Super.PostBeginPlay();
}

simulated function Timer()
{
	local float VelMag, LowestDesiredZ;
	local vector ForceDir;
    local CSPallasMainCannon cannon;

    cannon = CSPallasMainCannon(Owner);
    if(Instigator != None && cannon != None && VSize(Instigator.Location - Location) > cannon.MaxLockRange)
        HomingTarget = None;

	if (HomingTarget == None)
		return;

	ForceDir = Normal(HomingTarget.Location - Location);

    if (Instigator != None)
        LowestDesiredZ = HomingTarget.Location.Z - Abs(Instigator.Location.Z - HomingTarget.Location.Z)/2;
    else
        LowestDesiredZ = HomingTarget.Location.Z;

    if (ForceDir.Z + Location.Z < LowestDesiredZ)
        ForceDir.Z += LowestDesiredZ - (ForceDir.Z + Location.Z);

    ForceDir = Normal(ForceDir);

    // Do normal guidance to target.
    VelMag = VSize(Velocity);

    //clamp forcedir * multiplier between 0.5 and 0.8 depending on current velocity, this limits the rotation/direction change
    //ForceDir = Normal(ForceDir * FClamp((VSize(Velocity)/MaxSpeed),0.5, 0.8) * VelMag + Velocity);
    ForceDir = Normal(ForceDir * 0.6 * VelMag + Velocity);

    Velocity =  VelMag * ForceDir; //change direction
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

	PlaySound(sound'CSPallasV2.pinkexplosion',,2.5*TransientSoundVolume);

    if ( EffectIsRelevant(Location,false) )
    {
    	Spawn(class'ONSPlasmaHitPurple',,,HitLocation + HitNormal*20,rotator(HitNormal));
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
    
}

defaultproperties
{
     AccelerationAddPerSec=300.000000
     Speed=1300.000000
     MaxSpeed=2600.000000
     Damage=20.000000
     DamageRadius=250.000000
     MomentumTransfer=20000.000000
     MyDamageType=Class'CSPallasV2.CSPallasDamTypeMainCannon'
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
}
