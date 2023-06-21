// ============================================================================
// Link Tank weapon.
// ============================================================================
class LinkTank3HeavyGun extends ONSWeapon;

// ============================================================================
// Properties
// ============================================================================

// 0 = Red, 1 = Blue
var() array<Material> LinkSkin_Gold, LinkSkin_Green, LinkSkin_Red, LinkSkin_Blue;
var() int LinkBeamSkin;
var() sound LinkedFireSound;

// CPed from LinkFire
var(LinkBeam) class<LinkBeamEffect>	BeamEffectClass;
var(LinkBeam) Sound	MakeLinkSound;
var(LinkBeam) float LinkBreakDelay;
var(LinkBeam) float MomentumTransfer;
var(LinkBeam) class<DamageType> AltDamageType;
var(LinkBeam) int AltDamage;
var(LinkBeam) String MakeLinkForce;
var(LinkBeam) float LinkFlexibility;
var(LinkBeam) byte	LinkVolume;
var(LinkBeam) Sound BeamSounds[4];
var(LinkBeam) float VehicleDamageMult;

var float LinkMultiplier;  // linkers increase factor
var float VehicleHealScore; // how much occupied vehicle healing = 1pt player score
var float RangeExtPerLink; // how much range is extended per linker

// ============================================================================
// Internal vars
// ============================================================================
//var LinkBeamEffect			Beam;

// CPed from LinkFire
var float	UpTime;
var Pawn	LockedPawn;
var float	LinkBreakTime;

var bool bInitAimError;
var		bool bDoHit;
var		bool bFeedbackDeath;
var		bool bLinkFeedbackPlaying;
var		bool bStartFire;
var byte	SentLinkVolume;

var rotator DesiredAimError, CurrentAimError;

var Sound OldAmbientSound;

// ============================================================================
//replication
// ============================================================================
//{
//	reliable if (Role == ROLE_Authority)
//		Beam;
//}

simulated function UpdatePrecacheMaterials()
{
	Super.UpdatePrecacheMaterials();
	
	// this stuff should be covered by LinkGun anyway
//	Level.AddPrecacheMaterial(Texture'XEffectMat.Link.link_beam_green');  // hard-coded texture reference
//	Level.AddPrecacheMaterial(MapperSpecifiedMaterial);          // specified by mapper in UnrealEd
}

simulated function UpdatePrecacheStaticMeshes()
{
	Super.UpdatePrecacheStaticMeshes();
//	Level.AddPrecacheStaticMesh(StaticMesh'MyStaticMesh');
}


// ============================================================================
// ============================================================================
simulated function UpdateLinkColor( LinkAttachment.ELinkColor Color )
{
	switch ( Color )
	{
		case LC_Gold	:	Skins[LinkBeamSkin] = LinkSkin_Gold[Team];		break;
		case LC_Green	:	Skins[LinkBeamSkin] = LinkSkin_Green[Team];		break;
		case LC_Red		: 	Skins[LinkBeamSkin] = LinkSkin_Red[Team];		break;
		case LC_Blue	: 	Skins[LinkBeamSkin] = LinkSkin_Blue[Team];		break;
	}
	Skins[0] = Combiner'AS_Weapons_TX.LinkTurret.LinkTurret_Skin2_C';
}

// ============================================================================
// Spawn projectile. Adjust link properties if needed.
// ============================================================================
function Projectile SpawnProjectile(class<Projectile> ProjClass, bool bAltFire)
{
	local Projectile SpawnedProjectile;
	local int NumLinks;

	if (LinkTank3Heavy(Owner) != None)
		NumLinks = LinkTank3Heavy(Owner).GetLinks();
	else
		NumLinks = 0;

	// Swap out fire sound
	if (NumLinks > 0)
		FireSoundClass = LinkedFireSound;
	else
		FireSoundClass = default.FireSoundClass;

	SpawnedProjectile = Super.SpawnProjectile(ProjClass, bAltFire);
	if (PROJ_LinkTurret_Plasma(SpawnedProjectile) != None)
	{

		PROJ_LinkTurret_Plasma(SpawnedProjectile).Links = NumLinks;
		PROJ_LinkTurret_Plasma(SpawnedProjectile).LinkAdjust();
	}

	return SpawnedProjectile;
}

// ============================================================================
// Spawn/find link beam
// ============================================================================
function SpawnBeamEffect(Vector Start, Rotator Dir, Vector HitLocation, Vector HitNormal, int ReflectNum)
{
	local LinkBeamEffect ThisBeam;
	local LinkBeamEffect FoundBeam;

	if (LinkTank3Heavy(Owner) != None)
		FoundBeam = LinkTank3Heavy(Owner).Beam;

	if (FoundBeam == None || FoundBeam.bDeleteMe)
	{
		foreach DynamicActors(class'LinkBeamEffect', ThisBeam)
			if (ThisBeam.Instigator == Instigator)
				FoundBeam = ThisBeam;
	}

	if (FoundBeam == None)
	{
		FoundBeam = Spawn(BeamEffectClass, Owner,,WeaponFireLocation);
		if (LinkTank3Heavy(Owner) != None) LinkTank3Heavy(Owner).Beam = FoundBeam;
	}

	//if (LinkTank3HeavyBeamEffect(Beam) != None)
	//	LinkTank3HeavyBeamEffect(Beam).WeaponOwner = self;

	bDoHit = true;
	UpTime = AltFireInterval + 0.1;
}

simulated function ClientStartFire(Controller C, bool bAltFire)
{
//	log(self@"client start fire alt"@bAltFire,'KDebug');
	Super.ClientStartFire(C, bAltFire);

	// Write UpTime here in the client
	if (bAltFire && Role < ROLE_Authority)
	{
		UpTime = AltFireInterval + 0.1;
//		log("UpTime is now"@UpTime,'KDebug');
	}
}

// ============================================================================
// Cease fire, destroy link beam
// ============================================================================
function WeaponCeaseFire(Controller C, bool bWasAltFire)
{
	local LinkBeamEffect Beam;

	if (LinkTank3Heavy(Owner) != None)
		Beam = LinkTank3Heavy(Owner).Beam;

//	log(self@"ceasefire"@bWasAltFire,'KDebug');
	if (bWasAltFire && Beam != None)
	{
		Beam.Destroy();
		Beam = None;
		if (LinkTank3Heavy(Owner) != None)
		{
			LinkTank3Heavy(Owner).Beam = None;
			LinkTank3Heavy(Owner).bBeaming = false;
		}
		//AmbientSound = None;
		Owner.AmbientSound = OldAmbientSound;
		OldAmbientSound = None;
		//Owner.SoundVolume = ONSVehicle(Owner).Default.SoundVolume;
		SetLinkTo(None);

		// Can't link if there's no beam
		if (LinkTank3Heavy(Owner) != None)
		{
			//log(Level.TimeSeconds@Self@"Set Link Tank bLinking to FALSE in WeaponCeaseFire",'KDebug');
			LinkTank3Heavy(Owner).bLinking = false;
		}
	}
}

// ============================================================================
// ModeTick -- Maintain alt-firing link beam.
// Mostly c/p'd from LinkFire and modified accordingly to work with ONSWeapon
// ============================================================================
simulated event Tick(float dt)
{
	local Vector StartTrace, EndTrace, V, X, Y, Z;
	local Vector HitLocation, HitNormal, EndEffect;
	local Actor Other;
	local Rotator Aim;
	local LinkTank3Heavy LinkTank;
	//local float Step, ls;
	//local bot B;
	local bool bIsHealingObjective;
	local int AdjustedDamage, NumLinks;
	//local LinkBeamEffect LB;
	local DestroyableObjective HealObjective;
	local Vehicle LinkedVehicle;
	local LinkBeamEffect Beam;
	local float score;

	//log(self@"tick beam"@Beam@"uptime"@UpTime@"role"@Role,'KDebug');

	// I don't think ONSWeapon has a tick by default but it's always a good idea to call super when in doubt
	Super.Tick(dt);

	// We're not a LinkGun, so we don't need this
	//LinkGun = LinkGun(Weapon);
	// Instead let's get a reference to our LinkTank
	// This is easily changed over if I decide I want to recode the Link Badger based off this code
	//log(Level.TimeSeconds@self@"TICK -- Owner"@Owner@"LinkTank of Owner"@LinkTank3Heavy(Owner),'KDebug');
	if (LinkTank3Heavy(Owner) != None)
	{
		LinkTank = LinkTank3Heavy(Owner);
		NumLinks = LinkTank.GetLinks();
		Beam = LinkTank3Heavy(Owner).Beam;
		if (Beam != None )	 LinkTank3HeavyBeamEffect(Beam).SetBeamSize(NumLinks);
	}
	else
		NumLinks = 0;
	
	//if (Role < ROLE_Authority)
	//	log(Level.TimeSeconds@self@"TICK -- Role"@Role@"LinkBeam"@Beam,'KDebug');

	// If not firing, restore value of bInitAimError
	if (Beam == None && Role == ROLE_Authority)
	{
		bInitAimError = true;
		return;
	}

	if (LinkTank != None && LinkTank.GetLinks() < 0)
	{
        //log("warning:"@Instigator@"linktank had"@LinkTank.GetLinks()@"links");
        LinkTank.ResetLinks();
    }

    if ( (UpTime > 0.0) || (Role < ROLE_Authority) )
    {
//		log("warning: logspam ahead",'KDebug');

//		log("UpTime -= dt",'KDebug');
		UpTime -= dt;

		// FireStart begins at WeaponFireLocation
//		log("CalcWeaponFire",'KDebug');
		CalcWeaponFire();
//		log("GetAxes",'KDebug');
		GetAxes( WeaponFireRotation, X, Y, Z );
//		log("StartTrace = WeaponFireLocation",'KDebug');
		StartTrace = WeaponFireLocation;
//		log("TraceRange = default.TraceRange + NumLinks*250",'KDebug');
		TraceRange = default.TraceRange + NumLinks*RangeExtPerLink;

//		log("if role < role authority then do shit",'KDebug');
		// Get client LockedPawn
		if ( Role < ROLE_Authority )
        {
			//log(Level.TimeSeconds@self@"looking for a beam current beam"@beam,'KDebug');
			
			/*
			if ( Beam == None )
				ForEach DynamicActors(class'LinkBeamEffect', LB )
				{
					//log(self@"in tick check linkbeam"@LB@"instigator"@LB.Instigator@"vs our instigator"@Instigator@"and possibly our driver"@Vehicle(Owner).Driver@"also the link beams' bdelete is"@LB.bDeleteMe,'KDebug');
					//log("also our owner is"@owner@"and our owner's owner is"@owner.owner@"and our instigator is"@instigator@"and our instigator's owner is"@instigator.owner,'KDebug');
					//if ( !LB.bDeleteMe && (LB.Instigator != None) && (LB.Instigator == Instigator) )
					//log(self@"check beam"@lb@"owner"@lb.owner@"our owner"@owner@"instigator"@instigator,'KDebug');
					//if ( !LB.bDeleteMe && (LB.Instigator != None) && (LB.Owner == Owner) )
					if (LinkTank3HeavyBeamEffect(LB) != None && LinkTank3HeavyBeamEffect(LB).WeaponOwner == self)
					{
						log("and now it's ours",'KDebug');
						Beam = LB;
						break;
					}
				}
			*/

			if ( Beam != None )
				LockedPawn = Beam.LinkedPawn;
			//log("in tick found beam"@beam@"locked onto"@LockedPawn,'KDebug');
		}

		// If we're locked onto a pawn increase our trace distance
        if ( LockedPawn != None )
			TraceRange *= 1.5;

		// Skip this stuff -- in regular linkgun this will have bots link their leader, but in most cases the tank driver will be the leader
		/*
        if ( Role == ROLE_Authority )
		{
		    if ( bDoHit )
			    LinkGun.ConsumeAmmo(ThisModeNum, AmmoPerFire);

			B = Bot(Instigator.Controller);
			if ( (B != None) && (PlayerController(B.Squad.SquadLeader) != None) && (B.Squad.SquadLeader.Pawn != None) )
			{
				if ( IsLinkable(B.Squad.SquadLeader.Pawn)
					&& (B.Squad.SquadLeader.Pawn.Weapon != None && B.Squad.SquadLeader.Pawn.Weapon.GetFireMode(1).bIsFiring)
					&& (VSize(B.Squad.SquadLeader.Pawn.Location - StartTrace) < TraceRange) )
				{
					Other = Weapon.Trace(HitLocation, HitNormal, B.Squad.SquadLeader.Pawn.Location, StartTrace, true);
					if ( Other == B.Squad.SquadLeader.Pawn )
					{
						B.Focus = B.Squad.SquadLeader.Pawn;
						if ( B.Focus != LockedPawn )
							SetLinkTo(B.Squad.SquadLeader.Pawn);
						B.SetRotation(Rotator(B.Focus.Location - StartTrace));
 						X = Normal(B.Focus.Location - StartTrace);
 					}
 					else if ( B.Focus == B.Squad.SquadLeader.Pawn )
						bShouldStop = true;
				}
 				else if ( B.Focus == B.Squad.SquadLeader.Pawn )
					bShouldStop = true;
			}
		}
		*/
		
		if ( LockedPawn != None )
		{
			EndTrace = LockedPawn.Location + LockedPawn.BaseEyeHeight*Vect(0,0,0.5); // beam ends at approx gun height
			if ( Role == ROLE_Authority )
			{
				V = Normal(EndTrace - StartTrace);
				if ( (V dot X < LinkFlexibility) || LockedPawn.Health <= 0 || LockedPawn.bDeleteMe || (VSize(EndTrace - StartTrace) > 1.5 * TraceRange) )
				{
					SetLinkTo( None );
				}
			}
		}


        if ( LockedPawn == None )
        {

	        if (Role == ROLE_Authority)
	        	Aim = AdjustAim(true);
	        else
	        	Aim = WeaponFireRotation;

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

		if ( Role < ROLE_Authority )
		{
			//log("beam endloc set to"@Beam.EndEffect@"should be"@EndEffect,'KDebug');
			// LinkColor is handled on the tank
			/*
			if ( LinkGun.ThirdPersonActor != None )
			{
				if ( LinkGun.Linking || ((Other != None) && (Instigator.PlayerReplicationInfo.Team != None) && Other.TeamLink(Instigator.PlayerReplicationInfo.Team.TeamIndex)) )
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
                    if ( Beam != None )  Beam.bLockedOn = false;

                    Instigator.MakeNoise(1.0);

                   ;

                    if ( !Other.bWorldGeometry )
                    {
                        if ( Level.Game.bTeamGame && Pawn(Other) != None && Pawn(Other).PlayerReplicationInfo != None
							           && Pawn(Other).PlayerReplicationInfo.Team == Instigator.PlayerReplicationInfo.Team) // so even if friendly fire is on you can't hurt teammates
                            AdjustedDamage = 0;

						HealObjective = DestroyableObjective(Other);
						if ( HealObjective == None )
							HealObjective = DestroyableObjective(Other.Owner);
						if ( HealObjective != None && HealObjective.TeamLink(Instigator.GetTeamNum()) )
						{
							SetLinkTo(None,true);
							//log(Level.TimeSeconds@Self@"Set Link Tank bLinking to TRUE in Tick",'KDebug');
							LinkTank.bLinking = true;
							bIsHealingObjective = true;
							 AdjustedDamage = AdjustLinkDamage( NumLinks, None, AltDamage ); // no vehicle damage mutli on healing
							HealObjective.HealDamage(AdjustedDamage, Instigator.Controller, DamageType);
							//if (!HealObjective.HealDamage(AdjustedDamage, Instigator.Controller, DamageType))
							//	LinkGun.ConsumeAmmo(ThisModeNum, -AmmoPerFire);
						}
						else
						{
							if (LockedPawn != None)
								warn(self@"called takedamage with a linked pawn!!!");
							else {
								 AdjustedDamage = AdjustLinkDamage( NumLinks, Other, AltDamage );
								Other.TakeDamage(AdjustedDamage, Instigator, HitLocation, MomentumTransfer*X, AltDamageType);
								
							}	
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
			AdjustedDamage = AdjustLinkDamage( NumLinks, None, AltDamage ); // Target None = No vehicle damage multiplier
			AdjustedDamage *= Instigator.DamageScaling;  // Not sure what this was, but left it in.
			
		if(LinkedVehicle.HealDamage(AdjustedDamage, Instigator.Controller, DamageType))
	      {
	        score = 1;
	        if(LinkedVehicle.default.Health >= VehicleHealScore)
	            score = LinkedVehicle.default.Health / VehicleHealScore;
	        if (ONSPlayerReplicationInfo(Instigator.Controller.PlayerReplicationInfo) != None && !LinkedVehicle.IsVehicleEmpty())
	            ONSPlayerReplicationInfo(Instigator.Controller.PlayerReplicationInfo).AddHealBonus((AdjustedDamage/1.5) / LinkedVehicle.default.Health * score);
        }  		
			//if (!LinkedVehicle.HealDamage(AdjustedDamage, Instigator.Controller, DamageType))
			//	LinkGun.ConsumeAmmo(ThisModeNum, -AmmoPerFire);
		}
		if (LinkTank != None && bDoHit)
		{
			//log(Level.TimeSeconds@Self@"Set Link Tank bLinking to (LockedPawn != None) || bIsHealingObjective in Tick",'KDebug');
			LinkTank.bLinking = (LockedPawn != None) || bIsHealingObjective;
			//log("(This resolved to"@LinkTank.bLinking$")",'KDebug');
		}


		//if ( bShouldStop )
		//	B.StopFiring();
		//else
		//{

		// Beam is created in TraceFire, don't create it again here.

		// beam effect is created and destroyed when firing starts and stops
		//if ( (Beam == None) && bIsFiring )
		//{
		//	Beam = Weapon.Spawn( BeamEffectClass, Instigator );
		//	// vary link volume to make sure it gets replicated (in case owning player changed it client side)
		//	if ( SentLinkVolume == Default.LinkVolume )
		//		SentLinkVolume = Default.LinkVolume + 1;
		//	else
		//		SentLinkVolume = Default.LinkVolume;
		//}

		// Handle color changes
		if ( Beam != None )
		{
			if ( (LinkTank != None && LinkTank.bLinking) || ((Other != None) && (Instigator.PlayerReplicationInfo.Team != None) && Other.TeamLink(Instigator.PlayerReplicationInfo.Team.TeamIndex)) )
			{
				Beam.LinkColor = Instigator.PlayerReplicationInfo.Team.TeamIndex + 1;

				// Color change is handled on the tank itself
				//if ( LinkGun.ThirdPersonActor != None )
				//{
				//	if ( Instigator.PlayerReplicationInfo.Team == None || Instigator.PlayerReplicationInfo.Team.TeamIndex == 0 )
				//		LinkAttachment(LinkGun.ThirdPersonActor).SetLinkColor( LC_Red );
				//	else
				//		LinkAttachment(LinkGun.ThirdPersonActor).SetLinkColor( LC_Blue );
				//}
			}
			else
			{
				Beam.LinkColor = 0;

				// Color change is handled on the tank itself
				//if ( LinkGun.ThirdPersonActor != None )
				//{
				//	if ( LinkGun.Links > 0 )
				//		LinkAttachment(LinkGun.ThirdPersonActor).SetLinkColor( LC_Gold );
				//	else
				//		LinkAttachment(LinkGun.ThirdPersonActor).SetLinkColor( LC_Green );
				//}
			}

			Beam.Links = NumLinks;
			if (OldAmbientSound == None)
			{
				OldAmbientSound = Owner.AmbientSound;
				Owner.AmbientSound = BeamSounds[Min(Beam.Links,3)];
			}
			//AmbientSound = BeamSounds[Min(Beam.Links,3)];
			if (LinkTank != None)
				LinkTank.bBeaming = true;
			Soundvolume = FireSoundVolume;
			//Owner.SoundPitch = Owner.Default.SoundPitch;
			//Owner.SoundVolume = SentLinkVolume;
			Beam.LinkedPawn = LockedPawn;
			Beam.bHitSomething = (Other != None);
			Beam.EndEffect = EndEffect;
		}

		//}
	}
	
	bDoHit = false;
}

// ============================================================================
// AdjustLinkDamage
// Return adjusted damage based on number of links
// Takes a NumLinks argument instead of an actual LinkGun
// ============================================================================
function float AdjustLinkDamage( int NumLinks, Actor Target, float Damage )
{
	local float AdjDamage;
	
	AdjDamage = Damage * (LinkMultiplier*NumLinks+1);

	if (Target != None && Target.IsA('Vehicle') ) 	AdjDamage *= VehicleDamageMult;
  if (Instigator.HasUDamage()) 	AdjDamage *= 2;
	
	return AdjDamage;
	
}


// ============================================================================
// SetLinkTo
// Add our link to the other pawn
// ============================================================================
function SetLinkTo(Pawn Other, optional bool bHealing)
{
	// Sanity check
	if (LockedPawn != Other)
	{
	    if (LockedPawn != None && LinkTank3Heavy(Owner) != None)
	    {
			//log(self@"setlinkto"@other@"current"@LockedPawn,'KDebug');
	        RemoveLink(1 + LinkTank3Heavy(Owner).GetLinks(), Instigator);

	        // Added flag so the tank doesn't flash from green to teamcolor rapidly while linking a non-Wormbo node
	        if (!bHealing)
	        {
				//log(Level.TimeSeconds@Self@"Set Link Tank bLinking to FALSE in SetLinkTo"@Other,'KDebug');
	        	LinkTank3Heavy(Owner).bLinking = false;
	        }
	    }

	    LockedPawn = Other;

	    // Light up panels if linking a node
	    //if (LinkTank3Heavy(Owner) != None)
	    //	LinkTank3Heavy(Owner).bLinking = bIsHealingObjective;

	    if (LockedPawn != None)
	    {
			if (LinkTank3Heavy(Owner) != None)
			{
		        if (!AddLink(1 + LinkTank3Heavy(Owner).GetLinks(), Instigator))
		        {
		            bFeedbackDeath = true;
		        }
		        			//log(Level.TimeSeconds@Self@"Set Link Tank bLinking to TRUE in SetLinkTo"@Other,'KDebug');
		        LinkTank3Heavy(Owner).bLinking = true;
			}
	
	        LockedPawn.PlaySound(MakeLinkSound, SLOT_None);
	    }
	}   
}

// ============================================================================
// AddLink
// Add our links to the target's LinkGun
// No need to notify other LinkTanks -- they will pick up the link automatically in HealDamage
// (This will also work for other Link Vehicles utilizing the same code)
// c/p'd from LinkFire
// ============================================================================
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

// ============================================================================
// RemoveLink
// Remove our link from the target's LinkGun
// c/p'd from LinkFire
// ============================================================================
function RemoveLink(int Size, Pawn Starter)
{
    local Inventory Inv;
    if (LockedPawn != None && !bFeedbackDeath)
    {
        if (LockedPawn != Starter)
        {
            Inv = LockedPawn.FindInventoryType(class'LinkGun');
            if (Inv != None)
            {
				//log(self@"removing link from"@Inv);
                LinkFire(LinkGun(Inv).GetFireMode(1)).RemoveLink(Size, Starter);
                LinkGun(Inv).Links -= Size;
            }
        }
    }
}

// ============================================================================
// IsLinkable
// More c/p action
// ============================================================================
function bool IsLinkable(Actor Other)
{
    local Pawn P;
    local LinkGun LG;
    local LinkFire LF;
    local int sanity;
    //local ONSVehicle OwnerVehicle;

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
            if ( LF.LockedPawn == Pawn(Owner) )
                return false;

            LG = LinkGun(LF.LockedPawn.Weapon);
            if ( LG == None )
                break;
            LF = LinkFire(LG.GetFireMode(1));
            sanity++;
        }

        return ( Level.Game.bTeamGame && P.GetTeamNum() == ONSVehicle(Owner).Team );
    }

    return false;
}


// ============================================================================
// TraceFire
// Spawn the beam and all but don't actually do any damage here
// ============================================================================
function TraceFire(Vector Start, Rotator Dir)
{
    local Vector X, End, HitLocation, HitNormal, RefNormal;
    local Actor Other;
    local ONSWeaponPawn WeaponPawn;
    local Vehicle VehicleInstigator;
    //local int Damage;
    local bool bDoReflect;
    local int ReflectNum;

    MaxRange();

    if ( bDoOffsetTrace )
    {
    	WeaponPawn = ONSWeaponPawn(Owner);
	    if ( WeaponPawn != None && WeaponPawn.VehicleBase != None )
    	{
    		if ( !WeaponPawn.VehicleBase.TraceThisActor(HitLocation, HitNormal, Start, Start + vector(Dir) * (WeaponPawn.VehicleBase.CollisionRadius * 1.5)))
				Start = HitLocation;
		}
		else
			if ( !Owner.TraceThisActor(HitLocation, HitNormal, Start, Start + vector(Dir) * (Owner.CollisionRadius * 1.5)))
				Start = HitLocation;
    }

    ReflectNum = 0;
    while ( true )
    {
        bDoReflect = false;
        X = Vector(Dir);
        End = Start + TraceRange * X;

        //skip past vehicle driver
        VehicleInstigator = Vehicle(Instigator);
        if ( ReflectNum == 0 && VehicleInstigator != None && VehicleInstigator.Driver != None )
        {
        	VehicleInstigator.Driver.bBlockZeroExtentTraces = false;
        	Other = Trace(HitLocation, HitNormal, End, Start, true);
        	VehicleInstigator.Driver.bBlockZeroExtentTraces = true;
        }
        else
        	Other = Trace(HitLocation, HitNormal, End, Start, True);

		/* Don't actually do any damage here, just spawn the beam
        if ( Other != None && (Other != Instigator || ReflectNum > 0) )
        {
            if (bReflective && Other.IsA('xPawn') && xPawn(Other).CheckReflect(HitLocation, RefNormal, DamageMin*0.25))
            {
                bDoReflect = True;
                HitNormal = vect(0,0,0);
            }
            else if (!Other.bWorldGeometry)
            {
                Damage = (DamageMin + Rand(DamageMax - DamageMin));
 				if ( Vehicle(Other) != None || Pawn(Other) == None )
 				{
 					HitCount++;
 					LastHitLocation = HitLocation;
					SpawnHitEffects(Other, HitLocation, HitNormal);
				}
               	Other.TakeDamage(Damage, Instigator, HitLocation, Momentum*X, DamageType);
				HitNormal = vect(0,0,0);
            }
            else
            {
                HitCount++;
                LastHitLocation = HitLocation;
                SpawnHitEffects(Other, HitLocation, HitNormal);
	    }
        }
        else
        {
            HitLocation = End;
            HitNormal = Vect(0,0,0);
            HitCount++;
            LastHitLocation = HitLocation;
        }
        */

        SpawnBeamEffect(Start, Dir, HitLocation, HitNormal, ReflectNum);

        if ( bDoReflect && ++ReflectNum < 4 )
        {
            //Log("reflecting off"@Other@Start@HitLocation);
            Start	= HitLocation;
            Dir		= Rotator(RefNormal); //Rotator( X - 2.0*RefNormal*(X dot RefNormal) );
        }
        else
        {
            break;
        }
    }

    NetUpdateTime = Level.TimeSeconds - 1;
}

// ============================================================================
//
// ============================================================================
state ProjectileFireMode
{
	function Fire(Controller C)
	{
		//if (Beam != None)
		//	CeaseFire(C);

		Super.Fire(C);
	}

    function AltFire(Controller C)
    {
		//log(self@"alt-firing",'KDebug');
        FlashMuzzleFlash();

        if (AmbientEffectEmitter != None)
        {
            AmbientEffectEmitter.SetEmitterStatus(true);
        }

        // Play firing noise
        //if (bAmbientFireSound)
        //    AmbientSound = AltFireSoundClass;
        //else
        //   PlayOwnedSound(AltFireSoundClass, SLOT_None, FireSoundVolume/255.0,, FireSoundRadius, FireSoundPitch, False);

        TraceFire(WeaponFireLocation, WeaponFireRotation);
    }
}

// ============================================================================

defaultproperties
{
     LinkSkin_Gold(0)=Shader'UT2004Weapons.Shaders.PowerPulseShaderYellow'
     LinkSkin_Gold(1)=Shader'UT2004Weapons.Shaders.PowerPulseShaderYellow'
     LinkSkin_Green(0)=Shader'UT2004Weapons.Shaders.PowerPulseShader'
     LinkSkin_Green(1)=Shader'UT2004Weapons.Shaders.PowerPulseShader'
     LinkSkin_Red(0)=Shader'UT2004Weapons.Shaders.PowerPulseShaderRed'
     LinkSkin_Blue(1)=Shader'UT2004Weapons.Shaders.PowerPulseShaderBlue'
     LinkBeamSkin=2
     LinkedFireSound=Sound'WeaponSounds.LinkGun.BLinkedFire'
     BeamEffectClass=Class'LinkVehiclesOmni.LinkTank3HeavyBeamEffect'
     MakeLinkSound=Sound'WeaponSounds.LinkGun.LinkActivated'
     LinkBreakDelay=0.500000
     MomentumTransfer=2000.000000
     AltDamageType=Class'LinkVehiclesOmni.DamTypeLinkTank3HeavyBeam'
     AltDamage=21
     MakeLinkForce="LinkActivated"
     LinkFlexibility=0.550000
     LinkVolume=240
     BeamSounds(0)=Sound'WeaponSounds.LinkGun.BLinkGunBeam1'
     BeamSounds(1)=Sound'WeaponSounds.LinkGun.BLinkGunBeam2'
     BeamSounds(2)=Sound'WeaponSounds.LinkGun.BLinkGunBeam3'
     BeamSounds(3)=Sound'WeaponSounds.LinkGun.BLinkGunBeam4'
     VehicleDamageMult=1.500000
     LinkMultiplier = 1.50000
     bInitAimError=True
     YawBone="Object02"
     PitchBone="Object02"
     PitchUpLimit=9000
     WeaponFireAttachmentBone="Muzzle"
     RotationsPerSecond=0.500000
     FireInterval=0.350000
     AltFireInterval=0.120000
     FireSoundClass=SoundGroup'WeaponSounds.PulseRifle.PulseRifleFire'
     FireSoundVolume=256.000000
     FireForce="Explosion05"
     DamageMin=0
     DamageMax=0
     TraceRange=6000.000000
     ProjectileClass=Class'LinkVehiclesOmni.LinkTank3HeavyProjectile'
     ShakeRotMag=(X=40.000000)
     ShakeRotRate=(X=2000.000000)
     ShakeRotTime=2.000000
     ShakeOffsetMag=(Y=1.000000)
     ShakeOffsetRate=(Y=-2000.000000)
     ShakeOffsetTime=4.000000
     AIInfo(0)=(bLeadTarget=True,WarnTargetPct=0.990000,RefireRate=0.990000)
     AIInfo(1)=(bInstantHit=True,WarnTargetPct=0.990000,RefireRate=0.990000)
     Mesh=SkeletalMesh'AS_VehiclesFull_M.LinkBody'
     DrawScale=0.300000
     SoundPitch=112
     SoundRadius=512.000000
     TransientSoundRadius=1024.000000
     VehicleHealScore=200
     RangeExtPerLink=500 // how much range is extended per linker
}
