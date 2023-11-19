//=============================================================================
// LinkBadger2.
//=============================================================================
class LinkBadger extends MyBadger;

// Green -- Combiner'UT2004Weapons.Shaders.Combiner12'
// Blue -- Combiner'UT2004Weapons.Shaders.Combiner15'
// Red -- Combiner'UT2004Weapons.RedLink.Combiner12'
// Gold -- Combiner'UT2004Weapons.Shaders.Combiner17'

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

// ============================================================================
// Properties
// ============================================================================

// 0 = Red, 1 = Blue
var() array<Material> LinkSkin_Gold, LinkSkin_Green, LinkSkin_Red, LinkSkin_Blue;

// ============================================================================
// Internal vars
// ============================================================================

var array<LinkerStruct> Linkers;			// For keeping track of links
var int Links;
var bool bLinking;							// True if we're linking a vehicle/node/player
var bool bBotHealing;
var bool bBeaming;							// True if utilizing alt-fire

var LinkAttachment.ELinkColor OldLinkColor;

var LinkBeamEffect Beam;

replication
{
    unreliable if (Role == ROLE_Authority && bNetDirty)
        Links, bLinking, Beam, bBeaming;
}

simulated function PostNetBeginPlay()
{
    PassengerWeapons.Length = 0;
    super.PostNetBeginPlay();
}

// ============================================================================
// ============================================================================
simulated function UpdateLinkColor( LinkAttachment.ELinkColor Color )
{
	local int i;

	// Don't waste cycles continually switching out for the same skin
	if (Color != OldLinkColor)
	{
		switch ( Color )
		{
			case LC_Gold	:	Skins[0] = LinkSkin_Gold[Team];		break;
			case LC_Green	:	Skins[0] = LinkSkin_Green[Team];	break;
			case LC_Red		: 	Skins[0] = LinkSkin_Red[Team];		break;
			case LC_Blue	: 	Skins[0] = LinkSkin_Blue[Team];		break;
		}
		OldLinkColor = Color;
	}

	// Update weapon colors too
	for (i = 0; i < Weapons.Length; i++)
		if (ONSLinkTankWeapon(Weapons[i]) != None)
			ONSLinkTankWeapon(Weapons[i]).UpdateLinkColor(Color);
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
	if (TeamLink(Healer.GetTeamNum()))
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


// ============================================================================
// Tick
// Remove linkers from the linker list after they stop linking
// ============================================================================
simulated event Tick(float DT)
{
	Super.Tick(DT);

	if (bBotHealing)
		AltFire();

	if (Role == ROLE_Authority)
		ResetLinks();
	//else
	//	log(Level.TimeSeconds@Self@"Beam Effect:"@Beam,'KDebug');

	//log(self@"tick links"@links,'KDebug');

	//log(Level.TimeSeconds@Self@"TICK -- Linking"@bLinking,'KDebug');
	// When linked, always show gold link panels
	if (Links > 0)
		UpdateLinkColor(LC_Gold);
	// If linking a vehicle/player/node, show team-colored link panels
	else if (bLinking && Team == 0)
		UpdateLinkColor(LC_Red);
	else if (bLinking && Team == 1)
		UpdateLinkColor(LC_Blue);
	// Show regular green link panels
	else
		UpdateLinkColor(LC_Green);
}

// Don't allow primary fire if beaming
function Fire(optional float F)
{
	if (!bBeaming)
		Super.Fire(F);
}

static function StaticPrecache(LevelInfo L)
{
    Default.PassengerWeapons.Length = 0;
    super(ONSTreadCraft).StaticPrecache(L);

//	L.AddPrecacheMaterial(Material'ONSToys1Tex.LinkTankTex.LinkTankBodyBlue');
//	L.AddPrecacheMaterial(Material'ONSToys1Tex.LinkTankTex.LinkTankTread');
	L.AddPrecacheMaterial(Material'UT2004Weapons.NewWeaps.LinkPowerGreen');
	L.AddPrecacheMaterial(Material'UT2004Weapons.NewWeaps.LinkPowerRed');
	L.AddPrecacheMaterial(Material'UT2004Weapons.NewWeaps.LinkPowerBlue');
	L.AddPrecacheMaterial(Material'UT2004Weapons.NewWeaps.LinkPowerYellow');
//	L.AddPrecacheMaterial(Material'AS_Weapons_TX.LinkTurret.LinkTurret_skin1');
//	L.AddPrecacheMaterial(Material'AS_Weapons_TX.LinkTurret.LinkTurret_skin2');

	// FX
}

simulated function UpdatePrecacheStaticMeshes()
{
//	Level.AddPrecacheStaticMesh( StaticMesh'AW-2004Particles.Weapons.PlasmaSphere' );

	super.UpdatePrecacheStaticMeshes();
}

simulated function UpdatePrecacheMaterials()
{
//	Level.AddPrecacheMaterial(Material'ONSToys1Tex.LinkTankTex.LinkTankBodyBlue');
//	Level.AddPrecacheMaterial(Material'ONSToys1Tex.LinkTankTex.LinkTankTread');
	Level.AddPrecacheMaterial(Material'UT2004Weapons.NewWeaps.LinkPowerGreen');
	Level.AddPrecacheMaterial(Material'UT2004Weapons.NewWeaps.LinkPowerRed');
	Level.AddPrecacheMaterial(Material'UT2004Weapons.NewWeaps.LinkPowerBlue');
	Level.AddPrecacheMaterial(Material'UT2004Weapons.NewWeaps.LinkPowerYellow');
//	Level.AddPrecacheMaterial(Material'AS_Weapons_TX.LinkTurret.LinkTurret_skin1');
//	Level.AddPrecacheMaterial(Material'AS_Weapons_TX.LinkTurret.LinkTurret_skin2');

	// FX

	super(ONSTreadCraft).UpdatePrecacheMaterials();
}

function bool RecommendLongRangedAttack()
{
	return true;
}

defaultproperties
{
     LinkSkin_Gold(0)=Texture'MoreBadgers.LinkBadger.LinkBadgerRed'
     LinkSkin_Gold(1)=Texture'MoreBadgers.LinkBadger.LinkBadgerBlue'
     LinkSkin_Green(0)=Texture'MoreBadgers.LinkBadger.LinkBadgerRed'
     LinkSkin_Green(1)=Texture'MoreBadgers.LinkBadger.LinkBadgerBlue'
     LinkSkin_Red(0)=Texture'MoreBadgers.LinkBadger.LinkBadgerRed'
     LinkSkin_Blue(1)=Texture'MoreBadgers.LinkBadger.LinkBadgerBlue'
     DriverWeapons(0)=(WeaponClass=Class'CSBadgerFix.ONSLinkBadgerWeapon',WeaponBone="TurretSpawn")
    PassengerWeapons(0)=(WeaponPawnClass=Class'CSBadgerFix.BadgerMinigun',WeaponBone="MinigunSpawn")

     RedSkin=Texture'MoreBadgers.LinkBadger.LinkBadgerRed'
     BlueSkin=Texture'MoreBadgers.LinkBadger.LinkBadgerBlue'
     Begin Object Class=SVehicleWheel Name=SVehicleWheel32
         bPoweredWheel=True
         bHandbrakeWheel=True
         BoneName="RightRearTIRe"
         BoneRollAxis=AXIS_Y
         BoneOffset=(X=-20.000000)
         WheelRadius=26.000000
         SupportBoneName="RightRearSTRUT"
     End Object
     Wheels(0)=SVehicleWheel'CSBadgerFix.SVehicleWheel32'

     Begin Object Class=SVehicleWheel Name=SVehicleWheel33
         bPoweredWheel=True
         bHandbrakeWheel=True
         BoneName="LeftRearTIRE"
         BoneRollAxis=AXIS_Y
         BoneOffset=(X=-20.000000)
         WheelRadius=26.000000
         SupportBoneName="LeftRearSTRUT"
     End Object
     Wheels(1)=SVehicleWheel'CSBadgerFix.SVehicleWheel33'

     Begin Object Class=SVehicleWheel Name=SVehicleWheel34
         bPoweredWheel=True
         SteerType=VST_Steered
         BoneName="RightFrontTIRE"
         BoneRollAxis=AXIS_Y
         BoneOffset=(X=20.000000)
         WheelRadius=26.000000
         SupportBoneName="RightFrontSTRUT"
     End Object
     Wheels(2)=SVehicleWheel'CSBadgerFix.SVehicleWheel34'

     Begin Object Class=SVehicleWheel Name=SVehicleWheel35
         bPoweredWheel=True
         SteerType=VST_Steered
         BoneName="LeftFrontTIRE"
         BoneRollAxis=AXIS_Y
         BoneOffset=(X=20.000000)
         WheelRadius=26.000000
         SupportBoneName="LeftFrontSTRUT"
     End Object
     Wheels(3)=SVehicleWheel'CSBadgerFix.SVehicleWheel35'

     VehiclePositionString="in a Link Badger"
     VehicleNameString="Link Badger"
     HealthMax=700.000000
     Health=700
     Begin Object Class=KarmaParamsRBFull Name=KarmaParamsRBFull8
         KInertiaTensor(0)=1.000000
         KInertiaTensor(3)=3.000000
         KInertiaTensor(5)=3.500000
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
         KImpactThreshold=500.000000
         KCOMOffset=(X=0.0,Y=0.0,Z=-1.35)
     End Object
     KParams=KarmaParamsRBFull'CSBadgerFix.KarmaParamsRBFull8'

}
