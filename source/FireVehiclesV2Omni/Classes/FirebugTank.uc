/******************************************************************************
FirebugTank

Creation date: 2012-10-11 19:06
Last change: $Id$
Copyright © 2012, Wormbo
Website: http://www.koehler-homepage.de/Wormbo/
Feel free to reuse this code. Send me a note if you found it helpful or want
to report bugs/provide improvements.
Please ask for permission first, if you intend to make money off reused code.
******************************************************************************/

class FirebugTank extends HoverTank;


//=============================================================================
// Imports
//=============================================================================

//#exec obj load file=FirebugTankMesh.ukx package=WVHoverTankV2.Firebug
//#exec audio import file=Sounds\FlameJumpSound.wav
// Reference these from Wormbo's WVHoverTankV2 package...this whole thing is dependent on it.


//=============================================================================
// Properties
//=============================================================================

var() float JumpDuration;
var() float JumpDelay;
var() float JumpForceMag;
var() float JumpTorqueMag;
var() Sound JumpSound;
var() string JumpForce;

var() float FlamerForceMag;
var() class<Projectile> FlameJumpProjectileClass;


//=============================================================================
// Variables
//=============================================================================

var float JumpCountdown, LastJumpTime;
var bool bDoFlameJump, bOldDoFlameJump, bHasJumped;
var byte LastFlameProjectileOffset;
var vector JumpDir;


//=============================================================================
// Replication
//=============================================================================

replication
{
	reliable if (bNetDirty)
		bDoFlameJump, JumpDir;
}


simulated function UpdatePrecacheMaterials()
{
	Super.UpdatePrecacheMaterials();

	Level.AddPrecacheMaterial(Texture'LBScorcht');
	Level.AddPrecacheMaterial(Texture'rocketblastmark');
	Level.AddPrecacheMaterial(Texture'EmitterTextures.MultiFrame.LargeFlames');
	Level.AddPrecacheMaterial(Texture'EpicParticles.Beams.WhiteStreak01aw');
}

static function StaticPrecache(LevelInfo L)
{
	Super.StaticPrecache(L);

	L.AddPrecacheMaterial(Texture'LBScorcht');
	L.AddPrecacheMaterial(Texture'rocketblastmark');
	L.AddPrecacheMaterial(Texture'EmitterTextures.MultiFrame.LargeFlames');
	L.AddPrecacheMaterial(Texture'EpicParticles.Beams.WhiteStreak01aw');
}


simulated event ClientVehicleExplosion(bool bFinal)
{
	local vector X, Y, Z;

	Super.ClientVehicleExplosion(bFinal);

	if (bFinal)
	{
		GetAxes(Rotation, X, Y, Z);
		Spawn(class'FirebugExplosionScorch',,, Location + CollisionHeight * Z, rot(-16384,0,0));
	}
}

function bool ImportantVehicle()
{
	return false; // not as much as other hover tanks due to limited range
}

simulated function float ChargeBar()
{
	// Clamp to 0.999 so charge bar doesn't blink when maxed
	return FMin((Level.TimeSeconds - LastJumpTime) / JumpDelay, 0.999);
}

simulated event DrivingStatusChanged()
{
	Super.DrivingStatusChanged();

	if (!bDriving)
	{
		JumpCountDown = 0.0;
		LastFlameProjectileOffset = -1;
		bHasJumped = False;
	}
}

simulated function Tick(float DeltaTime)
{
	local vector X, Y, Z, Offset;
	local int i;

	//log(HoverDustOffset.Length@LastFlameProjectileOffset@JumpCountDown@JumpDuration);

	Super.Tick(DeltaTime);

	JumpCountdown -= DeltaTime;

	CheckJump();

	if (bDoFlameJump != bOldDoFlameJump)
	{
		JumpCountdown = JumpDuration;
		bOldDoFlameJump = bDoFlameJump;
		if (Controller != Level.GetLocalPlayerController() && EffectIsRelevant(Location, false))
		{
			SpawnJumpEffect();
		}
	}

	// spawn jump flame projectiles
	if (Role == ROLE_Authority && bHasJumped && LastFlameProjectileOffset < 2 * HoverDustOffset.Length)
	{
		GetAxes(Rotation, X, Y, Z);
		i = Min(2 * HoverDustOffset.Length * (1 - JumpCountDown / JumpDuration), 2 * HoverDustOffset.Length);

		while (LastFlameProjectileOffset < i)
		{
			Offset = HoverDustOffset[(LastFlameProjectileOffset++ * 7) % HoverDustOffset.Length];
			Spawn(FlameJumpProjectileClass, Self,, Location + Offset, rotator(0.1 * VRand() - Z));
		}

		bHasJumped = LastFlameProjectileOffset < 2 * HoverDustOffset.Length;
	}
}

simulated function SpawnJumpEffect()
{
	local Emitter JumpEffect;
	local vector HN, HL;
	local vector X, Y, Z;

	JumpEffect = Spawn(class'FlameJumpEmitter');
	JumpEffect.SetBase(Self);

	GetAxes(Rotation, X, Y, Z);

	if (!FastTrace(Location - 300 * Z, Location) || Trace(HL, HN, Location - 200 * Z, Location, false, vect(100,100,100)) != None)
	{
		Spawn(class'FirebugJumpFlameScorch',,, Location, OrthoRotation(-Z, Y, X) + rot(0,0,2) * Rand(0x8000));
	}
}

simulated function CheckJump()
{
	//local vector X, Y, Z, Dir, Offset;
	//local int i;
	//const NUM_FLAMES = 16;

	// If we are on the ground, and press Rise, and we not currently in the middle of a jump, start a new one.
	if (JumpCountdown <= 0.0 && Rise >= 0 && bOnGround && Level.TimeSeconds - JumpDelay >= LastJumpTime && (bWeaponIsAltFiring || Rise > 0))
	{
		PlaySound(JumpSound,,1.0);

		if (Role == ROLE_Authority)
		{
			bDoFlameJump = !bDoFlameJump;
			JumpDir = (vect(0,0.5,0) * Throttle + vect(1,0,0) * Steering) * JumpTorqueMag;
			LastFlameProjectileOffset = 0;
			bHasJumped = True;
			/*
			GetAxes(Rotation, X, Y, Z);
			for (i = 0; i < NUM_FLAMES; i++)
			{
				Dir = 3 * (Sin(Pi * i / NUM_FLAMES) * X + Cos(Pi * i / NUM_FLAMES) * Y) - Z;
				Weapons[ActiveWeapon].Spawn(FlameJumpProjectileClass, Weapons[ActiveWeapon],, Location - 1.2 * CollisionHeight * Z, rotator(Dir));
			}
			*/
		}
		if (Level.NetMode != NM_DedicatedServer)
		{
			SpawnJumpEffect();
			ClientPlayForceFeedback(JumpForce);
		}

		if (AIController(Controller) != None)
			Rise = 0;

		LastJumpTime = Level.TimeSeconds;
	}
	//else if (Rise < 0)
	//{
	//	JumpCountdown = 0.0; // Stops any jumping that was going on.
	//}
}

simulated function KApplyForce(out vector Force, out vector Torque)
{
	local vector X, Y, Z;

	Super.KApplyForce(Force, Torque);

	if (bDriving && JumpCountdown > 0.0)
	{
		GetAxes(Rotation, X, Y, Z);
		Force += Z * JumpForceMag;
		if (JumpCountDown > 0.7 * JumpDuration)
			Torque += JumpDir.X * X + JumpDir.Y * Y;
	}

	if (bDriving && Weapons.Length > 0 && ActiveWeapon < Weapons.Length && Weapons[ActiveWeapon] != None && Weapons[ActiveWeapon].FlashCount != 0)
	{
		Force -= vector(Weapons[ActiveWeapon].WeaponFireRotation) * FlamerForceMag;
	}
}

function TakeDamage(int Damage, Pawn instigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> DamageType)
{


	if (DamageType.name == 'FlameKill')
		Damage *= 0.20;

if (DamageType.name == 'FireKill')
		Damage *= 0.25;
				
if (DamageType.name == 'Burned')
		Damage *= 0.25;
		
if (DamageType.name == 'FireBall')
		Damage *= 0.20;
		
if (DamageType.name == 'DamTypeFirebugFlame')
		Damage *= 0.50;

if (DamageType.name == 'FlameKillRaptor')
		Damage *= 0.50;

	if (DamageType.name == 'HeatRay')
		Damage *= 0.20;

if (DamageType.name == 'DamTypeDracoFlamethrower')
		Damage *= 0.30;

if (DamageType.name == 'DamTypeDracoNapalmRocket')
		Damage *= 0.25;

if (DamageType.name == 'DamTypeDracoNapalmGlob')
		Damage *= 0.50;


    Super.TakeDamage(Damage, instigatedBy, Hitlocation, Momentum, damageType);
}

function ShouldTargetMissile(Projectile P)
{
	local AIController C;

	C = AIController(Controller);
	if (C != None && C.Skill >= 3.0 && (C.Enemy == None || !C.LineOfSightTo(C.Enemy) || VSize(C.Enemy.Location - Location) > Weapons[ActiveWeapon].MaxRange()) )
		ShootMissile(P);
}

function bool Dodge(eDoubleClickDir DoubleClickMove)
{
	Rise = 1;
	return true;
}


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
     JumpDuration=0.500000
     JumpDelay=2.500000
     JumpForceMag=400.000000
     JumpTorqueMag=500.000000
     JumpSound=Sound'WVHoverTankV2.FlameJumpSound'
     JumpForce="HoverBikeJump"
     FlamerForceMag=50.000000
     FlameJumpProjectileClass=Class'FlameJumpProjectile'
     HoverDustOffset(0)=(X=112.000000,Y=-78.000000)
     HoverDustOffset(1)=(X=56.000000,Y=-78.000000)
     HoverDustOffset(2)=(X=-4.000000,Y=-78.000000)
     HoverDustOffset(3)=(X=-56.000000,Y=-78.000000)
     HoverDustOffset(4)=(X=-105.000000,Y=-78.000000)
     HoverDustOffset(5)=(X=112.000000,Y=78.000000)
     HoverDustOffset(6)=(X=56.000000,Y=78.000000)
     HoverDustOffset(7)=(X=-4.000000,Y=78.000000)
     HoverDustOffset(8)=(X=-56.000000,Y=78.000000)
     HoverDustOffset(9)=(X=-105.000000,Y=78.000000)
     EnginePitchRange=35
     RaisedHoverCheckDist=130.000000
     DustEmitterClass=Class'FireVehiclesV2Omni.FirebugDustEmitter'
     MaxGroundSpeed=1000.000000
     TurretSocketClass=Class'FireVehiclesV2Omni.FirebugTurretSocket'
     ThrusterOffsets(0)=(X=135.000000,Y=90.000000)
     ThrusterOffsets(1)=(X=135.000000)
     ThrusterOffsets(2)=(X=135.000000,Y=-90.000000)
     ThrusterOffsets(3)=(X=45.000000,Y=90.000000)
     ThrusterOffsets(4)=(X=45.000000)
     ThrusterOffsets(5)=(X=45.000000,Y=-90.000000)
     ThrusterOffsets(6)=(X=-45.000000,Y=90.000000)
     ThrusterOffsets(7)=(X=-45.000000)
     ThrusterOffsets(8)=(X=-45.000000,Y=-90.000000)
     ThrusterOffsets(9)=(X=-135.000000,Y=90.000000)
     ThrusterOffsets(10)=(X=-135.000000)
     ThrusterOffsets(11)=(X=-135.000000,Y=-90.000000)
     HoverPenScale=2.800000
     HoverCheckDist=130.000000
     MaxThrustForce=220.000000
     MaxStrafeForce=220.000000
     DriverWeapons(0)=(WeaponClass=Class'FireVehiclesV2Omni.FirebugFlameTurret',WeaponBone="MainCannonAttach")
     bHasAltFire=False
     RedSkin=Shader'WVHoverTankV2.Skins.FirebugShaderRed'
     BlueSkin=Shader'WVHoverTankV2.Skins.FirebugShaderBlue'
     DisintegrationEffectClass=Class'FireVehiclesV2Omni.FirebugExplosionEffect'
     ExplosionDamage=250.000000
     ExplosionRadius=800.000000
     ExplosionMomentum=100000.000000
     ExplosionDamageType=Class'FireVehiclesV2Omni.DamTypeFirebugExplosion'
     VehicleMass=8.000000
     bShowChargingBar=True
     ExitPositions(0)=(Y=-160.000000,Z=80.000000)
     ExitPositions(1)=(Y=160.000000,Z=80.000000)
     EntryRadius=250.000000
     FPCamPos=(X=-50.000000,Y=0.000000,Z=150.000000)
     FPCamViewOffset=(X=-30.000000)
     TPCamLookat=(Z=100.000000)
     TPCamWorldOffset=(Z=150.000000)
     VehiclePositionString="in a Firebug 2.5"
     VehicleNameString="Firebug"
     VehicleDescription="The Firebug is a small and agile hover tank that can quickly turn enemies into a smoking pile of ashes with its twin flamethrowers."
     RanOverDamageType=Class'FireVehiclesV2Omni.DamTypeFirebugRoadkill'
     CrushedDamageType=Class'FireVehiclesV2Omni.DamTypeFirebugPancake'
     bJumpCapable=True
     bCanJump=True
     HealthMax=600.000000
     Health=600
     Mesh=SkeletalMesh'WVHoverTankV2.Firebug.FirebugTankMesh'
     SoundPitch=70
     CollisionRadius=180.000000
     CollisionHeight=45.000000
}
