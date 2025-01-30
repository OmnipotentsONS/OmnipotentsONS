//-----------------------------------------------------------
// copied (too much to subclass from ONSShockTankCannon
//-----------------------------------------------------------
class HospitalerShieldCannon extends ONSWeapon;

var()   float   MaxShieldHealth;
var()   float   MaxDelayTime;
var()   float   ShieldRechargeRate; // Rate at which shield recharges when deactivated.
var float ShieldRechargeRateActive; // Rate at which the shield recharges when UP and linked.
var		float	LastShieldHitTime;

var     float   CurrentShieldHealth;
var     float   CurrentDelayTime;
var     float   CurrentRechargeTime;
var     bool    bShieldActive, bLastShieldActive;
var		bool	bPutShieldUp;
var     byte    ShieldHitCount, LastShieldHitCount;

var     HospitalerShield   ShockShield;

var float ComboDamage;
var float ComboRadius;
var float ComboMomentum;

var HospitalerV3Omni MyHospitaler;

var float LinkMultiplier;  // linkers increase shield Regen
var int NumLinks; // set from main vehicle
var float SelfHealAmount; // Combo does some self heal always
var float HealTeamBaseAmount;  // base amount to heal team
var float SelfHealMultiplier; // Combo alos gains health based on total damage times this multiplier
var float MaxDamageHealthHeal; // max healing per damage

var Material RegenerationMaterial;

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

    ShockShield = spawn(class'HospitalerShield', self);

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

/* Theese aren't in ONSSHockTAnkCannon */
function WeaponCeaseFire(Controller C, bool bWasAltFire)
{
	if (bWasAltFire) CeaseAltFire();
	Super.WeaponCeaseFire(C, bWasAltFire);
}


function CeaseFire(Controller C)
{
	Super.CeaseFire(C);
  //if (HospitalerShieldCannonPawn(Owner).bShieldUp) CeaseAltFire(); // don't drop shield on normal ceasefire.
  // tODO this isn't working right on Dedicated sERver.  bWeaponisAltFiring isn't REPLICATED so here its unreliable.
  // not sure why we altCeasefire in ceasefire?!
}


function CeaseAltFire()
{
    if (ShockShield != None) DeactivateShield();
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
        ShockShield.ActivateShield(Instigator.Controller.GetTeamNum());
        ScaleShieldStrengthEffect();
}

simulated function ScaleShieldStrengthEffect() 
{
	// tried a bunch left it all here for reference... the one line seems to work best.
	//ShockShield.ShockShieldEffect.Emitters[0].ColorScale[0].Color = class'Canvas'.static.MakeColor( 64,(CurrentShieldHealth/MaxShieldHealth)*128 + 127,64);
	//ShockShield.ShockShieldEffect.Emitters[0].ColorScale[0].Color = class'Canvas'.static.MakeColor( 128,(CurrentShieldHealth/MaxShieldHealth)*128 + 127,64);
	 //ShockShield.ShockShieldEffect.Emitters[0].ColorScale[1].RelativeTime = FClamp(((MaxShieldHealth - CurrentShieldHealth)/MaxShieldHealth),0,1);
				//
     //   if (Instigator.Controller.GetTeamNum() == 1) // blue
        // Color is RGB by position
     //   		ShockShield.ShockShieldEffect.Emitters[0].ColorScale[0].Color = class'Canvas'.static.MakeColor( (CurrentShieldHealth/MaxShieldHealth)*255,(CurrentShieldHealth/MaxShieldHealth)*128,(CurrentShieldHealth/MaxShieldHealth)*64);
      //  else { // Red
            //
           // ShockShield.ShockShieldEffect.Emitters[0].ColorScale[1].Color = class'Canvas'.static.MakeColor( (CurrentShieldHealth/MaxShieldHealth)*255,(CurrentShieldHealth/MaxShieldHealth)*64,(CurrentShieldHealth/MaxShieldHealth)*32);
            
       // }
    // ShockShield.ShockShieldEffect.LightHue =(CurrentShieldHealth/MaxShieldHealth)*192 + 64;
     //ShockShield.ShockShieldEffect.LightBrightness =(CurrentShieldHealth/MaxShieldHealth)*192 + 64;
     //ShockShield.ShockShieldEffect.AmbientGlow =(CurrentShieldHealth/MaxShieldHealth)*254;
     if (ShockShield.ShockShieldEffect!=None) ShockShield.ShockShieldEffect.Emitters[0].Opacity=FMax(0.3,(CurrentShieldHealth/MaxShieldHealth)*1);
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

//	  log(self@"ProximityExplosion Called");
    ComboHit = Spawn(class'HospitalerShieldComboHit', self);
	if ( Level.NetMode == NM_DedicatedServer )
	{
		ComboHit.LifeSpan = 0.6;
	}
    AttachToBone(ComboHit, 'SIDEgunBARREL');
    ComboHit.SetRelativeLocation(vect(300,0,0));
    SetTimer(0.4, false);
}

function Timer()
{
    PlaySound(sound'ONSBPSounds.ShockTank.ShockBallExplosion', SLOT_None,1.0,,800);
    Spawn(class'HospitalerV3Omni.HospitalerProximityExplosion', self,, Location + vect(0,0,-70));
    HurtRadius(ComboDamage, ComboRadius, class'DamTypeHospitalerShockProximityExplosion', ComboMomentum, Location);
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
        ShockShield.SpawnHitEffect(Instigator.Controller.GetTeamNum());

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
       ScaleShieldStrengthEffect();
    }
}

simulated function Tick(float DT)
{
    Super.Tick(DT);

		
		
    if (Owner != None && HospitalerV3Omni(ONSWeaponPawn(Owner).VehicleBase) != None)
			NumLinks = HospitalerV3Omni(ONSWeaponPawn(Owner).VehicleBase).Links;
	  else
		  NumLinks = 0;

    if (ShockShield == None || Role < ROLE_Authority)
        return;

    if (CurrentShieldHealth <= 0)                        // Ran out of shield energy so deactivate
        DeactivateShield();

    if (bShieldActive && (CurrentShieldHealth < MaxShieldHealth))  // Shield is on and needs recharge
    // only recharge while up if Hospitaler is being linkend
    {
       CurrentShieldHealth += (ShieldRechargeRateActive * ((NumLinks*LinkMultiplier))) * DT;
       //if num links is 0, then no recharging while shield is up.
       if (CurrentShieldHealth >= MaxShieldHealth) CurrentShieldHealth = MaxShieldHealth;
    }
    else if (!bShieldActive && (CurrentShieldHealth < MaxShieldHealth))  // Shield is off and needs recharge
    {
        if (CurrentDelayTime < MaxDelayTime)           // Shield is in delay
            CurrentDelayTime += DT;
        else                                           // Shield is in recharge
        {
            CurrentShieldHealth += (ShieldRechargeRate * ((NumLinks+1)*LinkMultiplier)) * DT;
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
  local float damageTotal;
  local float actualMomentum;
  

//  log(self@":HurtRadius - Start");
	damageTotal=0;
	foreach VisibleCollidingActors( class 'Actor', Victims, DamageRadius, HitLocation )
	{
		// don't let blast damage affect fluid - VisibleCollisingActors doesn't really work for them - jag
		if( (Victims != ONSWeaponPawn(Owner).VehicleBase) && (Victims.Role == ROLE_Authority) && !Victims.IsA('FluidSurfaceInfo') )
		{
			if (Pawn(Victims) != None && Pawn(Victims).GetTeamNum() == Instigator.Controller.GetTeamNum()) ActualMomentum=0;
			else ActualMomentum=Momentum; //only use momentum on non-team mates
			
			dir = Victims.Location - HitLocation;
			dist = FMax(1,VSize(dir));
			dir = dir/dist;
			damageScale = 1 - FMax(0,(dist - Victims.CollisionRadius)/DamageRadius);
			Victims.TakeDamage(damageScale * DamageAmount,Instigator,Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,(damageScale * ActualMomentum * dir),	DamageType);
			if (Pawn(Victims) != None && Pawn(Victims).GetTeamNum() != Instigator.Controller.GetTeamNum()) damageTotal += (damageScale * DamageAmount);
			if (Vehicle(Victims) != None && Vehicle(Victims).Health > 0) {
				Vehicle(Victims).DriverRadiusDamage(DamageAmount, DamageRadius, Instigator.Controller, DamageType, ActualMomentum, HitLocation);
			}	
				

      //Friendlies gain Health!
      if ( Pawn(Victims) != None && Victims != Instigator  && (Pawn(Victims).GetTeamNum() == Instigator.Controller.GetTeamNum()) )    //&& !Victims.IsA('EONSPaladin')
      {
      	//log(self@"Have Friendly to heal");
         Pawn(Victims).SetOverlayMaterial( RegenerationMaterial, 0.25, false );
         If (Pawn(Victims).IsA('Vehicle')) 
            Pawn(Victims).GiveHealth((HealTeamBaseAmount*(NumLinks+3)),Pawn(Victims).HealthMax);
              // vehicles get extra healing if there's linkers, and 3 times base amount with 0 linkers.  They have to be close. Snuggling even.
         else
             Pawn(Victims).GiveHealth(HealTeamBaseAmount,Pawn(Victims).HealthMax); // heal players Base Amount no increase for link
         // lets not downscale team healing based on Range
      }
		}
	}
	// self heal base amount
	//log(self@":HurtRadius - SelfHealBaseAmount-CurrentHealth"@ONSWeaponPawn(Owner).VehicleBase.Health);
	HospitalerV3Omni(ONSWeaponPawn(Owner).VehicleBase).GiveHealth(SelfHealAmount, HospitalerV3Omni(ONSWeaponPawn(Owner).VehicleBase).HealthMax);
 // log(self@":HurtRadius - AFTER SelfHealBaseAmount-CurrentHealth"@ONSWeaponPawn(Owner).VehicleBase.Health);

	//  self heal based on Damage
	
	HospitalerV3Omni(ONSWeaponPawn(Owner).VehicleBase).GiveHealth(FMin(damageTotal * SelfHealMultiplier, MaxDamageHealthHeal), HospitalerV3Omni(ONSWeaponPawn(Owner).VehicleBase).HealthMax);
}

defaultproperties
{
     MaxShieldHealth=2100.000000 // Reduced a bit but still want to take one mino hit.
     MaxDelayTime=0.330000
     ShieldRechargeRate=320.000000
     ShieldRechargeRateActive=180.000
     CurrentShieldHealth=2100.000000
     YawBone="SIDEgunBASE"
     PitchBone="SIDEgunBARREL"
     PitchUpLimit=18000
     PitchDownLimit=58000
     WeaponFireAttachmentBone="Firepoint"
     WeaponFireOffset=280
     RotationsPerSecond=0.500000
     bShowChargingBar=True
     RedSkin=Texture'IllyHeavyCrusaderSkins.HeavyCrusader.HeavyCrusader_0'
     BlueSkin=Texture'IllyHeavyCrusaderSkins.HeavyCrusader.HeavyCrusader_1'
     FireInterval=1.50000
     //EffectEmitterClass=Class'OnslaughtFull.FX_IonPlasmaTank_ShockWave'
     EffectEmitterClass=Class'OnslaughtBP.ONSShockTankMuzzleFlash'
     FireSoundClass=Sound'ONSBPSounds.ShockTank.ShockBallFire'
     RotateSound=Sound'ONSBPSounds.ShockTank.TurretHorizontal'
     ProjectileClass=Class'HospitalerV3Omni.HospitalerShieldCannonProjectile'
     AIInfo(0)=(bTrySplash=True,bLeadTarget=True,WarnTargetPct=0.750000,RefireRate=0.800000)
     AIInfo(1)=(bInstantHit=True,RefireRate=0.990000)
     Mesh=SkeletalMesh'ONSWeapons-A.PRVsideGun'
     DrawScale=1.5
     
     bForceSkelUpdate=True
     bNetNotify=True
     
     ComboDamage=333;
     ComboRadius=1250;
     ComboMomentum=170000;
     
     
     LinkMultiplier=0.8 // number of linkers +1 * shield Recharge rate.
     SelfHealAmount=60  // this is health, 
     HealTeamBaseAmount=175  // this is real health
     SelfHealMultiplier=0.33  //self heal from Shield Combo  pt heal for 1  pts damage
     MaxDamageHealthHeal=600  // max self heal from Shield combo.
     RegenerationMaterial=Shader'XGameShaders.PlayerShaders.PlayerShieldSh'
}
