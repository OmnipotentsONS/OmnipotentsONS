/******************************************************************************
PersesOmniArtilleryTurretPawn

Creation date: 2011-08-18 22:20
Last change: $Id$
Copyright © 2011, Wormbo
Website: http://www.koehler-homepage.de/Wormbo/
Feel free to reuse this code. Send me a note if you found it helpful or want
to report bugs/provide improvements.
Please ask for permission first, if you intend to make money off reused code.
******************************************************************************/

class PersesOmniArtilleryTurretPawn extends ArtilleryWeaponPawn CacheExempt;


//=============================================================================
// Imports
//=============================================================================

// #e xec obj load file=UT3SPMA.uax 
// NOTHING HERE REFS THAT ^



//=============================================================================
// Variables
//=============================================================================

var float ClientUpdateTime;
var bool bTurnedOff;
var bool bJustDeployed;
var PersesOmniArtilleryCameraShell MortarCamera;
var rotator LastAim;


//=============================================================================
// Replication
//=============================================================================

replication
{
	reliable if (True)
		MortarCamera;

	reliable if (Role < ROLE_Authority)
		ServerAim;
}


simulated function String GetDebugName()
{
	return Name$" (build "$class'PersesOmniMAS'.default.Build$")";
}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	
	// register to make AVRiL redirection work
	if (Role == Role_Authority && !bAutoTurret && !bNonHumanControl && !IndependentVehicle())
		Level.Game.RegisterVehicle(self); // wouldn't register by default if attached turret of other vehicle
}

/** Don't draw a crosshair. */
simulated function DrawHUD(Canvas Canvas);

function bool IsDeployed()
{
	// it's a gunner seat - there's nothing else we could do besides our artillery thing
	return true;
}

function ChooseFireAt(Actor A)
{
	if (MortarCamera != None && MortarCamera.bDeployed && !MortarCamera.bShotDown && !MortarCamera.LineOfSightTo(A))
	{
		// abandon current camera because it can't see the new target
		MortarCamera.ShotDown();
	}
	
	Super.ChooseFireAt(A);
}

function VehicleFire(bool bWasAltFire)
{
	//log("VehicleFire"@bWasAltFire@MortarCamera);
	if (MortarCamera != None && !MortarCamera.bShotDown)
	{
		if (!MortarCamera.bDeployed)
		{
			// fire and altfire both cause camera deployment
			if (AIController(Instigator.Controller) != None)
			{
				return; // camera auto-deploys for bots
			}
			
			MortarCamera.Deploy();
			CustomAim = Gun.WeaponFireRotation;
			StopWeaponFiring();
			return;
		}
		else if (bWasAltFire && AIController(Instigator.Controller) == None)
		{
			MortarCamera.ShotDown();
			return;
		}
	}
	
	Super.VehicleFire(bWasAltFire);
}

/** Fire shot or deploy camera when human-controlled. */
function Fire(float F)
{
	if (MortarCamera != None && !MortarCamera.bShotDown && !MortarCamera.bDeployed && AIController(Controller) == None)
		VehicleFire(True); // don't count manual camera deployment as actual firing
	else
		Super.Fire(F);
}

/** Only used when human-controlled, and only for deploying or disconnecting the camera. */
function AltFire(optional float F)
{
	if (MortarCamera == None || MortarCamera.bShotDown || AIController(Controller) != None)
		Super.AltFire(F);
	else
		VehicleFire(True); // no need to set bWeaponIsAltFiring or call Gun.ClientStartFire
}

function ServerAim(int NewDirection)
{
	CustomAim.Yaw = NewDirection & 0xffff;
	CustomAim.Pitch = NewDirection >>> 16;
	CustomAim.Roll = 0;
}

function int LimitPitch(int Pitch)
{
	if (MortarCamera != None)
		return Clamp((Pitch << 16) >> 16, -16384, 16383) & 0xFFFF;

	return Gun.LimitPitch(Pitch, Rotation);
}

simulated function TurnOff()
{
	Super.TurnOff();
	
	bTurnedOff = True;
}

simulated function Tick(float DeltaTime)
{
	Super.Tick(DeltaTime);

	if (MortarCamera != None)
	{
		bCustomAiming = True;
		if (PersesOmniArtilleryTurret(Gun) != None && IsLocallyControlled())
			CustomAim = PersesOmniArtilleryTurret(Gun).TargetRotation;

		if (IsLocallyControlled() && IsHumanControlled())
		{
			if (!bTurnedOff && PlayerController(Controller) != None && PlayerController(Controller).ViewTarget != MortarCamera)
			{
				PlayerController(Controller).SetViewTarget(MortarCamera);
				PlayerController(Controller).bBehindView = False;
			}
			
			if (bJustDeployed || Level.TimeSeconds - ClientUpdateTime > 0.05 && CustomAim != LastAim)
			{
				ClientUpdateTime = Level.TimeSeconds;
				ServerAim(CustomAim.Yaw & 0xffff | CustomAim.Pitch << 16);
				LastAim = CustomAim;
				bJustDeployed = false;
			}
		}
		
		// OMG HACK! (what's wrong with implementing all ONSVehicle aiming methods in ONSWeaponPawn?)
		if (AIController(Controller) != None && Gun != None)
		{
			Gun.bAimable = False; // prevent rotation in the ONSWeaponPawn's native Tick (it does The Wrong Thing)
			Gun.CurrentHitLocation = Gun.WeaponFireLocation + vector(CustomAim) * Gun.AimTraceRange;
		}
	}
	else if (AIController(Controller) != None)
	{
		bCustomAiming = True;
		if (PersesOmniArtilleryTurret(Gun) != None)
		{
			CustomAim = PersesOmniArtilleryTurret(Gun).TargetRotation;
			SetRotation(CustomAim);

			Gun.bAimable = False; // prevent rotation in the ONSWeaponPawn's native Tick (it does The Wrong Thing)
			Gun.CurrentHitLocation = Gun.WeaponFireLocation + vector(CustomAim) * Gun.AimTraceRange;
		}
	}
	else
	{
		bCustomAiming = False;
		if (IsLocallyControlled() && Gun != None)
			CustomAim = Gun.WeaponFireRotation;
	}
}

simulated function Actor AlternateTarget()
{
	return MortarCamera;
}

event bool VerifyLock(Actor Aggressor, out actor NewTarget)
{
	if (MortarCamera != None && !FastTrace(VehicleBase.Location, Aggressor.Location))
	{
		NewTarget = MortarCamera;
		return False;
	}

	NewTarget = VehicleBase;
	return False;
}

simulated event Destroyed()
{
	if (MortarCamera != None)
		MortarCamera.ShotDown();

	Super.Destroyed();
}

function DriverLeft()
{
	if (MortarCamera != None)
		MortarCamera.ShotDown();

	Super.DriverLeft();
}

function Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
	if (MortarCamera != None)
		MortarCamera.ShotDown();

	Super.Died(Killer, damageType, HitLocation);
}

function bool RecommendLongRangedAttack()
{
	return true;
}

function ShouldTargetMissile(Projectile P);

static function StaticPrecache(LevelInfo L)
{
	Super.StaticPrecache(L);

	L.AddPrecacheStaticMesh(StaticMesh'ONS-BPJW1.Meshes.LargeShell');
	L.AddPrecacheStaticMesh(StaticMesh'ONS-BPJW1.Meshes.Target');
	L.AddPrecacheStaticMesh(StaticMesh'ONS-BPJW1.Meshes.Mini_Shell');
	L.AddPrecacheStaticMesh(StaticMesh'ONS-BPJW1.Meshes.TargetNo');

	L.AddPrecacheMaterial(Material'ONSBPTextures.Skins.SPMAGreen');
	L.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.MuzzleSpray');
	L.AddPrecacheMaterial(Material'ONSBPTextures.Skins.SPMATan');
	L.AddPrecacheMaterial(Material'AW-2004Particles.Fire.NapalmSpot');
	L.AddPrecacheMaterial(Material'AW-2004Particles.Fire.SmokeFragment');
	L.AddPrecacheMaterial(Material'ONSBPTextures.fX.Missile');
	L.AddPrecacheMaterial(Material'ONSBPTextures.Smoke');
	L.AddPrecacheMaterial(Material'ONSBPTextures.fX.ExploTrans');
	L.AddPrecacheMaterial(Material'ONSBPTextures.fX.Flair1');
	L.AddPrecacheMaterial(Material'ONSBPTextures.fX.Flair1Alpha');
	L.AddPrecacheMaterial(Material'ONSBPTextures.fX.seexpt');
	L.AddPrecacheMaterial(Material'ONSBPTextures.Skins.ArtilleryCamTexture');
	L.AddPrecacheMaterial(Material'ONSBPTextures.fX.TargetAlpha_test');
	L.AddPrecacheMaterial(Material'ONSBPTextures.fX.TargetAlpha_test2');
	L.AddPrecacheMaterial(Material'ONSBPTextures.fX.Fire');
	L.AddPrecacheMaterial(Material'VehicleFX.Particles.DustyCloud2');
	L.AddPrecacheMaterial(Material'VMParticleTextures.DirtKICKGROUP.dirtKICKTEX');
	L.AddPrecacheMaterial(Material'BenTex01.textures.SmokePuff01');
	L.AddPrecacheMaterial(Material'ArboreaTerrain.ground.flr02ar');
	L.AddPrecacheMaterial(Material'ONSBPTextures.fX.TargetAlphaNo');
	L.AddPrecacheMaterial(Material'AbaddonArchitecture.Base.bas28go');
}

simulated function UpdatePrecacheStaticMeshes()
{
	Level.AddPrecacheStaticMesh(StaticMesh'ONS-BPJW1.Meshes.LargeShell');
	Level.AddPrecacheStaticMesh(StaticMesh'ONS-BPJW1.Meshes.Target');
	Level.AddPrecacheStaticMesh(StaticMesh'ONS-BPJW1.Meshes.Mini_Shell');
	Level.AddPrecacheStaticMesh(StaticMesh'ONS-BPJW1.Meshes.TargetNo');

	Super.UpdatePrecacheStaticMeshes();
}

simulated function UpdatePrecacheMaterials()
{
	Level.AddPrecacheMaterial(Material'ONSBPTextures.Skins.SPMAGreen');
	Level.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.MuzzleSpray');
	Level.AddPrecacheMaterial(Material'ONSBPTextures.Skins.SPMATan');
	Level.AddPrecacheMaterial(Material'AW-2004Particles.Fire.NapalmSpot');
	Level.AddPrecacheMaterial(Material'AW-2004Particles.Fire.SmokeFragment');
	Level.AddPrecacheMaterial(Material'ONSBPTextures.fX.Missile');
	Level.AddPrecacheMaterial(Material'ONSBPTextures.Smoke');
	Level.AddPrecacheMaterial(Material'ONSBPTextures.fX.ExploTrans');
	Level.AddPrecacheMaterial(Material'ONSBPTextures.fX.Flair1');
	Level.AddPrecacheMaterial(Material'ONSBPTextures.fX.Flair1Alpha');
	Level.AddPrecacheMaterial(Material'ONSBPTextures.fX.seexpt');
	Level.AddPrecacheMaterial(Material'ONSBPTextures.Skins.ArtilleryCamTexture');
	Level.AddPrecacheMaterial(Material'ONSBPTextures.fX.TargetAlpha_test');
	Level.AddPrecacheMaterial(Material'ONSBPTextures.fX.TargetAlpha_test2');
	Level.AddPrecacheMaterial(Material'ONSBPTextures.fX.Fire');
	Level.AddPrecacheMaterial(Material'VehicleFX.Particles.DustyCloud2');
	Level.AddPrecacheMaterial(Material'VMParticleTextures.DirtKICKGROUP.dirtKICKTEX');
	Level.AddPrecacheMaterial(Material'BenTex01.textures.SmokePuff01');
	Level.AddPrecacheMaterial(Material'ArboreaTerrain.ground.flr02ar');
	Level.AddPrecacheMaterial(Material'ONSBPTextures.fX.TargetAlphaNo');
	Level.AddPrecacheMaterial(Material'AbaddonArchitecture.Base.bas28go');

	Super.UpdatePrecacheMaterials();
}


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
     FireImpulse=(X=-50000.000000)
     GunClass=Class'PersesOmni.PersesOmniArtilleryTurret'
     bHasFireImpulse=True
     bDrawDriverInTP=False
     bAllowViewChange=False
     ExitPositions(0)=(Y=-365.000000,Z=200.000000)
     ExitPositions(1)=(Y=365.000000,Z=200.000000)
     ExitPositions(2)=(Y=-365.000000,Z=-100.000000)
     ExitPositions(3)=(Y=365.000000,Z=-100.000000)
     EntryPosition=(Z=-150.000000)
     EntryRadius=150.000000
     FPCamPos=(X=160.000000,Y=-30.000000,Z=75.000000)
     TPCamDistance=375.000000
     TPCamLookat=(X=100.000000,Y=-30.000000,Z=-100.000000)
     TPCamWorldOffset=(Z=350.000000)
     TPCamDistRange=(Min=200.000000)
     DriverDamageMult=0.000000
     VehiclePositionString="in a Perses artillery turret"
     VehicleNameString="Perses Artillery Turret"
     MaxDesireability=0.600000
     bStasis=False
}
