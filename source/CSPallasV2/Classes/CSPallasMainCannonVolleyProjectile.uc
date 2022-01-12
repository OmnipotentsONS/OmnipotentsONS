
class CSPallasMainCannonVolleyProjectile extends CSPallasMainCannonProjectile;

#exec AUDIO IMPORT FILE=Sounds\orangeexplosion.wav

simulated function PostBeginPlay()
{
	local vector Dir;
	Dir = vector(Rotation);

	if (Level.NetMode != NM_DedicatedServer)
	{
		SmokeTrailEffect = Spawn(class'CSPallasV2.CSPallasPlasmaEffectOrange',,,Location - 15 * Dir);
		SmokeTrailEffect.Setbase(self);
	}

	InitialDir = vector(Rotation);
	Velocity = InitialDir * Speed;

	if (PhysicsVolume.bWaterVolume)
		Velocity = 0.6 * Velocity;

	SetTimer(0.1, true);

	super(Projectile).PostBeginPlay();
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

    VelMag = VSize(Velocity);
    ForceDir = Normal(ForceDir * 0.60 * VelMag + Velocity);

    Velocity =  VelMag * ForceDir; //change direction
    //Acceleration += 5 * ForceDir;
    SetRotation(rotator(ForceDir)); //rotate to match direction
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

simulated function Explode(vector HitLocation, vector HitNormal)
{
	local PlayerController PC;

	PlaySound(sound'CSPallasV2.orangeexplosion',,2.5*TransientSoundVolume);

    if ( EffectIsRelevant(Location,false) )
    {
    	Spawn(class'CSPallasPlasmaHitOrange',,,HitLocation + HitNormal*20,rotator(HitNormal));
    	PC = Level.GetLocalPlayerController();
		if ( (PC.ViewTarget != None) && VSize(PC.ViewTarget.Location - Location) < 5000 )
	        Spawn(class'ExplosionCrap',,, HitLocation + HitNormal*20, rotator(HitNormal));
    }

	BlowUp(HitLocation);
	Destroy();
}

defaultproperties
{
     AccelerationAddPerSec=2000.000000
     Speed=5000.000000
     MaxSpeed=15000.000000
     Damage=15.000000
}
