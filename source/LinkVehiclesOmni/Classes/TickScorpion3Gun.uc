//-----------------------------------------------------------
// (c) RBThinkTank 07
//  Coded by milk & Charybdis + Significant chunks of code from the original link gun.
//   ONSRVLinkGun.uc - The weapon for the LS.
//-----------------------------------------------------------
class TickScorpion3Gun extends ONSWeapon;

#exec OBJ LOAD FILE=..\Animations\ONSWeapons-A.ukx

var bool bIsFiring;
var TickScorpion3Omni MyTickScorpion;
var()	float	InheritVelocityScale; // Amount of vehicles velocity

var TickScorpion3BeamEffect			Beam;
var class<TickScorpion3BeamEffect>	BeamEffectClass;

var Sound	MakeLinkSound;
var float	UpTime;
var Pawn	LockedPawn;
var float	LinkBreakTime;
var() float LinkBreakDelay;
var float	LinkScale[6];
var float CurrDrawScale;
var int NumLinkers;  // Links from base vehicle, not used here though.

var String MakeLinkForce;

var() int Damage;
var() float MomentumTransfer;

var() float LinkFlexibility;
var float LinkMultiplier;
var float SelfHealMultiplier; 
var float VehicleDamageMultiplier;
var float VehicleHealScore;
var float RangeExtPerLink;

var		bool bDoHit;
var()	bool bFeedbackDeath;
var		bool bInitAimError;
var		bool bLinkFeedbackPlaying;
var		bool bStartFire;
var byte	LinkVolume;
var byte	SentLinkVolume;

var rotator DesiredAimError, CurrentAimError;

var Sound BeamSounds[4];


var float MinAim;

// for alt-fire taken from ONSRVWebLauncher
var()   float   SpreadAngle; // Angle between initial shots, in radians.
var()   float   MinProjectiles, MaxProjectiles, MaxHoldTime;
var float   StartHoldTime;
var bool    bHoldingFire;
var sound   ChargeUpSound, ChargeLoop;



replication
{
    reliable if (Role == ROLE_Authority)
		bIsFiring, CurrDrawScale;
}

/*
simulated function PostNetBeginPlay()
{
	//if(TickScorpion3Omni(Owner) != None)
	//	MyTickScorpion = TickScorpion3Omni(Owner);
	Super.PostNetBeginPlay();
}
*/

simulated function SetFireRateModifier(float Modifier)
{
    Super.SetFireRateModifier(Modifier);

    MaxHoldTime = default.MaxHoldTime / Modifier;
}


function byte BestMode()
{
	return 0;
}

simulated function float MaxRange()
{
	AimTraceRange = 6000;

	return AimTraceRange;
}


simulated function float ChargeBar()
{
    if (bHoldingFire)
        return (FMin(Level.TimeSeconds - StartHoldTime, MaxHoldTime) / MaxHoldTime);
    else
        return 0;
}


simulated function DestroyEffects()
{
	super.DestroyEffects();

    if ( Level.NetMode != NM_Client )
    {
        if ( Beam != None )
            Beam.Destroy();
    }
}

function float AdjustLinkDamage( int NumLinks, Actor Other, float Damage )
{
	local float AdjDamage;
	
	
	AdjDamage =Min( DamageMin,Damage * (1*NumLinks+1)*CurrDrawScale);
	//Damage = Damage * (LinkMultiplier*NumLinks+1);

	if ( Other.IsA('Vehicle') ) AdjDamage *= VehicleDamageMultiplier;
  if (Instigator.HasUDamage()) 	AdjDamage *= 2;
	
	return AdjDamage;
}

// STATE INSTANT FIRE ===============================================================
state InstantFireMode
{
	
simulated function ClientStopFire(Controller C, bool bWasAltFire)
{

	Super.ClientStopfire(C,bWasAltFire);
	if(!bWasAltFire)
	{
		bIsFiring=False;
	}

  if (Role < ROLE_Authority)
  {
        bHoldingFire = false;
        if (FireCountdown <= 0)
        {
            //FIXME make sounds clientside as well!
            if (bIsAltFire)
                FireCountdown = AltFireInterval;
            else
                FireCountdown = FireInterval;

            FlashMuzzleFlash();

            if (!bIsAltFire)
                PlaySound(FireSoundClass, SLOT_None, FireSoundVolume/255.0,, FireSoundRadius,, false);
        }
    }

}

simulated function ClientStartFire(Controller C, bool bWasAltFire)
{

	Super.ClientStartfire(C,bWasAltFire);
	if(!bWasAltFire)
	{
		bIsFiring=true;
	}

}
	
    simulated function ClientSpawnHitEffects()
    {
    }

    function SpawnHitEffects(Actor HitActor, vector HitLocation, vector HitNormal)
    {
    }
    
	 simulated function tick(float dt)
	{
		local Vector StartTrace, EndTrace, V, X; 
		local Vector HitLocation, HitNormal, EndEffect;
		local Actor Other;
		local Rotator Aim;
		//local float ls;
		local bot B;
		local bool bShouldStop, bIsHealingObjective;
		local int AdjustedDamage;
		local TickScorpion3BeamEffect LB;
		local DestroyableObjective HealObjective;
		local Vehicle LinkedVehicle;
		local float score;
	
		Super.Tick(dt);
		
		
		MyTickScorpion = TickScorpion3Omni(Owner);
		If (MyTickScorpion == None) return; // no driver nothing to do.
		
		CurrDrawScale = MyTickScorpion.CurrDrawScale;
		//log(self@"Tick, CurrDrawScale="@CurrDrawScale);
		// get it from basevehicle and set it so we can ref it from beameffect.
		//SetDrawScale(CurrDrawScale);
		// Set in Vehicle.
		
		//Scale Beam Size, LB but uses Default Size.  
		
		if ( !bIsFiring )
	    {
			bInitAimError = true;
	        return;
	    }
		//if (MyTickScorpion.Links < 0)
		//{
		     //log("warning:"@Instigator@"linkgun had"@MyTickScorpion.Links@"links");
		//	NumLinkers = MyTickScorpion.Links = 0;  // we aren't enabling link stacking power
		//}
		//ls = LinkScale[Min(MyTickScorpion.Links,5)];
		
		if ( (UpTime > 0.0) || (Instigator.Role < ROLE_Authority) )
		{
			UpTime -= dt;
			StartTrace=WeaponFireLocation;
			TraceRange = default.TraceRange*CurrDrawScale + MyTickScorpion.Links*RangeExtPerLink;
			
	        if ( Instigator.Role < ROLE_Authority )
	        {
				if ( Beam == None )
					ForEach DynamicActors(class'TickScorpion3BeamEffect', LB )
						if ( !LB.bDeleteMe && (LB.Instigator != None) && (LB.Instigator == Instigator) )
						{
							Beam = LB;
							break;
						}

				if ( Beam != None ) LockedPawn = Beam.LinkedPawn;
			}

	        if ( LockedPawn != None ) TraceRange *= 1.5;

	   

			if ( LockedPawn != None )
			{
				EndTrace = LockedPawn.Location + LockedPawn.BaseEyeHeight*Vect(0,0,0.5); // beam ends at approx gun height
				if ( Instigator.Role == ROLE_Authority )
				{
					V = Normal(EndTrace - StartTrace);
					if (  (V dot Vector(WeaponFireRotation) < LinkFlexibility) || LockedPawn.Health <= 0 || LockedPawn.bDeleteMe || (VSize(EndTrace - StartTrace) > 1.5 * TraceRange) )
					{
						SetLinkTo( None );
					}
				}
			}

	        if ( LockedPawn == None )
	        {
				
	            if ( Bot(Instigator.Controller) != None )
	            {	
					/*
					if ( bInitAimError )
					{
						CurrentAimError = AdjustAim(StartTrace, AimError);
						bInitAimError = false;
					}
					else
					{
						BoundError();
						CurrentAimError.Yaw = CurrentAimError.Yaw + Instigator.Rotation.Yaw;
					}

					// smooth aim error changes
					Step = 7500.0 * dt;
					if ( DesiredAimError.Yaw ClockWiseFrom CurrentAimError.Yaw )
					{
						CurrentAimError.Yaw += Step;
						if ( !(DesiredAimError.Yaw ClockWiseFrom CurrentAimError.Yaw) )
						{
							CurrentAimError.Yaw = DesiredAimError.Yaw;
							DesiredAimError = AdjustAim(StartTrace, AimError);
						}
					}
					else
					{
						CurrentAimError.Yaw -= Step;
						if ( DesiredAimError.Yaw ClockWiseFrom CurrentAimError.Yaw )
						{
							CurrentAimError.Yaw = DesiredAimError.Yaw;
							DesiredAimError = AdjustAim(StartTrace, AimError);
						}
					}
					CurrentAimError.Yaw = CurrentAimError.Yaw - Instigator.Rotation.Yaw;
					if ( BoundError() )
						DesiredAimError = AdjustAim(StartTrace, AimError);
					CurrentAimError.Yaw = CurrentAimError.Yaw + Instigator.Rotation.Yaw;

					if ( Instigator.Controller.Target == None )
						Aim = Rotator(Instigator.Controller.FocalPoint - StartTrace);
					else
						Aim = Rotator(Instigator.Controller.Target.Location - StartTrace);

					Aim.Yaw = CurrentAimError.Yaw;

					// save difference
					CurrentAimError.Yaw = CurrentAimError.Yaw - Instigator.Rotation.Yaw;
					*/
				}
				else
		          Aim = WeaponFireRotation;//GetPlayerAim(StartTrace, AimError); ANOTHER FUNCTION FOR WEAPONS WE DON'T HAVE.'
	            X = Vector(Aim);
	            EndTrace = StartTrace + TraceRange * X;
	      } // Locked Pawn None

	        Other = Trace(HitLocation, HitNormal, EndTrace, StartTrace, true);
	        if ( Other != None && Other != Instigator )
				EndEffect = HitLocation;
			else
				EndEffect = EndTrace;

			if ( Beam != None )
				Beam.EndEffect = EndEffect;
			
			if ( Instigator.Role < ROLE_Authority )
			{
				/*
					if ( MyTickScorpion.Linking || ((Other != None) && (Instigator.PlayerReplicationInfo.Team != None) && Other.TeamLink(Instigator.PlayerReplicationInfo.Team.TeamIndex)) )
					{
						if (Instigator.PlayerReplicationInfo.Team == None || Instigator.PlayerReplicationInfo.Team.TeamIndex == 0)
							LinkAttachment(LinkGun.ThirdPersonActor).SetLinkColor( LC_Red );
						else
							LinkAttachment(LinkGun.ThirdPersonActor).SetLinkColor( LC_Blue );
					}
					else
					{
						if ( LinkGun.Links > 0 )
							LinkAttachment(LinkGun.ThirdPersonActor).SetLinkColor( LC_Gold );
						else
							LinkAttachment(LinkGun.ThirdPersonActor).SetLinkColor( LC_Green );
					}
				*/
				return;
			}
	        if ( Other != None && Other != Instigator )   {
	            // target can be linked to
	            if ( IsLinkable(Other) )    {
	                if ( Other != lockedpawn )  SetLinkTo( Pawn(Other) );
	                if ( lockedpawn != None )   LinkBreakTime = LinkBreakDelay;
	            }
	            else {   // stop linking
	                if ( lockedpawn != None )  {
	                    if ( LinkBreakTime <= 0.0 )
	                        SetLinkTo( None );
	                    else
	                        LinkBreakTime -= dt;
	                }

	                // beam is updated every frame, but damage is only done based on the firing rate
	                if ( bDoHit ) {
	                    if ( Beam != None ) 	Beam.bLockedOn = false;
	                    Instigator.MakeNoise(1.0);
	                    AdjustedDamage = AdjustLinkDamage( NumLinkers, Other, Damage );
	                    if ( !Other.bWorldGeometry )  {
	                        if ( Level.Game.bTeamGame && Pawn(Other) != None && Pawn(Other).PlayerReplicationInfo != None && Pawn(Other).PlayerReplicationInfo.Team == Instigator.PlayerReplicationInfo.Team) // so even if friendly fire is on you can't' hurt teammates
	                            AdjustedDamage = 0;

											  	HealObjective = DestroyableObjective(Other);
													if ( HealObjective == None )  HealObjective = DestroyableObjective(Other.Owner);
													if ( HealObjective != None && HealObjective.TeamLink(Instigator.GetTeamNum()) ) 	{
															SetLinkTo(None);
															bIsHealingObjective = true;
															HealObjective.HealDamage(AdjustedDamage, Instigator.Controller, DamageType);
								//if (!HealObjective.HealDamage(AdjustedDamage, Instigator.Controller, DamageType))
									//LinkGun.ConsumeAmmo(ThisModeNum, -AmmoPerFire);
													}
													else {
															Other.TakeDamage(AdjustedDamage, Instigator, HitLocation, Momentum*X, DamageType);
															// heal itself
								 							if (MyTickScorpion!=None&&MyTickScorpion.Health<MyTickScorpion.HealthMax&&(ONSPowerCore(HealObjective)==None||ONSPowerCore(HealObjective).PoweredBy(Team)&&!LockedPawn.IsInState('NeutralCore')))
                     								MyTickScorpion.HealDamage(Round(AdjustedDamage * SelfHealMultiplier), Instigator.Controller, DamageType);
													}

											if ( Beam != None )		Beam.bLockedOn = true;
											}  // world geo
									} // do hit
							} // stop linking
						} // other none

			// vehicle healing
			LinkedVehicle = Vehicle(LockedPawn);
			if ( LinkedVehicle != None && bDoHit )
			{
				AdjustedDamage = AdjustLinkDamage( NumLinkers, Other, Damage );
				if(LinkedVehicle.HealDamage(AdjustedDamage, Instigator.Controller, DamageType))
	      {
	        score = 1;
	        if(LinkedVehicle.default.Health >= VehicleHealScore)
	            score = LinkedVehicle.default.Health / VehicleHealScore;
	        if (ONSPlayerReplicationInfo(Instigator.Controller.PlayerReplicationInfo) != None && !LinkedVehicle.IsVehicleEmpty())
	            ONSPlayerReplicationInfo(Instigator.Controller.PlayerReplicationInfo).AddHealBonus((AdjustedDamage/1.5) / LinkedVehicle.default.Health * score);
        }  		
			}
			MyTickScorpion.Linking = (LockedPawn != None) || bIsHealingObjective;

			if ( bShouldStop )
				B.StopFiring();
			else
			{
				// beam effect is created and destroyed when firing starts and stops
				if ( (Beam == None) && bIsFiring )
				{
					Beam = Spawn( BeamEffectClass, Instigator );
					// vary link volume to make sure it gets replicated (in case owning player changed it client side)
					if ( SentLinkVolume == Default.LinkVolume )
						SentLinkVolume = Default.LinkVolume + 1;
					else
						SentLinkVolume = Default.LinkVolume;
				}

				if ( Beam != None )
				{
					if ( MyTickScorpion.Linking || ((Other != None) && (Instigator.PlayerReplicationInfo.Team != None) && Other.TeamLink(Instigator.PlayerReplicationInfo.Team.TeamIndex)) )
					{
						Beam.LinkColor = Instigator.PlayerReplicationInfo.Team.TeamIndex + 1;
						/*if ( LinkGun.ThirdPersonActor != None )
						{
							if ( Instigator.PlayerReplicationInfo.Team == None || Instigator.PlayerReplicationInfo.Team.TeamIndex == 0 )
								LinkAttachment(LinkGun.ThirdPersonActor).SetLinkColor( LC_Red );
							else
								LinkAttachment(LinkGun.ThirdPersonActor).SetLinkColor( LC_Blue );
						}*/
					}
					else
					{
						Beam.LinkColor = 0;
						/*if ( LinkGun.ThirdPersonActor != None )
						{
							if ( LinkGun.Links > 0 )
								LinkAttachment(LinkGun.ThirdPersonActor).SetLinkColor( LC_Gold );
							else
								LinkAttachment(LinkGun.ThirdPersonActor).SetLinkColor( LC_Green );
						}*/
					}

					Beam.Links = MyTickScorpion.Links;
					if(Vehicle(Instigator) != None)
					{
						Vehicle(Instigator).Driver.AmbientSound = BeamSounds[Min(Beam.Links,3)];//changes
						Vehicle(Instigator).Driver.SoundVolume = SentLinkVolume;//changes
					}
					Beam.LinkedPawn = LockedPawn;
					Beam.bHitSomething = (Other != None);
					Beam.EndEffect = EndEffect;
					Beam.TickScorp3Gun=Self;
				}
			}
	    }
	    else
	        WeaponCeaseFire(Instigator.Controller, False);//StopFiring();

	    bStartFire = false;
	    bDoHit = false;
	}


    function Fire(Controller C)
    {

		
		bIsFiring = true;

		bDoHit = true;
		UpTime = FireInterval+0.1;

        ShakeView();
        FlashMuzzleFlash();

        if (AmbientEffectEmitter != None)
        {
            AmbientEffectEmitter.SetEmitterStatus(true);
        }
		/*
        // Play firing noise
        if (bAmbientFireSound)
            AmbientSound = FireSoundClass;
        else
            PlayOwnedSound(AltFireSoundClass, SLOT_None, AltFireSoundVolume/255.0,, AltFireSoundRadius,, False);*/
		}

simulated function OwnerEffects()
    {
        if (Role < ROLE_Authority && !bHoldingFire && bIsAltFire)
        {
            bHoldingFire = true;
            StartHoldTime = Level.TimeSeconds;
        }
    }
	function AltFire(Controller C) {
		 //log(self@"AltFire Called,bHoldingFire="@bHoldingFire);
  	 if (!bHoldingFire)
        {
            StartHoldTime = Level.TimeSeconds;
            bHoldingFire = true;
            AmbientSound = ChargeUpSound;
            SetTimer(MaxHoldTime, False);
        }
    }
    
    
    function Timer()
    {
        if (bHoldingFire)
            AmbientSound = ChargeLoop;
    }
    

    
	function CeaseFire(Controller C)
	{
		local vector GunDir, RightDir, UpDir, FireDir, FireOffset;
		local int i, NumProjectiles;
		local float SpreadAngleRad, FireAngleRad;
		local TickWebCasterProjectileLeader Leader;
		local TickWebCasterProjectile P;

   // log(self@"CeaseFire Called,bHoldingFire="@bHoldingFire@",bIsAltFire="@bIsAltFire);
	//	if (!bIsAltFire) return;
		if (!bHoldingFire) return;

		ClientPlayForceFeedback("BioRifleFire");

		AmbientSound = None;
    //log(self@"CeaseFire Called, CalcWeaponFire()");
		CalcWeaponFire();

		if (bCorrectAim)
			WeaponFireRotation = AdjustAim(false);

		// Defines plane in which projectiles will start travelling in.
		GetAxes(WeaponFireRotation, GunDir, RightDir, UpDir);

    MaxProjectiles = FClamp(Round(default.MaxProjectiles * CurrDrawScale), default.MaxProjectiles, default.MaxProjectiles*2);
    
		NumProjectiles = MinProjectiles + 2 * int(0.5 * (MaxProjectiles - MinProjectiles) * (FMin(Level.TimeSeconds - StartHoldTime, MaxHoldTime) / MaxHoldTime));
		//log(self@"TickWebCaster, CurrDrawSCale="@CurrDrawScale@"NumProjectiles="@NumProjectiles@"MaxProjectiles="@MaxProjectiles);
		
		bHoldingFire = false;

		//SpreadAngleRad = SpreadAngle * (Pi/180.0);
		SpreadAngleRad = (SpreadAngle - Rand(10))* (Pi/180.0); //??? play with this some more?

		// Spawn all the projectiles
		for(i = 0; i < NumProjectiles; i++)
		{
			FireAngleRad = ((1 - NumProjectiles) + 2 * i) * (SpreadAngleRad / NumProjectiles);
			FireDir = Cos(FireAngleRad) * GunDir + Sin(FireAngleRad) * RightDir;
			FireOffset = ((1 - NumProjectiles) + 2 * i) * RightDir;
			
			switch (i) {
				case 0:
					Leader = Spawn(class'TickWebCasterProjectileLeader', self,, WeaponFireLocation + FireOffset, rotator(FireDir));
					
					if (Leader != None)
					{
						Leader.Velocity += InheritVelocityScale * Instigator.Velocity;
						Leader.Projectiles.Length = 2 * NumProjectiles - 2;
						Leader.ProjTeam = C.GetTeamNum();

						Leader.ProjNumber = 0;
						Leader.Projectiles[0] = Leader;
						Leader.Leader = Leader;
						
						//Adjust web for TickScale 
						Leader.SuckTargetSearchRange = Leader.default.SuckTargetSearchRange + ((CurrDrawScale-1)*Leader.default.SuckTargetSearchRange);
						//log(self@"SuckTargetSearchRange="@Leader.SuckTargetSearchRange@" default="@Leader.default.SuckTargetSearchRange);
						//increase suck/sticky force
						// from leader SuckTargets(3)=(SuckTargetClass=Class'Engine.Vehicle',SuckTargetRange=150.000000,SuckTargetForce=6500.000000,SuckReduceVelFactor=0.900000)
					//	log(self@"SuckTargetRange="@Leader.SuckTargets[3].SuckTargetRange@" default="@Leader.default.SuckTargets[3].SuckTargetRange@"CurrDrawScale="@CurrDrawScale);
						Leader.SuckTargets[3].SuckTargetForce = Leader.default.SuckTargets[3].SuckTargetForce + ((CurrDrawScale-1)*Leader.default.SuckTargets[3].SuckTargetForce);
						Leader.SuckTargets[3].SuckReduceVelFactor = Leader.default.SuckTargets[3].SuckReduceVelFactor + ((CurrDrawScale-1)*Leader.default.SuckTargets[3].SuckReduceVelFactor);
					}
					break;
					
				case NumProjectiles - 1:
					
					P = Spawn(class'TickWebCasterProjectile', self, , WeaponFireLocation + FireOffset, rotator(FireDir));
				
					if (P != None && Leader != None)
					{
						P.ProjNumber = 2 * i - 1;
						Leader.Projectiles[P.ProjNumber] = P;
						P.Leader = Leader;
					}
					break;
				
				default:
					if (i % 2 == 1)
						FireOffset -= 0.5 * UpDir;
					
					P = Spawn(class'TickWebCasterProjectile', self, , WeaponFireLocation + FireOffset, rotator(FireDir - 0.05 * UpDir));
					
					if (P != None && Leader != None)
					{
						P.ProjNumber = 2 * i - 1;
						Leader.Projectiles[P.ProjNumber] = P;
						P.Leader = Leader;
					}
					
					FireOffset += UpDir;
					P = Spawn(class'TickWebCasterProjectile', self, , WeaponFireLocation + FireOffset, rotator(FireDir + 0.05 * UpDir));
					
					if (P != None && Leader != None)
					{
						P.ProjNumber = 2 * i;
						Leader.Projectiles[P.ProjNumber] = P;
						P.Leader = Leader;
					}
			}
		}

		ShakeView();
		FlashMuzzleFlash();

		// Play firing noise
		if (bAmbientFireSound)
			AmbientSound = FireSoundClass;
		else
			PlayOwnedSound(FireSoundClass, SLOT_None, FireSoundVolume/255.0,, FireSoundRadius,, false);

		FireCountdown = FireInterval;
	}



}
// END Instant STATE ============================================

// Alt fire stuff

//state ProjectileFireMode
//{
 
 		
//}
// Projectile State END (Altfire)======================================

function SetLinkTo(Pawn Other)
{
    if (LockedPawn != None && MyTickScorpion != None)
    {
        RemoveLink(1 + MyTickScorpion.Links, Instigator);
        MyTickScorpion.Linking = false;
    }

    LockedPawn = Other;

    if (LockedPawn != None)
    {
        if (!AddLink(1 + MyTickScorpion.Links, Instigator))
        {
            bFeedbackDeath = true;
        }
        MyTickScorpion.Linking = true;
        LockedPawn.PlaySound(MakeLinkSound, SLOT_None);
    }
}

function bool AddLink(int Size, Pawn Starter)
{
    local Inventory Inv;
    if (LockedPawn != None && !bFeedbackDeath)
    {
        if (LockedPawn == Starter)
        {
            return false;
        }
        else
        {
			//add code that checks for linkscorp.
            Inv = LockedPawn.FindInventoryType(class'LinkGun');
            if (Inv != None)
            {
                if (LinkFire(LinkGun(Inv).GetFireMode(1)).AddLink(Size, Starter))
                    LinkGun(Inv).Links += Size;
                else
                    return false;
            }
        }
    }
    return true;
}

function RemoveLink(int Size, Pawn Starter)
{
    local Inventory Inv;
    if (LockedPawn != None && !bFeedbackDeath)
    {
        if (LockedPawn != Starter)
        {
			//add code that checks for linkscorp.

            Inv = LockedPawn.FindInventoryType(class'LinkGun');
            if (Inv != None)
            {
                LinkFire(LinkGun(Inv).GetFireMode(1)).RemoveLink(Size, Starter);
                LinkGun(Inv).Links -= Size;
            }
        }
    }
}

function bool IsLinkable(Actor Other)
{
    local Pawn P;
    local LinkGun LG;
    local LinkFire LF;
    local int sanity;

    if ( Other.IsA('Pawn') && Other.bProjTarget )
    {
        P = Pawn(Other);
        if ( P.Weapon == None || !P.Weapon.IsA('LinkGun') )
		{
			if ( Vehicle(P) != None )
				return P.TeamLink( Instigator.GetTeamNum() );

            return false;
		}

        // pro-actively prevent link cycles from happening
        LG = LinkGun(P.Weapon);
        LF = LinkFire(LG.GetFireMode(1));
        while ( LF != None && LF.LockedPawn != None && LF.LockedPawn != P && sanity < 32 )
        {
            if ( LF.LockedPawn == Instigator )
                return false;

            LG = LinkGun(LF.LockedPawn.Weapon);
            if ( LG == None )
                break;
            LF = LinkFire(LG.GetFireMode(1));
            sanity++;
        }

        return ( Level.Game.bTeamGame && P.GetTeamNum() == Instigator.GetTeamNum() );
    }

    return false;
}

function WeaponCeaseFire(Controller C, bool bWasAltFire)
{
	Super.WeaponCeaseFire(C, bWasAltFire);
	if(!bWasAltFire)
	{
		bIsFiring = false;
		if(Vehicle(Instigator) != None)
		{
			Vehicle(Instigator).Driver.AmbientSound = None;//changes
			Vehicle(Instigator).Driver.SoundVolume = Instigator.Default.SoundVolume;//changes
		}
	    if (Beam != None)
	    {
	        Beam.Destroy();
	        Beam = None;
	    }
	    SetLinkTo(None);
		bStartFire = true;
		bFeedbackDeath = false;
		if (MyTickScorpion.Links <= 0)
			StopForceFeedback("BLinkGunBeam1");
	}
}

defaultproperties
{
     BeamEffectClass=Class'LinkVehiclesOmni.TickScorpion3BeamEffect'
     MakeLinkSound=Sound'WeaponSounds.LinkGun.LinkActivated'
     LinkBreakDelay=0.500000
     LinkScale(1)=0.500000
     LinkScale(2)=0.900000
     LinkScale(3)=1.200000
     LinkScale(4)=1.400000
     LinkScale(5)=1.500000
     MakeLinkForce="LinkActivated"
     Damage=12  //link gun shaft is 9
     DamageMin=12 
     Momentum=-10000  //sucking u in 
     LinkFlexibility=0.300000
     bInitAimError=True
     LinkVolume=240
     BeamSounds(0)=Sound'WeaponSounds.LinkGun.BLinkGunBeam1'
     BeamSounds(1)=Sound'WeaponSounds.LinkGun.BLinkGunBeam2'
     BeamSounds(2)=Sound'WeaponSounds.LinkGun.BLinkGunBeam3'
     BeamSounds(3)=Sound'WeaponSounds.LinkGun.BLinkGunBeam4'
     YawBone="rvGUNTurret"
     PitchBone="rvGUNbody"
     PitchUpLimit=13000
     WeaponFireAttachmentBone="RVfirePoint"
     bInstantFire=True
     bDoOffsetTrace=True
     FireInterval=0.120000
     FireSoundVolume=255.000000
     DamageType=Class'XWeapons.DamTypeLinkShaft'
     TraceRange=5500.000000  // 1100 is link gun's trace range
     ShakeRotMag=(Z=60.000000)
     ShakeRotRate=(Z=4000.000000)
     ShakeRotTime=6.000000
     ShakeOffsetMag=(Y=1.000000,Z=1.000000)
     ShakeOffsetRate=(X=1000.000000,Y=1000.000000,Z=1000.000000)
     ShakeOffsetTime=3.000000
     AIInfo(0)=(bLeadTarget=True,bFireOnRelease=True,WarnTargetPct=0.500000,RefireRate=0.650000)
     CullDistance=7500.000000
     Mesh=SkeletalMesh'ONSWeapons-A.RVnewGun'
     RedSkin=Texture'LinkScorpion3Tex.TickTex.TickScorpGun'
     BlueSkin=Texture'LinkScorpion3Tex.TickTex.TickScorpGun'
     SoundVolume=150
    
     CurrDrawScale = 1
     NumLinkers = 1
     LinkMultiplier = 1.5
		 SelfHealMultiplier = 1.1
		 VehicleDamageMultiplier = 1.1 //  increased damage to vehicles might add some specific vehicles here?
     VehicleHealScore = 200
     RangeExtPerLink = 500
     //AltFire
     AltFireInterval=0.30000
     AltFireSoundClass=Sound'ONSVehicleSounds-S.LaserSounds.Laser17'
     AltFireForce="BioRifleFire"
    // AltDamageType=Class'LinkVehiclesOmni.DmgTypeTickWebCaster'
     AltFireProjectileClass=Class'LinkVehiclesOmni.TickWebCasterProjectile'
     SpreadAngle=15.000000
     MinProjectiles=3.000000
     MaxProjectiles=11.000000
     MaxHoldTime=3.000000
}
