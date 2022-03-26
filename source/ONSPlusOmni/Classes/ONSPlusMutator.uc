// ONSPlus: Coded by Shambler (Shambler__@Hotmail.com or Shambler@OldUnreal.com , ICQ:108730864)
// NOTE: I can't be held responsible for any damage to mental health caused by looking at this code
Class ONSPlusMutator extends Mutator;
	//config(ONSPlus);

//CONST ONSPlusVersion="v1.1beta24";
CONST MinONSPlusPluginVersion="v101";

// Failed to bring this over to mutator, not reliable : / (whitelist requirements)
/*var config bool bEnableTieBreaks;

var config enum ETieBreakType
{
	TIE_NodeCount,
	TIE_NoWin,
	TIE_Expose,
	TIE_RandomWin,
	TIE_InstaDeath,
} TieBreakType;

var config ETieBreakType SecondaryTieBreakType;

var config bool bNodeCountHealth;

var bool bInitialWait;*/

// General configurable variables, for disabling specific features
var config bool bDisablePlayerClass;
var config bool bDropChecks;
var config bool bSelectableExits;
var config bool bNodeHealScoreFix;
var config bool bVehicleHealScore;
var config bool bVehicleDamageScore;
var config bool bPallyShieldScore;

var config float HealValueScore; // After a player heals this much vehicle health he is rewarded one point
var config float DamageValueScore; // Same as above but relates to damage dealt instead
var config float PallyValueScore; // Again, as above except relates to damage absorbed by pally shield


var config bool bNodeIsolateBonus;
var config int IsolateBonusPctPerNode;

var config bool bAllowEnhancedRadar;
var config bool bRestrictMissileLock;

var config bool bDisablePreferredTeam;
var config bool bDisableVersionCheck;
var config bool bDisableONSPlusTurrets;
var config bool bDisablePreMatchTeamSwitch;

//var config bool bAllowFlyingLevi; // Just for a laugh every now and then ;)

var config bool bVehicleDistanceCheck; // Only for locked vehicles, starts the respawn timer on these vehicles if they are more than a certain distance away from the vehicle spawn
var config float RespawnTimerDistance; // The minimum distance at which a vehicle must be before the respawn timer is enabled
var config int DistanceCheckTimer; // The time it takes for unused vehicles to respawn after passing RespawnTimerDistance


// Word filter list for names/say command
struct EFilteredWord
{
	var string Word;		// The word to be replaced
	var string Replacement;		// The replacement for Word
	var int HitCount;		// A rating of how 'bad' this word is, every time a player says this word...his word counter is incremented by 'HitCount' until it reaches MaxWordHits
};

// If a player reaches MaxWordHits, this struct (used in the MaxHitAction variable) determines what happens to that player (quite self-explanatory here-on)
enum EMaxHitAction
{
	HA_Kick,
	HA_SessionBan,
	HA_PermyBan
};

var config array<EFilteredWord> BlacklistedWords;	// Dynamic array of blacklisted word information
var config int MaxWordHits;				// The maximum number of 'HitCounts' a player can use up before 'MaxHitAction' is performed on him
var config EMaxHitAction MaxHitAction;			// What to do when a player hits MaxWordHits
var config bool bEnableWordFilter;			// Enables or disables the entire word filter system
var config bool bClientSendFilter;			// Complicated. If true, each client scans all messages he sends to server...If false, all clients scan messages coming to THEM
							//	N.B. This is less-efficient when set to false BUT when it's false, the server chat logs will contain uncensored messages
var config bool bFilterAdmin;				// Wether or not to filter admins chat :)

/*
	Custom ONSPlus vehicle system (the system to allow plugin vehicles so as to make them compatable with ONSPlus)
	---

	+  What's needed?
	|	1: A way to dynamicly call functions related to missile lock on's and exit selection
	|	2: A version compatability check (which versions of ONSPlus is the vehicle plugin compatable with and is ONSPlus compatable with)
	|	3: A way to replace vehicles
	|	4: A way to initialise a vehicle and plugin for use with a player
	|	5: A system of verifying delegates
	|
	-> Soloutions
		1: Delegates will be used to reference these functions, multiple plugin handler's (on both client and server, the no. of them will be proportional to the number of
			seperate plugin packages) will use static functions to initialise these delegates, the delegates will be in the ONSPlusxPlayer, ONSPlusAvril and
			ONSPlusAttackCraftMissile classes.
		2: Use these values in ONSPlusMutator: MinONSPlusPluginVersion, ONSPlusversion (i.e. current) and these in the plugin handler: MinONSPlusVersion, CompiledONSPlusVersion
			if a plugin handler is out of date (i.e. ONSPlus is at a version below the plugins MinONSPlusVersion or the plugin is at a version below ONSPlus's
			MinONSPlusPluginVersion) then do not replace those vehicles. (N.B. Reperesent vehicle classes as strings)
		3: Call the function 'ReplaceVehicleClass' in the custom vehicle plugin (which will subclass from ONSPlusVehiclePlugin), the list of active plugins will be iterated and
			that function will get called on each plugin. (at the same time as the hard-coded vehicles are replaced)
		4: For the plugin: Use DLO to get a reference to its class and if it passes the version checks then add the class to the custom vehicle plugin array, (the plugins will
			work entirely on static functions) then get rid of plugins that use vehicles which are not currently present.
			For the vehicle, the plugin class list will be replicated to every client and the client will then use static functions from those plugins to handle delegates
		5: The plugin function header for handling delegates will use this function 'SetupVehicleDelegates' to setup the delegates. It will return true if it successfully
			setup the ONSPlusxPlayer delegates and it will set the ONSPlusxPlayers 'CurDelegateOwner' variable to the vehicle so that every delegate call can be verified.
			The same will happen for Avril's and Raptor rockets when appropriate, they will use the 'HomingTarget' variable to determine if the delegates are still valid.

	+  Problems
	|	1: How will the neccessary plugins be determined?
	|	2: How will the client be made aware of the neccessary plugins?
	|	3: Plugins will be dynamicly added to the package map, when to add them and how?
	|	4: How will the avril and raptor rockets handle lock ons etc.?
	|
	-> Soloutions
		1: The entire list of plugins will be loaded from the config array ('CustomVehiclePlugins') to the active array ('ActiveCVehiclePlugins') and then the levels
			NavigationPoint list will be used to check every vehicle factories class (through the 'CanReplaceClass' function in the plugins, the entire plugin list will be
			iterated), if a plugin is going to replace a vehicle class then add it to a temporary list....after all the vehicle factories have been iterated, delete the
			existing 'ActiveCVehiclePlugins' list and replace it with the temporary list.
		2: A function will be used to replicate individual classes to the client's controller, the 'ActiveCVehiclePlugins' list will be iterated and each class replicated
			individually. (TODO: Decide where to do this initialization, and SEE IF YOU CAN MOVE OTHER INITIALIZATIONS AWAY FROM MODIFYPLAYER)
		3: Add the plugins to the package map during PreBeginPlay, after the 'ActiveCVehiclePlugins' list is setup
		4: When the Avril/Raptor rockets lock on to something then setup delegates in their classes which point to the appropriate vehicles lock on/lost lock notifications and
			use the 'HomingTarget' variable to verify the delegates

*/
var config bool bEnableCustomVehiclePlugins;
var config array<string> CustomVehiclePlugins;

var config bool bRPGCompatible;

var array< class<ONSPlusVehiclePlugin> > ActiveCVehiclePlugins;


var ONSPlusScoreRules ScoreRules;


// Hack for TitanTeamFix
var mutator ExtraMut;


var ONSPlusConfig_Mut OPConfig;
var bool bPostInitTimer;


// Setup WebAdmin settings
static function FillPlayInfo(PlayInfo PlayInfo)
{
	Super.FillPlayInfo(PlayInfo);

	PlayInfo.AddSetting("ONSPlus", "bDropChecks", "Drop Checks", 0, 0, "Check");
	PlayInfo.AddSetting("ONSPlus", "bSelectableExits", "Selectable Exits", 0, 0, "Check");

	PlayInfo.AddSetting("ONSPlus", "bVehicleHealScore", "Give Vehicle Heal Bonus", 0, 1, "Check");
	PlayInfo.AddSetting("ONSPlus", "HealValueScore", "Heal Damage Per Point", 0, 2, "Text");

	PlayInfo.AddSetting("ONSPlus", "bVehicleDamageScore", "Give Vehicle Damage Bonus", 0, 3, "Check");
	PlayInfo.AddSetting("ONSPlus", "DamageValueScore", "Damage Per Point", 0, 4, "Text");

	PlayInfo.AddSetting("ONSPlus", "bNodeHealScoreFix", "Share Node Healing", 0, 0, "Check");
	PlayInfo.AddSetting("ONSPlus", "bNodeIsolateBonus", "Give Node Isolation Bonus", 0, 5, "Check");
	PlayInfo.AddSetting("ONSPlus", "IsolateBonusPctPerNode", "% Increase Per Node", 0, 6, "Text");

	PlayInfo.AddSetting("ONSPlus", "bAllowEnhancedRadar", "Enhanced Menu Radar", 0, 7, "Check");
	PlayInfo.AddSetting("ONSPlus", "bRestrictMissileLock", "Restrict Missile Locks", 0, 8, "Check");

	PlayInfo.AddSetting("ONSPlus", "bDisablePreferredTeam", "Disable Preferred Teams", 0, 9, "Check");
	PlayInfo.AddSetting("ONSPlus", "bDisableVersionCheck", "Disable UT2k4 version check", 0, 10, "Check");

	PlayInfo.AddSetting("ONSPlus", "bEnableCustomVehiclePlugins", "Custom Vehicle Plugins", 0, 11, "Check");

	PlayInfo.AddSetting("ONSPlus", "bDisablePreMatchTeamSwitch", "Disable PreMatch Team switching", 0, 12, "Check");

	PlayInfo.AddSetting("ONSPlus", "bVehicleDistanceCheck", "Vehicle Distance Checks", 0, 13, "Check");
	PlayInfo.AddSetting("ONSPlus", "RespawnTimerDistance", "Respawn Distance", 0, 14, "Check");
	PlayInfo.AddSetting("ONSPlus", "DistanceCheckTimer", "Distance Respawn Time", 0, 15, "Check");

	PlayInfo.AddSetting("ONSPlus", "bPallyShieldScore", "Give Pally Shield Bonus", 0, 16, "Check");
	PlayInfo.AddSetting("ONSPlus", "PallyValueScore", "Shield damage per point", 0, 17, "Check");

	PlayInfo.AddSetting("ONSPlus", "bRPGCompatible", "Make ONSPlus compatible with RPG", 0, 18, "Check");

	// Word filter
	//PlayInfo.AddSetting("WordFilter", "bEnableWordFilter", "Enable Word filteR", 0, 13, "Check");
	//PlayInfo.AddSetting("WordFilter", "BlacklistedWords", "Filtered Words", 0, 14, "Text");
}

static event string GetDescriptionText(string PropName)
{
	switch (PropName)
	{
		case "bDropChecks":			return "Enable/Disable exit height checks when leaving a vehicle";
		case "bSelectableExits":		return "Enable/Disable players being able to choose their vehicle exits";
		case "bNodeHealScoreFix":		return "Enable/Disable shared scoring between linked players when healing nodes";

		case "bVehicleHealScore":		return "Enable/Disable bonus points for healing a vehicle";
		case "HealValueScore":			return "One point is awarded every time a player heals this much health on a vehicle";

		case "bVehicleDamageScore":		return "Enable/Disable bonus points for damaging a vehicle";
		case "DamageValueScore":		return "One point is awarded every time a player damages a vehicle this much";

		case "bPallyShieldScore":		return "Enable/Disable bonus points for absorbing damage with the pally shield";
		case "PallyValueScore":			return "One point is awarded every time a Pally driver absorbs this much shield damage";


		case "bNodeIsolateBonus":		return "Enable/Disable bonus points for isolating nodes";
		case "IsolateBonusPctPerNode":		return "The percentage of bonus points awarded to a player for every isolated node";

		case "bAllowEnhancedRadar":		return "Enable/Disable improved menu radar which shows occupied vehicle spawns";
		case "bRestrictMissileLock":		return "Enable/Disable restriction of missile locks to occupied or used vehicles";

		case "bDisablePreferredTeam":		return "Enable/Disable assigned players to their preferred team";
		case "bDisableVersionCheck":		return "Enable/Disable incompatability message that gets shown to pre-3369 clients";

		case "bEnableCustomVehiclePlugins":	return "Enable/Disable custom vehicle plugins for ONSPlus";

		case "bRPGCompatible":			return "If true, makes ONSPlus compatible with RPG by disabling ONSPlus weapons";

		case "bDisablePreMatchTeamSwitch":	return "Enable/Disable the ability to change teams before the start of a match";

		case "bVehicleDistanceCheck":		return "Enable/Disable checks which respawn locked vehicles far from their spawn";
		case "RespawnTimerDistance":		return "The distance from spawn at which a locked vehicles respawn timer is set";
		case "DistanceCheckTimer":		return "The length of the distance checks respawn delay";

		// Word filter
		//case "bEnableWordFilter":	return "Enable/Disable the filtering of bad words in players names and text communication";
		//case "BlacklistedWords":	return "Words that are filtered and replaced with ****";
	}
}

// Replace various stuff
function PreBeginPlay()
{
	local actor A;

	local vector GunnerPos, FireImpulse, AltFireImpulse, DrivePos, EntryPosition,
		FPCamPos, FPCamViewOffset, TPCamLookat, TPCamWorldOffset,
		HUDOverlayOffset, MGPLocation;
	local rotator GunnerRot, DriveRot, MGPRotation;
	local class<Actor> DestroyEffectClass;
	local name CameraBone, DriveAnim;
	local color CrosshairColor;
	local float CrosshairX, CrosshairY, Steering, Throttle, Rise, EntryRadius,
		TPCamDistance, WaterDamage, HUDOverlayFOV;
	local Texture CrosshairTexture;
	local bool bDrawDriverInTP, bDriverCollideActors, bRelativeExitPos,
		bDrawMeshInFP, bZeroPCRotOnEntry, bHUDTrackVehicle, bHighScoreKill,
		bDesiredBehindView, bFPNoZFromCameraPitch;
	local byte Team;
	local array<Vector> ExitPositions;
	local Range TPCamDistRange;
	local int MaxViewYaw, MaxViewPitch;
	local array<sound> BulletSounds;
	local Material SpawnOverlay[2];

	local array< class<ONSPlusVehiclePlugin> > FinalPluginList;
	local int i;
	local string sTempStr;

	if (Level.Netmode != NM_Standalone && int(Level.EngineVersion) < 3369)
	{
		Log("This version of ONSPlus is only 100% compatable with patch 3369, any previous patch won't work and any patch released after is untested", 'ONSPlusError');
		Destroy();

		return;
	}


	// Setup config
	OPConfig = new(none, "ONSPlus") Class'ONSPlusConfig_Mut';

	bDisablePlayerClass = OPConfig.bDisablePlayerClass;
	bDropChecks = OPConfig.bDropChecks;
	bSelectableExits = OPConfig.bSelectableExits;
	bNodeHealScoreFix = OPConfig.bNodeHealScoreFix;
	bVehicleHealScore = OPConfig.bVehicleHealScore;
	bVehicleDamageScore = OPConfig.bVehicleDamageScore;
	bPallyShieldScore = OPConfig.bPallyShieldScore;
	HealValueScore = OPConfig.HealValueScore;
	DamageValueScore = OPConfig.DamageValueScore;
	PallyValueScore = OPConfig.PallyValueScore;
	bNodeIsolateBonus = OPConfig.bNodeIsolateBonus;
	IsolateBonusPctPerNode = OPConfig.IsolateBonusPctPerNode;
	bAllowEnhancedRadar = OPConfig.bAllowEnhancedRadar;
	bRestrictMissileLock = OPConfig.bRestrictMissileLock;
	bDisablePreferredTeam = OPConfig.bDisablePreferredTeam;
	bDisableVersionCheck = OPConfig.bDisableVersionCheck;
	bDisableONSPlusTurrets = OPConfig.bDisableONSPlusTurrets;
	bDisablePreMatchTeamSwitch = OPConfig.bDisablePreMatchTeamSwitch;
	bVehicleDistanceCheck = OPConfig.bVehicleDistanceCheck;
	RespawnTimerDistance = OPConfig.RespawnTimerDistance;
	DistanceCheckTimer = OPConfig.DistanceCheckTimer;
	BlackListedWords = OPConfig.BlackListedWords;
	MaxWordHits = OPConfig.MaxWordHits;
	MaxHitAction = OPConfig.MaxHitAction;
	bEnableWordFilter = OPConfig.bEnableWordFilter;
	bClientSendFilter = OPConfig.bClientSendFilter;
	bFilterAdmin = OPConfig.bFilterAdmin;
	bEnableCustomVehiclePlugins = OPConfig.bEnableCustomVehiclePlugins;
	bRPGCompatible = OPConfig.bRPGCompatible;
	CustomVehiclePlugins = OPConfig.CustomVehiclePlugins;


	Level.Game.GameReplicationInfoClass = Class'ONSPlusGameReplicationInfo';

	if (ONSOnslaughtGame(level.game) != none)
		Level.Game.HUDType = string(Class'ONSPlusHUDOns');


	if (bEnableCustomVehiclePlugins)
		InitializeVehiclePlugins();

	foreach AllActors(Class'Actor', A)
	{
		// Sort the custom vehicles list
		if (SVehicleFactory(A) != none && bEnableCustomVehiclePlugins && SVehicleFactory(A).VehicleClass != none)
		{
			// Iterate the list of plugins and check if the current vehicleclass is used, if a plugin uses it then add that plugin to the final list
			for (i=0; i<ActiveCVehiclePlugins.Length; ++i)
			{
				if (ActiveCVehiclePlugins[i].static.CanReplaceClass(SVehicleFactory(A).VehicleClass))
				{
					FinalPluginList[FinalPluginList.Length] = ActiveCVehiclePlugins[i];

					sTempStr = string(ActiveCVehiclePlugins[i]);
					sTempStr = Left(sTempStr, InStr(sTempStr, "."));


					// Add the plugins package to the serverpackages list
					if (sTempStr != "")
						AddToPackageMap(sTempStr);

					// The plugin has been added to the final list, no need to do further checks with it so remove it
					ActiveCVehiclePlugins.Remove(i, 1);

					break;
				}
			}
		}
	}

	// The final list should be ready now
	if (bEnableCustomVehiclePlugins)
		ActiveCVehiclePlugins = FinalPluginList;

	Super.PreBeginPlay();
}

function InitializeVehiclePlugins()
{
	local int i;
	local class<ONSPlusVehiclePlugin> CurrentPlugin;


	// Load all plugins
	for (i=0; i<CustomVehiclePlugins.Length; i++)
	{
		if (CustomVehiclePlugins[i] == "")
			continue;


		CurrentPlugin = Class<ONSPlusVehiclePlugin>(DynamicLoadObject(CustomVehiclePlugins[i], Class'Class'));

		// Check if it was a valid class and do version checks
		if (CurrentPlugin != none && float(CurrentPlugin.static.MinONSPlusVersion()) <= float(GetONSPlusVersion())
			&& float(CurrentPlugin.static.CompiledONSPlusVersion()) >= float(MinONSPlusPluginVersion))
			ActiveCVehiclePlugins[ActiveCVehiclePlugins.Length] = CurrentPlugin;
	}

}

function PostBeginPlay()
{
	if (bDeleteMe)
		return;


	// Hack for replacing stuff after PostBeginPlay is called (note: use the initialstate function or whatever instead? note2: possibly, but CBA..don't fix what ain't broke)
	SetTimer(0.001, false);


	if (!bDisablePlayerClass)
		Level.Game.PlayerControllerClassName = string(Class'ONSPlusxPlayer');//"ONSPlus.ONSPlusxPlayer";

	ScoreRules = Spawn(Class'ONSPlusScoreRules');
	ScoreRules.MutatorOwner = self;
	ScoreRules.OPInitialise();
	Level.Game.AddGameModifier(ScoreRules);

	if (ONSOnslaughtGame(level.game) != none)
		ONSOnslaughtGame(Level.Game).GameUMenuType = string(Class'ONSPlusLoginMenu'); //"ONSPlus.ONSPlusLoginMenu";
	else if (xVehicleCTFGame(level.game) != none)
		xVehicleCTFGame(level.game).GameUMenuType = string(Class'ONSPlusLoginMenuVCTF');//"ONSPlus.ONSPlusLoginMenuVCTF";
}

function OPSaveConfig()
{
	if (OPConfig == none)
		OPConfig = new(none, "ONSPlus") Class'ONSPlusConfig_Mut';

	OPConfig.bDisablePlayerClass = bDisablePlayerClass;
	OPConfig.bDropChecks = bDropChecks;
	OPConfig.bSelectableExits = bSelectableExits;
	OPConfig.bNodeHealScoreFix = bNodeHealScoreFix;
	OPConfig.bVehicleHealScore = bVehicleHealScore;
	OPConfig.bVehicleDamageScore = bVehicleDamageScore;
	OPConfig.bPallyShieldScore = bPallyShieldScore;
	OPConfig.HealValueScore = HealValueScore;
	OPConfig.DamageValueScore = DamageValueScore;
	OPConfig.PallyValueScore = PallyValueScore;
	OPConfig.bNodeIsolateBonus = bNodeIsolateBonus;
	OPConfig.IsolateBonusPctPerNode = IsolateBonusPctPerNode;
	OPConfig.bAllowEnhancedRadar = bAllowEnhancedRadar;
	OPConfig.bRestrictMissileLock = bRestrictMissileLock;
	OPConfig.bDisablePreferredTeam = bDisablePreferredTeam;
	OPConfig.bDisableVersionCheck = bDisableVersionCheck;
	OPConfig.bDisableONSPlusTurrets = bDisableONSPlusTurrets;
	OPConfig.bDisablePreMatchTeamSwitch = bDisablePreMatchTeamSwitch;
	OPConfig.bVehicleDistanceCheck = bVehicleDistanceCheck;
	OPConfig.RespawnTimerDistance = RespawnTimerDistance;
	OPConfig.DistanceCheckTimer = DistanceCheckTimer;
	OPConfig.BlackListedWords = BlackListedWords;
	OPConfig.MaxWordHits = MaxWordHits;
	OPConfig.MaxHitAction = MaxHitAction;
	OPConfig.bEnableWordFilter = bEnableWordFilter;
	OPConfig.bClientSendFilter = bClientSendFilter;
	OPConfig.bFilterAdmin = bFilterAdmin;
	OPConfig.bEnableCustomVehiclePlugins = bEnableCustomVehiclePlugins;
	OPConfig.bRPGCompatible = bRPGCompatible;
	OPConfig.CustomVehiclePlugins = CustomVehiclePlugins;

	OPConfig.SaveConfig();
}

// Initiate the GRI variables for replication
function InitGRI()
{
	if (Level.Game.GameReplicationInfo != None && ONSPlusGameReplicationInfo(Level.Game.GameReplicationInfo) != None)
	{
		ONSPlusGameReplicationInfo(Level.Game.GameReplicationInfo).bDropChecks = bDropChecks;

		ONSPlusGameReplicationInfo(Level.Game.GameReplicationInfo).bSelectableExits = bSelectableExits;
		ONSPlusGameReplicationInfo(Level.Game.GameReplicationInfo).bVehicleHealScoreFix = bVehicleHealScore;
		ONSPlusGameReplicationInfo(Level.Game.GameReplicationInfo).bVehicleDamageScore = bVehicleDamageScore;
		ONSPlusGameReplicationInfo(Level.Game.GameReplicationInfo).bPallyShieldScore = bPallyShieldScore;

		ONSPlusGameReplicationInfo(Level.Game.GameReplicationInfo).HealScoreQuota = HealValueScore;
		ONSPlusGameReplicationInfo(Level.Game.GameReplicationInfo).DamageScoreQuota = DamageValueScore;
		ONSPlusGameReplicationInfo(Level.Game.GameReplicationInfo).PallyScoreQuota = PallyValueScore;

		ONSPlusGameReplicationInfo(Level.Game.GameReplicationInfo).bRestrictMissileLock = bRestrictMissileLock;

		ONSPlusGameReplicationInfo(Level.Game.GameReplicationInfo).bDisablePreMatchTeamSwitch = bDisablePreMatchTeamSwitch;

		//ONSPlusGameReplicationInfo(Level.Game.GameReplicationInfo).bAllowFlyingLevi = bAllowFlyingLevi;

		if (ONSOnslaughtGame(level.game) != none)
		{
			ONSPlusGameReplicationInfo(Level.Game.GameReplicationInfo).bAllowEnhancedRadar = bAllowEnhancedRadar;
			ONSPlusGameReplicationInfo(Level.Game.GameReplicationInfo).bNodeHealScoreFix = bNodeHealScoreFix;
			ONSPlusGameReplicationInfo(Level.Game.GameReplicationInfo).bIsolateNodeBonus = bNodeIsolateBonus;
			ONSPlusGameReplicationInfo(Level.Game.GameReplicationInfo).IsolateBonusPctPerNode = IsolateBonusPctPerNode;
		}

		ONSPlusGameReplicationInfo(Level.Game.GameReplicationInfo).bAllowPreferredTeam = !bDisablePreferredTeam;

		ONSPlusGameReplicationInfo(Level.Game.GameReplicationInfo).bVehicleDistanceCheck = bVehicleDistanceCheck;
		ONSPlusGameReplicationInfo(Level.Game.GameReplicationInfo).RespawnTimerDistance = RespawnTimerDistance;
		ONSPlusGameReplicationInfo(Level.Game.GameReplicationInfo).DistanceCheckTimer = DistanceCheckTimer;
	}
}

function Timer()
{
	local actor A;
	local ONSVehicleFactory VF;
	local KarmaBoostVolume KB;
	local BlockingVolume BV;
	local SpecialVehicleObjective SV;
	local Trigger T;
	local int i, j;
	local class<Vehicle> CurClass;

	Super.Timer();

	if (bPostInitTimer)
	{
		OPSaveConfig();

		return;
	}


	InitGRI();

	// Part of removed tiebreak code
	//if (bEnableTieBreaks)
	//	SetTimer(Level.TimeDilation, True);

	// Various map-fixing replacements and ONSPlus specific replacements
	foreach AllActors(Class'Actor', A)
	{
		// Replace vehicles
		if (ONSVehicleFactory(A) != None)
		{
			VF = ONSVehicleFactory(A);

            for (i=0; i<ActiveCVehiclePlugins.Length; ++i)
                if (ActiveCVehiclePlugins[i].static.ReplaceVehicleClass(VF.VehicleClass))
                    break;
		}
		// Replace LinkGun
		else if (xWeaponBase(A) != None && xWeaponBase(A).WeaponType == Class'LinkGun')
		{
			if ((bNodeHealScoreFix || bVehicleHealScore) && !bRPGCompatible)
				xWeaponBase(A).WeaponType = Class'ONSPlusLinkGun';
		}
		else if (WeaponLocker(A) != None)
		{
			if (/*bVehicleHealScore || bNodeHealScoreFix*/ !bRPGCompatible)
			{
				for (i=0; i<WeaponLocker(A).Weapons.Length; i++)
				{
					if (WeaponLocker(A).Weapons[i].WeaponClass == Class'LinkGun' && (bNodeHealScoreFix || bVehicleHealScore))
						WeaponLocker(A).Weapons[i].WeaponClass = Class'ONSPlusLinkGun';
					else if (WeaponLocker(A).Weapons[i].WeaponClass == Class'ONSAVRiL')
						WeaponLocker(A).Weapons[i].WeaponClass = Class'ONSPlusAVRiL';
				}
			}
		}
		else if (LinkGunPickup(A) != None)
		{
			if ((bNodeHealScoreFix || bVehicleHealScore) && !bRPGCompatible)
				LinkGunPickup(A).InventoryType = Class'ONSPlusLinkGun';
		}
		// Replace AVRiL
		else if (xWeaponBase(A) != None && xWeaponBase(A).WeaponType == Class'ONSAVRiL')
		{
			if (!bRPGCompatible)
				xWeaponBase(A).WeaponType = Class'ONSPlusAVRiL';
		}
		else if (ONSAVRiLPickup(A) != None)
		{
			if (!bRPGCompatible)
				ONSAVRiLPickup(A).InventoryType = Class'ONSPlusAVRiL';
		}
		// Set KarmaBoostVolume's vehicle settings to the new vehicles
		else if (KarmaBoostVolume(A) != None)
		{
			KB = KarmaBoostVolume(A);

			for (i=0; i<KB.AffectedClasses.Length; i++)
			{
                for (j=0; j<ActiveCVehiclePlugins.Length; ++j)
                {
                    CurClass = Class<Vehicle>(KB.AffectedClasses[i]);

                    if (ActiveCVehiclePlugins[j].static.ReplaceVehicleClass(CurClass))
                    {
                        KB.AffectedClasses[i] = CurClass;
                        break;
                    }
                }
			}
		}
		// Set BlockingVolume's vehicle settings to the new vehicles (is this even needed?)
		else if (BlockingVolume(A) != None)
		{
			BV = BlockingVolume(A);

			for (i=0; i<BV.BlockedClasses.Length; i++)
			{
                for (j=0; j<ActiveCVehiclePlugins.Length; ++j)
                {
                    CurClass = Class<Vehicle>(BV.BlockedClasses[i]);

                    if (ActiveCVehiclePlugins[j].static.ReplaceVehicleClass(CurClass))
                    {
                        BV.BlockedClasses[i] = CurClass;
                        break;
                    }
                }
			}
		}
		else if (SpecialVehicleObjective(A) != None)
		{
			SV = SpecialVehicleObjective(A);

			for (i=0; i<SV.AccessibleVehicleClasses.Length; i++)
			{
                for (j=0; j<ActiveCVehiclePlugins.Length; ++j)
                    if (ActiveCVehiclePlugins[j].static.ReplaceVehicleClass(SV.AccessibleVehicleClasses[i]))
                        break;
			}
		}
		else if (Trigger(A) != None && Trigger(A).TriggerType == TT_ClassProximity)
		{
			T = Trigger(A);

            for (i=0; i<ActiveCVehiclePlugins.Length; ++i)
            {
                CurClass = Class<Vehicle>(T.ClassProximityType);

                if (ActiveCVehiclePlugins[i].static.ReplaceVehicleClass(CurClass))
                {
                    T.ClassProximityType = CurClass;
                    break;
                }
            }
		}
	}


	// I want to reuse timer to occasionally save config variables (not a nice way to do it but works...I also have it set to save on servertravel)
	bPostInitTimer = True;
	SetTimer(180, True);
}

// It's very frustrating that this doesn't work...well..it 'does' work but adding the health back on like I've done has one
// of two undesired side effects: the core health shows up higher than it really is OR the core dies earlier than it should
// A pity because if it were not for this small problem I could keep the overtime code
/*
function Timer()
{
	local int CDmg[2], i, TeamNodes[2], TotalNodes;
	local ONSOnslaughtGame OG;

	//Log("In timer");

	if (Level.Game.IsInState('MatchInProgress') && ONSOnslaughtGame(Level.Game).bOvertime)
	{
		if (!bInitialWait)
		{
			bInitialWait = True;
			return;
		}

		//Log("Reducing core dmg");

		OG = ONSOnslaughtGame(Level.Game);

		for (i=0; i<OG.PowerCores.Length; i++)
		{
			if (!OG.PowerCores[i].bFinalCore && OG.PowerCores[i].CoreStage != 255)
			{
				if (OG.PowerCores[i].CoreStage == 0 && OG.PowerCores[i].DefenderTeamIndex < 2)
					TeamNodes[OG.PowerCores[i].DefenderTeamIndex]++;

				TotalNodes++;
			}
		}

		CDmg[0] = OG.OvertimeCoreDrainPerSec - OG.OvertimeCoreDrainPerSec * (float(TeamNodes[0]) / TotalNodes);
		CDmg[1] = OG.OvertimeCoreDrainPerSec - OG.OvertimeCoreDrainPerSec * (float(TeamNodes[1]) / TotalNodes);

        	OG.PowerCores[OG.FinalCore[0]].Health += CDmg[0];
        	OG.PowerCores[OG.FinalCore[1]].Health += CDmg[1];
	}
}*/

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	if (bVehicleHealScore && Controller(Other) != None && MessagingSpectator(Other) == None)
		Controller(Other).PlayerReplicationInfoClass = class'ONSPlusPlayerReplicationInfo';

	return true;
}

// Added to initialise vehicle factory info (and later modified for other stuff too)
function ModifyPlayer(Pawn Other)
{
	local int i;

	// Word filter variables
	local int iTempInt;
	local string sNewName;

	Super.ModifyPlayer(Other);

	if (ONSOnslaughtGame(level.game) == none)
		return;

	if (Other != none && Other.PlayerReplicationInfo != none && ONSPlusPlayerReplicationInfo(Other.PlayerReplicationInfo) != none)
	{
		if (ONSPlusPlayerReplicationInfo(Other.PlayerReplicationInfo).MutatorOwner == none)
			ONSPlusPlayerReplicationInfo(Other.PlayerReplicationInfo).MutatorOwner = self;

		if (!ONSPlusPlayerReplicationInfo(Other.PlayerReplicationInfo).bInitializedVSpawnList
			|| ONSPlusPlayerReplicationInfo(Other.PlayerReplicationInfo).LastInitialiseTeam != Other.GetTeamNum())
		{
			ScoreRules.InitialiseVehicleSpawnList(ONSPlusPlayerReplicationInfo(Other.PlayerReplicationInfo));
			ONSPlusPlayerReplicationInfo(Other.PlayerReplicationInfo).bInitializedVSpawnList = True;
			ONSPlusPlayerReplicationInfo(Other.PlayerReplicationInfo).LastInitialiseTeam = Other.GetTeamNum();
		}

		if (bEnableWordFilter && !ONSPlusPlayerReplicationInfo(Other.PlayerReplicationInfo).bInitialisedWordList)
		{
			ONSPlusPlayerReplicationInfo(Other.PlayerReplicationInfo).bInitialisedWordList = True;
			ONSPlusPlayerReplicationInfo(Other.PlayerReplicationInfo).bFilterSentWords = bClientSendFilter;
			ONSPlusPlayerReplicationInfo(Other.PlayerReplicationInfo).bFilterAdmins = bFilterAdmin;

			// Check the players name to make sure it contains no blacklisted words (this only happens once serverside)
			sNewName = Other.PlayerReplicationInfo.PlayerName;

			for (i=0; i<BlacklistedWords.Length; i++)
			{
				// While checking the player name, send the info to the PRI at the same time
				ONSPlusPlayerReplicationInfo(Other.PlayerReplicationInfo).UpdateWordFilter(BlacklistedWords[i], i);

				ONSPlusPlayerReplicationInfo(Other.PlayerReplicationInfo).MaxWordHits = MaxWordHits;
				ONSPlusPlayerReplicationInfo(Other.PlayerReplicationInfo).MaxHitAction = MaxHitAction;


				RecheckName:

				iTempInt = InStr(caps(sNewName), caps(BlacklistedWords[i].Word));

				if (iTempInt != -1)
				{
					sNewName = Left(sNewName, iTempInt)$BlacklistedWords[i].Replacement$Mid(sNewName, iTempInt + Len(BlackListedWords[i].Word));

					//ONSPlusPlayerReplicationInfo(Other.PlayerReplicationInfo).HitWord(BlacklistedWords[i].HitCount);
					ONSPlusPlayerReplicationInfo(Other.PlayerReplicationInfo).HitWord(i);

					// Repeat the same check in case the same word is in the list more than once
					//i--;
					Goto 'RecheckName';
				}
			}

			// If the name has had to be modified then assign the new name to the player
			if (sNewName != Other.PlayerReplicationInfo.PlayerName)
				Other.PlayerReplicationInfo.SetPlayerName(sNewName);
		}


		if (Other.Controller != none && ONSPlusxPlayer(Other.Controller) != none)
		{
			// Do a check on the client to make sure he/she is running 3369 or higher, if not then a popup will open for them
			if (!bDisableVersionCheck && !ONSPlusxPlayer(Other.Controller).bDidVersionCheck)
			{
				ONSPlusxPlayer(Other.Controller).bDidVersionCheck = True;
				ONSPlusxPlayer(Other.Controller).DoVersionCheck();
			}

			// If there are any custom vehicle plugins loaded, send them to the client
			if (bEnableCustomVehiclePlugins && !ONSPlusxPlayer(Other.Controller).bInitializedClientPlugins)
			{
				for (i=0; i<ActiveCVehiclePlugins.Length; ++i)
					ONSPlusxPlayer(Other.Controller).ReceiveVehiclePlugin(ActiveCVehiclePlugins[i]);

				ONSPlusxPlayer(Other.Controller).bInitializedClientPlugins = True;
			}
		}
	}
}

function ModifyLogin(out string Portal, out string Options)
{
	local int iTempInt, iTempInt2;
	local string sTempStr;

	// Remove the preferred team
	if (bDisablePreferredTeam)
	{
		iTempInt = InStr(Caps(Options), "?TEAM=");
		sTempStr = Mid(Options, iTempInt + 1);
		iTempInt2 = InStr(sTempStr, "?");

		if (iTempInt2 != -1)
			sTempStr = Left(Options, iTempInt)$Mid(sTempStr, iTempInt2);
		else
			sTempStr = Left(Options, iTempInt);

		// I just noticed that all previous versions of this code (in NoPreferredTeam, TTF and ONSPlus) were missing this line of code :p (haha)
		Options = sTempStr;
	}

	// TitanTeamFix hack
	if (ExtraMut != none)
		ExtraMut.ModifyLogin(Portal, Options);

	Super.ModifyLogin(Portal, Options);
}

function ServerTraveling(string URL, bool bItems)
{
	OPSaveConfig();

	Super.ServerTraveling(URL, bItems);
}

// ***** TitanTeamFix hack's

function NotifyLogout(Controller Exiting)
{
	if (ExtraMut != none)
		ExtraMut.NotifyLogout(Exiting);

	Super.NotifyLogout(Exiting);
}

// *****

static function string GetONSPlusVersion()
{

    // If the mod package is ONSPlus_101beta23.u, this function returns "101beta23", kinda dumb
    // This is used in the server info and in version checks.  We aren't using the plugin system
    // so we don't care about version checks.  Since this is just server info anyway, simply use a string
    // snarf

    /* 

	local string sTempStr;

	sTempStr = string(Class'ONSPlusMutator');
	sTempStr = Left(sTempStr, InStr(sTempStr, "."));

	return Mid(sTempStr, InStr(sTempStr, "_") + 1);
    */

    return ")o(mni 1.0";
}

defaultproperties
{
	bAddToServerPackages=True
/*
	bDropChecks=True
	bAllowEnhancedRadar=True
	bRestrictMissileLock=True

	bSelectableExits=True

	bNodeHealScoreFix=True
	bVehicleHealScore=True
	bVehicleDamageScore=True
	bPallyShieldScore=True

	bNodeIsolateBonus=True
	IsolateBonusPctPerNode=20

	HealValueScore=200.000000
	DamageValueScore=400.000000
	PallyValueScore=1000.000000

	bEnableCustomVehiclePlugins=False
	bRPGCompatible=False
*/
	FriendlyName="ONSPlusOmni"
	Description="ONSPlus (Omni) adds many fixes and small enhancements to the Onslaught and VehicleCTF gametypes"
}