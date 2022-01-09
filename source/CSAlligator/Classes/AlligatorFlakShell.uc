class Alligatorflakshell extends Flakshell;

var	xemitter trail;
var vector initialDir;
var actor Glow;

simulated function PostBeginPlay()
{
	local Rotator R;
	local PlayerController PC;
	
	if ( !PhysicsVolume.bWaterVolume && (Level.NetMode != NM_DedicatedServer) )
	{
		PC = Level.GetLocalPlayerController();
		if ( (PC.ViewTarget != None) && VSize(PC.ViewTarget.Location - Location) < 6000 )
			Trail = Spawn(class'FlakShellTrail',self);
		Glow = Spawn(class'FlakGlow', self);
	}

	Super.PostBeginPlay();
	Velocity = Vector(Rotation) * Speed;  
	R = Rotation;
	R.Roll = 32768;
	SetRotation(R);
	Velocity.z += TossZ; 
	initialDir = Velocity;
}

simulated function destroyed()
{
	if ( Trail != None ) 
		Trail.mRegen=False;
	if ( glow != None )
		Glow.Destroy();
	Super.Destroyed();
}


simulated function ProcessTouch(Actor Other, Vector HitLocation)
{
	if ( Other != Instigator )
	{
		SpawnEffects(HitLocation, -1 * Normal(Velocity) );
		Explode(HitLocation,Normal(HitLocation-Other.Location));
	}
}

simulated function SpawnEffects( vector HitLocation, vector HitNormal )
{
	local PlayerController PC;

	PlaySound (Sound'WeaponSounds.BExplosion1',,3*TransientSoundVolume);
	if ( EffectIsRelevant(Location,false) )
	{
		PC = Level.GetLocalPlayerController();
		if ( (PC.ViewTarget != None) && VSize(PC.ViewTarget.Location - Location) < 3000 )
				spawn(class'AlligatorFlakExplosion',,,HitLocation + HitNormal*16 );
		spawn(class'AlligatorFlakExplosion',,,HitLocation + HitNormal*16 );
		spawn(class'AlligatorSmokeRing',,,HitLocation + HitNormal*16, rotator(HitNormal) );
		if ( (ExplosionDecal != None) && (Level.NetMode != NM_DedicatedServer) )
			Spawn(ExplosionDecal,self,,HitLocation, rotator(-HitNormal));
	}
}

simulated function Landed( vector HitNormal )
{
	SpawnEffects( Location, HitNormal );
	Explode(Location,HitNormal);
}

simulated function HitWall (vector HitNormal, actor Wall)
{
	Landed(HitNormal);
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
	local vector start;
    local rotator rot;
    local int i;
    local AlligatorFlakChunk NewChunk;

	start = Location + 10 * HitNormal;
	if ( Role == ROLE_Authority )
	{
		HurtRadius(damage, 220, MyDamageType, MomentumTransfer, HitLocation);	
		for (i=0; i<6; i++)
		{
			rot = Rotation;
			rot.yaw += FRand()*32000-16000;
			rot.pitch += FRand()*32000-16000;
			rot.roll += FRand()*32000-16000;
			NewChunk = Spawn( class 'AlligatorFlakChunk',, '', Start, rot);
		}
	}
    Destroy();
}

defaultproperties
{
     Speed=7000.000000
     TossZ=25.000000
     Damage=131.000000
     DamageRadius=660.000000
     MyDamageType=Class'CSAlligator.AlligatorFlak'
     ExplosionDecal=None
     Physics=PHYS_Flying
     AmbientSound=Sound'VMVehicleSounds-S.HoverTank.IncomingShell'
     LifeSpan=4.000000
     DrawScale=20.000000
}
