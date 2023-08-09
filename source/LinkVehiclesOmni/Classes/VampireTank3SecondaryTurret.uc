// ============================================================================
// Link Tank weapon.
// ============================================================================
class VampireTank3SecondaryTurret extends ONSWeapon;

// ============================================================================
// Properties
// ============================================================================

// 0 = Red, 1 = Blue
var() array<Material> LinkSkin_Gold, LinkSkin_Green, LinkSkin_Red, LinkSkin_Blue;
var() int LinkBeamSkin;
var() sound LinkedFireSound;

// CPed from LinkFire
var(LinkBeam) class<VampireTank3TurretBeamEffect>	BeamEffectClass;
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

var float LinkMultiplier;  // linkers increase factor, not used in vampire, but will leave the code just in case want to add it back
var VampireTank3TurretBeamEffect Beam;
var float SelfHealMultiplier; 
var config int VehicleHealScore;
var VampireTank3 MyVampireTank;  // need reference to it to healit
var float RangeExtPerLink;

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
var bool bBeaming;							// True if utilizing alt-fire

// ============================================================================
replication
// ============================================================================
{
	reliable if (Role == ROLE_Authority)
		Beam;
	unreliable if (Role == ROLE_Authority && bNetDirty)
    bBeaming;
}

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

simulated function PostNetBeginPlay()
{
	//if(VampireTank3(Owner) != None)
	//	MyVampireTank = VampireTank3(ONSWeaponPawn(Owner).VehicleBase);
	
	
	Super.PostNetBeginPlay();
}
 



// ============================================================================
// Spawn projectile. Adjust link properties if needed.
// ============================================================================
function Projectile SpawnProjectile(class<Projectile> ProjClass, bool bAltFire)
{
	local Projectile SpawnedProjectile;
	local int NumLinks;

  //log("VampireTank3SecondaryTurret VT="$VampireTank3(ONSWeaponPawn(Owner).VehicleBase));

	if (VampireTank3(ONSWeaponPawn(Owner).VehicleBase) != None)
		NumLinks = VampireTank3(ONSWeaponPawn(Owner).VehicleBase).Links;
	else
		NumLinks = 0;

  //log("VampireTank3SecondaryTurret NumLinks="$NumLinks);
	// Swap out fire sound
	if (NumLinks > 0)
		FireSoundClass = LinkedFireSound;
	else
		FireSoundClass = default.FireSoundClass;

	SpawnedProjectile = Super.SpawnProjectile(ProjClass, bAltFire);
	if (SpawnedProjectile != None)
	{
		  		  // can we change color here? yes we can set RGB values  WHY DID THIS SUDDENLY stop working on server?!
		  		  /* subclassed the color server issues
		  PROJ_LinkTurret_Plasma(SpawnedProjectile).Plasma.Emitters[0].ColorScale[0].Color = class'Canvas'.static.MakeColor( 136, 14, 79);
   		PROJ_LinkTurret_Plasma(SpawnedProjectile).Plasma.Emitters[0].ColorScale[1].Color = class'Canvas'.static.MakeColor( 136, 14, 79);

    	PROJ_LinkTurret_Plasma(SpawnedProjectile).Plasma.Emitters[1].ColorScale[0].Color = class'Canvas'.static.MakeColor( 124, 10, 2);
    	PROJ_LinkTurret_Plasma(SpawnedProjectile).Plasma.Emitters[1].ColorScale[1].Color = class'Canvas'.static.MakeColor( 0, 77, 64);

    	PROJ_LinkTurret_Plasma(SpawnedProjectile).Plasma.Emitters[2].ColorScale[0].Color = class'Canvas'.static.MakeColor(74,20,140); //74,20,140
    	PROJ_LinkTurret_Plasma(SpawnedProjectile).Plasma.Emitters[2].ColorScale[1].Color = class'Canvas'.static.MakeColor( 74,20,140);
  		*/
  		
  		VampireTank3ProjectileSmall(SpawnedProjectile).Links = NumLinks;
  		VampireTank3ProjectileSmall(SpawnedProjectile).LinkAdjust();  //sets size based on links.
  		
	}

	return SpawnedProjectile;
}

// ============================================================================
// Spawn/find link beam
// ============================================================================
function SpawnBeamEffect(Vector Start, Rotator Dir, Vector HitLocation, Vector HitNormal, int ReflectNum)
{
	//local VampireTank3TurretBeamEffect ThisBeam;
	//local VampireTank3TurretBeamEffect FoundBeam;

	//if (VampireTank3(Owner) != None)
	//	FoundBeam = VampireTank3(Owner).Beam;

	//if (FoundBeam == None || FoundBeam.bDeleteMe)
	//{
	//	foreach DynamicActors(class'VampireTank3TurretBeamEffect', ThisBeam)
	//		if (ThisBeam.Instigator == Instigator)
	//			FoundBeam = ThisBeam;
	//}

	//if (FoundBeam == None)
	//{
	//	FoundBeam = Spawn(BeamEffectClass, Owner,,WeaponFireLocation);
	//	if (VampireTank3(Owner) != None) VampireTank3(Owner).Beam = FoundBeam;
	//}


	if (Beam == None)
	  {
	  	Beam = Spawn(BeamEffectClass, Owner,,WeaponFireLocation);
	  	//log("Spawned Beam="$Beam,'VampTankSpawnBeamEffect');
	  	//if (VampireTank3(Owner) != None) VampireTank3(Owner).Beam = FoundBeam;
	  }


	bDoHit = true;
	UpTime = AltFireInterval + 0.1;
}

simulated function ClientStartFire(Controller C, bool bAltFire)
{
	//log(self@"client start fire alt"@bAltFire,'KDebug');
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
	//local VampireTank3TurretBeamEffect Beam;

	//if (VampireTank3(Owner) != None)
	//	Beam = VampireTank3(Owner).Beam;
	//log(self@"WeaponCeaseFire, bWasAltFire"@bWasAltFire,'VampireTankDebug');
  Super.WeaponCeaseFire(C, bWasAltFire);
	
	if (bWasAltFire && Beam != None)
	{
		Beam.Destroy();
		Beam = None;
		if (VampireTank3(Owner) != None)
		{
			//VampireTank3(Owner).Beam = None;
			bBeaming = false;
		}
		AmbientSound = None;
		//Owner.AmbientSound = OldAmbientSound;
		OldAmbientSound = None;
		//Owner.SoundVolume = ONSVehicle(Owner).Default.SoundVolume;
		SetLinkTo(None);

		// Can't link if there's no beam
		if (VampireTank3(Owner) != None)
		{
			//log(Level.TimeSeconds@Self@"Set Link Tank bLinking to FALSE in WeaponCeaseFire",'KDebug');
			VampireTank3(Owner).bLinking = false;
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
	
	//local float Step, ls;
	//local bot B;
	local bool bIsHealingObjective;
	local int AdjustedDamage, NumLinks;
	//local LinkBeamEffect LB;
	local DestroyableObjective HealObjective;
	local Vehicle LinkedVehicle;
	
	//local VampireTank3TurretBeamEffect Beam;

	//log(self@"tick beam"@Beam@"uptime"@UpTime@"role"@Role,'KDebug');

	// I don't think ONSWeapon has a tick by default but it's always a good idea to call super when in doubt
	Super.Tick(dt);

	// We're not a LinkGun, so we don't need this
	//LinkGun = LinkGun(Weapon);
	// Instead let's get a reference to our LinkTank
	// This is easily changed over if I decide I want to recode the Link Badger based off this code
	//log(Level.TimeSeconds@self@"TICK -- Owner"@Owner@"LinkTank of Owner"@VampireTank3(Owner),'KDebug');

	if (Owner != None) MyVampireTank = VampireTank3(ONSWeaponPawn(Owner).VehicleBase);
	NumLinks = 0;
	
	//  link stacking	
	if (MyVampireTank != None) {
		  NumLinks = MyVampireTank.GetLinks();
  } 
	
	
	  
	//if (Role < ROLE_Authority)
	//	log(Level.TimeSeconds@self@"TICK -- Role"@Role@"LinkBeam"@Beam,'KDebug');

	// If not firing, restore value of bInitAimError
	if (Beam == None && Role == ROLE_Authority) 	{
		bInitAimError = true;
		return;
	}

	//if (MyVampireTank != None && MyVampireTank.GetLinks() < 0) 	{
        //log("warning:"@Instigator@"linktank had"@LinkTank.GetLinks()@"links");
  //      MyVampireTank.ResetLinks();
  // }

    if ( (UpTime > 0.0) || (Role < ROLE_Authority) )     {
//		log("warning: logspam ahead",'KDebug');
//		log("UpTime -= dt",'KDebug');
		UpTime -= dt;

		// FireStart begins at WeaponFireLocation
		//log("CalcWeaponFire",'KDebug');
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
					if (VampireTank3TurretBeamEffect(LB) != None && VampireTank3TurretBeamEffect(LB).WeaponOwner == self)
					{
						log("and now it's ours",'KDebug');
						Beam = LB;
						break;
					}
				}
			*/

			if ( Beam != None ) LockedPawn = Beam.LinkedPawn;
			//log("in tick found beam"@beam@"locked onto"@LockedPawn,'KDebug');
		}

		// If we're locked onto a pawn increase our trace distance
      if ( LockedPawn != None ) TraceRange *= 1.5;

	
		if ( LockedPawn != None )
		{
			EndTrace = LockedPawn.Location + LockedPawn.BaseEyeHeight*Vect(0,0,0.5); // beam ends at approx gun height
			if ( Role == ROLE_Authority )
			{
				V = Normal(EndTrace - StartTrace);
				if ( (V dot X < LinkFlexibility) || LockedPawn.Health <= 0 || LockedPawn.bDeleteMe || (VSize(EndTrace - StartTrace) > 1.5 * TraceRange) )
				{				SetLinkTo( None ); 				}
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

		    if ( Beam != None )	Beam.EndEffect = EndEffect;

				if ( Role < ROLE_Authority ) return;
		
        if ( Other != None && Other != Instigator )
        {
            // target can be linked to
            if ( IsLinkable(Other) )
            {
                if ( Other != lockedpawn )  SetLinkTo( Pawn(Other) );
                if ( lockedpawn != None )   LinkBreakTime = LinkBreakDelay;
            }
            else
            {    // stop linking
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
													MyVampireTank.bLinking = true;
													bIsHealingObjective = true;
									  			AdjustedDamage = AdjustLinkDamage( NumLinks, None, AltDamage ); // no vehicle damage mutli on healing, passing in None deactivates.
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
														 //log(self@"Just before HealDamage to MyVampireTank="@MyVampireTank); 
														 if (MyVampireTank!=None&&MyVampireTank.Health<MyVampireTank.HealthMax&&(ONSPowerCore(HealObjective)==None||ONSPowerCore(HealObjective).PoweredBy(Team)&&!LockedPawn.IsInState('NeutralCore')))
						                     MyVampireTank.HealDamage(Round(AdjustedDamage * SelfHealMultiplier), Instigator.Controller, DamageType);
													}	
												}

												if ( Beam != None )
													Beam.bLockedOn = true;
										}  // World geo
						}  // do hit
			}
		}

		// vehicle healing
		LinkedVehicle = Vehicle(LockedPawn);
		
		//log(self@" LinkedVehicle="@LinkedVehicle@" ONSWeaponPawn(Owner).VehicleBase="@ONSWeaponPawn(Owner).VehicleBase);
		// exclude self healing.
		if ( LinkedVehicle != None && bDoHit && (LinkedVehicle != ONSWeaponPawn(Owner).VehicleBase) )
		{
			AdjustedDamage = AdjustLinkDamage( NumLinks, None, AltDamage ) * Instigator.DamageScaling;
		
			 if(LinkedVehicle.HealDamage(AdjustedDamage, Instigator.Controller, DamageType))
	     			   if (ONSPlayerReplicationInfo(Instigator.Controller.PlayerReplicationInfo) != None && !LinkedVehicle.IsVehicleEmpty())
                  ONSPlayerReplicationInfo(Instigator.Controller.PlayerReplicationInfo).AddHealBonus(FMin((AdjustedDamage * LinkedVehicle.LinkHealMult) / VehicleHealScore, LInkedVehicle.HealthMax - LinkedVehicle.Health)); 
			//LinkedVehicle.HealDamage(AdjustedDamage, Instigator.Controller, DamageType);
			//if (!LinkedVehicle.HealDamage(AdjustedDamage, Instigator.Controller, DamageType))
			//	LinkGun.ConsumeAmmo(ThisModeNum, -AmmoPerFire);
		}
		if (MyVampireTank != None && bDoHit)
		{
			//log(Level.TimeSeconds@Self@"Set Link Tank bLinking to (LockedPawn != None) || bIsHealingObjective in Tick",'KDebug');
			MyVampireTank.bLinking = (LockedPawn != None) || bIsHealingObjective;
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
			if ( (MyVampireTank != None && MyVampireTank.bLinking) || ((Other != None) && (Instigator.PlayerReplicationInfo.Team != None) && Other.TeamLink(Instigator.PlayerReplicationInfo.Team.TeamIndex)) )
			  	Beam.LinkColor = Instigator.PlayerReplicationInfo.Team.TeamIndex + 1;
			else
					Beam.LinkColor = 0;
			
			Beam.Links = NumLinks;
			if (OldAmbientSound == None)
			{
				OldAmbientSound = Owner.AmbientSound;
				AmbientSound = BeamSounds[Min(Beam.Links,3)];
			}
			//AmbientSound = BeamSounds[Min(Beam.Links,3)];
			//if (LinkTank != None)
			bBeaming = true;
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
// ============================================



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
	    if (LockedPawn != None && MyVampireTank != None)
	    {
			//log(self@"setlinkto"@other@"current"@LockedPawn,'KDebug');
	        RemoveLink(1 + MyVampireTank.GetLinks(), Instigator);

	        if (!bHealing)
	        {
				//log(Level.TimeSeconds@Self@"Set Link Tank bLinking to FALSE in SetLinkTo"@Other,'KDebug');
	        	MyVampireTank.bLinking = false;
	        }
	    }

	    LockedPawn = Other;

	    // Light up panels if linking a node
	    //if (VampireTank3(Owner) != None)
	    //	VampireTank3(Owner).bLinking = bIsHealingObjective;

	    if (LockedPawn != None)
	    {
			if (VampireTank3(Owner) != None)
			{
		        if (!AddLink(1 + MyVampireTank.GetLinks(), Instigator))
		        {
		            bFeedbackDeath = true;
		        }
		        			//log(Level.TimeSeconds@Self@"Set Link Tank bLinking to TRUE in SetLinkTo"@Other,'KDebug');
		        MyVampireTank.bLinking = true;
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

	
    if ( Other.IsA('Pawn') && Other.bProjTarget )   {
        P = Pawn(Other);
        if ( P.Weapon == None || !P.Weapon.IsA('LinkGun') )
				{
	  			if ( Vehicle(P) != None ) return P.TeamLink( Instigator.GetTeamNum() );
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

        return ( Level.Game.bTeamGame && P.GetTeamNum() == Instigator.GetTeamNum() );
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
        	//log(self@"TraceFire:Skipping Driver...");
        	VehicleInstigator.Driver.bBlockZeroExtentTraces = false;
        	Other = Trace(HitLocation, HitNormal, End, Start, true);
        	VehicleInstigator.Driver.bBlockZeroExtentTraces = true;
        }
        else {
        	//log(self@"TraceFire:Not Driver...");
        	Other = Trace(HitLocation, HitNormal, End, Start, True);
        }
        
        
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
				bBeaming=true;
        TraceFire(WeaponFireLocation, WeaponFireRotation);
    }
}

// ============================================================================

defaultproperties
{
    // LinkSkin_Gold(0)=Shader'UT2004Weapons.Shaders.PowerPulseShaderYellow'
    // LinkSkin_Gold(1)=Shader'UT2004Weapons.Shaders.PowerPulseShaderYellow'
    // LinkSkin_Green(0)=Shader'UT2004Weapons.Shaders.PowerPulseShader'
   //  LinkSkin_Green(1)=Shader'UT2004Weapons.Shaders.PowerPulseShader'
     LinkSkin_Red(0)=Shader'UT2004Weapons.Shaders.PowerPulseShaderRed'
     LinkSkin_Blue(1)=Shader'UT2004Weapons.Shaders.PowerPulseShaderBlue'
     LinkBeamSkin=2
     LinkedFireSound=Sound'WeaponSounds.LinkGun.BLinkedFire'
     BeamEffectClass=Class'LinkVehiclesOmni.VampireTank3TurretBeamEffect'
     MakeLinkSound=Sound'WeaponSounds.LinkGun.LinkActivated'
     LinkBreakDelay=0.500000
     MomentumTransfer=2000.000000
     AltDamageType=Class'LinkVehiclesOmni.DamTypeVampireTank3Beam'
     AltDamage=15
     MakeLinkForce="LinkActivated"
     LinkFlexibility=0.550000
     LinkVolume=240
     BeamSounds(0)=Sound'WeaponSounds.LinkGun.BLinkGunBeam1'
     BeamSounds(1)=Sound'WeaponSounds.LinkGun.BLinkGunBeam2'
     BeamSounds(2)=Sound'WeaponSounds.LinkGun.BLinkGunBeam3'
     BeamSounds(3)=Sound'WeaponSounds.LinkGun.BLinkGunBeam4'
     VehicleDamageMult=1.500000
     LinkMultiplier = 0.80000
     bInitAimError=True
     YawBone="rvGUNTurret"
     PitchBone="rvGUNbody"
     PitchUpLimit=13000
     PitchDownLimit=59000
     WeaponFireAttachmentBone="RVfirePoint"
     RotationsPerSecond=0.500000
     FireInterval=0.350000
     AltFireInterval=0.120000
     FireSoundClass=SoundGroup'WeaponSounds.PulseRifle.PulseRifleFire'
     FireSoundVolume=256.000000
     FireForce="Explosion05"
     DamageMin=0
     DamageMax=0
     TraceRange=6600.000000
     ProjectileClass=Class'LinkVehiclesOmni.VampireTank3ProjectileSmall'
     ShakeRotMag=(X=40.000000)
     ShakeRotRate=(X=2000.000000)
     ShakeRotTime=2.000000
     ShakeOffsetMag=(Y=1.000000)
     ShakeOffsetRate=(Y=-2000.000000)
     ShakeOffsetTime=4.000000
     AIInfo(0)=(bLeadTarget=True,WarnTargetPct=0.990000,RefireRate=0.990000)
     AIInfo(1)=(bInstantHit=True,WarnTargetPct=0.990000,RefireRate=0.990000)
     Mesh=SkeletalMesh'ONSWeapons-A.RVnewGun'
     RedSkin=Texture'LinkScorpion3Tex.TickTex.TickScorpGun'
     BlueSkin=Texture'LinkScorpion3Tex.TickTex.TickScorpGun'
     DrawScale=1.200000
     SoundPitch=112
     SoundRadius=512.000000
     TransientSoundRadius=1024.000000
     SelfHealMultiplier = 1.1
     VehicleHealScore=250.0
     RangeExtPerLink=500
     
}
