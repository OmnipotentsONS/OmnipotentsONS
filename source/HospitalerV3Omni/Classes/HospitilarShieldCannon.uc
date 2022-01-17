//-----------------------------------------------------------
//
//-----------------------------------------------------------
class HospitilarShieldCannon extends ONSWeapon;

var()   float   MaxShieldHealth;
var()   float   MaxDelayTime;
var()   float   ShieldRechargeRate;
var		float	LastShieldHitTime;

var     float   CurrentShieldHealth;
var     float   CurrentDelayTime;
var     float   CurrentRechargeTime;
var     bool    bShieldActive, bLastShieldActive;
var		bool	bPutShieldUp;
var     byte    ShieldHitCount, LastShieldHitCount;

var     HospitilarShield   ShockShield;


replication
{
    reliable if (bNetOwner && Role == ROLE_Authority)
        CurrentShieldHealth;

    reliable if (Role == ROLE_Authority)
        bShieldActive, ShieldHitCount;
}

simulated function PostNetBeginPlay()
{
    Super.PostNetBeginPlay();

    ShockShield = spawn(class'HospitilarShield', self);

    if (ShockShield != None)
        AttachToBone(ShockShield, 'SIDEgunBARREL');
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

	if ( VSize(B.Enemy.Location - Location) < 900 )
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
		if ( B.Pawn.Health < 0.3 * B.Pawn.Default.Health )
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
		if ( Level.Game.GameDifficulty < 5 )
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
		    Fire(C);
		}
		AimLockReleaseTime = Level.TimeSeconds + FireCountdown * FireIntervalAimLock;

	    return True;
	}

	return False;
}

function WeaponCeaseFire(Controller C, bool bWasAltFire)
{
	Super.WeaponCeaseFire(C, bWasAltFire);
	CeaseAltFire();
}

function CeaseFire(Controller C)
{
	Super.CeaseFire(C);
	CeaseAltFire();
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

    Super.Destroyed();
}

simulated function ActivateShield()
{
    bShieldActive = true;

    if (ShockShield != None)
        ShockShield.ActivateShield(Team);
}

simulated function DeactivateShield()
{
    bShieldActive = false;

    if (ShockShield != None)
        ShockShield.DeactivateShield();
}


// For when the shield is hit by our own shockball
function ProximityExplosion()
{
    local Emitter ComboHit;

    ComboHit = Spawn(class'HospitilarShieldComboHit', self);
	if ( Level.NetMode == NM_DedicatedServer )
	{
		ComboHit.LifeSpan = 0.6;
	}
    AttachToBone(ComboHit, 'SIDEgunBARREL');
    ComboHit.SetRelativeLocation(vect(300,0,0));
    SetTimer(0.5, false);
}

function Timer()
{
    PlaySound(sound'ONSBPSounds.ShockTank.ShockBallExplosion', SLOT_None,1.0,,800);
    Spawn(class'ONSShockTankProximityExplosion', self,, Location + vect(0,0,-70));
    HurtRadius(200, 900, class'DamTypeShockTankProximityExplosion', 150000, Location);
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
                PlaySound(AltFireSoundClass, SLOT_None, FireSoundVolume/255.0,, AltFireSoundRadius,, false);
            else
                PlaySound(FireSoundClass, SLOT_None, FireSoundVolume/255.0,, FireSoundRadius,, false);
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
}

simulated function float ChargeBar()
{
    return FClamp(CurrentShieldHealth/MaxShieldHealth, 0.0, 0.999);
}

simulated function HurtRadius( float DamageAmount, float DamageRadius, class<DamageType> DamageType, float Momentum, vector HitLocation )
{
	local actor Victims;
	local float damageScale, dist;
	local vector dir;

	foreach VisibleCollidingActors( class 'Actor', Victims, DamageRadius, HitLocation )
	{
		// don't let blast damage affect fluid - VisibleCollisingActors doesn't really work for them - jag
		if( (Victims != self) && (Victims.Role == ROLE_Authority) && !Victims.IsA('FluidSurfaceInfo') )
		{
			dir = Victims.Location - HitLocation;
			dist = FMax(1,VSize(dir));
			dir = dir/dist;
			damageScale = 1 - FMax(0,(dist - Victims.CollisionRadius)/DamageRadius);
			Victims.TakeDamage
			(
				damageScale * DamageAmount,
				Instigator,
				Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
				(damageScale * Momentum * dir),
				DamageType
			);
			if (Vehicle(Victims) != None && Vehicle(Victims).Health > 0)
				Vehicle(Victims).DriverRadiusDamage(DamageAmount, DamageRadius, Instigator.Controller, DamageType, Momentum, HitLocation);
		}
	}
}

defaultproperties
{
     MaxShieldHealth=8000.000000
     MaxDelayTime=1.000000
     ShieldRechargeRate=800.000000
     CurrentShieldHealth=8000.000000
     YawBone="SIDEgunBASE"
     PitchBone="SIDEgunBARREL"
     PitchUpLimit=18000
     PitchDownLimit=58000
     WeaponFireAttachmentBone="Firepoint"
     RotationsPerSecond=0.500000
     bShowChargingBar=True
     RedSkin=Texture'IllyHeavyCrusaderSkins.HeavyCrusader.HeavyCrusader_0'
     BlueSkin=Texture'IllyHeavyCrusaderSkins.HeavyCrusader.HeavyCrusader_1'
     FireInterval=2.350000
     EffectEmitterClass=Class'OnslaughtFull.FX_IonPlasmaTank_ShockWave'
     FireSoundClass=Sound'ONSBPSounds.ShockTank.ShockBallFire'
     RotateSound=Sound'ONSBPSounds.ShockTank.TurretHorizontal'
     ProjectileClass=Class'HospitalerV3Omni.HospitilarShieldCannonProjectile'
     AIInfo(0)=(bTrySplash=True,bLeadTarget=True,WarnTargetPct=0.750000,RefireRate=0.800000)
     AIInfo(1)=(bInstantHit=True,RefireRate=0.990000)
     Mesh=SkeletalMesh'ONSWeapons-A.PRVsideGun'
     bForceSkelUpdate=True
     bNetNotify=True
}
