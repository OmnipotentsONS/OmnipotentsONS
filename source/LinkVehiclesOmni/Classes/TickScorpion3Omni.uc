// Updated for Omni Link3 by pooty
// Tick link with healing and growing.  Its link beam heals friendlies, but drains enemies and heals its self.

class TickScorpion3Omni extends ONSWheeledCraft;  // instead of ONSRV
// based on Hyena (which has two firing modes and drives nice)

#exec OBJ LOAD FILE=LinkScorpion3Tex.utx
#exec obj load file=TickScorpion3Mesh.ukx

var bool Linking;
var int Links, OldLinks;
struct HealerStruct
{
	var LinkGun LinkGun;
	var TickScorpion3Omni TickScorpion3Omni;
	var float LastHealTime; 
};

var array<HealerStruct> Healers; //the array of people currently healing.

var ONSWeapon Gun;
var TickScorpion3Gun TS3Gun;

var float LastTimeLinkLoop;
var float CurrDrawScale;
var int intCurrDrawScale;

var() array<Material> TickSkin_Red, TickSkin_Blue;
var int NewSkin, OldSkin;


replication
{
    unreliable if (Role == ROLE_Authority)
        Linking, Links, CurrDrawScale, intCurrDrawScale, NewSkin, OldSkin;
}

//link scorp needs to tell link gun when it's links change'

simulated function PostNetBeginPlay()
{
	
	SetBoneScale(4, 0.0, 'CarLShoulder');
	SetBoneScale(5, 0.0, 'CarRShoulder');

	Super.PostNetBeginPlay();
}


/*
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
	Super(ONSWheeledCraft).VehicleFire(bWasAltFire);
}

function VehicleCeaseFire(bool bWasAltFire)
{
	Super(ONSWheeledCraft).VehicleCeaseFire(bWasAltFire);
}
*/

/*
function bool SomeoneLinksToMe()
{
	local Pawn LP;
	local int sanity;
	LP = TickScorpion3Gun(Weapons[0]).LockedPawn;
	while ( LP != None && sanity < 32 )
	{
		if( TickScorpion3Omni(LP) != None )
		{
			//LS=TickScorpion3Omni(LP);
			LP=TickScorpion3Gun(TickScorpion3Omni(LP).Weapons[0]).LockedPawn;
		}
		else
		{
		//we found a player w/ a link gun some where.
//Inv = LP.FindInventoryType(class'LinkGun');
	//		if (Inv != None)
	//		{
	//			LP=LinkFire(LinkGun(Inv).GetFireMode(1)).LockedPawn;
	//		}
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
*/


/* //for v2
function bool ConsumeAmmo(int Mode, float load, optional bool bAmountNeededIsMax)
{
	local Controller C;

	if (Linking && LinkFire(FireMode[1]).LockedPawn != None && ONSRVLinkGun(Weapons[0]).LockedPawn == None)
		return true;


	//use ammo from linking teammates
	if (Instigator != None && Instigator.PlayerReplicationInfo != None && Instigator.PlayerReplicationInfo.Team != None)
	{
		for (C = Level.ControllerList; C != None; C = C.NextController)
			if (C.Pawn != None && LinkGun(C.Pawn.Weapon) != None && LinkGun(C.Pawn.Weapon).LinkedTo(self))
				LinkGun(C.Pawn.Weapon).LinkedConsumeAmmo(Mode, load, bAmountNeededIsMax);
	}

	return Super.ConsumeAmmo(Mode, load, bAmountNeededIsMax);
}
*/

/* Don't need this no link stacking
simulated function Timer()
{
	local int HealerLinks;
	local int i;
	Super.Timer();
	//log("TIMER IS BEING CALLED");
	if(Healers.Length == 0 && Links != 0)
		Links = 0;
	else if(LastTimeLinkLoop + 0.5f < Level.TimeSeconds)
	{
		for (i=0; i < Healers.Length; i++)
		{
			if(Healers[i].LastHealTime + 0.3f > Level.TimeSeconds)
			{			
				if( Healers[i].TickScorpion3Omni != None )
				{
					HealerLinks += Healers[i].TickScorpion3Omni.Links;
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
				TickScorpion3Gun(Weapons[0]).RemoveLink(OldLinks-Links,Weapons[0].Instigator);
			}
			else //we gained a link or two
			{
				TickScorpion3Gun(Weapons[0]).AddLink(Links-OldLinks,Weapons[0].Instigator);
			}
			OldLinks=Links;
			
		}
		//log("Links: "$Links);
	}
}
*/


function bool HealDamage(int Amount, Controller Healer, class<DamageType> DamageType)
{

  //Used for link Stacking	
  /*
	local int i;
	local bool bFoundInHealerArray;
	local LinkGun LG;


	if(TeamLink(Healer.GetTeamNum()))
	{
		if(TickScorpion3Omni(Healer.Pawn) != None)
		{
			for (i=0; i < Healers.Length; i++)
			{
				if(Healers[i].TickScorpion3Omni != None && Healers[i].TickScorpion3Omni == Healer.Pawn)
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
				else if(TickScorpion3Omni(Healer.Pawn) != None)
				{
					Healers[i].TickScorpion3Omni = TickScorpion3Omni(Healer.Pawn);
				}
		}
	}
	*/
	
	// Scale it based on healing
	   ScaleTickScorp(true, Amount);
	   return super.HealDamage(Amount, Healer, DamageType);
}


// No link stacking no need to do this
/*
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

*/

function ChooseFireAt(Actor A)
{
	if (Pawn(A) != None && Vehicle(A) == None && VSize(A.Location - Location) < 1500 && Controller.LineOfSightTo(A))
	{
		if (!bWeaponIsAltFiring)
			AltFire(0);
	}
	else if (bWeaponIsAltFiring)
		VehicleCeaseFire(true);

	Fire(0);
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
	L.AddPrecacheMaterial(Material'LinkScorpion3Tex.TickTex.Tick-Red-Light');
  L.AddPrecacheMaterial(Material'LinkScorpion3Tex.TickTex.Tick-Red');
  L.AddPrecacheMaterial(Material'LinkScorpion3Tex.TickTex.Tick-Red-Full');
  L.AddPrecacheMaterial(Material'LinkScorpion3Tex.TickTex.Tick-Blue-Light');
  L.AddPrecacheMaterial(Material'LinkScorpion3Tex.TickTex.Tick-Blue');
  L.AddPrecacheMaterial(Material'LinkScorpion3Tex.TickTex.Tick-Blue-Full');
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
	Level.AddPrecacheMaterial(Material'LinkScorpion3Tex.TickTex.Tick-Red-Light');
  Level.AddPrecacheMaterial(Material'LinkScorpion3Tex.TickTex.Tick-Red');
  Level.AddPrecacheMaterial(Material'LinkScorpion3Tex.TickTex.Tick-Red-Full');
  Level.AddPrecacheMaterial(Material'LinkScorpion3Tex.TickTex.Tick-Blue-Light');
  Level.AddPrecacheMaterial(Material'LinkScorpion3Tex.TickTex.Tick-Blue');
  Level.AddPrecacheMaterial(Material'LinkScorpion3Tex.TickTex.Tick-Blue-Full');
	Super.UpdatePrecacheMaterials();
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

	


function TakeDamage(int Damage, Pawn instigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> DamageType)
{
	  ScaleTickScorp(false, Damage);
	  //if (TickScorpGun.bActive)
	   Momentum *= 0; //sucking don't allow momentum... we are "stuck" might want to check locked pawn (link beam locked)
    Super.TakeDamage(Damage, instigatedBy, Hitlocation, Momentum, damageType);
}

simulated function ScaleTickScorp(bool bHeal, int Damage){
	
	CurrDrawScale = FMax(1,(Health/HealthMax)*2.33);
	NewSkin = Clamp(Round(Health/HealthMax*3.1)-1,0,2);
	//log(self$"Health="$Health$", HealthMax="$HealthMax$" NewSkin="$NewSkin);
	intCurrDrawScale = NewSkin + 1; // (1,2,3) for scaling other things based on int
	// Can't scale collision its constant based on mesh.
	// Mesh is also a constant so you can't change it.
	// So lets play with other attributes/skins
	  //Scale Gun though
	  Gun = Weapons[0];
	  Gun.SetDrawScale(FClamp(CurrDrawScale,1,1.5));
		TS3Gun = TickScorpion3Gun(Gun);
		
	//AmbientGlow=FMax(default.AmbientGlow*CurrDrawScale, 255);
	if (NewSkin != OldSkin) {  // only change skins when needed.
		//log(@self@"Changing Skins...")
		Spawn(class'TickScorp3GrowthEffect', Self,,);
		// put some kind off effect.
		// RepSkin tells server to replicate skin on clients.
		if (Team == 0 )  {
			 RepSkin = TickSkin_Red[NewSkin];
			 Skins[0] = TickSkin_Red[NewSkin];
			 OldSkin = NewSkin;
			 
		}	 
		else {
			 RepSkin = TickSkin_Blue[NewSkin];
		 	 Skins[0] = TickSkin_Blue[NewSkin];
	  	 OldSkin = NewSkin;	
	  }
	  
	  // Doesn't work either, it loads new mesh and size but again
	  /// doesn't update the collisoin box!  WTF.  No way to force the engine to 
	  // Update Collision box once the actor is spawned.
	  //If (Health > 451 ) 
	  //	LinkMesh(SkeletalMesh'TickScorpion3Mesh.RV1o5');
	 // 	LinkSkelAnim()?
	 // else LinkMesh(SkeletalMesh'ONSVehicles-A.RV');
//	  SetCollision();
	  
	  	// Adjust TP Camera NOT NEEDED
	//  TPCamDistance=default.TPCamDistance * CurrDrawScale;
	 //FPCamPos=(X=15.000000,Z=25.000000)
    //   TPCamWorldOffset.Z = default.TPCamWorldOffset.Z * CurrDrawScale;
	  
	}
	  VehicleMass = default.VehicleMass * (CurrDrawScale);
	  
	  // Play with these. Based on Scale.
	  KParams.KImpactThreshold= 80000*CurrDrawScale*2;
	  KParams.KFriction = 0.8;
	 
		 
		
   
  
  
    
		
		

  
	// Speed?
}


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
     AirPitchDamping=55.000000
     AirRollTorque=35.000000
     AirRollDamping=35.000000
     MaxJumpSpin=100.000000
     DriverWeapons(0)=(WeaponClass=Class'LinkVehiclesOmni.TickScorpion3Gun',WeaponBone="ChainGunAttachment")
     
//     RedSkin=Shader'LinkScorpion3Tex.LinkrvRedShad'
//     BlueSkin=Shader'LinkScorpion3Tex.LinkrvBlueShad'
     RedSkin=Texture'LinkScorpion3Tex.TickTex.Tick-Red-Light'
     BlueSkin=Texture'LinkScorpion3Tex.TickTex.Tick-Blue-Light'
     
     
    TickSkin_Red[0]=Texture'LinkScorpion3Tex.TickTex.Tick-Red-Light'
    TickSkin_Red[1]=Texture'LinkScorpion3Tex.TickTex.Tick-Red'
    TickSkin_Red[2]=Texture'LinkScorpion3Tex.TickTex.Tick-Red-Full'
    TickSkin_Blue[0]=Texture'LinkScorpion3Tex.TickTex.Tick-Blue-Light'
    TickSkin_Blue[1]=Texture'LinkScorpion3Tex.TickTex.Tick-Blue'
    TickSkin_Blue[2]=Texture'LinkScorpion3Tex.TickTex.Tick-Blue-Full'
     
     IdleSound=Sound'ONSVehicleSounds-S.RV.RVEng01'
     StartUpSound=Sound'ONSVehicleSounds-S.RV.RVStart01'
     ShutDownSound=Sound'ONSVehicleSounds-S.RV.RVStop01'
     StartUpForce="RVStartUp"
     DestroyedVehicleMesh=StaticMesh'ONSDeadVehicles-SM.RVDead'
     DestructionEffectClass=Class'Onslaught.ONSSmallVehicleExplosionEffect'
     DisintegrationEffectClass=Class'Onslaught.ONSVehDeathRV'
     DisintegrationHealth=-25.000000
     DestructionLinearMomentum=(Min=200000.000000,Max=300000.000000)
     DestructionAngularMomentum=(Min=100.000000,Max=150.000000)
     DamagedEffectOffset=(X=60.000000,Y=10.000000,Z=10.000000)
     bEjectPassengersWhenFlipped=False
     ImpactDamageMult=0.000100
     HeadlightCoronaOffset(0)=(X=86.000000,Y=30.000000,Z=7.000000)
     HeadlightCoronaOffset(1)=(X=86.000000,Y=-30.000000,Z=7.000000)
     HeadlightCoronaMaterial=Texture'Flakwolf_Tex.Hyena.HyenaFlare'
     HeadlightCoronaMaxSize=65.000000
     HeadlightProjectorMaterial=Texture'Flakwolf_Tex.Hyena.HyenaProjector'
     HeadlightProjectorOffset=(X=90.000000,Z=7.000000)
     HeadlightProjectorRotation=(Pitch=-1000)
     HeadlightProjectorScale=0.300000
    
     
     
     
     
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
     Wheels(0)=SVehicleWheel'LinkVehiclesOmni.TickScorpion3Omni.RRWheel'

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
     Wheels(1)=SVehicleWheel'LinkVehiclesOmni.TickScorpion3Omni.LRWheel'

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
     Wheels(2)=SVehicleWheel'LinkVehiclesOmni.TickScorpion3Omni.RFWheel'

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
     Wheels(3)=SVehicleWheel'LinkVehiclesOmni.TickScorpion3Omni.LFWheel'

		 VehicleMass = 3.3
     bScriptedRise=True
     VehiclePositionString="in a Tick Scorpion"
     VehicleNameString="Tick Scorpion 3.34"
     RanOverDamageType=Class'LinkVehiclesOmni.DamTypeLinkScorp3Roadkill'
     CrushedDamageType=Class'LinkVehiclesOmni.DamTypeLinkScorp3Pancake'
     Begin Object Class=KarmaParamsRBFull Name=KParams0
         /*KInertiaTensor(0)=1.000000
         KInertiaTensor(3)=3.000000
         KInertiaTensor(5)=3.000000
         KCOMOffset=(X=-0.250000,Z=-0.40000)
         KLinearDamping=0.050000
         KAngularDamping=0.500000*/
         KInertiaTensor(0)=1.000000
         KInertiaTensor(3)=3.000000
         KInertiaTensor(5)=3.000000
         KCOMOffset=(X=-0.250000,Z=-0.40000)
         KLinearDamping=0.050000
         KAngularDamping=0.450000
         bKStayUpright=True
         StayUprightStiffness=50
         StayUprightDamping=2
         KStartEnabled=True
         bKNonSphericalInertia=True
         bHighDetailOnly=False
         bClientOnly=False
         bKDoubleTickRate=True
         bDestroyOnWorldPenetrate=True
         bDoSafetime=True
         KFriction=0.700000
         KImpactThreshold=10000.000000
     End Object
     KParams=KarmaParamsRBFull'LinkVehiclesOmni.TickScorpion3Omni.KParams0'

     bDrawDriverInTP=True
     bDrawMeshInFP=True
     bHasHandbrake=True
     bSeparateTurretFocus=True
     bSpawnProtected=False
     DrivePos=(X=2.000000,Z=38.000000)
     ExitPositions(0)=(Y=-165.000000,Z=100.000000)
     ExitPositions(1)=(Y=165.000000,Z=100.000000)
     ExitPositions(2)=(Y=-165.000000,Z=-100.000000)
     ExitPositions(3)=(Y=165.000000,Z=-100.000000)
     EntryRadius=160.000000
     
     FPCamPos=(X=15.000000,Z=25.000000)
     TPCamDistance=375.000000
     TPCamLookat=(X=0.000000,Z=0.000000)
     TPCamWorldOffset=(Z=100.000000)
     CenterSpringForce="SpringONSSRV"
     
     MaxDesireability=0.400000
     ObjectiveGetOutDist=1500.000000
		 HornSounds(0)=Sound'ONSVehicleSounds-S.Horns.Dixie_Horn'
     HornSounds(1)=Sound'ONSVehicleSounds-S.Horns.La_Cucharacha_Horn'
     bReplicateAnimations=True
     bShowChargingBar=True
     Health=300
     HealthMax=900
     DriverDamageMult=0 // no driver damage
     CurrDrawScale = 1
     Mesh=SkeletalMesh'ONSVehicles-A.RV' // same as ONSRV
     //Mesh=SkeletalMesh'TickScorpion3Mesh.RV1o5'
     CollisionRadius=100.000000
     CollisionHeight=40.000000
     DamagedEffectHealthFireFactor = 0.125 //100
	   DamagedEffectHealthSmokeFactor = 0.25 //200
	   OldSkin = 0
	   NewSkin = 0
	   Links = 0
}
