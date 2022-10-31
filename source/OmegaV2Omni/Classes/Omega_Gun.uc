class Omega_Gun extends ONSWeapon;


var()	class<FX_Turret_IonCannon_BeamFire> BeamEffectClass;
var		float	StartHoldTime, MaxHoldTime, ShockMomentum, ShockRadius, SecDamage, SecDamageRadius, SecMomentum,PrimaryDamage, PrimaryDamageRadius, PrimaryMomentum;
var		bool	bHoldingFire, bFireMode;
var		int		BeamCount, OldBeamCount;

var	sound	ChargingSound, ShockSound;

var	FX_IonPlasmaTank_AimLaser	AimLaser;

replication
{
    reliable if ( bNetDirty && !bNetOwner && Role == ROLE_Authority )
		bFireMode, BeamCount, OldBeamCount, bHoldingFire;
}

simulated function Destroyed()
{
	KillLaserBeam();

	super.Destroyed();
}

function PlayFiring()
{
	AmbientSound = None;
	PlaySound(sound'WeaponSounds.BExplosion5', SLOT_None, FireSoundVolume/255.0,,,, False);
}

function PlayChargeUp()
{
	AmbientSound = ChargingSound;
}

function PlayRelease()
{
	AmbientSound = None;
  PlaySound(sound'WeaponSounds.TranslocatorModuleRegeneration', SLOT_None, FireSoundVolume/255.0,,,, False);
}

simulated event FlashMuzzleFlash()
{
	super.FlashMuzzleFlash();

	if ( Level.NetMode != NM_DedicatedServer )
	{
		if ( !IsAltFire() && BeamCount != OldBeamCount )
		{
			OldBeamCount = BeamCount;
			PlayAnim('Fire', 0.5, 0);
			super.ShakeView();
		}
	}
}

simulated function bool IsAltFire()
{
	if ( Instigator.IsLocallyControlled() )
		return bIsAltFire;

	return bFireMode;
}

simulated function ShakeView()
{
	if ( IsAltFire() )
		super.ShakeView();
}

simulated function float ChargeBar()
{
	if ( bHoldingFire )
		return (FMin(Level.TimeSeconds - StartHoldTime, MaxHoldTime) / MaxHoldTime);
	else
		return 0;
}

function SpawnBeamEffect(Vector Start, Rotator Dir, Vector HitLocation, Vector HitNormal, int ReflectNum)
{
   local FX_Turret_IonCannon_BeamFire Beam;

    
    Beam = Spawn(BeamEffectClass,,, Start, Dir);
    if (ReflectNum != 0) Beam.Instigator = None; // prevents client side repositioning of beam start
    Beam.Damage = PrimaryDamage;   // defaults below in props
    Beam.DamageRadius = PrimaryDamageRadius;
    Beam.MomentumTransfer = PrimaryMomentum;
    Beam.AimAt(HitLocation, HitNormal);
}

function SpawnLaserBeam()
{
	CalcWeaponFire();
    AimLaser = Spawn(class'FX_IonPlasmaTank_AimLaser', Self,, WeaponFireLocation, WeaponFireRotation);
}

function KillLaserBeam()
{
	if ( AimLaser != None )
	{
		AimLaser.Destroy();
		AimLaser = None;
	}
}

simulated function UpdateLaserBeamLocation( out vector Start, out vector HitLocation )
{
	local vector	HitNormal;
	local rotator	Dir;

	CalcWeaponFire();
	Start		= WeaponFireLocation;
	Dir			= WeaponFireRotation;
	HitLocation	= vect(0,0,0);
	SimulateTraceFire( Start, Dir, HitLocation, HitNormal );
	//log("UpdateLaserBeamLocation WFL:" @ WeaponFireLocation @ "WFR:" @ WeaponFireRotation
	//	@ "Start:" @ Start @ "HL:" @ HitLocation );
}

event bool AttemptFire( Controller C, bool bAltFire )
{
	bFireMode = bAltFire;
	return super.AttemptFire( C, bAltFire );
}

state ProjectileFireMode
{
	simulated function ClientStartFire(Controller C, bool bAltFire)
	{
		bFireMode	= bAltFire;
		bIsAltFire	= bAltFire;
		//log("ClientStartFire");
		if ( !bAltFire )
		{
			if ( Role < ROLE_Authority && FireCountdown <= 0 )
			{
				bHoldingFire	= true;
				StartHoldTime	= Level.TimeSeconds;
				SetTimer( MaxHoldTime, false );
			}
			else
				SetTimer( FireCountDown, false );	// synch to starthold matches server (done in timer)
			//super.ClientStartFire(C, bAltFire);


		}
		else
		{
			super.ClientStartFire(C, bAltFire);
		}
	}

	simulated function Timer()
	{
		if ( !bHoldingFire )
		{
			if ( Role < Role_Authority && !bFireMode )
			{
				bHoldingFire	= true;
				StartHoldTime	= Level.TimeSeconds;
				SetTimer( MaxHoldTime, false );
			}
			return;
		}

		bHoldingFire	= false;
		FireCountdown	= FireInterval;
		SetTimer(FireInterval, false);

		if ( Role == ROLE_Authority )
		{
			KillLaserBeam();
			CalcWeaponFire();
			FlashCount++;
			PlayFiring();

			if ( AmbientEffectEmitter != None )
				AmbientEffectEmitter.SetEmitterStatus( true );

			TraceFire(WeaponFireLocation, WeaponFireRotation);
		}
		BeamCount++;
		FlashMuzzleFlash();
	}

	simulated function ClientStopFire(Controller C, bool bWasAltFire)
	{
		//log("ClientStopFire");
		super.ClientStopFire(C, bWasAltFire);

		if ( bHoldingFire )
		{
			bHoldingFire	= false;
			FireCountdown	= FireInterval;
			ClientPlayForceFeedback("BioRifleFire");
		}
		SetTimer(0, false);
	}

	function Fire(Controller C)
	{
		NetUpdateTime = Level.TimeSeconds - 1;
		bFireMode = false;
		//log("Fire");
		if ( !bHoldingFire )
		{
			PlayChargeUp();
			StartHoldTime	= Level.TimeSeconds;
			bHoldingFire	= true;
			SetTimer( MaxHoldTime, false );
			SpawnLaserBeam();
		}
	}

	function AltFire(Controller C)
	{
		local actor		Shock;
		super.ShakeView();
		PlaySound(ShockSound, SLOT_None, 128/255.0,,, 2.5, False);
    Shock = Spawn(class'FX_IonPlasmaTank_ShockWave', Self,, Location);
    //  Weapon.HurtRadius(DamageAmount, DamageRadius, DamageType, Momentum, HitLocation);
    //HurtRadius(200, 1000, class'OmegaV2Omni.DamTypeOmegaIonBlast', 300000, Location);
    HurtRadius(SecDamage, SecDamageRadius, class'OmegaV2Omni.DamTypeOmegaIonBlast', SecMomentum, Location);
		Shock.SetBase( Instigator );
	}

}

	function CeaseFire(Controller C)
	{
		//log("CeaseFire");

		KillLaserBeam();

		if ( bHoldingFire )
		{
			if ( Role == Role_Authority )
				PlayRelease();

			SetTimer(0, false);
			bHoldingFire	= false;
			FireCountdown	= FireInterval;
		}
	}

defaultproperties
{
     BeamEffectClass=Class'OnslaughtFull.ONSHoverTank_IonPlasma_BeamFire'
     
     ShockMomentum=50000.000000
     ShockRadius=2500.000000
     //ChargingSound=Sound'AssaultSounds.AssaultRifle.IonPowerUp'
     ChargingSound=Sound'ONSVehicleSounds-S.RV.RVChargeUp01'
     ShockSound=Sound'ONSVehicleSounds-S.AVRiL.AvrilFire01'
     
     // Hold time is the time on charging bar
     MaxHoldTime=2.0000
     // time it takes to restart charging.
     FireInterval=1.5000
     
     AltFireInterval=3.000000
     FireSoundClass=Sound'WeaponSounds.BaseImpactAndExplosions.BExplosion5'
     // primary fire damage
     PrimaryDamage = 100 // 200 default
     PrimaryDamageRadius = 1750 // 2000 default
     PrimaryMomentum = 80000 // 150000 default
     
     // secondary fire damage
     SecDamage = 200
     SecDamageRadius = 1000
     SecMomentum = 300000
     // Not sure what the below is?!  They are set at 0 in ION tank.
     DamageMin=100
     DamageMax=100
     //TraceRange=12500.000000
     // Was too short and upset Enyo
     TraceRange=14500.000000
    
     // Was 20000, 15000 is avril lock on range...so range plus half blast radius (give or take)
     AIInfo(0)=(bTrySplash=True,bLeadTarget=True,WarnTargetPct=0.990000,RefireRate=0.990000)
     Mesh=SkeletalMesh'ONSWeapons-A.PlasmaGun'
     SoundPitch=112
     SoundRadius=512.000000
     
     // Pitch limits..this is based on ONSWeapon, not a vehicle weapon like ONSAttackCraftGUN
     // ONSWeaponDefault
     //  PitchUpLimit=5000
     //  PitchDownLimit=60000
     // ONSAttackCRaftDefault
     //PitchUpLimit=18000
     // PitchDownLimit=49153
     
     PitchUpLimit=18000
     PitchDownLimit=49153
}

