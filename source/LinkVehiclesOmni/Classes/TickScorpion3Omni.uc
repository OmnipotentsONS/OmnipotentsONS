// Updated for Omni Link3 by pooty
// Tick link with healing and growing.  Its link beam heals friendlies, but drains enemies and heals its self.

class TickScorpion3Omni extends ONSRV;

var bool Linking;
var int Links, OldLinks;
struct HealerStruct
{
	var LinkGun LinkGun;
	var TickScorpion3Omni TickScorpion3Omni;
	var float LastHealTime; 
};

var array<HealerStruct> Healers; //the array of people currently healing.

var float LastTimeLinkLoop;
replication
{
    unreliable if (Role == ROLE_Authority)
        Linking, Links;
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


function bool HealDamage(int Amount, Controller Healer, class<DamageType> DamageType)
{
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
    return super.HealDamage(Amount, Healer, DamageType);
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
     MaxJumpSpin=100.000000
     DriverWeapons(0)=(WeaponClass=Class'LinkVehiclesOmni.TickScorpion3Gun')
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

     bScriptedRise=True
     VehiclePositionString="in a Tick Scorpion"
     VehicleNameString="Tick Scorpion 3.0"
     RanOverDamageType=Class'LinkVehiclesOmni.DamTypeLinkScorp3Roadkill'
     CrushedDamageType=Class'LinkVehiclesOmni.DamTypeLinkScorp3Pancake'
     Begin Object Class=KarmaParamsRBFull Name=KParams0
         KInertiaTensor(0)=1.000000
         KInertiaTensor(3)=3.000000
         KInertiaTensor(5)=3.000000
         KCOMOffset=(X=-0.250000,Z=-0.400000)
         KLinearDamping=0.050000
         KAngularDamping=0.050000
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
     KParams=KarmaParamsRBFull'LinkVehiclesOmni.TickScorpion3Omni.KParams0'


     Health=300
     HealthMax=800
}
