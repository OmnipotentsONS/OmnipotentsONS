//-----------------------------------------------------------
//
//-----------------------------------------------------------
class Proj_BombShell extends Projectile;

//#exec TEXTURE  IMPORT NAME=NewFlakSkin FILE=textures\jflakslugel1.bmp GROUP="Skins" DXT=5

var	xemitter trail;
var actor Glow;
var class<Emitter> AirExplosionEffectClass;
var bool bExploded;

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
	R = Rotation;
	R.Roll = 32768;
	SetRotation(R);
}

simulated function StartTimer(float Fuse)
{
    SetTimer(Fuse, False);
}

simulated function Timer()
{
    local int i;
    local Proj_BombShellSmall SmallShell;

	PlaySound(sound'ONSBPSounds.Artillery.ShellBrakingExplode');
	if ( Level.NetMode != NM_DedicatedServer )
		spawn(class'ONSArtilleryShellSplit', self, , Location, Rotation);

    for (i=0; i<5; i++)
    {
        SmallShell = spawn(class'Proj_BombShellSmall', self, , Location, Rotation);
		if ( SmallShell != None )
			SmallShell.Velocity = Velocity + (VRand() * 500.0);
    }
    Destroy();
}

simulated function Destroyed()
{
	if ( !bExploded )
		ExplodeInAir();
	if ( Trail != None )
		Trail.mRegen=False;
	if ( glow != None )
		Glow.Destroy();
	Super.Destroyed();
}


simulated function ProcessTouch(Actor Other, Vector HitLocation)
{
	if (Other != Instigator && !Other.IsA('ONSMortarShell'))
	{
        SpawnEffects(HitLocation, -1 * Normal(Velocity) );
		Explode(HitLocation,Normal(HitLocation-Other.Location));
	}
}

simulated function SpawnEffects( vector HitLocation, vector HitNormal )
{
	local PlayerController PC;

	PlaySound(sound'ONSBPSounds.Artillery.ShellFragmentExplode', SLOT_None, 2.0);
	if ( EffectIsRelevant(Location,false) )
	{
		PC = Level.GetLocalPlayerController();
		Spawn(class'Onslaught.ONSTankHitRockEffect',,, Location, Rotation);
        Spawn(class'CSAPVerIV.FX_NukeFlashFirst',,, Location, Rotation);
        Spawn(class'CSAPVerIV.FX_NukeFlash',,, Location, Rotation);
        Spawn(class'CSAPVerIV.FX_MissileHitGlow',,, Location, Rotation);
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
	bExploded = true;
    HurtRadius(Damage, DamageRadius, MyDamageType, MomentumTransfer, HitLocation);
    Destroy();
}

simulated function ExplodeInAir()
{
	bExploded = true;
    PlaySound(sound'ONSBPSounds.Artillery.ShellFragmentExplode', SLOT_None, 2.0);
	if ( Level.NetMode != NM_DedicatedServer )
		spawn(AirExplosionEffectClass);
    HurtRadius(Damage, DamageRadius, MyDamageType, MomentumTransfer, vect(0,0,0));
    Explode(vect(0,0,0),vect(0,0,0));
    Destroy();
}

event TakeDamage(int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType)
{
    if (Damage > 0 && (EventInstigator == None || EventInstigator.Controller == None ||
                       Instigator == None || Instigator.Controller == None ||
                       !EventInstigator.Controller.SameTeamAs(Instigator.Controller)))
        ExplodeInAir();
}

defaultproperties
{
     AirExplosionEffectClass=Class'Onslaught.ONSSmallVehicleExplosionEffect'
     Speed=2500.000000
     MaxSpeed=4000.000000
     Damage=250.000000
     DamageRadius=660.000000
     MomentumTransfer=575000.000000
     MyDamageType=Class'OnslaughtBP.DamTypeArtilleryShell'
     ExplosionDecal=Class'XEffects.ShockAltDecal'
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'ONS-BPJW1.Meshes.LargeShell'
     CullDistance=10000.000000
     bNetTemporary=False
     Physics=PHYS_Falling
     AmbientSound=Sound'ONSBPSounds.Artillery.ShellAmbient'
     LifeSpan=8.000000
     DrawScale=2.500000
     AmbientGlow=100
     SoundVolume=255
     SoundRadius=100.000000
     bProjTarget=True
     bIgnoreTerminalVelocity=True
     bOrientToVelocity=True
     ForceType=FT_Constant
     ForceRadius=60.000000
     ForceScale=5.000000
}
