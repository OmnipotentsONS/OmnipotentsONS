class CSLinkMechWeapon extends ONSWeapon;


var float MinAim;
var class<xEmitter>     MuzFlashClass;
var xEmitter            MuzFlash;
//var class<ShockBeamEffect> BeamEffectClass;

///////////

// CPed from LinkFire
// 0 = Red, 1 = Blue
var() array<Material> LinkSkin_Gold, LinkSkin_Green, LinkSkin_Red, LinkSkin_Blue;
var() int LinkBeamSkin;
var() sound LinkedFireSound;
var() float HealMult;

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



///////////


simulated function PostBeginPlay()
{
    local rotator r;
    super.PostBeginPlay();
    r = GetBoneRotation(YawBone);
    //r.Pitch -= 32768;
    r.Yaw += 32768;
    r.Roll -= 16384;

    SetBoneRotation(YawBone, r);
}

simulated event FlashMuzzleFlash()
{
    local rotator r;

    super.FlashMuzzleFlash();

    if ( Level.NetMode != NM_DedicatedServer && FlashCount > 0 )
	{
        if (MuzFlash == None)
        {
            MuzFlash = Spawn(MuzFlashClass);
            if ( MuzFlash != None )
				AttachToBone(MuzFlash, 'tip');
        }
        if (MuzFlash != None)
        {
            
            MuzFlash.Trigger(self, None);
            R.Roll = Rand(65536);
            SetBoneRotation('bone flashA', R, 0, 1.0);
        }
    }
}


simulated function GetViewAxes( out vector xaxis, out vector yaxis, out vector zaxis )
{
    if ( Instigator.Controller == None )
        GetAxes( Instigator.Rotation, xaxis, yaxis, zaxis );
    else
        GetAxes( Instigator.Controller.Rotation, xaxis, yaxis, zaxis );
}

state InstantFireMode
{
    function Fire(Controller C)
    {
        if(Vehicle(Owner) != None)
        {
            Vehicle(Owner).PlayFiring();
        }

		Super.Fire(C);
    }

    function AltFire(Controller C)
    {
        local CSLinkMechLinkProjectile P;
        if(Vehicle(Owner) != None)
        {
            Vehicle(Owner).PlayFiring();
        }

		//Super.AltFire(C);
        P = CSLinkMechLinkProjectile(SpawnProjectile(AltFireProjectileClass, true));
        P.Links = CSLinkMech(Owner).Links;
    }
}

/*
function SpawnBeamEffect(Vector Start, Rotator Dir, Vector HitLocation, Vector HitNormal, int ReflectNum)
{
    local ShockBeamEffect Beam;

    Beam = Spawn(BeamEffectClass,,, Start, Dir);
    Beam.Instigator = None; // prevents client side repositioning of beam start
    Beam.AimAt(HitLocation, HitNormal);
}
*/


//////////////////

simulated function UpdateLinkColor( LinkAttachment.ELinkColor Color )
{
    /*
	switch ( Color )
	{
		case LC_Gold	:	Skins[LinkBeamSkin] = LinkSkin_Gold[Team];		break;
		case LC_Green	:	Skins[LinkBeamSkin] = LinkSkin_Green[Team];		break;
		case LC_Red		: 	Skins[LinkBeamSkin] = LinkSkin_Red[Team];		break;
		case LC_Blue	: 	Skins[LinkBeamSkin] = LinkSkin_Blue[Team];		break;
	}
	Skins[0] = Combiner'AS_Weapons_TX.LinkTurret.LinkTurret_Skin2_C';
    */

    if ( MuzFlash != None )
	{
		switch ( Color )
		{
			case LC_Gold	: MuzFlash.Skins[0] = FinalBlend'XEffectMat.LinkMuzProjYellowFB';	break;
			case LC_Green	:
			default			: MuzFlash.Skins[0] = FinalBlend'XEffectMat.LinkMuzProjGreenFB';	break;
		}
	}
}

function Projectile SpawnProjectile(class<Projectile> ProjClass, bool bAltFire)
{    
    local Projectile P;
    local ONSWeaponPawn WeaponPawn;
    local vector StartLocation, HitLocation, HitNormal, Extent;
	local int NumLinks;

	if (CSLinkMech(Owner) != None)
		NumLinks = CSLinkMech(Owner).GetLinks();
	else
		NumLinks = 0;

	// Swap out fire sound
	if (NumLinks > 0)
		FireSoundClass = LinkedFireSound;
	else
		FireSoundClass = default.FireSoundClass;


    if (bDoOffsetTrace)
    {
       	Extent = ProjClass.default.CollisionRadius * vect(1,1,0);
        Extent.Z = ProjClass.default.CollisionHeight;
       	WeaponPawn = ONSWeaponPawn(Owner);
    	if (WeaponPawn != None && WeaponPawn.VehicleBase != None)
    	{
    		if (!WeaponPawn.VehicleBase.TraceThisActor(HitLocation, HitNormal, WeaponFireLocation, WeaponFireLocation + vector(WeaponFireRotation) * (WeaponPawn.VehicleBase.CollisionRadius * 1.5), Extent))
			StartLocation = HitLocation;
		else
			StartLocation = WeaponFireLocation + vector(WeaponFireRotation) * (ProjClass.default.CollisionRadius * 1.1);
	}
	else
	{
		if (!Owner.TraceThisActor(HitLocation, HitNormal, WeaponFireLocation, WeaponFireLocation + vector(WeaponFireRotation) * (Owner.CollisionRadius * 1.5), Extent))
			StartLocation = HitLocation;
		else
			StartLocation = WeaponFireLocation + vector(WeaponFireRotation) * (ProjClass.default.CollisionRadius * 1.1);
	}
    }
    else
    	StartLocation = WeaponFireLocation;

    P = spawn(ProjClass, self, , StartLocation, WeaponFireRotation);

    if (P != None)
    {
        if (bInheritVelocity)
            P.Velocity = Instigator.Velocity;

        FlashMuzzleFlash();

        // Play firing noise
        if (bAltFire)
        {
            if (bAmbientAltFireSound)
                AmbientSound = AltFireSoundClass;
            else
                PlayOwnedSound(AltFireSoundClass, SLOT_None, FireSoundVolume/255.0,, AltFireSoundRadius,FireSoundPitch, false);
        }
        else
        {
            if (bAmbientFireSound)
                AmbientSound = FireSoundClass;
            else
                PlayOwnedSound(FireSoundClass, SLOT_None, FireSoundVolume/255.0,, FireSoundRadius,FireSoundPitch, false);
        }
    }


	if (CSLinkMechLinkProjectile(P) != None)
	{

		CSLinkMechLinkProjectile(P).Links = NumLinks;
		CSLinkMechLinkProjectile(P).LinkAdjust();
	}

	return P;
}

function SpawnBeamEffect(Vector Start, Rotator Dir, Vector HitLocation, Vector HitNormal, int ReflectNum)
{
	local LinkBeamEffect ThisBeam;
	local LinkBeamEffect FoundBeam;

	if (CSLinkMech(Owner) != None)
		FoundBeam = CSLinkMech(Owner).Beam;

	if (FoundBeam == None || FoundBeam.bDeleteMe)
	{
		foreach DynamicActors(class'LinkBeamEffect', ThisBeam)
			if (ThisBeam.Instigator == Instigator)
				FoundBeam = ThisBeam;
	}

	if (FoundBeam == None)
	{
		//FoundBeam = Spawn(BeamEffectClass, Owner,,WeaponFireLocation);
		FoundBeam = Spawn(BeamEffectClass, Owner,,WeaponFireLocation, WeaponFireRotation);
		if (CSLinkMech(Owner) != None)
			CSLinkMech(Owner).Beam = FoundBeam;
	}

	//if (ONSLinkTankBeamEffect(Beam) != None)
	//	ONSLinkTankBeamEffect(Beam).WeaponOwner = self;

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

	if (CSLinkMech(Owner) != None)
		Beam = CSLinkMech(Owner).Beam;

//	log(self@"ceasefire"@bWasAltFire,'KDebug');
	if (bWasAltFire && Beam != None)
	{
		Beam.Destroy();
		Beam = None;
		if (CSLinkMech(Owner) != None)
		{
			CSLinkMech(Owner).Beam = None;
			CSLinkMech(Owner).bBeaming = false;
		}
		//AmbientSound = None;
		Owner.AmbientSound = OldAmbientSound;
		OldAmbientSound = None;
		//Owner.SoundVolume = ONSVehicle(Owner).Default.SoundVolume;
		SetLinkTo(None);

		// Can't link if there's no beam
		if (CSLinkMech(Owner) != None)
		{
			//log(Level.TimeSeconds@Self@"Set Link Tank bLinking to FALSE in WeaponCeaseFire",'KDebug');
			CSLinkMech(Owner).bLinking = false;
		}
	}
}

simulated event Tick(float dt)
{
	local Vector StartTrace, EndTrace, V, X, Y, Z;
	local Vector HitLocation, HitNormal, EndEffect;
	local Actor Other;
	local Rotator Aim;
	local CSLinkMech LinkTank;
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
	Super.Tick(dt);

	// We're not a LinkGun, so we don't need this
	//LinkGun = LinkGun(Weapon);
	// Instead let's get a reference to our LinkTank
	// This is easily changed over if I decide I want to recode the Link Badger based off this code
	//log(Level.TimeSeconds@self@"TICK -- Owner"@Owner@"LinkTank of Owner"@ONSLinkTank(Owner),'KDebug');
	if (CSLinkMech(Owner) != None)
	{
		LinkTank = CSLinkMech(Owner);
		NumLinks = LinkTank.GetLinks();
		Beam = CSLinkMech(Owner).Beam;
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
						//log("and now it's ours",'KDebug');
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
							HealObjective.HealDamage(HealMult * AdjustedDamage, Instigator.Controller, DamageType);
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
// AdjustLinkDamage
// Return adjusted damage based on number of links
// Takes a NumLinks argument instead of an actual LinkGun
// ============================================================================
simulated function float AdjustLinkDamage( int NumLinks, Actor Other, float Damage )
{
	Damage = Damage * (1.5*NumLinks+1);

	if ( Other.IsA('Vehicle') )
		Damage *= VehicleDamageMult;

	return Damage;
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
	    if (LockedPawn != None && CSLinkMech(Owner) != None)
	    {
			//log(self@"setlinkto"@other@"current"@LockedPawn,'KDebug');
	        RemoveLink(1 + CSLinkMech(Owner).GetLinks(), Instigator);

	        // Added flag so the tank doesn't flash from green to teamcolor rapidly while linking a non-Wormbo node
	        if (!bHealing)
	        {
				//log(Level.TimeSeconds@Self@"Set Link Tank bLinking to FALSE in SetLinkTo"@Other,'KDebug');
	        	CSLinkMech(Owner).bLinking = false;
	        }
	    }

	    LockedPawn = Other;

	    // Light up panels if linking a node
	    //if (ONSLinkTank(Owner) != None)
	    //	ONSLinkTank(Owner).bLinking = bIsHealingObjective;

	    if (LockedPawn != None)
	    {
			if (CSLinkMech(Owner) != None)
			{
		        if (!AddLink(1 + CSLinkMech(Owner).GetLinks(), Instigator))
		        {
		            bFeedbackDeath = true;
		        }
		        			//log(Level.TimeSeconds@Self@"Set Link Tank bLinking to TRUE in SetLinkTo"@Other,'KDebug');
		        CSLinkMech(Owner).bLinking = true;
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


state ProjectileFireMode
{
	function Fire(Controller C)
	{
         if(Vehicle(Owner) != None)
        {
            Vehicle(Owner).PlayFiring();
        }

		Super.Fire(C);
	}

    function AltFire(Controller C)
    {
        if (AmbientEffectEmitter != None)
        {
            AmbientEffectEmitter.SetEmitterStatus(true);
        }

        if(Vehicle(Owner) != None)
        {
            Vehicle(Owner).PlayFiring();
        }
        FlashMuzzleFlash();

        TraceFire(WeaponFireLocation, WeaponFireRotation);
    }
}


//////////////////
function bool FocusOnLeader(bool bLeaderFiring)
{
	local Bot B;
	local Pawn LeaderPawn;
	local Actor Other;
	local vector HitLocation, HitNormal, StartTrace;
	local Vehicle V;

	B = Bot(Instigator.Controller);
	if ( B == None )
		return false;
	if ( PlayerController(B.Squad.SquadLeader) != None )
		LeaderPawn = B.Squad.SquadLeader.Pawn;
	else
	{
		V = B.Squad.GetLinkVehicle(B);
		if ( V != None )
		{
			LeaderPawn = V;
			bLeaderFiring = (LeaderPawn.Health < LeaderPawn.HealthMax) && (V.LinkHealMult > 0)
							&& ((B.Enemy == None) || V.bKeyVehicle);
		}
	}
	if ( LeaderPawn == None )
	{
		LeaderPawn = B.Squad.SquadLeader.Pawn;
		if ( LeaderPawn == None )
			return false;
	}
	if ( !bLeaderFiring && (LeaderPawn.Weapon == None || !LeaderPawn.Weapon.IsFiring()) )
		return false;
	if ( (Vehicle(LeaderPawn) != None)
		|| ((LinkGun(LeaderPawn.Weapon) != None) && ((vector(B.Squad.SquadLeader.Rotation) dot Normal(Instigator.Location - LeaderPawn.Location)) < 0.9)) )
	{
		StartTrace = Instigator.Location + Instigator.EyePosition();
		if ( VSize(LeaderPawn.Location - StartTrace) < TraceRange )
		{
			Other = Trace(HitLocation, HitNormal, LeaderPawn.Location, StartTrace, true);
			if ( Other == LeaderPawn )
			{
				B.Focus = Other;
				return true;
			}
		}
	}
	return false;
}

function byte BestMode()
{
	local float EnemyDist;
	local bot B;
	local Vehicle V;

	B = Bot(Instigator.Controller);
	if ( B == None )
		return 0;

	if ( ( (DestroyableObjective(B.Squad.SquadObjective) != None && B.Squad.SquadObjective.TeamLink(B.GetTeamNum()))
		|| (B.Squad.SquadObjective == None && DestroyableObjective(B.Target) != None && B.Target.TeamLink(B.GetTeamNum())) )
	     && VSize(B.Squad.SquadObjective.Location - B.Pawn.Location) < TraceRange && (B.Enemy == None || !B.EnemyVisible()) )
		return 1;
	if ( FocusOnLeader(B.Focus == B.Squad.SquadLeader.Pawn) )
		return 1;

	V = B.Squad.GetLinkVehicle(B);
	if ( V == None )
		V = Vehicle(B.MoveTarget);
	if ( V == B.Target )
		return 1;
	if ( (V != None) && (VSize(Instigator.Location - V.Location) < TraceRange)
		&& (V.Health < V.HealthMax) && (V.LinkHealMult > 0) && B.LineOfSightTo(V) )
		return 1;
	if ( B.Enemy == None )
		return 0;
	EnemyDist = VSize(B.Enemy.Location - Instigator.Location);
	if ( EnemyDist > TraceRange )
		return 0;
	return 1;
}


defaultproperties
{
    Mesh=mesh'NewWeapons2004.NewLinkGun_3rd'
    YawBone="Bone Weapon"
    PitchBone="Bone Weapon"
    DrawScale=2.5
    MuzFlashClass=class'CSLinkMechMuzFlash'

    YawStartConstraint=0
    YawEndConstraint=65535
    PitchUpLimit=18000
    PitchDownLimit=49153

    DamageType=class'CSLinkMechDamTypeLinkShaft'
    AltDamageType=class'CSLinkMechDamTypeLinkShaft'

    //FireSoundClass=Sound'WeaponSounds.ShockRifle.ShockRifleFire'
    //FireSoundVolume=255
    FireSoundRadius=500
    //FireInterval=0.12
    FireInterval=0.18
    FireSoundPitch=0.8

    ProjectileClass=class'CSLinkMechLinkProjectile'
    //AltFireSoundClass=Sound'WeaponSounds.ShockRifle.ShockRifleAltFire'

    AltFireSoundRadius=1500
    //AltFireInterval=0.6

    RotateSound=sound'CSMech.turretturn'
    RotateSoundThreshold=50.0

    //WeaponFireAttachmentBone=Bone_Flash
    WeaponFireAttachmentBone="bone flashA"
    WeaponFireOffset=0.0
    bAimable=True
    bInstantRotation=true
    //bInstantFire=true
    //bDoOffsetTrace=true
    DualFireOffset=0
    //AIInfo(0)=(bLeadTarget=true,RefireRate=0.95)
    //AIInfo(1)=(bLeadTarget=true,AimError=400,RefireRate=0.50)
    MinAim=0.900

    ///////////////
     LinkSkin_Gold(0)=Shader'UT2004Weapons.Shaders.PowerPulseShaderYellow'
     LinkSkin_Gold(1)=Shader'UT2004Weapons.Shaders.PowerPulseShaderYellow'
     LinkSkin_Green(0)=Shader'UT2004Weapons.Shaders.PowerPulseShader'
     LinkSkin_Green(1)=Shader'UT2004Weapons.Shaders.PowerPulseShader'
     LinkSkin_Red(0)=Shader'UT2004Weapons.Shaders.PowerPulseShaderRed'
     LinkSkin_Blue(1)=Shader'UT2004Weapons.Shaders.PowerPulseShaderBlue'
     LinkBeamSkin=2
     LinkedFireSound=Sound'WeaponSounds.LinkGun.BLinkedFire'
     HealMult=1.500000
     BeamEffectClass=Class'CSlinkMechLinkBeamEffect'
     MakeLinkSound=Sound'WeaponSounds.LinkGun.LinkActivated'
     //AltDamage=15
     AltDamage=45
     LinkBreakDelay=0.500000
     MakeLinkForce="LinkActivated"
     LinkFlexibility=0.550000
     LinkVolume=240
     BeamSounds(0)=Sound'WeaponSounds.LinkGun.BLinkGunBeam1'
     BeamSounds(1)=Sound'WeaponSounds.LinkGun.BLinkGunBeam2'
     BeamSounds(2)=Sound'WeaponSounds.LinkGun.BLinkGunBeam3'
     BeamSounds(3)=Sound'WeaponSounds.LinkGun.BLinkGunBeam4'
     VehicleDamageMult=1.500000
     bInitAimError=True
     AltFireInterval=0.120000
     FireSoundClass=SoundGroup'WeaponSounds.PulseRifle.PulseRifleFire'
     FireSoundVolume=256.000000
     FireForce="Explosion05"
     DamageMin=0
     DamageMax=0
     //TraceRange=5000.000000
     TraceRange=4000.000000

     SoundPitch=112
     SoundRadius=512.000000
     TransientSoundRadius=1024.000000

     AIInfo(0)=(bLeadTarget=True,WarnTargetPct=0.990000,RefireRate=0.990000)
     AIInfo(1)=(bInstantHit=True,WarnTargetPct=0.990000,RefireRate=0.990000)

    //////////////
}