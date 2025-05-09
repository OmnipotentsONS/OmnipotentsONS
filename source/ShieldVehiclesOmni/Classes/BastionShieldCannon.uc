//-----------------------------------------------------------
// copied (too much to subclass from ONSShockTankCannon
//-----------------------------------------------------------
class BastionShieldCannon extends ONSWeapon;

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

var     BastionShield   ShockShield;

var float ComboDamage;
var float ComboRadius;
var float ComboMomentum;

var Bastion MyBastion;

var float LinkMultiplier;  // linkers increase shield Regen
var int NumLinks; // set from main vehicle
var float SelfHealAmount; // Combo does some self heal always
var float HealTeamBaseAmount;  // base amount to heal team
var float SelfHealMultiplier; // Combo alos gains health based on total damage times this multiplier
var float MaxDamageHealthHeal; // max healing per damage
var float NodeHealAmount; // amount to heal a node
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

    ShockShield = spawn(class'BastionShield', self);

    if (ShockShield != None)
        AttachToBone(ShockShield, 'ElectroGun');
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

/* Theese aren't in ONSSHockTAnkCannon 
// They make the shield drop for combo
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
*/

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

    if (ShockShield != None) {
        ShockShield.ActivateShield(Instigator.Controller.GetTeamNum());
        ScaleShieldStrengthEffect();
    }    
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

    ComboHit = Spawn(class'BastionShieldComboHit', self);
   	if ( Level.NetMode == NM_DedicatedServer )
	{
		ComboHit.LifeSpan = 0.6;
	}
    AttachToBone(ComboHit, 'BigGun');
    ComboHit.SetRelativeLocation(vect(300,0,0));
    SetTimer(0.5, false);
}

function Timer()
{
    PlaySound(sound'ONSBPSounds.ShockTank.ShockBallExplosion', SLOT_None,1.0,,800);
    Spawn(class'BastionProximityExplosion', self,, Location + vect(0,0,-50)); // 0,0,-70
    HurtRadius(ComboDamage, ComboRadius, class'DamTypeBastionProximityExplosion', ComboMomentum, Location);
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
        ScaleShieldStrengthEffect();
    }
}

simulated function Tick(float DT)
{
    Super.Tick(DT);

		
		if (Bastion(Owner) != None) 
		  { MyBastion=Bastion(Owner);
		    NumLinks = MyBastion.Links;
		  }
		else  NumLinks = 0;

    if (ShockShield == None || Role < ROLE_Authority)
        return;

    if (CurrentShieldHealth <= 0)                        // Ran out of shield energy so deactivate
        DeactivateShield();

    if (bShieldActive && (CurrentShieldHealth < MaxShieldHealth))  // Shield is on and needs recharge
    // only recharge while up if Bastion is being linkend
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
    return FClamp(CurrentShieldHealth/MaxShieldHealth, 0.0, 0.9999);
}

simulated function HurtRadius( float DamageAmount, float DamageRadius, class<DamageType> DamageType, float Momentum, vector HitLocation )
{
	local actor Victims;
	local float damageScale, dist;
	local vector dir;
  local float damageTotal;
  local float ActualMomentum;
  local DestroyableObjective Node;
  

//  log(self@":HurtRadius - Start");
	damageTotal=0; 
	foreach VisibleCollidingActors( class 'Actor', Victims, DamageRadius, HitLocation )
	{
		// don't let blast damage affect fluid - VisibleCollisingActors doesn't really work for them - jag
		if( (Victims != self) && (Victims.Role == ROLE_Authority) && !Victims.IsA('FluidSurfaceInfo') )
		{
			if (Pawn(Victims) != None && Pawn(Victims).GetTeamNum() == Instigator.Controller.GetTeamNum()) ActualMomentum=0;
			else ActualMomentum=Momentum; //only use momentum on non-team mates
			
			dir = Victims.Location - HitLocation;
			dist = FMax(1,VSize(dir));
			dir = dir/dist;
			damageScale = 1 - FMax(0,(dist - Victims.CollisionRadius)/DamageRadius);
			Victims.TakeDamage(damageScale * DamageAmount,Instigator,Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,(damageScale * ActualMomentum * dir),	DamageType);
			if (Pawn(Victims) != None && Pawn(Victims).GetTeamNum() != Instigator.Controller.GetTeamNum()) 
			  damageTotal += (damageScale * DamageAmount);
			if (Vehicle(Victims) != None && Vehicle(Victims).Health > 0) {
				Vehicle(Victims).DriverRadiusDamage(DamageAmount, DamageRadius, Instigator.Controller, DamageType, ActualMomentum, HitLocation);
			}	
				
			if ( Pawn(Victims) != None && Victims != Instigator ) {
      //Friendlies gain Health!
         if (Pawn(Victims).GetTeamNum() == Instigator.Controller.GetTeamNum())    //&& !Victims.IsA('EONSPaladin')
			      {
			      	//log(self@"Have Friendly to heal");
			         Pawn(Victims).SetOverlayMaterial( RegenerationMaterial, 0.25, false );
			         If (Pawn(Victims).IsA('Vehicle')) 
			            Pawn(Victims).GiveHealth((HealTeamBaseAmount*(NumLinks+1)),Pawn(Victims).HealthMax);
			            // vehicles get extra healing if there's linkers
			         else
			             Pawn(Victims).GiveHealth(HealTeamBaseAmount,Pawn(Victims).HealthMax); // heal players Base Amount no increase for link
			         // lets not downscale team healing based on Range
			      }
			} // friends
			//log("Victims="@Victims,'ShieldVehiclesOmni');  		
			      // heal nodes if it touches any part.
      Node = DestroyableObjective(Victims);			      
      /* Just the node, not the parts since its HurtRadius
      if (Victims.IsA('ONSPowerNodeEnergySphere') 
			 	    || Victims.IsA('ONSPowerNodeShield') 
			 	    || Victims.IsA('ONSSpecialLinkBeamCatcher')
			 	    || Victims.IsA('ONSSpecialPowerNodeShield') 
			 	    || Victims.IsA('ONSSpecialPowerNodeEnergySphere')) 
			 	    Node = DestroyableObjective(Victims.Owner);*/
		//	log("Node="@Node,'ShieldVehiclesOmni');  		
			if (Node != None) {
			  	// While its constructing PoweredBy(TeamNum) doesn't get set right.  It only gets set when node fully powers up.
            if (ONSPowerNode(Node) != None && (Node.DefenderTeamIndex == Instigator.Controller.GetTeamNum()) && Node.Health > 0 )
					  //if (ONSPowerNode(Node) != None && ONSPowerNode(Node).PoweredBy(TeamNum) && Node.Health > 0 )
			  		{ // Friendly Node
			  			Node.HealDamage(NodeHealAmount*((LinkMultiplier*NumLinks)+1), Instigator.Controller, DamageType);
			  		//	log("Bastion Healing Friendly Node for "@(NodeHealAmount*((LinkMultiplier*NumLinks)+1))@" health",'ShieldVehiclesOmni');
			     	}
      } // node
		} // victims
	} // for
	// self heal base amount
	//log(self@":HurtRadius - SelfHealmount="@SelfHealAmount);
	// Note HealDamage amount is modified by LinkHealMult (from Engine.Vehicle) (from linkgun healing), default is 0.35
	// so to get actual healing amount use GiveHealth instead .SelfHealAmount (in health) 
	MyBastion.GiveHealth(SelfHealAmount, MyBastion.HealthMax);
  //log(self@":HurtRadius - AFTER SelfHealBaseAmount-CurrentHealth"@ONSWeaponPawn(Owner).VehicleBase.Health);
	//  self heal based on Damage
	//log(self@":HurtRadius - FromDamage="@Round(damageTotal * SelfHealMultiplier));
	//Heal up to MaxDamageHealthHeal
	MyBastion.GiveHealth(FMin(damageTotal * SelfHealMultiplier, MaxDamageHealthHeal), MyBastion.HealthMax);
}

defaultproperties
{
     MaxShieldHealth=3400.000000
     MaxDelayTime=0.330000
     ShieldRechargeRate=325.000000
     ShieldRechargeRateActive=150.000
     CurrentShieldHealth=2800.000000
     YawBone="8WheelerTop"
     PitchBone="TurretAttach"
     PitchUpLimit=18000
     PitchDownLimit=58000
     WeaponFireAttachmentBone="Firepoint"
     WeaponFireOffset=90
     RotationsPerSecond=0.180000
     bShowChargingBar=True
     RedSkin=Texture'Bastion_Tex.Bastion.RedBastion'
     BlueSkin=Texture'Bastion_Tex.Bastion.BlueBastion'
     Mesh=SkeletalMesh'ONSBPAnimations.ShockTankCannonMesh'
     FireInterval=1.50000
     EffectEmitterClass=Class'OnslaughtBP.ONSShockTankMuzzleFlash'
     FireSoundClass=Sound'ONSBPSounds.ShockTank.ShockBallFire'
     RotateSound=Sound'ONSBPSounds.ShockTank.TurretHorizontal'
     ProjectileClass=Class'ShieldVehiclesOmni.BastionShieldCannonProjectile'
     AIInfo(0)=(bTrySplash=True,bLeadTarget=True,WarnTargetPct=0.750000,RefireRate=0.800000)
     AIInfo(1)=(bInstantHit=True,RefireRate=0.990000)
     DrawScale=0.800000
     bForceSkelUpdate=True
     bNetNotify=True
     
     ComboDamage=275;  //damage scales down with distance. 1.5 to vehicles.
     ComboRadius=1050;
     ComboMomentum=150000;
     
     
     LinkMultiplier=0.8 // number of linkers +1 * shield Recharge rate.
     SelfHealAmount=40  // this is health, HealDamage takes damage points (typically from Link) so divided it by (Engine.Vehicle).LinkHealthMult
     HealTeamBaseAmount=150  // this is real health
     SelfHealMultiplier=0.45  //self heal from Shield Combo  pt heal for 1  pts damage
     MaxDamageHealthHeal= 225  // max self heal from Shield combo.
     NodeHealAmount=130 // every 1.5s, link gun is 112 every 1.5s
     RegenerationMaterial=Shader'XGameShaders.PlayerShaders.PlayerShieldSh'
}
