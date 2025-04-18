class VampireTank3Gun extends ONSWeapon;

#exec OBJ LOAD FILE=..\Animations\ONSWeapons-A.ukx

var bool bIsFiring;
var VampireTank3 MyVampireTank;
var()	float	InheritVelocityScale; // Amount of vehicles velocity

var VampireTank3BeamEffect			Beam;
var class<VampireTank3BeamEffect>	BeamEffectClass;

var Sound	MakeLinkSound;
var float	UpTime;
var Pawn	LockedPawn;
var float	LinkBreakTime;
var() float LinkBreakDelay;
var float	LinkScale[6];


var String MakeLinkForce;

var() int Damage;

var() float LinkFlexibility;
var float LinkMultiplier;
var float SelfHealMultiplier; 
var float VehicleDamageMult;
var config int VehicleHealScore; // how much occupied vehicle healing = 1pt player score
var float RangeExtPerLink; // how much range is extended per linker
var float LinkMultiplierCap;

var		bool bDoHit;
var()	bool bFeedbackDeath;
var		bool bInitAimError;
var		bool bLinkFeedbackPlaying;
var		bool bStartFire;
var byte	LinkVolume;
var byte	SentLinkVolume;

var rotator DesiredAimError, CurrentAimError;
var class<DamageType>   AltDamageType;

var Sound BeamSounds[4];


var float MinAim;
var     float   AltFireMomentum, AltFireRadius, AltFireDamage, AltFireDamageVehicleMult, AltFireMomentumVehicleMult;
Var float AltFireMomentumEasterEggMult, AltFireDamageEasterEggMult; //Multiplier for some vehicles.
     
var float               AltFireCountdown;  // countdown only for alt-fire separate from fire.

replication
{
    reliable if (Role == ROLE_Authority)
		bIsFiring;
}

/*
simulated function PostNetBeginPlay()
{
	if(VampireTank3(Owner) != None)
		MyVampireTank = VampireTank3(Owner);
	Super.PostNetBeginPlay();
}
*/

simulated function ClientStopFire(Controller C, bool bWasAltFire)
{

	Super.ClientStopfire(C,bWasAltFire);
	if(!bWasAltFire)
	{
		bIsFiring=False;
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

function byte BestMode()
{
	return 0;
}

simulated function float MaxRange()
{
	AimTraceRange = 6000;

	return AimTraceRange;
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

function float AdjustLinkDamage( int NumLinks, Actor Target, float Damage )
{
	local float AdjDamage;
	
AdjDamage = Damage * FMin(LinkMultiplier*NumLinks+1,LinkMultiplierCap);
	// no matter how many linkers Multiplier Cap

	if (Target != None && Target.IsA('Vehicle') ) 	AdjDamage *= VehicleDamageMult;
  if (Instigator.HasUDamage()) 	AdjDamage *= 2;
	
	return AdjDamage;
	
}



// ====================== Instant Fire
state InstantFireMode
{
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
	//	local float ls;
		local bot B;
		local bool bShouldStop, bIsHealingObjective;
		local int AdjustedDamage;
		local VampireTank3BeamEffect LB;
		local DestroyableObjective HealObjective;
		local Vehicle LinkedVehicle;

		Super.Tick(dt);
		
		MyVampireTank = VampireTank3(Owner);
		If (MyVampireTank == None) return; // no driver nothing to do.
		
		 if(AltFireCountdown > 0)  AltFireCountdown -= dt;
				
		if ( !bIsFiring )
	    {
			bInitAimError = true;
	        return;
	    }
		if (MyVampireTank.Links < 0)
		{
		     //log("warning:"@Instigator@"linkgun had"@MyVampireTank.Links@"links");
			MyVampireTank.Links = 0;
		}
		//ls = LinkScale[Min(MyVampireTank.Links,5)];
		if ( (UpTime > 0.0) || (Instigator.Role < ROLE_Authority) )
		{
			UpTime -= dt;
			StartTrace=WeaponFireLocation;
			TraceRange = default.TraceRange + MyVampireTank.Links*250;
			
	        if ( Instigator.Role < ROLE_Authority )
	        {
				if ( Beam == None )
					ForEach DynamicActors(class'VampireTank3BeamEffect', LB )
						if ( !LB.bDeleteMe && (LB.Instigator != None) && (LB.Instigator == Instigator) )
						{
							Beam = LB;
							break;
						}

				if ( Beam != None )
					LockedPawn = Beam.LinkedPawn;
			}

	        if ( LockedPawn != None )
				TraceRange *= 1.5;

	   

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
	        }

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
					if ( MyVampireTank.Linking || ((Other != None) && (Instigator.PlayerReplicationInfo.Team != None) && Other.TeamLink(Instigator.PlayerReplicationInfo.Team.TeamIndex)) )
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
	        if ( Other != None && Other != Instigator )
	        {
	            // target can be linked to
	            if ( IsLinkable(Other) )
	            {
	                if ( Other != lockedpawn )
	                    SetLinkTo( Pawn(Other) );

	                if ( lockedpawn != None )
	                    LinkBreakTime = LinkBreakDelay;
	            }
	            else
	            {
	                // stop linking
	                if ( lockedpawn != None )
	                {
	                    if ( LinkBreakTime <= 0.0 )
	                        SetLinkTo( None );
	                    else
	                        LinkBreakTime -= dt;
	                }

	                // beam is updated every frame, but damage is only done based on the firing rate
	                if ( bDoHit )
	                {
	                    if ( Beam != None )	Beam.bLockedOn = false;
	                    Instigator.MakeNoise(1.0);

	                    AdjustedDamage = AdjustLinkDamage( MyVampireTank.Links, Other, Damage );

	                    if ( !Other.bWorldGeometry )
	                    {
	                        if ( Level.Game.bTeamGame && Pawn(Other) != None && Pawn(Other).PlayerReplicationInfo != None
								&& Pawn(Other).PlayerReplicationInfo.Team == Instigator.PlayerReplicationInfo.Team) // so even if friendly fire is on you can't' hurt teammates
	                            AdjustedDamage = 0;

							HealObjective = DestroyableObjective(Other);
							if ( HealObjective == None )
								HealObjective = DestroyableObjective(Other.Owner);
							if ( HealObjective != None && HealObjective.TeamLink(Instigator.GetTeamNum()) )
							{
								SetLinkTo(None);
								bIsHealingObjective = true;
								HealObjective.HealDamage(AdjustedDamage, Instigator.Controller, DamageType);
								//if (!HealObjective.HealDamage(AdjustedDamage, Instigator.Controller, DamageType))
									//LinkGun.ConsumeAmmo(ThisModeNum, -AmmoPerFire);
							}
							else {
								Other.TakeDamage(AdjustedDamage, Instigator, HitLocation, Momentum*X, DamageType);
								// heal itself
								 if (MyVampireTank!=None&&MyVampireTank.Health<MyVampireTank.HealthMax&&(ONSPowerCore(HealObjective)==None||ONSPowerCore(HealObjective).PoweredBy(Team)&&!ONSPowerCore(HealObjective).IsInState('NeutralCore')))
                     MyVampireTank.HealDamage(Round(AdjustedDamage * SelfHealMultiplier), Instigator.Controller, DamageType);
							}

							if ( Beam != None )
								Beam.bLockedOn = true;
						}
					}
				}
			}

			// vehicle healing
			LinkedVehicle = Vehicle(LockedPawn);
			if ( LinkedVehicle != None && bDoHit )
			{
				AdjustedDamage = AdjustLinkDamage( MyVampireTank.Links, None, Damage ); // Target None = No vehicle damage multiplier
					
		  	if(LinkedVehicle.HealDamage(AdjustedDamage, Instigator.Controller, DamageType))
	        if (ONSPlayerReplicationInfo(Instigator.Controller.PlayerReplicationInfo) != None && !LinkedVehicle.IsVehicleEmpty())
                  ONSPlayerReplicationInfo(Instigator.Controller.PlayerReplicationInfo).AddHealBonus(FMin((AdjustedDamage * LinkedVehicle.LinkHealMult) / VehicleHealScore, LInkedVehicle.HealthMax - LinkedVehicle.Health)); 
			}
			MyVampireTank.bLinking = (LockedPawn != None) || bIsHealingObjective;

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
					if ( MyVampireTank.bLinking || ((Other != None) && (Instigator.PlayerReplicationInfo.Team != None) && Other.TeamLink(Instigator.PlayerReplicationInfo.Team.TeamIndex)) )
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

					Beam.Links = MyVampireTank.Links;
					if(Vehicle(Instigator) != None)
					{
						Vehicle(Instigator).Driver.AmbientSound = BeamSounds[Min(Beam.Links,3)];//changes
						Vehicle(Instigator).Driver.SoundVolume = SentLinkVolume;//changes
					}
					Beam.LinkedPawn = LockedPawn;
					Beam.bHitSomething = (Other != None);
					Beam.EndEffect = EndEffect;
					Beam.VampTankGun=Self;
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






	function AltFire(Controller C)
	{
		local VampireLightiningShockWave		Shock;
		local float		DistScale, dist;
		local vector	dir, StartLocation;
		local Actor		Victims;
		local Pawn  VictimPawn;

		NetUpdateTime = Level.TimeSeconds - 1;
		//bFireMode = true;
	//	log(self@"AltFire start....");
		StartLocation = Instigator.Location;

		PlaySound(Sound'ONSVehicleSounds-S.AVRiL.AvrilFire01', SLOT_None, 128/255.0,,, 2.5, False);

		Shock = Spawn(class'VampireLightiningShockWave', Self,, StartLocation);
		
		if (Instigator.GetTeamNum()==0) {
			//Red
			 Shock.Emitters[1].ColorScale[0].Color = class'Canvas'.static.MakeColor( 204,0, 0);
       Shock.Emitters[1].ColorScale[1].Color = class'Canvas'.static.MakeColor( 204,0, 0);
       Shock.Emitters[1].ColorScale[2].Color = class'Canvas'.static.MakeColor( 204,0, 0);
		}
		else
		{
			//Blue
			 Shock.Emitters[1].ColorScale[0].Color = class'Canvas'.static.MakeColor( 0,0, 255);
       Shock.Emitters[1].ColorScale[1].Color = class'Canvas'.static.MakeColor( 0,0, 255);
       Shock.Emitters[1].ColorScale[2].Color = class'Canvas'.static.MakeColor( 0,0, 255);
		}

	  /*Shock.Emitters[0].ColorScale[0].Color = class'Canvas'.static.MakeColor( 0, 77, 64);
	  Shock.Emitters[0].ColorScale[1].Color = class'Canvas'.static.MakeColor( 136, 14, 79);
	  Shock.Emitters[0].ColorScale[2].Color = class'Canvas'.static.MakeColor( 136, 14, 79);

    Shock.Emitters[1].ColorScale[0].Color = class'Canvas'.static.MakeColor( 124, 10, 2);
    Shock.Emitters[1].ColorScale[1].Color = class'Canvas'.static.MakeColor( 0, 77, 64);
    Shock.Emitters[1].ColorScale[2].Color = class'Canvas'.static.MakeColor( 0, 77, 64);

    Shock.Emitters[2].ColorScale[0].Color = class'Canvas'.static.MakeColor(0, 77, 64); //74,20,140
    Shock.Emitters[2].ColorScale[1].Color = class'Canvas'.static.MakeColor( 74,20,140);
    Shock.Emitters[2].ColorScale[2].Color = class'Canvas'.static.MakeColor( 74,20,140);
    */
		Shock.SetBase( Instigator );



		foreach VisibleCollidingActors( class'Actor', Victims, AltFireRadius, StartLocation )
		{
			//log("found:" @ Victims.GetHumanReadableName() );
			// don't let Shock affect fluid - VisibleCollisingActors doesn't really work for them - jag
			
			//log("Victims:" @ Victims.GetHumanReadableName() @ "DistScale:" @ DistScale );
				if (Victims != Instigator && !Victims.IsA('FluidSurfaceInfo')) { //&& (Victims.Controller != None)
					dir = Victims.Location - StartLocation;
					dir.Z = 0;
					dist = FMax(1,VSize(dir));
					dir = Normal(Dir)*0.5 + vect(0,0,1);
					DistScale = 1 - FMax(0,(dist - Victims.CollisionRadius)/AltFireRadius);
				
					VictimPawn = Pawn(Victims);
				
				//log("VictimPawn:"@ "Victim Team:" @ VictimPawn.Controller.GetTeamNum() @ "Instigator Team:" @ Instigator.GetTeamNum()  );
					if (VictimPawn != None && VictimPawn.Controller != None 
			   		 && VictimPawn.Controller.GetTeamNum() != Instigator.GetTeamNum()  // spare your team
				 		&& (Victims.Role == ROLE_Authority) )
				 		// only does damage if there's instigators/controllers doesn't affect empty stuff. so no blast against empty vehicles.
				  { // Handle Vehicles/Infantry (pawns)
					//log("PawnVictims:" @ Victims.GetHumanReadableName() @ "DistScale:" @ DistScale );
				
					if (Victims.IsA('Omnitaur')|| Victims.IsA('Minotaur')|| Victims.IsA('MinotaurClassic'))
					{
							// Special easter egg!  
							VictimPawn.AddVelocity( DistScale * -AltFireMomentum * dir * AltFireMomentumEasterEggMult);
							VictimPawn.TakeDamage(DistScale * AltFireDamage * AltFireDamageEasterEggMult, Instigator, VictimPawn.Location, DistScale * AltFireMomentum * dir, AltDamageType);
							MyVampireTank.HealDamage(DistScale * AltFireDamage * SelfHealMultiplier, Instigator.Controller, DamageType);
					}
					else if (Vehicle(Victims) == None)
							 {
								//Victims.AddVelocity( DistScale * -AltFireMomentum * dir );
								// I think add velocity was bypassing spawn protection.
								VictimPawn.TakeDamage(DistScale * AltFireDamage, Instigator, VictimPawn.Location, DistScale * AltFireMomentum * dir, AltDamageType);
								MyVampireTank.HealDamage(DistScale * AltFireDamage * SelfHealMultiplier, Instigator.Controller, DamageType);
							 }
							 else
							 { // Vehicles
						  		VictimPawn.AddVelocity( DistScale * -AltFireMomentum * dir * AltFireMomentumVehicleMult);
									VictimPawn.TakeDamage(DistScale * AltFireDamage * AltFireDamageVehicleMult, Instigator, VictimPawn.Location, DistScale * AltFireMomentum * dir, AltDamageType);
									MyVampireTank.HealDamage(DistScale * AltFireDamage * SelfHealMultiplier, Instigator.Controller, DamageType);
							 }

				
				} // end pawns
				// non pawns (eg. Nodes here)
				//log("Actor, Not Pawns" @ Victims);
				if (Victims.IsA('ONSPowerCore') || Victims.IsA('ONSPowerNodeEnergySphere')) 
				{
					//log("FoundPowerCode/Node - Do Damage" $ Victims);
					Victims.TakeDamage(DistScale * AltFireDamage  * AltFireDamageVehicleMult, Instigator, Victims.Location, DistScale * AltFireMomentum * dir, DamageType);
					MyVampireTank.HealDamage(DistScale * AltFireDamage * SelfHealMultiplier, Instigator.Controller, DamageType);
				}
			}
		}
	} // alt fire




}// ====================== Instant Fire







function SetLinkTo(Pawn Other)
{
    if (LockedPawn != None && MyVampireTank != None)
    {
        RemoveLink(1 + MyVampireTank.Links, Instigator);
        MyVampireTank.bLinking = false;
    }

    LockedPawn = Other;

    if (LockedPawn != None)
    {
        if (!AddLink(1 + MyVampireTank.Links, Instigator))
        {
            bFeedbackDeath = true;
        }
        MyVampireTank.bLinking = true;
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
		if (MyVampireTank.Links <= 0)
			StopForceFeedback("BLinkGunBeam1");
	}
}

// Added 03/2023 pooty to make primary fire available all the time
// base code from ONSWeapon

event bool AttemptFire(Controller C, bool bAltFire)
{
    if(Role != ROLE_Authority || bForceCenterAim)
        return False;

    if (FireCountdown <= 0 && !bAltFire)
    {
        CalcWeaponFire();
        if (bCorrectAim)
            WeaponFireRotation = AdjustAim(bAltFire);
        if (Spread > 0)
            WeaponFireRotation = rotator(vector(WeaponFireRotation) + VRand()*FRand()*Spread);

        DualFireOffset *= -1;

        Instigator.MakeNoise(1.0);
        FireCountdown = FireInterval;
        Fire(C);
        AimLockReleaseTime = Level.TimeSeconds + FireCountdown * FireIntervalAimLock;

        return True;
    }
    
    if (AltFireCountdown <= 0 && bAltFire)
    {
        CalcWeaponFire();
        if (bCorrectAim)
            WeaponFireRotation = AdjustAim(bAltFire);
        if (Spread > 0)
            WeaponFireRotation = rotator(vector(WeaponFireRotation) + VRand()*FRand()*Spread);

        DualFireOffset *= -1;

        Instigator.MakeNoise(1.0);
        AltFireCountdown = AltFireInterval;
        AltFire(C);
        AimLockReleaseTime = Level.TimeSeconds + AltFireCountdown * FireIntervalAimLock;

        return True;
    }

    return False;
}


simulated function float ChargeBar()
{
	return FClamp(0.999 - (AltFireCountDown / AltFireInterval), 0.0, 0.999);
	// Charge bar is just for AltFire
}



defaultproperties
{
     BeamEffectClass=Class'LinkVehiclesOmni.VampireTank3BeamEffect'
     MakeLinkSound=Sound'WeaponSounds.LinkGun.LinkActivated'
     LinkBreakDelay=0.500000
     //LinkScale(1)=0.500000
     //LinkScale(2)=0.900000
     //LinkScale(3)=1.200000
     //LinkScale(4)=1.400000
     //LinkScale(5)=1.500000
     MakeLinkForce="LinkActivated"
     Damage=17  //link gun shaft is 9, Scorp,Badger is 15,  Regular link tank, 17 Hvy LinkTank 19  This is its primary close in weapon.
     Momentum=-25000
     LinkFlexibility=0.5500000
     bInitAimError=True
     LinkVolume=240
     BeamSounds(0)=Sound'WeaponSounds.LinkGun.BLinkGunBeam1'
     BeamSounds(1)=Sound'WeaponSounds.LinkGun.BLinkGunBeam2'
     BeamSounds(2)=Sound'WeaponSounds.LinkGun.BLinkGunBeam3'
     BeamSounds(3)=Sound'WeaponSounds.LinkGun.BLinkGunBeam4'
     YawBone="Object02"
     PitchBone="Object02"
     PitchUpLimit=12000
     WeaponFireAttachmentBone="Muzzle"
     bInstantFire=True
     bDoOffsetTrace=True
     FireInterval=0.120000
     AltFireInterval=3.750000
     FireSoundVolume=255.000000
     DamageType=Class'DamTypeVampireTank3Beam'
     TraceRange=6000.000000  // 1100 is link gun's trace range, this same as heavy link tank beam
     ShakeRotMag=(Z=60.000000)
     ShakeRotRate=(Z=4000.000000)
     ShakeRotTime=6.000000
     ShakeOffsetMag=(Y=1.000000,Z=1.000000)
     ShakeOffsetRate=(X=1000.000000,Y=1000.000000,Z=1000.000000)
     ShakeOffsetTime=3.000000
     AIInfo(0)=(bLeadTarget=True,bFireOnRelease=True,WarnTargetPct=0.500000,RefireRate=0.650000)
     CullDistance=7500.000000
     Mesh=SkeletalMesh'AS_VehiclesFull_M.LinkBody'
     Skins(0)=Texture'LinkTank3Tex.VampireTank.LinkTurretBlack2'
     Skins(1)=Texture'LinkTank3Tex.VampireTank.LinkTurretBlack1'
     Skins(2)=Shader'UT2004Weapons.Shaders.PowerPulseShaderRed'
     DrawScale=0.200000
     SoundVolume=150
    
     LinkMultiplier = 0.0;  //Removed 12/2023 smaller since it heals itself
		 SelfHealMultiplier = 1.20  //this is healing DAMAGE, not purely health
		 VehicleDamageMult = 1.35  // set here instead DamType
		 VehicleHealScore=350
		 RangeExtPerLink=500 // how much range is extended per linker
		 LinkMultiplierCap = 2.5
  
     AltFireRadius=1500.000000
     AltFireDamage=275.000000 //  phoenix. 350 but has no vehicle multiplier
     AltFireDamageVehicleMult=2.000000 // ion blast already had 2.0 multipler... so it does 500 to vehicles.  Applies to nodes
     AltFireDamageEasterEggMult=6.500000
     AltFireMomentumVehicleMult=4.000000
     AltFireMomentumEasterEggMult=40.000000
     AltFireMomentum=20000.000000
     AltDamageType=Class'DamTypeVampireTankShockwave'
     bShowChargingBar=True
}
