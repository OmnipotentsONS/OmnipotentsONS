//=============================================================================
// StealthBadger.
//=============================================================================
class StealthBadger extends Badger;

// "Stealth" badger that becomes invisible when not moving or firing.

var(Stealth) Material InvisibleMaterial;	// Material applied to vehicle when invisible
var(Stealth) Float MinVelocityForInvis;		// Minimum velocity to consider the vehicle "stopped"
var(Stealth) Float FireVisibleTime;			// How long after firing to stay visible
var(Stealth) Sound CloakSound;				// Sound played when cloaking
var(Stealth) Sound UnCloakSound;			// Sound played when decloaking

// Internal vars
var bool bInvisible;
var float InvisiFireTime;
var Emitter MutantFX;

// Replication Block
replication
{
	// When we become invisible, server sets bInvisible to true and replicates to client.
	// Client sets invisibility skins in PostNetReceive after being updated on bInvisible.
	unreliable if (Role == ROLE_Authority && bNetDirty)
		bInvisible;
}

// SetInvisibility
// Turns visibility on or off. Sets bInvisible and applies necessary skins.
function SetInvisibility(bool bInvis)
{
	// Only do this as ROLE_Authority.
	// bInvisible will replicate to clients and they will update skins with PostNetReceive.
	if (Role < ROLE_Authority)
		return;

	if (bInvis != bInvisible)
	{
		bInvisible = bInvis;
		if (bInvis == true)
		{
			Visibility = 0;
//			AmbientSound = None;
			PlaySound(CloakSound);
			SoundVolume = 32;
			Skins[0] = InvisibleMaterial;
			WeaponPawns[0].Gun.Skins[0] = InvisibleMaterial;
			Weapons[0].Skins[0] = InvisibleMaterial;
			Weapons[0].RepSkin = InvisibleMaterial;
            //bDrawVehicleShadow=false;
		}
		else
		{
			Visibility = default.Visibility;
//			AmbientSound = IdleSound;
			SoundVolume = 255;
			PlaySound(UncloakSound);
		    if (Team == 0 && RedSkin != None)
			{
	    	    Skins[0] = RedSkin;
				WeaponPawns[0].Gun.Skins[0] = RedSkin;
				Weapons[0].Skins[0] = RedSkin;
				Weapons[0].RepSkin = RedSkin;
			}
		    else if (Team == 1 && BlueSkin != None)
			{
	    	    Skins[0] = BlueSkin;
				WeaponPawns[0].Gun.Skins[0] = BlueSkin;
				Weapons[0].Skins[0] = BlueSkin;
				Weapons[0].RepSkin = BlueSkin;
			}
            //bDrawVehicleShadow=true;
		}
	}
}

// PostNetReceive
// Net clients receive bInvisible and update skins accordingly.
simulated event PostNetReceive()
{
	if (bInvisible)
	{
		Skins[0] = InvisibleMaterial;
		WeaponPawns[0].Gun.Skins[0] = InvisibleMaterial;
//		Weapons[0].Skins[0] = InvisibleMaterial;
	}
	else
	{
	    if (Team == 0 && RedSkin != None)
		{
    	    Skins[0] = RedSkin;
			WeaponPawns[0].Gun.Skins[0] = RedSkin;
//			Weapons[0].Skins[0] = RedSkin;
		}
	    else if (Team == 1 && BlueSkin != None)
		{
    	    Skins[0] = BlueSkin;
			WeaponPawns[0].Gun.Skins[0] = BlueSkin;
//			Weapons[0].Skins[0] = BlueSkin;
		}
	}
}

// KDriverLeave
// Turn visible again if driver leaves.
function bool KDriverLeave(bool bForceLeave)
{
	if (Super.KDriverLeave(bForceLeave))
	{
		SetInvisibility(false);
		return true;
	}
	else
		return false;
}

// DriverDied
// Turn visible again if driver dies.
function DriverDied()
{
	SetInvisibility(false);
	Super.DriverDied();
}

// WeaponFired
// Called by this vehicle's weapons. Stay visible while firing.
function WeaponFired()
{
	InvisiFireTime = Level.TimeSeconds;
	if (bInvisible)
		SetInvisibility(false);
}

// Tick
// Update visibility depending on whether vehicle is moving or not.
event Tick(float Delta)
{
	Super.Tick(Delta);

	// Never become invisible if we have no driver
	if (Role < ROLE_Authority || Driver == None)
		return;

	// Stay visible a set period of time after firing.
	if (InvisiFireTime > 0 && Level.TimeSeconds - InvisiFireTime < FireVisibleTime)
		return;

	if (VSize(Velocity) <= MinVelocityForInvis)
		SetInvisibility(true);
	else
		SetInvisibility(false);
}

defaultproperties
{
     InvisibleMaterial=Shader'MoreBadgers.Stealth.InvisiBadger'
     MinVelocityForInvis=999999.000000
     FireVisibleTime=1.000000
     CloakSound=Sound'ONSBPSounds.ShockTank.ShieldActivate'
     UnCloakSound=Sound'ONSBPSounds.ShockTank.ShieldOff'
     GearRatios(0)=-1.000000
     GearRatios(1)=0.800000
     GearRatios(2)=1.000000
     GearRatios(3)=1.200000
     GearRatios(4)=1.600000
     DustSlipRate=0.000000
     DustSlipThresh=0.000000
     bMakeBrakeLights=False
     DaredevilThreshInAirTime=1.200000
     DriverWeapons(0)=(WeaponClass=Class'CSBadgerFix.StealthBadgerMinigun')
     PassengerWeapons(0)=(WeaponPawnClass=Class'CSBadgerFix.StealthBadgerTurretPawn')
     RedSkin=Texture'MoreBadgers.Stealth.DarkBadger_Red'
     BlueSkin=Texture'MoreBadgers.Stealth.DarkBadger_Blue'
     HeadlightCoronaMaterial=None
     HeadlightProjectorMaterial=None
     HeadlightProjectorScale=0.000000
     Begin Object Class=SVehicleWheel Name=SVehicleWheel12
         bPoweredWheel=True
         bHandbrakeWheel=True
         BoneName="RightRearTIRe"
         BoneRollAxis=AXIS_Y
         BoneOffset=(X=-20.000000)
         WheelRadius=26.000000
         SupportBoneName="RightRearSTRUT"
     End Object
     Wheels(0)=SVehicleWheel'CSBadgerFix.SVehicleWheel12'

     Begin Object Class=SVehicleWheel Name=SVehicleWheel13
         bPoweredWheel=True
         bHandbrakeWheel=True
         BoneName="LeftRearTIRE"
         BoneRollAxis=AXIS_Y
         BoneOffset=(X=-20.000000)
         WheelRadius=26.000000
         SupportBoneName="LeftRearSTRUT"
     End Object
     Wheels(1)=SVehicleWheel'CSBadgerFix.SVehicleWheel13'

     Begin Object Class=SVehicleWheel Name=SVehicleWheel14
         bPoweredWheel=True
         SteerType=VST_Steered
         BoneName="RightFrontTIRE"
         BoneRollAxis=AXIS_Y
         BoneOffset=(X=20.000000)
         WheelRadius=26.000000
         SupportBoneName="RightFrontSTRUT"
     End Object
     Wheels(2)=SVehicleWheel'CSBadgerFix.SVehicleWheel14'

     Begin Object Class=SVehicleWheel Name=SVehicleWheel15
         bPoweredWheel=True
         SteerType=VST_Steered
         BoneName="LeftFrontTIRE"
         BoneRollAxis=AXIS_Y
         BoneOffset=(X=20.000000)
         WheelRadius=26.000000
         SupportBoneName="LeftFrontSTRUT"
     End Object
     Wheels(3)=SVehicleWheel'CSBadgerFix.SVehicleWheel15'

     VehicleMass=5.000000
     VehicleNameString="Stealth Badger"
     HealthMax=300.000000
     Health=300
     SoundVolume=255
     SoundPitch=48
     SoundRadius=100.000000
     TransientSoundVolume=0.100000
     TransientSoundRadius=300.000000
     bNetNotify=True
     bDrawVehicleShadow=false
     Begin Object Class=KarmaParamsRBFull Name=KarmaParamsRBFull4
         KInertiaTensor(0)=1.000000
         KInertiaTensor(3)=3.000000
         KInertiaTensor(5)=3.500000
         KLinearDamping=0.050000
         KAngularDamping=0.050000
         KStartEnabled=True
         bKNonSphericalInertia=True
         bHighDetailOnly=False
         bClientOnly=False
         bKDoubleTickRate=True
         bDestroyOnWorldPenetrate=True
         bDoSafetime=True
         KFriction=0.500000
         KImpactThreshold=500.000000
         KCOMOffset=(X=0.0,Y=0.0,Z=-1.0)

     End Object
     KParams=KarmaParamsRBFull'CSBadgerFix.KarmaParamsRBFull4'

}
