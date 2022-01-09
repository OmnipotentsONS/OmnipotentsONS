//=============================================================================
// ONSLinkBadgerWeapon.
//=============================================================================
class ONSLinkBadgerWeapon extends ONSLinkTankWeapon;

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
//	Skins[0] = Combiner'AS_Weapons_TX.LinkTurret.LinkTurret_Skin2_C';
}

// ============================================================================
// Spawn projectile. Adjust link properties if needed.
// ============================================================================
function Projectile SpawnProjectile(class<Projectile> ProjClass, bool bAltFire)
{
	local Projectile SpawnedProjectile;
	local int NumLinks;

	if (LinkBadger(Owner) != None)
		NumLinks = LinkBadger(Owner).GetLinks();
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

	if (LinkBadger(Owner) != None)
		FoundBeam = LinkBadger(Owner).Beam;

	if (FoundBeam == None || FoundBeam.bDeleteMe)
	{
		foreach DynamicActors(class'LinkBeamEffect', ThisBeam)
			if (ThisBeam.Instigator == Instigator)
				FoundBeam = ThisBeam;
	}

	if (FoundBeam == None)
	{
		FoundBeam = Spawn(BeamEffectClass, Owner,,WeaponFireLocation);
		if (LinkBadger(Owner) != None)
			LinkBadger(Owner).Beam = FoundBeam;
	}

	//if (ONSLinkTankBeamEffect(Beam) != None)
	//	ONSLinkTankBeamEffect(Beam).WeaponOwner = self;

	bDoHit = true;
	UpTime = AltFireInterval + 0.1;
}

// ============================================================================
// Cease fire, destroy link beam
// ============================================================================
function WeaponCeaseFire(Controller C, bool bWasAltFire)
{
	local LinkBeamEffect Beam;

	if (LinkBadger(Owner) != None)
		Beam = LinkBadger(Owner).Beam;

//	log(self@"ceasefire"@bWasAltFire,'KDebug');
	if (bWasAltFire && Beam != None)
	{
		Beam.Destroy();
		Beam = None;
		if (LinkBadger(Owner) != None)
		{
			LinkBadger(Owner).Beam = None;
			LinkBadger(Owner).bBeaming = false;
		}
		//AmbientSound = None;
		Owner.AmbientSound = OldAmbientSound;
		OldAmbientSound = None;
		//Owner.SoundVolume = ONSVehicle(Owner).Default.SoundVolume;
		SetLinkTo(None);

		// Can't link if there's no beam
		if (LinkBadger(Owner) != None)
		{
			//log(Level.TimeSeconds@Self@"Set Link Tank bLinking to FALSE in WeaponCeaseFire",'KDebug');
			LinkBadger(Owner).bLinking = false;
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
	local LinkBadger LinkTank;
	//local float Step, ls;
	//local bot B;
	local bool bIsHealingObjective;
	local int AdjustedDamage, NumLinks;
	//local LinkBeamEffect LB;
	local DestroyableObjective HealObjective;
	local Vehicle LinkedVehicle;
	local LinkBeamEffect Beam;

	//log(self@"tick beam"@Beam@"uptime"@UpTime@"role"@Role,'KDebug');

	// I don't think ONSWeapon has a tick by default but it's always a good idea to call super when in doubt
	Super(ONSWeapon).Tick(dt);

	// We're not a LinkGun, so we don't need this
	//LinkGun = LinkGun(Weapon);
	// Instead let's get a reference to our LinkTank
	// This is easily changed over if I decide I want to recode the Link Badger based off this code
	//log(Level.TimeSeconds@self@"TICK -- Owner"@Owner@"LinkTank of Owner"@ONSLinkTank(Owner),'KDebug');
	if (LinkBadger(Owner) != None)
	{
		LinkTank = LinkBadger(Owner);
		NumLinks = LinkTank.GetLinks();
		Beam = LinkTank.Beam;
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
		TraceRange = default.TraceRange + NumLinks*250;

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
					if (ONSLinkTankBeamEffect(LB) != None && ONSLinkTankBeamEffect(LB).WeaponOwner == self)
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
			// More bot shit, ignore for linktank
			/*
            if ( Bot(Instigator.Controller) != None )
            {
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
			}
			else
			*/
	        //Aim = GetPlayerAim(StartTrace, AimError);
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
                    if ( Beam != None )
						Beam.bLockedOn = false;

                    Instigator.MakeNoise(1.0);

                    AdjustedDamage = AdjustLinkDamage( NumLinks, Other, AltDamage );

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
							HealObjective.HealDamage(AdjustedDamage, Instigator.Controller, DamageType);
							//if (!HealObjective.HealDamage(AdjustedDamage, Instigator.Controller, DamageType))
							//	LinkGun.ConsumeAmmo(ThisModeNum, -AmmoPerFire);
						}
						else
						{
							if (LockedPawn != None)
								warn(self@"called takedamage with a linked pawn!!!");
							else
								Other.TakeDamage(AdjustedDamage, Instigator, HitLocation, MomentumTransfer*X, AltDamageType);
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
			AdjustedDamage = AltDamage * (1.5*NumLinks+1) * Instigator.DamageScaling;
			if (Instigator.HasUDamage())
				AdjustedDamage *= 2;
			LinkedVehicle.HealDamage(AdjustedDamage, Instigator.Controller, DamageType);
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
// SetLinkTo
// Add our link to the other pawn
// ============================================================================
function SetLinkTo(Pawn Other, optional bool bHealing)
{
	// Sanity check
	if (LockedPawn != Other)
	{
	    if (LockedPawn != None && LinkBadger(Owner) != None)
	    {
			//log(self@"setlinkto"@other@"current"@LockedPawn,'KDebug');
	        RemoveLink(1 + LinkBadger(Owner).GetLinks(), Instigator);

	        // Added flag so the tank doesn't flash from green to teamcolor rapidly while linking a non-Wormbo node
	        if (!bHealing)
	        {
				//log(Level.TimeSeconds@Self@"Set Link Tank bLinking to FALSE in SetLinkTo"@Other,'KDebug');
	        	LinkBadger(Owner).bLinking = false;
	        }
	    }

	    LockedPawn = Other;

	    // Light up panels if linking a node
	    //if (LinkBadger2(Owner) != None)
	    //	LinkBadger2(Owner).bLinking = bIsHealingObjective;

	    if (LockedPawn != None)
	    {
			if (LinkBadger(Owner) != None)
			{
		        if (!AddLink(1 + LinkBadger(Owner).GetLinks(), Instigator))
		        {
		            bFeedbackDeath = true;
		        }
		        			//log(Level.TimeSeconds@Self@"Set Link Tank bLinking to TRUE in SetLinkTo"@Other,'KDebug');
		        LinkBadger(Owner).bLinking = true;
			}
	
	        LockedPawn.PlaySound(MakeLinkSound, SLOT_None);
	    }
	}   
}

defaultproperties
{
     LinkSkin_Gold(0)=Texture'MoreBadgers.LinkBadger.LinkBadgerRed'
     LinkSkin_Gold(1)=Texture'MoreBadgers.LinkBadger.LinkBadgerBlue'
     LinkSkin_Green(0)=Texture'MoreBadgers.LinkBadger.LinkBadgerRed'
     LinkSkin_Green(1)=Texture'MoreBadgers.LinkBadger.LinkBadgerBlue'
     LinkSkin_Red(0)=Texture'MoreBadgers.LinkBadger.LinkBadgerRed'
     LinkSkin_Blue(1)=Texture'MoreBadgers.LinkBadger.LinkBadgerBlue'
     LinkBeamSkin=0
     YawBone="BadgerTurret"
     PitchBone="TurretBarrel"
     PitchUpLimit=6000
     PitchDownLimit=61500
     WeaponFireAttachmentBone="TurretFire"
     RedSkin=Texture'MoreBadgers.LinkBadger.LinkBadgerRed'
     BlueSkin=Texture'MoreBadgers.LinkBadger.LinkBadgerBlue'
     ShakeRotMag=(X=0.000000,Z=250.000000)
     ShakeRotRate=(X=0.000000,Z=2500.000000)
     ShakeRotTime=0.000000
     ShakeOffsetMag=(Y=0.000000)
     ShakeOffsetRate=(Y=0.000000)
     ShakeOffsetTime=0.000000
     Mesh=SkeletalMesh'CSBadgerFix.BadgerTurret'
     DrawScale=1.000000
     bSelected=True
}
