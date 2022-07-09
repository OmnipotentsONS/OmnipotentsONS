class CSDarkLeviFlakShell extends flakshell;

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

	Super(Projectile).PostBeginPlay();
	Velocity = Vector(Rotation) * Speed;  
	R = Rotation;
	R.Roll = 32768;
	SetRotation(R);
	Velocity.z += TossZ; 
	initialDir = Velocity;
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
	local vector start;
    local rotator rot;
    local int i;
    local CSDarkLeviFlakChunk NewChunk;

	start = Location + 10 * HitNormal;
	if ( Role == ROLE_Authority )
	{
		HurtRadius(damage, damageradius, MyDamageType, MomentumTransfer, HitLocation);	
		for (i=0; i<13; i++)
		{
			rot = Rotation;
			rot.yaw += FRand()*32000-16000;
			rot.pitch += FRand()*32000-16000;
			rot.roll += FRand()*32000-16000;
			NewChunk = Spawn( class 'CSDarkLeviFlakChunk',, '', Start, rot);
		}
	}
    Destroy();
}

simulated function SpawnEffects( vector HitLocation, vector HitNormal )
{
	local PlayerController PC;

	PlaySound (Sound'WeaponSounds.BExplosion1',,3*TransientSoundVolume);
	if ( EffectIsRelevant(Location,false) )
	{
		PC = Level.GetLocalPlayerController();
		if ( (PC.ViewTarget != None) && VSize(PC.ViewTarget.Location - Location) < 3000 )
			spawn(class'CSDarkLeviFlakExplosion',,,HitLocation + HitNormal*16 );
		spawn(class'CSDarkLeviFlashExplosion',,,HitLocation + HitNormal*16 );
		spawn(class'CSDarkLeviSmokeRing',,,HitLocation + HitNormal*16, rotator(HitNormal) );
		if ( (ExplosionDecal != None) && (Level.NetMode != NM_DedicatedServer) )
			Spawn(ExplosionDecal,self,,HitLocation, rotator(-HitNormal));
	}
}

defaultproperties
{
    ExplosionDecal=class'CSDarkLeviFlakScorch'
	TossZ=+225.0
	bProjTarget=True
    speed=1200.000000
    Damage=90.000000
    //speed=6000.000000
    //bBounce=True
    //Acceleration=(X=0,Y=0,Z=-960)

    //DamageRadius=800
    DamageRadius=220
    //Damage=360.000000
    MomentumTransfer=30000
    bNetTemporary=True
    Physics=PHYS_Falling
    MyDamageType=class'CSDarkLeviDamTypeFlakShell'
    LifeSpan=6.000000
    DrawType=DT_StaticMesh
    StaticMesh=StaticMesh'WeaponStaticMesh.FlakShell'
    Skins(0)=texture'NewFlakSkin'
    DrawScale=8.0
    //DrawScale=32.0
    //DrawScale=40.0
    AmbientGlow=100
    AmbientSound=Sound'WeaponSounds.BaseProjectileSounds.BFlakCannonProjectile'
    SoundRadius=100
    SoundVolume=255
    ForceType=FT_Constant
    ForceScale=5.0
    ForceRadius=60.0
    CullDistance=+12000.0
}