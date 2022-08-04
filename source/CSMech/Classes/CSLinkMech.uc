class CSLinkMech extends CSHoverMech
    placeable;

#exec AUDIO IMPORT FILE=Sounds\EngStop4.wav
#exec AUDIO IMPORT FILE=Sounds\EngStart4.wav
#exec AUDIO IMPORT FILE=Sounds\voltron.wav
#exec AUDIO IMPORT FILE=Sounds\counterattack.wav
#exec AUDIO IMPORT FILE=Sounds\FootStep4.wav
#exec AUDIO IMPORT FILE=Sounds\EngIdle.wav


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
// Internal vars
// ============================================================================

var array<LinkerStruct> Linkers;			// For keeping track of links
var int Links;
var bool bLinking;							// True if we're linking a vehicle/node/player
var bool bBotHealing;
var bool bBeaming;							// True if utilizing alt-fire

var LinkAttachment.ELinkColor OldLinkColor;

var LinkBeamEffect Beam;
var HudCTeamDeathMatch OurHud;

replication
{
    unreliable if (Role == ROLE_Authority && bNetDirty)
        Links, bLinking, Beam, bBeaming;
}

// ============================================================================
// ============================================================================
simulated function UpdateLinkColor( LinkAttachment.ELinkColor Color )
{
	local int i;

    /*
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
    */

	// Update weapon colors too
	for (i = 0; i < Weapons.Length; i++)
		if (CSLinkMechWeapon(Weapons[i]) != None)
			CSLinkMechWeapon(Weapons[i]).UpdateLinkColor(Color);
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

simulated event Tick(float DT)
{
    super.Tick(DT);

    if (bBotHealing)
		AltFire();

	if (Role == ROLE_Authority)
		ResetLinks();
	if (Links > 0)
		UpdateLinkColor(LC_Gold);
	else if (bLinking && Team == 0)
		UpdateLinkColor(LC_Red);
	else if (bLinking && Team == 1)
		UpdateLinkColor(LC_Blue);
	// Show regular green link panels
	else
		UpdateLinkColor(LC_Green);

}

function Fire(optional float F)
{
	if (!bBeaming)
		Super.Fire(F);
}

// ============================================================================
// C/P'd Ion Tank stuff
// ============================================================================
function AltFire(optional float F)
{
	super(ONSVehicle).AltFire( F );
}

function ClientVehicleCeaseFire(bool bWasAltFire)
{
	super(ONSVehicle).ClientVehicleCeaseFire( bWasAltFire );
}



defaultproperties
{    
    VehicleNameString="Linkatron 1.8"
    VehiclePositionString="in a Linkatron"
    Mesh=Mesh'CSMech.BotA'
    RedSkin=Texture'CSMech.LinkMechBodyRed';
    RedSkinHead=Texture'CSMech.LinkMechHeadRed';
    BlueSkin=Texture'CSMech.LinkMechBodyBlue';
    BlueSkinHead=Texture'CSMech.LinkMechHeadBlue';    
	Health=1600
	HealthMax=1600
	DriverWeapons(0)=(WeaponClass=class'CSLinkMechWeapon',WeaponBone=righthand)
    HornAnims(0)=gesture_halt
    HornAnims(1)=Gesture_Taunt01
    HornSounds(0)=sound'CSMech.voltron'
    HornSounds(1)=sound'CSMech.counterattack'
    IdleSound=sound'CSMech.EngIdle'    
    StartUpSound=sound'CSMech.EngStart4'
	ShutDownSound=sound'CSMech.EngStop4'   
    FootStepSound=sound'CSMech.FootStep4' 
    DodgeAnims(2)=DoubleJumpL
    DodgeAnims(3)=DoubleJumpR

    //////
    /* todo ?
     LinkSkin_Gold(0)=Combiner'ONSToys1Tex.LinkTankTex.LinkTankBodyRed-DoubleLink'
     LinkSkin_Gold(1)=Combiner'ONSToys1Tex.LinkTankTex.LinkTankBodyBlue-DoubleLink'
     LinkSkin_Green(0)=Combiner'ONSToys1Tex.LinkTankTex.LinkTankBodyRed-Idle'
     LinkSkin_Green(1)=Combiner'ONSToys1Tex.LinkTankTex.LinkTankBodyBlue-Idle'
     LinkSkin_Red(0)=Combiner'ONSToys1Tex.LinkTankTex.LinkTankBodyRed-Linking'
     LinkSkin_Blue(1)=Combiner'ONSToys1Tex.LinkTankTex.LinkTankBodyBlue-Linking'
     */

    //////
}
