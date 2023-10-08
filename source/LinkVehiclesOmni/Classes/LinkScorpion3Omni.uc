// Updated for Omni Link3 by pooty

//-----------------------------------------------------------
// (c) RBThinkTank 07
//  Coded by milk & Charybdis
//   LinkScorpon.uc - A linking version of the standard scorp.
//-----------------------------------------------------------
class LinkScorpion3Omni extends ONSRV;

var bool bLinking;
var int Links, OldLinks;
struct HealerStruct
{
	var LinkGun LinkGun;
	var LinkScorpion3Omni LinkScorpion3Omni;
	var float LastHealTime; 
};

var array<HealerStruct> Healers; //the array of people currently healing.


var float LastTimeLinkLoop;

// Linking vars from LinkTankCode, the base code here wasn't right, only counted linkers with linkgun
// Not other link vehicles (including other LinkScorps -- dumb)


// ============================================================================
// Structs
// ============================================================================
struct LinkerStruct {
	var Controller LinkingController;
	var int NumLinks;
	var float LastLinkTime;
};

// ============================================================================
// Consts
// ============================================================================
const LINK_DECAY_TIME = 0.250000;			// Time to remove a linker from the linker list
const AI_HEAL_SEARCH = 4096.000000;			// Radius for bots to search for damaged actors while driving


// ============================================================================
// Properties
// ============================================================================

// 0 = Red, 1 = Blue
var() array<Material> LinkSkin_Gold, LinkSkin_Green, LinkSkin_Red, LinkSkin_Blue;


// ============================================================================
// Vars
// ============================================================================

var array<LinkerStruct> Linkers;			// For keeping track of links
var bool bBotHealing;
//var bool bBeaming;							// True if utilizing alt-fire

var LinkAttachment.ELinkColor OldLinkColor;

var LinkBeamEffect Beam;


// boost
var () class<Emitter>	AfterburnerClass[2];
var Emitter				Afterburner[2];
var () Vector			AfterburnerOffset[2];
var () Rotator		AfterburnerRotOffset[2];
var bool				  bAfterburnersOn;

var bool  bBoost;         //Boost functionality
var float BoostForce;
var float BoostTime;
var int   BoostCount;
var Sound BoostSound, BoostReadySound;
var float BoostRechargeTime;
var float BoostRechargeCounter;
var float BoostFOV;

replication
{
    unreliable if (Role == ROLE_Authority)
        bLinking, Links, bBoost, BoostCount, BoostRechargeCounter;
}

//link scorp needs to tell link gun when it's links change'

simulated function PostNetBeginPlay()
{
	Super.PostNetBeginPlay();
	if(Role==Role_Authority)
	{
		SetTimer(0.2, true);
	}
}

function bool SomeoneLinksToMe()
{
	local Pawn LP;
	local int sanity;
	LP = LinkScorpion3Gun(Weapons[0]).LockedPawn;
	while ( LP != None && sanity < 32 )
	{
		if( LinkScorpion3Omni(LP) != None )
		{
			//LS=LinkScorpion3Omni(LP);
			LP=LinkScorpion3Gun(LinkScorpion3Omni(LP).Weapons[0]).LockedPawn;
		}
		else
		{
		//we found a player w/ a link gun some where.
			/*Inv = LP.FindInventoryType(class'LinkGun');
			if (Inv != None)
			{
				LP=LinkFire(LinkGun(Inv).GetFireMode(1)).LockedPawn;
			}*/
		if( LP.Weapon.IsA('LinkGun') )
			{
				LP=LinkFire(LinkGun(LP.Weapon).GetFireMode(1)).LockedPawn;
			}
		}
		if ( LP == self )
		{
			LastTimeLinkLoop=Level.TimeSeconds;
			return true;
			
		}
		if ( LP == None )
			break;
	sanity++;
	}
	return false;
}


simulated function Timer()
{
	local int HealerLinks;
	local int i;
	Super.Timer();
	//log("TIMER IS BEING CALLED");
	
	// when boost time exceeds time limit, turn it off and disable the primed detonator
  if (BoostCount == 0) {
		bBoost = false;
	  EnableAfterburners(bBoost);
	}  

	
	
	if(Healers.Length == 0 && Links != 0)
		Links = 0;
	else if(LastTimeLinkLoop + 0.5f < Level.TimeSeconds)
	{
		for (i=0; i < Healers.Length; i++)
		{
			if(Healers[i].LastHealTime + 0.3f > Level.TimeSeconds)
			{			
				if( Healers[i].LinkScorpion3Omni != None )
				{
					HealerLinks += Healers[i].LinkScorpion3Omni.Links;
					HealerLinks++;
				}
				if( Healers[i].LinkGun != None )
				{
					HealerLinks += Healers[i].LinkGun.Links;
					HealerLinks++;
				}
			}
		}
		if(HealerLinks != Links )
		{
			If(SomeoneLinksToMe())
			{
				Links=1;
			}
			else
				Links = HealerLinks;
		}
		if(Links != OldLinks )
		{
			//Level.Game.Broadcast(Instigator.Controller, Instigator.Controller.PlayerReplicationInfo.PlayerName$"'s scorpion now has "$links$" links. It used to have "$OldLinks$" links!");
			
			if(Links < OldLinks)//we lost a link or two
			{
				LinkScorpion3Gun(Weapons[0]).RemoveLink(OldLinks-Links,Weapons[0].Instigator);
			}
			else //we gained a link or two
			{
				LinkScorpion3Gun(Weapons[0]).AddLink(Links-OldLinks,Weapons[0].Instigator);
			}
			OldLinks=Links;
			
		}
		//log("Links: "$Links);
	}
}


// ============================================================================
// HealDamage
// When someone links the tank, record it and add it to the Linkers
// After a certain time period passes, remove that linker if they aren't linking anymore
// ============================================================================
function bool HealDamage(int Amount, Controller Healer, class<DamageType> DamageType)
{
	local int i;
	local bool bFound;
	
	if (Healer == None || Healer.bDeleteMe)
		return false;

	// If allied teammate, possibly add them to a link list
	if (TeamLink(Healer.GetTeamNum()) && Healer != Controller)  // Add Controller so selfhealing doesn't show link HUD)
	{
		for (i = 0; i < Linkers.Length; i++)
		{
			if (Linkers[i].LinkingController != None && Linkers[i].LinkingController == Healer)
			{
				bFound = true;
				Linkers[i].LastLinkTime = Level.TimeSeconds;
				// If other players are linking that pawn, record it
				if ( (Linkers[i].LinkingController.Pawn != None) && (Linkers[i].LinkingController.Pawn.Weapon != None) && (LinkGun(Linkers[i].LinkingController.Pawn.Weapon) != None) )
					Linkers[i].NumLinks = LinkGun(Linkers[i].LinkingController.Pawn.Weapon).Links;
				else
					Linkers[i].NumLinks = 0;
			}
		}
		if (!bFound)
		{
			Linkers.Insert(0,1);
			Linkers[0].LinkingController = Healer;
			Linkers[0].LastLinkTime = Level.TimeSeconds;
			// If other players are linking that pawn, record it
			if ( (Linkers[i].LinkingController.Pawn != None) && (Linkers[i].LinkingController.Pawn.Weapon != None) && (LinkGun(Linkers[i].LinkingController.Pawn.Weapon) != None) )
				Linkers[0].NumLinks = LinkGun(Linkers[0].LinkingController.Pawn.Weapon).Links;
			else
				Linkers[0].NumLinks = 0;
		}
	}

	return super.HealDamage(Amount, Healer, DamageType);
}

/* Original Heal Damage, used one above from LinkTank3
function bool HealDamage(int Amount, Controller Healer, class<DamageType> DamageType)
{
	local int i;
	local bool bFoundInHealerArray;
	local LinkGun LG;

	if(TeamLink(Healer.GetTeamNum()))
	{
		if(LinkScorpion3Omni(Healer.Pawn) != None)
		{
			for (i=0; i < Healers.Length; i++)
			{
				if(Healers[i].LinkScorpion3Omni != None && Healers[i].LinkScorpion3Omni == Healer.Pawn)
				{
					bFoundInHealerArray = true;
					Healers[i].LastHealTime=Level.TimeSeconds;
					break;
				}
			}
		}
		else if(Healer.Pawn.Weapon.IsA('LinkGun'))
		{

			LG = Linkgun(Healer.Pawn.Weapon);
			for (i=0; i < Healers.Length; i++)
			{
				if(Healers[i].LinkGun != None && Healers[i].LinkGun == LG)
				{
					bFoundInHealerArray = true;
					Healers[i].LastHealTime=Level.TimeSeconds;
					break;
				}
			}
		}
		if(!bFoundInHealerArray)
		{
				Healers.Insert(Healers.Length, 1);//This is gay.
				i=Healers.Length-1;
				Healers[i].LastHealTime=Level.TimeSeconds;
				if(LG != None)
				{
					Healers[i].LinkGun = LG;
				}
				else if(LinkScorpion3Omni(Healer.Pawn) != None)
				{
					Healers[i].LinkScorpion3Omni = LinkScorpion3Omni(Healer.Pawn);
				}
		}
	}
    return super.HealDamage(Amount, Healer, DamageType);
}
*/

simulated function DrawHUD(Canvas C)
{
	local PlayerController PC;
	local HudCTeamDeathMatch PlayerHud;

	//Hax. :P
    Super.DrawHUD(C);
	PC = PlayerController(Controller);
	if (Health < 1 || PC == None || PC.myHUD == None || PC.MyHUD.bShowScoreboard)
		return;
		
	PlayerHud=HudCTeamDeathMatch(PC.MyHud);
	
	if ( Links > 0 )
	{
		PlayerHud.totalLinks.value = Links;
		PlayerHud.DrawSpriteWidget (C, PlayerHud.LinkIcon);
		PlayerHud.DrawNumericWidget (C, PlayerHud.totalLinks, PlayerHud.DigitsBigPulse);
		PlayerHud.totalLinks.value = Links;
	}
}



function ChooseFireAt(Actor A)
{
	/*  No AltFire, just boost.
	if (Pawn(A) != None && Vehicle(A) == None && VSize(A.Location - Location) < 1500 && Controller.LineOfSightTo(A))
	{
		if (!bWeaponIsAltFiring)
			AltFire(0);
	}
	else if (bWeaponIsAltFiring)
		VehicleCeaseFire(true);
  */
  
	Fire(0);
}

function AltFire(optional float F)
{
	Super(ONSWheeledCraft).AltFire(F);
}

function ClientVehicleCeaseFire(bool bWasAltFire)
{
	Super(ONSWheeledCraft).ClientVehicleCeaseFire(bWasAltFire);
}


function VehicleFire(bool bWasAltFire)
{
	if (bWasAltFire)
	{
		Boost();
	}

  Super(Vehicle).VehicleFire(bWasAltFire);
}


function VehicleCeaseFire(bool bWasAltFire)
{
	Super(ONSWheeledCraft).VehicleCeaseFire(bWasAltFire);
}

function Boost()
{
		if (bBoost) 	{
		  PlaySound(BoostReadySound, SLOT_Misc, 128,,,160);
	}

  // If we have a boost ready and we're not currently using it
	if (BoostCount > 0 && !bBoost)
	{
    BoostRechargeCounter=0;
	  PlaySound(BoostSound, SLOT_Misc, 128,,,64); //Boost sound Pitch 160
		bBoost = true;
		BoostCount--;
	}
}



simulated function EnableAfterburners(bool bEnable)
{
	// Don't bother on dedicated server, this controls graphics only
	if (Level.NetMode != NM_DedicatedServer)
	{
		//Because we want the trail emitters to look right (proper team color and not strangely angled at startup) we need to create our emitters every time we boost
    if (bEnable)
    {
       // Create boosting emitters.
		   Afterburner[0] = spawn(AfterburnerClass[Team], self,, Location + (AfterburnerOffset[0] >> Rotation) );
		   Afterburner[0].SetBase(self);
		   Afterburner[0].SetRelativeRotation(AfterburnerRotOffset[0]);

		   Afterburner[1] = spawn(AfterburnerClass[Team], self,, Location + (AfterburnerOffset[1] >> Rotation) );
		   Afterburner[1].SetBase(self);
		   Afterburner[1].SetRelativeRotation(AfterburnerRotOffset[1]);
    }
    else
    {
       if (Afterburner[0] != none)
          Afterburner[0].Destroy();
       if (Afterburner[1] != none)
		      Afterburner[1].Destroy();
    }
	}

	bAfterburnersOn = bEnable; // update state of afterburners
}

simulated event KApplyForce(out vector Force, out vector Torque)
{
	Super.KApplyForce(Force, Torque); // apply other forces first

	if (bBoost && bVehicleOnGround)
	{
    Force += vector(Rotation); // get direction of vehicle
		Force += Normal(Force) * BoostForce; // apply force in that direction
	}
}


function Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
   if (Level.NetMode != NM_DedicatedServer)
	 {
	    if (Afterburner[0] != none)
         Afterburner[0].Destroy();
      if (Afterburner[1] != none)
	       Afterburner[1].Destroy();
   }

   //Handle vehicle ejection stuff
   //if (Driver != none && Driver.ShieldStrength >= 50)
   //   bEjectDriver=true;

   Super.Died(Killer, damageType, HitLocation);
}

simulated function Destroyed()
{
    if (Level.NetMode != NM_DedicatedServer)
	  {
		   if (Afterburner[0] != none)
          Afterburner[0].Destroy();
       if (Afterburner[1] != none)
		      Afterburner[1].Destroy();
    }

    Super.Destroyed();
}



simulated function tick(float dt)
{
	
  //If bAfterburnersOn and boost state don't agree
  if (bBoost != bAfterburnersOn)
  {
	   // it means we need to change the state of the vehicle (bAfterburnersOn)
	   // to match the desired state (bBoost)
     EnableAfterburners(bBoost); // show/hide afterburner smoke

	   // if we just enabled afterburners, set the timer
	   // to turn them off after set time has expired
	   if (bBoost)
	   {
	      SetTimer(BoostTime, false);
     }
	}

	if (Role == ROLE_Authority)
	{
			ResetLinks();
	   // Afterburners recharge after the change in time exceeds the specified charge duration
	   BoostRechargeCounter+=DT;
	   if (BoostRechargeCounter > BoostRechargeTime)
	   {
	      if (BoostCount < 1)
	      {
           BoostCount++;
           if( PlayerController(Controller) != None)
           {
			        PlayerController(Controller).ClientPlaySound(BoostReadySound,,,SLOT_Misc);
           }
           //PlaySound(BoostReadySound, SLOT_Misc,128);
        }
        BoostRechargeCounter = 0;
	   }
	}
	super.tick(Dt);
}


simulated function float ChargeBar()
{
    if (BoostCount != 1)
       return FClamp(BoostRechargeCounter/BoostRechargeTime, 0.0, 0.999);
    else
       return 0.999;
}

static function StaticPrecache(LevelInfo L)
{
    Super.StaticPrecache(L);
	// Precache  StaticMeshes 
	// Precache Textures
	L.AddPrecacheMaterial(Material'LinkScorpion3Tex.link_muz_purple');
	L.AddPrecacheMaterial(Material'LinkScorpion3Tex.link_beam_orange');
	L.AddPrecacheMaterial(Material'LinkScorpion3Tex.link_beam_purple');
	L.AddPrecacheMaterial(Material'LinkScorpion3Tex.link_spark_purple');
	L.AddPrecacheMaterial(Material'LinkScorpion3Tex.RVcolorBluelink');
	L.AddPrecacheMaterial(Material'LinkScorpion3Tex.RVcolorREDlink');
}

simulated function UpdatePrecacheStaticMeshes()
{

    Super.UpdatePrecacheStaticMeshes();
}

simulated function UpdatePrecacheMaterials()
{

	Level.AddPrecacheMaterial(Material'LinkScorpion3Tex.link_muz_purple');
	Level.AddPrecacheMaterial(Material'LinkScorpion3Tex.link_beam_orange');
	Level.AddPrecacheMaterial(Material'LinkScorpion3Tex.link_beam_purple');
	Level.AddPrecacheMaterial(Material'LinkScorpion3Tex.link_spark_purple');
	Level.AddPrecacheMaterial(Material'LinkScorpion3Tex.RVcolorBluelink');
	Level.AddPrecacheMaterial(Material'LinkScorpion3Tex.RVcolorREDlink');
	Super.UpdatePrecacheMaterials();
}


// ============================================================================
// GetLinks
// Returns number of linkers
// ============================================================================
function int GetLinks()
{
	return Links;
}

// ============================================================================
// ResetLinks
// Reset our linkers, called if Links < 0 or during tick
// ============================================================================
function ResetLinks()
{
	local int i;
	local int NewLinks;

	i = 0;
	NewLinks = 0;
	while (i < Linkers.Length)
	{
		// Remove linkers when their controllers are deleted
		// Or remove if LINK_DECAY_TIME seconds pass since they last linked the tank
		if (Linkers[i].LinkingController == None || Level.TimeSeconds - Linkers[i].LastLinkTime > LINK_DECAY_TIME)
			Linkers.Remove(i,1);
		else
		{
			NewLinks += 1 + Linkers[i].NumLinks;
			i++;
		}
	}

	if (Links != NewLinks)
		Links = NewLinks;
}





function ShouldTargetMissile(Projectile P)
{
	if ( (Health < 200) && (Bot(Controller) != None) 
		&& (Level.Game.GameDifficulty > 4 + 4*FRand())
		&& (VSize(P.Location - Location) < VSize(P.Velocity)) )
	{
		KDriverLeave(false);
		TeamUseTime = Level.TimeSeconds + 4;
	}
}




defaultproperties
{
	   WheelSoftness=0.025000
     WheelPenScale=1.200000
     WheelPenOffset=0.010000
     WheelRestitution=0.100000
     WheelInertia=0.100000
     WheelLongFrictionFunc=(Points=(,(InVal=100.000000,OutVal=1.000000),(InVal=200.000000,OutVal=0.900000),(InVal=10000000000.000000,OutVal=0.900000)))
     WheelLongSlip=0.001000
     WheelLatSlipFunc=(Points=(,(InVal=30.000000,OutVal=0.007000),(InVal=45.000000),(InVal=10000000000.000000)))
     WheelLongFrictionScale=1.250000
     WheelLatFrictionScale=1.550000
     WheelHandbrakeSlip=0.010000
     WheelHandbrakeFriction=0.100000
     WheelSuspensionTravel=15.000000
     WheelSuspensionMaxRenderTravel=15.000000
     FTScale=0.030000
     ChassisTorqueScale=0.400000
     MinBrakeFriction=4.750000
     MaxSteerAngleCurve=(Points=((OutVal=25.000000),(InVal=1500.000000,OutVal=11.000000),(InVal=1000000000.000000,OutVal=11.000000)))
     TorqueCurve=(Points=((OutVal=14.000000),(InVal=200.000000,OutVal=20.000000),(InVal=1500.000000,OutVal=28.000000),(InVal=2800.000000)))
     GearRatios(0)=-0.600000
     GearRatios(1)=0.610000
     GearRatios(2)=1.130000
     GearRatios(3)=1.630000
     GearRatios(4)=2.100000
     TransRatio=0.150000
     ChangeUpPoint=2000.000000
     ChangeDownPoint=1300.000000
     LSDFactor=1.000000
     EngineBrakeFactor=0.000100
     EngineBrakeRPMScale=0.100000
     MaxBrakeTorque=40.000000
     SteerSpeed=240.000000
     TurnDamping=35.000000
     StopThreshold=100.000000
     HandbrakeThresh=200.000000
     EngineInertia=0.100000
     IdleRPM=500.000000
     EngineRPMSoundRange=12000.000000
     SteerBoneName="SteeringWheel"
     SteerBoneAxis=AXIS_Z
     SteerBoneMaxAngle=90.000000
     RevMeterScale=4000.000000
     bMakeBrakeLights=True
     BrakeLightOffset(0)=(X=-100.000000,Y=23.000000,Z=7.000000)
     BrakeLightOffset(1)=(X=-100.000000,Y=-23.000000,Z=7.000000)
     BrakeLightMaterial=Texture'EpicParticles.Flares.FlashFlare1'
     DaredevilThreshInAirSpin=180.000000
     DaredevilThreshInAirTime=2.400000
     DaredevilThreshInAirDistance=33.000000
     bDoStuntInfo=True
     bAllowAirControl=True
     bAllowBigWheels=True
     AirTurnTorque=35.000000
     AirPitchTorque=55.000000
     AirPitchDamping=35.000000
     AirRollTorque=35.000000
     AirRollDamping=35.000000
     MaxJumpSpin=100.000000
     DriverWeapons(0)=(WeaponClass=Class'LinkVehiclesOmni.LinkScorpion3Gun')
     RedSkin=Shader'LinkScorpion3Tex.LinkrvRedShad'
     BlueSkin=Shader'LinkScorpion3Tex.LinkrvBlueShad'
     Begin Object Class=SVehicleWheel Name=RRWheel
         bPoweredWheel=True
         bHandbrakeWheel=True
         BoneName="tire02"
         BoneRollAxis=AXIS_Y
         BoneOffset=(Y=7.000000)
         WheelRadius=24.000000
         SupportBoneName="RrearStrut"
         SupportBoneAxis=AXIS_X
     End Object
     Wheels(0)=SVehicleWheel'LinkVehiclesOmni.LinkScorpion3Omni.RRWheel'

     Begin Object Class=SVehicleWheel Name=LRWheel
         bPoweredWheel=True
         bHandbrakeWheel=True
         BoneName="tire04"
         BoneRollAxis=AXIS_Y
         BoneOffset=(Y=-7.000000)
         WheelRadius=24.000000
         SupportBoneName="LrearStrut"
         SupportBoneAxis=AXIS_X
     End Object
     Wheels(1)=SVehicleWheel'LinkVehiclesOmni.LinkScorpion3Omni.LRWheel'

     Begin Object Class=SVehicleWheel Name=RFWheel
         bPoweredWheel=True
         SteerType=VST_Steered
         BoneName="tire"
         BoneRollAxis=AXIS_Y
         BoneOffset=(Y=7.000000)
         WheelRadius=24.000000
         SupportBoneName="RFrontStrut"
         SupportBoneAxis=AXIS_X
     End Object
     Wheels(2)=SVehicleWheel'LinkVehiclesOmni.LinkScorpion3Omni.RFWheel'

     Begin Object Class=SVehicleWheel Name=LFWheel
         bPoweredWheel=True
         SteerType=VST_Steered
         BoneName="tire03"
         BoneRollAxis=AXIS_Y
         BoneOffset=(Y=-7.000000)
         WheelRadius=24.000000
         SupportBoneName="LfrontStrut"
         SupportBoneAxis=AXIS_X
     End Object
     Wheels(3)=SVehicleWheel'LinkVehiclesOmni.LinkScorpion3Omni.LFWheel'

     bScriptedRise=True
     VehiclePositionString="in a Link Scorpion"
     VehicleNameString="Link Scorpion 3.4"
     RanOverDamageType=Class'LinkVehiclesOmni.DamTypeLinkScorp3Roadkill'
     CrushedDamageType=Class'LinkVehiclesOmni.DamTypeLinkScorp3Pancake'
     Begin Object Class=KarmaParamsRBFull Name=KParams0
         /*KInertiaTensor(0)=1.000000
         KInertiaTensor(3)=3.000000
         KInertiaTensor(5)=3.000000
         KCOMOffset=(X=-0.250000,Z=-0.40000)
         KLinearDamping=0.050000
         KAngularDamping=0.0500000*/
        KInertiaTensor(0)=1.000000
         KInertiaTensor(3)=3.000000
         KInertiaTensor(5)=3.500000
         KCOMOffset=(X=-0.00000,Y=0.00000,Z=-0.40000)
         KLinearDamping=0.050000
         KAngularDamping=0.050000
         bKStayUpright=True
         bKAllowRotate=False
         StayUprightStiffness=50
         StayUprightDamping=2
         KStartEnabled=True
         bKNonSphericalInertia=True
         bHighDetailOnly=False
         bClientOnly=False
         bKDoubleTickRate=True
         bDestroyOnWorldPenetrate=True
         bDoSafetime=True
         KFriction=0.500000
         KImpactThreshold=700.000000
     End Object
     KParams=KarmaParamsRBFull'LinkVehiclesOmni.LinkScorpion3Omni.KParams0'


     Health=400
     HealthMax=425
     
        
     // boost properties
     AfterburnerClass(0)=Class'LinkVehiclesOmni.LinkScorp3BoostTrailEmitterRed'
     AfterburnerClass(1)=Class'LinkVehiclesOmni.LinkScorp3BoostTrailEmitterBlue'
     AfterburnerOffset(0)=(X=-110.000000,Y=-21.000000,Z=-1.000000)
     AfterburnerOffset(1)=(X=-110.000000,Y=21.000000,Z=-1.000000)
     AfterburnerRotOffset(0)=(Yaw=32768)
     AfterburnerRotOffset(1)=(Yaw=32768)
     BoostForce=1600.000000
     BoostTime=2.000000
     BoostCount=1
     BoostSound=Sound'AssaultSounds.SkaarjShip.SkShipAccel01'
     BoostReadySound=Sound'AssaultSounds.HumanShip.HnShipFireReadyl01'
     BoostRechargeTime=8.000000
     bShowChargingBar=True
     DriverDamageMult=0 // no driver damage
}
