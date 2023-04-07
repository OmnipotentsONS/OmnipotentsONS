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

var String MakeLinkForce;

var() int Damage;
var() float MomentumTransfer;

var() float LinkFlexibility;
var float LinkMultiplier;
var float SelfHealMultiplier; 

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


replication
{
    reliable if (Role == ROLE_Authority)
		bIsFiring;
}

simulated function PostNetBeginPlay()
{
	if(TickScorpion3Omni(Owner) != None)
		MyTickScorpion = TickScorpion3Omni(Owner);
	Super.PostNetBeginPlay();
}

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

simulated function float AdjustLinkDamage( TickScorpion3Omni LS, Actor Other, float Damage )
{
	return Damage * (1*LS.Links+1)*MyTickScorpion.CurrDrawScale;
}

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
		local float ls;
		local bot B;
		local bool bShouldStop, bIsHealingObjective;
		local int AdjustedDamage;
		local TickScorpion3BeamEffect LB;
		local DestroyableObjective HealObjective;
		local Vehicle LinkedVehicle;
	
		Super.Tick(dt);
		
		// Scale the tick gun
		CurrDrawScale = MyTickScorpion.CurrDrawScale;
		// get it from basevehicle and set it so we can ref it from beameffect.
		SetDrawScale(CurrDrawScale);
		Damage = Min(default.Damage,Damage*MyTickScorpion.CurrDrawScale);
		//Scale Beam Size, LB but uses Default Size.  
		
		if ( !bIsFiring )
	    {
			bInitAimError = true;
	        return;
	    }
		if (MyTickScorpion.Links < 0)
		{
		     //log("warning:"@Instigator@"linkgun had"@MyTickScorpion.Links@"links");
			MyTickScorpion.Links = 0;
		}
		ls = LinkScale[Min(MyTickScorpion.Links,5)];
		if ( (UpTime > 0.0) || (Instigator.Role < ROLE_Authority) )
		{
			UpTime -= dt;
			StartTrace=WeaponFireLocation;
			TraceRange = default.TraceRange*CurrDrawScale + MyTickScorpion.Links*250;
			
	        if ( Instigator.Role < ROLE_Authority )
	        {
				if ( Beam == None )
					ForEach DynamicActors(class'TickScorpion3BeamEffect', LB )
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

	                    AdjustedDamage = AdjustLinkDamage( MyTickScorpion, Other, Damage );

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
								Other.TakeDamage(AdjustedDamage, Instigator, HitLocation, MomentumTransfer*X, DamageType);
								// heal itself
								 if (MyTickScorpion!=None&&MyTickScorpion.Health<MyTickScorpion.HealthMax&&(ONSPowerCore(HealObjective)==None||ONSPowerCore(HealObjective).PoweredBy(Team)&&!LockedPawn.IsInState('NeutralCore')))
                     MyTickScorpion.HealDamage(Round(AdjustedDamage * SelfHealMultiplier), Instigator.Controller, DamageType);
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
				AdjustedDamage = Damage * (LinkMultiplier*MyTickScorpion.Links+1) * Instigator.DamageScaling;
				if (Instigator.HasUDamage())
					AdjustedDamage *= 2;
				LinkedVehicle.HealDamage(AdjustedDamage, Instigator.Controller, DamageType);//if (! ))
					//LinkGun.ConsumeAmmo(ThisModeNum, -AmmoPerFire);
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

}

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
     LinkFlexibility=0.300000
     bInitAimError=True
     LinkVolume=240
     BeamSounds(0)=Sound'WeaponSounds.LinkGun.BLinkGunBeam1'
     BeamSounds(1)=Sound'WeaponSounds.LinkGun.BLinkGunBeam2'
     BeamSounds(2)=Sound'WeaponSounds.LinkGun.BLinkGunBeam3'
     BeamSounds(3)=Sound'WeaponSounds.LinkGun.BLinkGunBeam4'
     YawBone="rvGUNTurret"
     PitchBone="rvGUNbody"
     WeaponFireAttachmentBone="RVfirePoint"
     bInstantFire=True
     bDoOffsetTrace=True
     FireInterval=0.120000
     FireSoundVolume=255.000000
     DamageType=Class'XWeapons.DamTypeLinkShaft'
     TraceRange=3000.000000  // 1100 is link gun's trace range
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
    
     LinkMultiplier = 1.5;
		 SelfHealMultiplier = 1.1;
     
}
