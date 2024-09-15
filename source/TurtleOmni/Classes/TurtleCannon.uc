class TurtleCannon extends ONSShockTankCannon;


var()   float   MaxShieldHealth;
var()   float   MaxDelayTime;
Var()   float   ShieldOnRechargeRate;
var()   float   ShieldRechargeRate;
var		float	LastShieldHitTime;

var     float   CurrentShieldHealth;
var     float   CurrentDelayTime;
var     float   CurrentRechargeTime;
var     bool    bShieldActive, bLastShieldActive;
var		bool	bPutShieldUp;
var     byte    ShieldHitCount, LastShieldHitCount;

var     TurtleShield   TShield;

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

    TShield = spawn(class'TurtleShield', self);

    if (TShield != None)
        AttachToBone(TShield, 'ElectroGun');
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
		if ( (B.Squad.SquadObjective != None) && (VSize(B.Pawn.Location - B.Squad.SquadObjective.Location) < 1000)
			&& ((Normal(B.Enemy.Location - B.Squad.SquadObjective.Location) dot Normal(B.Pawn.Location - B.Squad.SquadObjective.Location)) > 0.7) )
			return 1;

		if ( B.Pawn.Health < 0.3 * B.Pawn.Default.Health )
			return 1;

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
		if ( TShield != None )
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

function CeaseAltFire()
{
    if (TShield != None)
        DeactivateShield();
}

simulated function Destroyed()
{
    if (TShield != None)
        TShield.Destroy();

    Super.Destroyed();
}

simulated function ActivateShield()
{
    bShieldActive = true;

    if (TShield != None)
        TShield.ActivateShield(Team);
     FireInterval=1.3000;
}

simulated function DeactivateShield()
{
    bShieldActive = false;

    if (TShield != None)
        TShield.DeactivateShield();
     FireInterval=3.3000;
}

function ProximityExplosion()
{
    local Emitter ComboHit;

    ComboHit = Spawn(class'TurtleShieldComboHit', self);
	if ( Level.NetMode == NM_DedicatedServer )
	{
		ComboHit.LifeSpan = 0.8;
	}
    AttachToBone(ComboHit, 'BigGun');
    ComboHit.SetRelativeLocation(vect(300,0,0));
    SetTimer(0.5, false);
}

function Timer()
{
    PlaySound(sound'ONSBPSounds.ShockTank.ShockBallExplosion', SLOT_None,1.0,,800);
    Spawn(class'TurtleProximityExplosion', self,, Location + vect(0,0,-70));
    HurtRadius(200, 900, class'TurtleDamTypeProximityExplosion', 150000, Location);
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

    if (TShield != None && ShieldHitCount != LastShieldHitCount)
    {
        TShield.SpawnHitEffect(Team);

        LastShieldHitCount = ShieldHitCount;
    }
}

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
        TShield.SpawnHitEffect(Team);
    }
}

simulated function Tick(float DT)
{
    Super.Tick(DT);

    if (TShield == None || Role < ROLE_Authority)
        return;

    if (CurrentShieldHealth <= 0)
        DeactivateShield();

    if (!bShieldActive && (CurrentShieldHealth < MaxShieldHealth))
    {
        if (CurrentDelayTime < MaxDelayTime)
            CurrentDelayTime += DT;
        else
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

simulated function HurtRadius( float DamageAmount, float DamageRadius, class<DamageType> DamageType, float Momentum, vector HitLocation )
{
	local actor Victims;
	local float damageScale, dist;
	local vector dir;

	foreach VisibleCollidingActors( class 'Actor', Victims, DamageRadius, HitLocation )
	{
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
     MaxShieldHealth=9001.000000
     MaxDelayTime=0.700000
     ShieldOnRechargeRate=45.000000
     ShieldRechargeRate=325.000000
     CurrentShieldHealth=1.000000
     RotationsPerSecond=0.200000
     RedSkin=Texture'Reptiles_Tex.Turtle.RedTurtle'
     BlueSkin=Texture'Reptiles_Tex.Turtle.BlueTurtle'
     FireInterval=3.300000
     AltFireInterval=0.500000
     EffectEmitterClass=Class'TurtleOmni.TurtleMuzzleFlash'
     FireSoundClass=Sound'CuddlyArmor_Sound.Turtle.TurtleCannon'
     FireSoundVolume=999.000000
     ProjectileClass=Class'TurtleOmni.TurtleProjectile'
}
