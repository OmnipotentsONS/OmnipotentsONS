class CSShieldMechWeapon extends ONSWeapon;

var float MinAim;
var class<xEmitter>     MuzFlashClass;
var xEmitter            MuzFlash;

var()   float   MaxShieldHealth;
var()   float   MaxDelayTime;
var()   float   ShieldRechargeRate;
Var()   float   ShieldOnRechargeRate;
var		float	LastShieldHitTime;

var     float   CurrentShieldHealth;
var     float   CurrentDelayTime;
var     float   CurrentRechargeTime;
var     bool    bShieldActive, bLastShieldActive;
var		bool	bPutShieldUp;
var     byte    ShieldHitCount, LastShieldHitCount;

var     CSShieldMechShield   ShockShield;

//////////////////////////////
//var class<DamageType> DamageType;       // weapon fire damage type (no projectile, so we put this here)
var float ShieldRange;                  // from pawn centre
var float StartHoldTime;
var float MinHoldTime;                  // held for this time or less will do minimum damage/force. held for MaxHoldTime will do max
var float MaxHoldTime;                  //wait this long between shots for full damage
var float MinForce, MaxForce;           // force to other players
var float MinDamage, MaxDamage;         // damage to other players
var float SelfForceScale;               // %force to self (when shielding a wall)
var float SelfDamageScale;              // %damage to self (when shielding a wall)
var float MinSelfDamage;
var Sound ChargingSound, ChargedLoop;   // charging sound
var Sound ShieldSound;
var xEmitter ChargingEmitter;           // emitter class while charging
var float AutoFireTestFreq;
var float FullyChargedTime;				// held for this long will do max damage
var bool bAutoRelease;
var bool bStartedChargingForce;
var	byte  ChargingSoundVolume;
var Pawn AutoHitPawn;
var float AutoHitTime;
var bool bHoldingFire;
var float DamageScale, MinDamageScale;
var bool bIsCharging, bOldIsCharging;

// jdf ---
var String ChargingForce;

var float HoldTime;

var class<ShockBeamEffect> BeamEffectClass;

////////////////////////////////////////////////////

replication
{
    reliable if (bNetOwner && Role == ROLE_Authority)
        CurrentShieldHealth;

    reliable if (Role == ROLE_Authority)
        bShieldActive, ShieldHitCount, bIsCharging;
}

simulated function PostNetBeginPlay()
{
    Super.PostNetBeginPlay();

    ShockShield = spawn(class'CSShieldMechShield',self);


    if (ShockShield != None)
    {
        AttachToBone(ShockShield, 'tip');
    }
}

simulated function DestroyEffects()
{
    if (ChargingEmitter != None)
        ChargingEmitter.Destroy();
	Super.DestroyEffects();
}

simulated function InitEffects()
{
	if ( Level.NetMode != NM_DedicatedServer )
	{
		ChargingEmitter = Spawn(class'CSShieldMechShieldCharge',self);
        if (ChargingEmitter != None)
        {
            AttachToBone(ChargingEmitter, 'tip');
        }

		ChargingEmitter.mRegenPause = true;
	}
    bStartedChargingForce = false;  // jdf
    Super.InitEffects();
}



function byte BestMode()
{
	local bot B;

	if ( CurrentShieldHealth <= 0 )
		return 0;
	if ( Projectile(Instigator.Controller.Target) != None )
		return 1;

	B = Bot(Instigator.Controller);
	if ( (B == None) || (B.Enemy == None) )
		return 0;

	if ( bPutShieldUp || !B.EnemyVisible() )
	{
		LastShieldHitTime = Level.TimeSeconds;
		bPutShieldUp = false;
		return 1;
	}

	if ( VSize(B.Enemy.Location - Location) < 3000 )
	{
		if ( bShieldActive )
			return 0;
		else
			return 1;
	}
	if ( bShieldActive && (Level.TimeSeconds - LastShieldHitTime < 2) )
	   return 1;
	else if ( B.Enemy != B.Target )
		return 0;
	else
	{
		// check if near friendly node, and between it and enemy
		if ( (B.Squad.SquadObjective != None) && (VSize(B.Pawn.Location - B.Squad.SquadObjective.Location) < 1000)
			&& ((Normal(B.Enemy.Location - B.Squad.SquadObjective.Location) dot Normal(B.Pawn.Location - B.Squad.SquadObjective.Location)) > 0.7) )
			return 1;

		// use shield if heavily damaged
		//if ( B.Pawn.Health < 0.3 * B.Pawn.Default.Health )
		if ( Vehicle(Owner).Health < 0.3 * Vehicle(Owner).Default.Health )
			return 1;

		// use shield against heavy vehicles
		if ( (B.Enemy == B.Target) && (Vehicle(B.Enemy) != None) && Vehicle(B.Enemy).ImportantVehicle() && (B.Enemy.Controller != None) 
			&& ((Vector(B.Enemy.Controller.Rotation) dot Normal(Instigator.Location - B.Enemy.Location)) > 0.9) )
			return 1;
	   return 0;
	}
}

function ShieldAgainstIncoming(optional Projectile P)
{
	if ( P != None )
	{
		if ( FireCountDown > (VSize(P.Location - Location) - 1100)/VSize(P.Velocity) )
			return;
		// put shield up if pointed in right direction
		if ( Level.Game.GameDifficulty < 2 )
		{
			CalcWeaponFire();
			if ( (Normal(P.Location - WeaponFireLocation) dot vector(WeaponFireRotation)) < 0.7 )
				return;
		}
		LastShieldHitTime = Level.TimeSeconds;
		bPutShieldUp = true;
		Instigator.Controller.FireWeaponAt(Instigator.Controller.Focus);
	}
	else if ( Instigator.Controller.Enemy != None )
	{
		if ( (FireCountDown > 0.2) && (FRand() < 0.6) )
			return;
		LastShieldHitTime = Level.TimeSeconds;
		bPutShieldUp = true;
		Instigator.Controller.FireWeaponAt(Instigator.Controller.Focus);
	}
}

event bool AttemptFire(Controller C, bool bAltFire)
{
  	if (Role != ROLE_Authority || bForceCenterAim)
		return False;

	if (bAltFire)
    {
		if ( ShockShield != None )
		{
			CurrentDelayTime = 0;

			if (!bShieldActive && CurrentShieldHealth > 0)
			{
				ActivateShield();
			}
		}
    }
	else if ( (AIController(C) != None) && bShieldActive && (VSize(C.Target.Location - Instigator.Location) > 900) )
	{
		DeactivateShield();
	}

	if (FireCountdown <= 0)
	{
		CalcWeaponFire();
		if (bCorrectAim)
			WeaponFireRotation = AdjustAim(bAltFire);
		if (Spread > 0)
			WeaponFireRotation = rotator(vector(WeaponFireRotation) + VRand()*FRand()*Spread);

        DualFireOffset *= -1;

		Instigator.MakeNoise(1.0);
		if (!bAltFire)
		{
		    FireCountdown = FireInterval;
            bIsCharging = true;
            NetUpdateTime = Level.TimeSeconds - 1;
		    Fire(C);
		}
		AimLockReleaseTime = Level.TimeSeconds + FireCountdown * FireIntervalAimLock;

	    return True;
	}

	return False;
}

function CeaseAltFire()
{
    if (ShockShield != None)
        DeactivateShield();
}

simulated function Destroyed()
{
    if (ShockShield != None)
        ShockShield.Destroy();

    if (ChargingEmitter != None)
        ChargingEmitter.Destroy();

    Super.Destroyed();
}

simulated function ActivateShield()
{
    bShieldActive = true;
    AmbientSound=ShieldSound;

    if (ShockShield != None)
        ShockShield.ActivateShield(Team);
}

simulated function DeactivateShield()
{
    bShieldActive = false;
    AmbientSound=None;

    if (ShockShield != None)
        ShockShield.DeactivateShield();
}

simulated function PostNetReceive()
{
    Super.PostNetReceive();

    if (bShieldActive != bLastShieldActive)
    {
        if (bShieldActive)
            ActivateShield();
        else
            DeactivateShield();

        bLastShieldActive = bShieldActive;
    }

    if (ShockShield != None && ShieldHitCount != LastShieldHitCount)
    {
        ShockShield.SpawnHitEffect(Team);

        LastShieldHitCount = ShieldHitCount;
    }

    if(bOldIsCharging != bIsCharging)
    {
        if(bIsCharging)
        {
            if(ChargingEmitter != None)
                ChargingEmitter.mRegenPause = false;
        }
        else
        {
            if(ChargingEmitter != None)
                ChargingEmitter.mRegenPause = true;
        }

        bOldIsCharging = bIsCharging;
    }
}

//do effects (muzzle flash, force feedback, etc) immediately for the weapon's owner (don't wait for replication)
simulated event OwnerEffects()
{
	if (!bIsRepeatingFF)
	{
		if (bIsAltFire)
			ClientPlayForceFeedback( AltFireForce );
		else
			ClientPlayForceFeedback( FireForce );
	}
    ShakeView();

	if (Role < ROLE_Authority)
	{
		if (!bIsAltFire)
            FireCountdown = FireInterval;

		AimLockReleaseTime = Level.TimeSeconds + FireCountdown * FireIntervalAimLock;

        if (!bIsAltFire)
            FlashMuzzleFlash();

		if (AmbientEffectEmitter != None)
			AmbientEffectEmitter.SetEmitterStatus(true);

        // Play firing noise
        if (!bAmbientFireSound)
        {
            if (bIsAltFire)
                PlaySound(AltFireSoundClass,, FireSoundVolume/255.0,, AltFireSoundRadius,, false);
            else
                PlaySound(FireSoundClass,, FireSoundVolume/255.0,, FireSoundRadius,, false);
        }
	}
}

function NotifyShieldHit(int Dam, Pawn instigatedBy)
{
    if (Pawn(Owner) != None && Pawn(Owner).Controller != None && ((InstigatedBy == None) || (InstigatedBy.Controller == None) || !InstigatedBy.Controller.SameTeamAs(Pawn(Owner).Controller)))
    {
		LastShieldHitTime = Level.TimeSeconds;
        CurrentShieldHealth -= Dam;
        ShieldHitCount++;
        ShockShield.SpawnHitEffect(Team);
    }
}

simulated function Tick(float DT)
{
    Super.Tick(DT);

    if (ShockShield == None || Role < ROLE_Authority)
        return;

    if (CurrentShieldHealth <= 0)                        // Ran out of shield energy so deactivate
        DeactivateShield();

    if (!bShieldActive && (CurrentShieldHealth < MaxShieldHealth))  // Shield is off and needs recharge
    {
        if (CurrentDelayTime < MaxDelayTime)           // Shield is in delay
            CurrentDelayTime += DT;
        else                                           // Shield is in recharge
        {
            CurrentShieldHealth += ShieldRechargeRate * DT;
            if (CurrentShieldHealth >= MaxShieldHealth)
                  CurrentShieldHealth = MaxShieldHealth;
        }
    }
    if (bShieldActive && (CurrentShieldHealth < MaxShieldHealth))
    {
        if (CurrentDelayTime < MaxDelayTime)
            CurrentDelayTime += DT;
        else
        {
            CurrentShieldHealth += ShieldOnRechargeRate * DT;
            if (CurrentShieldHealth >= MaxShieldHealth)
                  CurrentShieldHealth = MaxShieldHealth;
        }
    }
}

simulated function float ChargeBar()
{
    return FClamp(CurrentShieldHealth/MaxShieldHealth, 0.0, 0.999);
}

state InstantFireMode
{
    simulated function SpawnHitEffects(actor HitActor, vector HitLocation, vector HitNormal)
    {
    }

    simulated function OwnerEffects()
	{
		if (Role < ROLE_Authority && !bHoldingFire)
		{
			bHoldingFire = true;
			StartHoldTime = Level.TimeSeconds;
		}
	}

    simulated function ClientStartFire(Controller C, bool bAltFire)
    {
        super.ClientStartFire(C, bAltFire);
        if(Role < ROLE_Authority)
        {
            if(!bAltFire && ChargingEmitter != None)
            {
                ChargingEmitter.mRegenPause=false;
            }
        }
    }

    simulated function ClientStopFire(Controller C, bool bWasAltFire)
	{
		Super.ClientStopFire(C, bWasAltFire);

		if (FireCountdown <= 0)
		{
			ClientPlayForceFeedback(FireForce);
			ShakeView();
		}

		if (Role < ROLE_Authority)
		{
			bHoldingFire = false;

            if(ChargingEmitter != None)
                ChargingEmitter.mRegenPause=true;

			if (FireCountdown <= 0)
			{
				if (bIsAltFire)
					FireCountdown = AltFireInterval;
				else
					FireCountdown = FireInterval;

		        if (!bIsAltFire)
                {
                    FlashMuzzleFlash();
                    PlaySound(FireSoundClass, SLOT_None, FireSoundVolume/255.0,, FireSoundRadius,, false);
                }
		    }
		}
	}

    function Timer()
    {
        if (bHoldingFire)
        {
            AmbientSound = ChargedLoop;
        }
    }

	function CeaseFire(Controller C)
	{
		if (!bHoldingFire)
			return;

		ClientPlayForceFeedback(FireForce);
		AmbientSound = None;

		//CalcWeaponFire();
		//if (bCorrectAim)
		//	WeaponFireRotation = AdjustAim(false);

        //big wtf
        WeaponFireRotation = C.Rotation;
        WeaponFireRotation.Pitch += 2048;
        WeaponFireRotation.Yaw -= 512;

        DoFireEffect();
		//Super.Fire(C);
        FlashMuzzleFlash();

        if (AmbientEffectEmitter != None)
        {
            AmbientEffectEmitter.SetEmitterStatus(true);
        }

        // Play firing noise
        if (bAmbientFireSound)
            AmbientSound = FireSoundClass;
        else
            PlayOwnedSound(FireSoundClass, SLOT_None, FireSoundVolume/255.0,, FireSoundRadius, FireSoundPitch, False);

		FireCountdown = FireInterval;
		bHoldingFire = false;
        bIsCharging = false;
    	//NetUpdateTime = Level.TimeSeconds - 1;

        if(Vehicle(Owner) != None)
        {
            Vehicle(Owner).PlayFiring();
        }
	}

    function Fire(Controller C)
    {
        if (!bHoldingFire && !Vehicle(Owner).bWeaponisAltFiring)
		{
			StartHoldTime = Level.TimeSeconds;
			bHoldingFire = true;

            if(ChargingEmitter != None)
                ChargingEmitter.mRegenPause=false;

			AmbientSound = ChargingSound;
			SetTimer(MaxHoldTime, False);
		}
    }

    function AltFire(Controller C)
    {
        if(Vehicle(Owner) != None)
        {
            Vehicle(Owner).PlayFiring();
        }

		Super.AltFire(C);
    }
}

simulated event FlashMuzzleFlash()
{
    super.FlashMuzzleFlash();

    if ( Level.NetMode != NM_DedicatedServer)
	{
        if (MuzFlash == None)
        {
            MuzFlash = Spawn(MuzFlashClass,self,, WeaponFireLocation, WeaponFireRotation);
            if ( MuzFlash != None )
				AttachToBone(MuzFlash, 'tip');
        }

        if (MuzFlash != None)
        {
            MuzFlash.mStartParticles++;
            MuzFlash.Trigger(Self, Instigator);
        }
    }
}


/////////////

function Rotator AdjustAim(bool bAltFire)
{
	local rotator Aim, EnemyAim;

	if ( AIController(Instigator.Controller) != None && !bAltFire)
	{
		Aim = Instigator.Rotation;
		if ( Instigator.Controller.Enemy != None )
		{
			EnemyAim = rotator(Instigator.Controller.Enemy.Location - WeaponFireLocation);
			Aim.Pitch = EnemyAim.Pitch;
		}
		return Aim;
	}
	else
		return super.AdjustAim(bAltFire);
}

simulated function GetViewAxes( out vector xaxis, out vector yaxis, out vector zaxis )
{
    if ( Instigator.Controller == None )
        GetAxes( Instigator.Rotation, xaxis, yaxis, zaxis );
    else
        GetAxes( Instigator.Controller.Rotation, xaxis, yaxis, zaxis );
}

function DoFireEffect()
{
	local Vector HitLocation, HitNormal, StartTrace, EndTrace, X,Y,Z;
    local Rotator Aim;
	local Actor Other;
    local float Scale, Damage, Force;

	Instigator.MakeNoise(1.0);
    GetViewAxes(X,Y,Z);
	bAutoRelease = false;

	if ( (AutoHitPawn != None) && (Level.TimeSeconds - AutoHitTime < 0.15) )
	{
		Other = AutoHitPawn;
		HitLocation = Other.Location;
		AutoHitPawn = None;
	}
	else
	{
		//StartTrace = Instigator.Location;
		//Aim = AdjustAim(false);
        StartTrace = WeaponFireLocation;
        Aim = WeaponFireRotation;

		EndTrace = StartTrace + ShieldRange * Vector(Aim);
		Other = Trace(HitLocation, HitNormal, EndTrace, StartTrace, true);
        if(HitLocation == vect(0,0,0))
            HitLocation = EndTrace;
	}

    HoldTime = Level.TimeSeconds - StartHoldTime;

    Scale = (FClamp(HoldTime, MinHoldTime, FullyChargedTime) - MinHoldTime) / (FullyChargedTime - MinHoldTime); // result 0 to 1
    Damage = MinDamage + Scale * (MaxDamage - MinDamage);
    Force = MinForce + Scale * (MaxForce - MinForce);

    if (ChargingEmitter != None)
        ChargingEmitter.mRegenPause = true;

    if ( Other != None && Other != Instigator )
    {
		if ( Pawn(Other) != None || (Decoration(Other) != None && Decoration(Other).bDamageable) )
        {
        	Other.TakeDamage(Damage, Instigator, HitLocation, Force*(X+vect(0,0,0.5)), DamageType);
        }
		else
		{
			if ( xPawn(Instigator).bBerserk )
				Force *= 2.0;
			Instigator.TakeDamage(MinSelfDamage+SelfDamageScale*Damage, Instigator, HitLocation, -SelfForceScale*Force*X, DamageType);
			if ( DestroyableObjective(Other) != None )
            {
		      	Other.TakeDamage(Damage, Instigator, HitLocation, Force*(X+vect(0,0,0.5)), DamageType);
            }
		}
    }

    SpawnBeamEffect(StartTrace, Aim, HitLocation, Force*(X+vect(0,0,0.5)),0);

    SetTimer(0, false);
}

function Timer()
{
    local Actor Other;
    local Vector HitLocation, HitNormal, StartTrace, EndTrace;
    local Rotator Aim;
    local float Regen;
    local float ChargeScale;

    if (HoldTime > 0.0)
    {
	    StartTrace = Instigator.Location;
		Aim = AdjustAim(false);
	    EndTrace = StartTrace + ShieldRange * Vector(Aim);

        Other = Trace(HitLocation, HitNormal, EndTrace, StartTrace, true);
        if ( (Pawn(Other) != None) && (Other != Instigator) )
        {
			bAutoRelease = true;
            Vehicle(Owner).bWeaponisFiring = false;
            AmbientSound = None;
            //Instigator.AmbientSound = None;
			//Instigator.SoundVolume = Instigator.Default.SoundVolume;
            AutoHitPawn = Pawn(Other);
            AutoHitTime = Level.TimeSeconds;
            if (ChargingEmitter != None)
                ChargingEmitter.mRegenPause = true;
        }
        else
        {
            //Instigator.AmbientSound = ChargingSound;
			//Instigator.SoundVolume = ChargingSoundVolume;
            AmbientSound = ChargingSound;
			//Instigator.SoundVolume = ChargingSoundVolume;
            ChargeScale = FMin(HoldTime, FullyChargedTime);
            if (ChargingEmitter != None)
            {
                ChargingEmitter.mRegenPause = false;
                Regen = ChargeScale * 10 + 20;
                ChargingEmitter.mRegenRange[0] = Regen;
                ChargingEmitter.mRegenRange[1] = Regen;
                ChargingEmitter.mSpeedRange[0] = ChargeScale * -15.0;
                ChargingEmitter.mSpeedRange[1] = ChargeScale * -15.0;
                Regen = FMax((ChargeScale / 30.0),0.20);
                ChargingEmitter.mLifeRange[0] = Regen;
                ChargingEmitter.mLifeRange[1] = Regen;
            }

            if (!bStartedChargingForce)
            {
                bStartedChargingForce = true;
                ClientPlayForceFeedback( ChargingForce );
            }
        }
    }
    else
    {
        /*
		if ( Instigator.AmbientSound == ChargingSound )
		{
			Instigator.AmbientSound = None;
			Instigator.SoundVolume = Instigator.Default.SoundVolume;
		}
        */
		if ( AmbientSound == ChargingSound )
		{
			AmbientSound = None;
		}

        SetTimer(0, false);
    }
}

simulated function SetFireRateModifier(float Modifier)
{
	Super.SetFireRateModifier(Modifier);

	MaxHoldTime = default.MaxHoldTime / Modifier;
}

//debug
function SpawnBeamEffect(Vector Start, Rotator Dir, Vector HitLocation, Vector HitNormal, int ReflectNum)
{
    local ShockBeamEffect Beam;

    Beam = Spawn(BeamEffectClass,,, Start, Dir);
    Beam.Instigator = None; // prevents client side repositioning of beam start
    Beam.AimAt(HitLocation, HitNormal);
}


defaultproperties
{
    Mesh=mesh'Weapons.ShieldGun_3rd'
    YawBone='Bone_weapon'
    PitchBone='Bone_weapon'
    DrawScale=2.5
    MuzFlashClass=class'CSShieldMechForceRing'
    YawStartConstraint=0
    YawEndConstraint=65535
    PitchUpLimit=18000
    PitchDownLimit=49153

    DamageType=class'CSShieldMechDamTypeShieldImpact'

    FireSoundVolume=255
    FireSoundRadius=1500
    FireInterval=0.5
    FireSoundPitch=0.8

    AltFireSoundRadius=1500
    AltFireInterval=0.6

    RotateSound=sound'CSMech.turretturn'
    RotateSoundThreshold=50.0

    WeaponFireAttachmentBone=Bone_Flash
    WeaponFireOffset=0.0
    bAimable=True
    bInstantRotation=true
    bDoOffsetTrace=true
    DualFireOffset=0
    AIInfo(0)=(bLeadTarget=true,bTrySplash=true,WarnTargetPct=0.75,RefireRate=0.8)
    AIInfo(1)=(bInstantHit=true,RefireRate=0.99)
    MinAim=0.900
    TraceRange=20000

    bInstantFire=true
    bShowChargingBar=true
    bForceSkelUpdate=true
    bNetNotify=true

    MaxShieldHealth=10000.0
    CurrentShieldHealth=10000.0
    MaxDelayTime=0.7
    ShieldRechargeRate=400.0
    ShieldOnRechargeRate=50.0

    ShieldRange=1000.0
    MinForce=650000.0
    MaxForce=1000000.0
    MinDamage=250.0
    MaxDamage=2000.0
    SelfForceScale=1.0
    SelfDamageScale=0.0
    MinSelfDamage=0
    //MaxHoldTime=2.5
    MaxHoldTime=1.2
    MinDamageScale=0.15

    FullyChargedTime=1.2
    MinHoldtime=0.4
    AutoFireTestFreq=0.15
    Spread=0

    FireSoundClass=Sound'WeaponSounds.P1ShieldGunFire'
    ChargingSound=Sound'WeaponSounds.shieldgun_charge'
    ChargedLoop=Sound'WeaponSounds.shieldgun_charge'
	ChargingSoundVolume=200
    FireForce="ShieldGunFire"
    ChargingForce="shieldgun_charge"
    bStartedChargingForce=false

    ShakeOffsetMag=(X=-20.0,Y=0.00,Z=0.00)
    ShakeOffsetRate=(X=-1000.0,Y=0.0,Z=0.0)
    ShakeOffsetTime=2
    ShakeRotMag=(X=0.0,Y=0.0,Z=0.0)
    ShakeRotRate=(X=0.0,Y=0.0,Z=0.0)
    ShakeRotTime=2

    BeamEffectClass=class'CSShieldMechShieldBeam'
    ShieldSound=sound'WeaponSounds.BShield1'

}