class FlakRatOmniMineShell extends Projectile;

// #exec TEXTURE  IMPORT NAME=NewFlakSkin FILE=textures\jflakslugel1.bmp GROUP="Skins" DXT=5

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

simulated function PostNetBeginPlay()
{
    if (Role < ROLE_Authority && Physics == PHYS_None)
    {
        Landed(Vector(Rotation));
    }
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
			spawn(class'FlakExplosion',,,HitLocation + HitNormal*16 );
		spawn(class'FlashExplosion',,,HitLocation + HitNormal*16 );
		spawn(class'RocketSmokeRing',,,HitLocation + HitNormal*16, rotator(HitNormal) );
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
    local FlakRatOmniMineProjectileBlue NewChunkBlue;
    local FlakRatOmniMineProjectileRed NewChunkRed;

	start = Location + 10 * HitNormal;
	if ( Role == ROLE_Authority )
	{
		//HurtRadius(damage, 0, MyDamageType, MomentumTransfer, HitLocation);
		HurtRadius(damage, 220, MyDamageType, MomentumTransfer, HitLocation);
		for (i=0; i<3; i++)
		{
			rot = Rotation;
			rot.yaw += FRand()*32000-16000;
			rot.pitch += FRand()*32000-16000;
			rot.roll += FRand()*32000-16000;
                if (Instigator.GetTeamNum() == 1)
                     {
                     // Blue Mine
                     NewChunkBlue = Spawn( class'FlakRatOmniMineProjectileBlue',,'', Start, rot);
                      }
                else {
                     // Red Mine
                      NewChunkRed = Spawn( class'FlakRatOmniMineProjectileRed',,'', Start, rot);
                      }
		}
	}
    Destroy();
}

defaultproperties
{
     Speed=3600.000000
     TossZ=0.000000
     Damage=90.000000
     MomentumTransfer=75000.000000
     MyDamageType=Class'FlakRatOmni.DamTypeFlakRatOmniShell'
     ExplosionDecal=Class'XEffects.ShockAltDecal'
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'WeaponStaticMesh.FlakShell'
     CullDistance=5000.000000
     Physics=PHYS_Falling
     AmbientSound=Sound'WeaponSounds.BaseProjectileSounds.BFlakCannonProjectile'
     LifeSpan=6.000000
     DrawScale=8.000000
     Skins(0)=Texture'XWeapons.Skins.NewFlakSkin'
     AmbientGlow=100
     SoundVolume=255
     SoundRadius=100.000000
     bProjTarget=True
     ForceType=FT_Constant
     ForceRadius=60.000000
     ForceScale=5.000000
}
