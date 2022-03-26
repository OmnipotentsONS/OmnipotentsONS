// ONSPlus: Coded by Shambler (Shambler__@Hotmail.com or Shambler@OldUnreal.com , ICQ:108730864)
Class ONSPlusxPlayer extends xPlayer;

var bool bDisplayExitPoints;
var /*config*/ bool bDisableExitPointDisplay;
var /*config*/ bool bDisableSelectableExits;

var /*config*/ bool bDisableEnhancedRadarMap;

// Seriously...Why the fuck does this have to be so difficult, the playerinput system is totally stupid
var private transient PlayerInput PlayerInputPlus;

var float LastVRequestTime;

var bool bDidVersionCheck;

var bool bDebugFreezeRadar;

// Vehicle which 'should' currently own the below delegates
var Vehicle CurDelegateOwner;

var bool bInitializedClientPlugins;
var array< class<ONSPlusVehiclePlugin> > VehiclePlugins;

// Some fixes
var int SSTOCalls, SSTOCritical, SwitchCount, SUCalls;//, DodgeCount;
var float SSTOTimestamp, SwitchTimeStamp, SUTimestamp;//, LastLandTime;
var bool bSSTOKicked, bTempSpec;

// Seperate fix
var float AmbSSTimeStamp;
var int RollOffHits;
var object AudioObject;
var bool bCheckedForAudio;

var ONSPlusConfig_Player OPConfig;


replication
{
	reliable if (Role == ROLE_Authority)
		DoVersionCheck, ClientReceiveVehiclePlugin, ClientReceiveCoreTeams;

	reliable if (Role < ROLE_Authority)
		ServerTogglePreferredExit, SelectExitPointServer, ServerViewPlayer, ServerSendCoreTeams;//, ServerDebugRadar;
}

// Delegates for plugin vehicles
// Serverside
delegate DelTogglePreferredExit(optional int ExpireTime);
// Clientside/serverside
delegate DelSelectDirectionalExit(byte Direction, optional int ExpireTime, optional bool bPermenant);


// Setup config
simulated function PostBeginPlay()
{
	if (Level.Netmode != NM_DedicatedServer)
	{
		OPConfig = new(none, "ONSPlus") Class'ONSPlusConfig_Player';

		bDisableExitPointDisplay = OPConfig.bDisableExitPointDisplay;
		bDisableSelectableExits = OPConfig.bDisableSelectableExits;
		bDisableEnhancedRadarMap = OPConfig.bDisableEnhancedRadarMap;
	}

	Super.PostBeginPlay();
}

function OPSaveConfig()
{
	if (OPConfig == none)
		OPConfig = new(none, "ONSPlus") Class'ONSPlusConfig_Player';

	OPConfig.bDisableExitPointDisplay = bDisableExitPointDisplay;
	OPConfig.bDisableSelectableExits = bDisableSelectableExits;
	OPConfig.bDisableEnhancedRadarMap = bDisableEnhancedRadarMap;

	OPConfig.SaveConfig();
}


exec function GetWeapon(class<Weapon> NewWeaponClass)
{
	if (NewWeaponClass == Class'LinkGun')
		NewWeaponClass = Class'ONSPlusLinkGun';
	else if (NewWeaponClass == Class'ONSAVRiL')
		NewWeaponClass = Class'ONSPlusAVRiL';

	Super.GetWeapon(NewWeaponClass);
}

exec function ToggleExitPointDisplay()
{
	bDisableExitPointDisplay = !bDisableExitPointDisplay;
	OPSaveConfig();
}

exec function ToggleSelectableExits()
{
	bDisableSelectableExits = !bDisableSelectableExits;

	OPSaveConfig();

	if (bDisableSelectableExits)
		EmptyExitSelections();
}

// Clientside
exec function DisplayExitPoints()
{
	bDisplayExitPoints = !bDisplayExitPoints;
}

// Clientside
exec function TogglePreferredExit()
{
	if (!bDisableSelectableExits)
		ServerTogglePreferredExit();
}

// Serverside
function ServerTogglePreferredExit()
{
	local int i;

	if (bInitializedClientPlugins)
	{
		// Not occupying any of the hardcoded vehicles, see if a plugin vehicle is currently occupied
		if (CurDelegateOwner != Pawn)
		{
			for (i=0; i<VehiclePlugins.Length; ++i)
			{
				if (VehiclePlugins[i].static.SetupVehicleDelegates(Self, none, none, Vehicle(Pawn)))
				{
					CurDelegateOwner = Vehicle(Pawn);
					break;
				}
			}
		}

		// Delegates are appropriate for this vehicle, use them
		if (CurDelegateOwner == Pawn)
			DelTogglePreferredExit();
	}
}

exec function SetPreferredExit(string Direction, optional bool bPermenant, optional int Duration)
{
	local int Dir;

	if (bDisableSelectableExits)
		return;

	if (Direction ~= "Left")
		Dir = 1;
	else if (Direction ~= "Right")
		Dir = 2;
	else if (Direction ~= "Forward" || Direction ~= "Front")
		Dir = 3;
	else if (Direction ~= "Back" || Direction ~= "Backwards")
		Dir = 4;
	else if (Direction ~= "1" || Direction ~= "2" || Direction ~= "3" || Direction ~= "4")
		Dir = int(Direction);

	if (Duration > 0)
		bPermenant = False;

	SelectExitPoint(Dir, bPermenant, Duration);
	SelectExitPointServer(Dir, bPermenant, Duration);
}

exec function EmptyExitSelections()
{
	SelectExitPoint(5);
	SelectExitPointServer(5);
}

exec function DisplayEnhancedRadarMap()
{
	bDisableEnhancedRadarMap = !bDisableEnhancedRadarMap;
	OPSaveConfig();
}

function SelectExitPoint(int Point, optional bool bPermenant, optional int Duration)
{
	local int i;

	if (Duration <= 0)
		Duration = 3;

	if (bInitializedClientPlugins)
	{
		// Not occupying any of the hardcoded vehicles, see if a plugin vehicle is currently occupied
		if (CurDelegateOwner != Pawn)
		{
			for (i=0; i<VehiclePlugins.Length; ++i)
			{
				if (VehiclePlugins[i].static.SetupVehicleDelegates(Self, none, none, Vehicle(Pawn)))
				{
					CurDelegateOwner = Vehicle(Pawn);
					break;
				}
			}
		}

		// Delegates are appropriate for this vehicle, use them
		if (CurDelegateOwner == Pawn)
			DelSelectDirectionalExit(Point, Duration, bPermenant);
	}
}

function SelectExitPointServer(int Point, optional bool bPermenant, optional int Duration)
{
	if (Level.NetMode != NM_Standalone)
		SelectExitPoint(Point, bPermenant, Duration);
}

state PlayerDriving
{
ignores SeePlayer, HearNoise, Bump;

	function PlayerMove(float DeltaTime)
	{
		local eDoubleClickDir DoubleClickMove;

		Super.PlayerMove(DeltaTime);

		if ((Role < ROLE_Authority || Level.Netmode == NM_Standalone) && !bDisableSelectableExits)
		{
			DoubleClickMove = PlayerInputPlus.CheckForDoubleClickMove(1.1 * DeltaTime / Level.TimeDilation);

			if (DoubleClickMove > 0 && DoubleClickmove < 5)
			{
				SelectExitPointServer(DoubleClickMove);
				SelectExitPoint(DoubleClickMove);
			}
		}
	}
}

simulated function InitInputSystem()
{
	PlayerInputPlus = new(self) Class'ONSPlusPlayerInput';

	Super.InitInputSystem();
}

function PlayerTick(float DeltaTime)
{
	local int i;
	local AudioSubsystem TempObj;

	PlayerInputPlus.PlayerInput(DeltaTime);


	if (!bCheckedForAudio && Level.NetMode != NM_DedicatedServer)
	{
		foreach AllObjects(Class'AudioSubsystem', TempObj)
		{
			AudioObject = TempObj;
			break;
		}

		bCheckedForAudio = true;
	}


	// Exploit Fix
	if (Level.NetMode != NM_DedicatedServer && GameReplicationInfo != none && Level.TimeSeconds - AmbSSTimeStamp > 1.0)
	{
		for (i=0; i<GameReplicationInfo.PRIArray.Length; ++i)
		{
			if (GameReplicationInfo.PRIArray[i].Owner != none && Controller(GameReplicationInfo.PRIArray[i].Owner) != none &&
				Controller(GameReplicationInfo.PRIArray[i].Owner).Pawn != none && !Controller(GameReplicationInfo.PRIArray[i].Owner).Pawn.bFullVolume)
			{
				Controller(GameReplicationInfo.PRIArray[i].Owner).Pawn.bFullVolume = True;
				Controller(GameReplicationInfo.PRIArray[i].Owner).Pawn.SoundVolume = Controller(GameReplicationInfo.PRIArray[i].Owner).Pawn.default.SoundVolume * 0.51;
			}
		}

		AmbSSTimeStamp = Level.TimeSeconds;


		// No need to potentially affect performance if the player is a good boy :p
		if (RollOffHits < 5 && AudioObject != none && float(AudioObject.GetPropertyText("RollOff")) < 0.4)
		{
			RollOffHits++;
			AudioObject.SetPropertyText("RollOff", "0.4");
		}
	}


	if (RollOffHits >= 5)
		AudioObject.SetPropertyText("RollOff", "0.4");


	Super.PlayerTick(DeltaTime);
}

simulated function ClientReceiveLoginMenu(string MenuClass, bool bForce)
{
	if (/*GameReplicationInfo.GameClass ~= "Onslaught.ONSOnslaughtGame" || */MenuClass ~= "GUI2k4.UT2K4OnslaughtLoginMenu")
		LoginMenuClass = string(Class'ONSPlusLoginMenu');//"ONSPlus.ONSPlusLoginMenu";
	else
		LoginMenuClass = string(Class'ONSPlusLoginMenuVCTF');//"ONSPlus.ONSPlusLoginMenuVCTF";

	bForceLoginMenu = bForce;
}

// I have modified this function to request a vehicle info update every time the menu is opened (more efficient than the last implementation)
function ClientOpenMenu(string Menu, optional bool bDisconnect,optional string Msg1, optional string Msg2)
{
	if (Menu == MidGameMenuClass)
		GetVInfoUpdate();

	Super.ClientOpenMenu(Menu, bDisconnect, Msg1, Msg2);
}

function GetVInfoUpdate()
{
	if (Level.TimeSeconds - LastVRequestTime > 3.0 && !bDisableEnhancedRadarMap && PlayerReplicationInfo != none && ONSPlusPlayerReplicationInfo(PlayerReplicationInfo) != none)
	{
		LastVRequestTime = Level.TimeSeconds;
		ONSPlusPlayerReplicationInfo(PlayerReplicationInfo).RequestVehicleInfoUpdate();
	}
}

// Since this version of ONSPlus is only compatable with the 3369 patch I have decided to add a little bit of extra code here to popup a warning message
function DoVersionCheck()
{
	local string sTempStr, sSearchStr;
	local int iTempInt;

	if (int(Level.EngineVersion) < 3369)
	{
		ClientOpenMenu(/*"ONSPlus.ONSPlusBadVersionMsg"*/ string(Class'ONSPlusBadVersionMsg'), false,
				"You are running a version of UT2004 that is incompatable with the ONSPlus mutator",
				"Please update to UT2004 version 3369 by clicking the Download button below, "$
				"if you continue to play on this version then be advised that you will be prone to crashing");
	}
	else if (int(Level.EngineVersion) == 3369 /* Temporary */ && PlatformIsWindows())
	{
		// N.B. Linux versions have different OnslaughtBP pacakge so exclude them from this check, not sure bout Mac so leaving it in (better someone complain to me about a
		//	specific problem with the ECE message and Macs, than an obscure GPF problem due to bad installations)
		if (PlatformIsMacOS() || PlatformIsWindows())
			sSearchStr = "Names=1708 (6K/64K) Imports=737 (20K) Exports=1243 (43K) Gen=11 Lazy=0";
		else if (PlatformIsUnix())
			sSearchStr = "Names=1708 (6K/71K) Imports=737 (28K) Exports=1243 (58K) Gen=11 Lazy=0";

		if (sSearchStr != "")
		{
			sTempStr = ConsoleCommand("Obj Linkers");
			iTempInt = InStr(Caps(sTempStr), "(PACKAGE ONSLAUGHTBP):");

			if (iTempInt != -1)
			{
				sTempStr = Mid(sTempStr, iTempInt + 23);

				//if (Left(sTempStr, 70) != "Names=1708 (6K/64K) Imports=737 (20K) Exports=1243 (43K) Gen=11 Lazy=0")
				if (Left(sTempStr, 70) != sSearchStr)
				{
					ClientOpenMenu(/*"ONSPlus.ONSPlusBadVersionMsg"*/ string(Class'ONSPlusBadVersionMsg'), false,
							"You are running a version of the ECE bonus pack which does not match your UT2004 version",
							"This is often caused by installing ECE on top of recent patches, please reapply the 3369 "$
							"patch by clicking the Download button below, if you continue to play on this version then "$
							"be advised that you will be prone to crashing");
				}
			}
		}
	}
}

function ReceiveVehiclePlugin(Class<ONSPlusVehiclePlugin> Plugin)
{
	VehiclePlugins[VehiclePlugins.Length] = Plugin;
	ClientReceiveVehiclePlugin(Plugin);
}

function ClientReceiveVehiclePlugin(Class<ONSPlusVehiclePlugin> Plugin)
{
	VehiclePlugins[VehiclePlugins.Length] = Plugin;
	bInitializedClientPlugins = True;
}

exec function DebugFreezeRadar()
{
	bDebugFreezeRadar = !bDebugFreezeRadar;
}

/*exec function DebugHUD()
{
	ONSPlusHUD(myHUD).bOldRadarCode = !ONSPlusHUD(myHUD).bOldRadarCode;
}*/

// Gets rid of the pain in the ass suicide restriction (which needs to be put back in because some assholes are just too immature)
/*exec function Suicide()
{
	if (Pawn != None && Level.TimeSeconds - Pawn.LastStartTime > 1.0)
		Pawn.Suicide();
}*/

simulated function ClientSetHUD(class<HUD> newHUDClass, class<Scoreboard> newScoringClass)
{
	if (int(Level.EngineVersion) == 3372 && newHUDClass == Class'ONSPlusHUDOns')
		Super.ClientSetHUD(Class'ONSPlusHUD', newScoringClass);
	else
		Super.ClientSetHUD(newHUDClass, newScoringClass);
}

// Blacklisted word checks
exec function SetName(coerce string S)
{
	local int i, iTempInt;

	if (PlayerReplicationInfo != none && ONSPlusPlayerReplicationInfo(PlayerReplicationInfo) != none
		&& ONSPlusPlayerReplicationInfo(PlayerReplicationInfo).WordFilterList.Length > 0
		&& (!PlayerReplicationInfo.bAdmin || ONSPlusPlayerReplicationInfo(PlayerReplicationinfo).bFilterAdmins))
	{
		for (i=0; i<ONSPlusPlayerReplicationInfo(PlayerReplicationInfo).WordFilterList.Length; ++i)
		{
			iTempInt = InStr(Caps(S), Caps(ONSPlusPlayerReplicationInfo(PlayerReplicationInfo).WordFilterList[i].Word));

			if (iTempInt != -1 && ONSPlusPlayerReplicationInfo(PlayerReplicationInfo).WordFilterList[i].Word != "")
			{
				S = Left(S, iTempInt)$ONSPlusPlayerReplicationInfo(PlayerReplicationInfo).WordFilterList[i].Replacement
					$Mid(S, iTempInt + Len(ONSPlusPlayerReplicationInfo(PlayerReplicationInfo).WordFilterList[i].Word));

				//ONSPlusPlayerReplicationInfo(PlayerReplicationInfo).HitWord(ONSPlusPlayerReplicationInfo(PlayerReplicationInfo).WordFilterList[i].HitCount);
				ONSPlusPlayerReplicationInfo(PlayerReplicationInfo).HitWord(i);

				// Repeat the same check in case the same word is in the list more than once
				i--;
			}
		}
	}

	ChangeName(S);
	UpdateURL("Name", S, true);
	SaveConfig();
}

exec function Say(string Msg)
{
	local int i, iTempInt;
	local string sTempStr;

	Msg = Left(Msg, 128);


	if (PlayerReplicationInfo != none && ONSPlusPlayerReplicationInfo(PlayerReplicationInfo) != none
		&& ONSPlusPlayerReplicationInfo(PlayerReplicationInfo).WordFilterList.Length > 0
		&& (!PlayerReplicationInfo.bAdmin || ONSPlusPlayerReplicationInfo(PlayerReplicationinfo).bFilterAdmins))
	{
		sTempStr = Msg;

		for (i=0; i<ONSPlusPlayerReplicationInfo(PlayerReplicationInfo).WordFilterList.Length; ++i)
		{
			iTempInt = InStr(Caps(sTempStr), Caps(ONSPlusPlayerReplicationInfo(PlayerReplicationInfo).WordFilterList[i].Word));

			if (iTempInt != -1 && ONSPlusPlayerReplicationInfo(PlayerReplicationInfo).WordFilterList[i].Word != "")
			{
				sTempStr = Left(sTempStr, iTempInt)$ONSPlusPlayerReplicationInfo(PlayerReplicationInfo).WordFilterList[i].Replacement
					$Mid(sTempStr, iTempInt + Len(ONSPlusPlayerReplicationInfo(PlayerReplicationInfo).WordFilterList[i].Word));

				//ONSPlusPlayerReplicationInfo(PlayerReplicationInfo).HitWord(ONSPlusPlayerReplicationInfo(PlayerReplicationInfo).WordFilterList[i].HitCount);
				ONSPlusPlayerReplicationInfo(PlayerReplicationInfo).HitWord(i);

				// Repeat the same check in case the same word is in the list more than once
				i--;
			}
		}

		if (ONSPlusPlayerReplicationInfo(PlayerReplicationInfo).bFilterSentWords)
			Msg = sTempStr;

	}

	if (AllowTextMessage(Msg))
		ServerSay(Msg);
}

exec function TeamSay(string Msg)
{
	local int i, iTempInt;
	local string sTempStr;

	Msg = Left(Msg, 128);


	if (PlayerReplicationInfo != none && ONSPlusPlayerReplicationInfo(PlayerReplicationInfo) != none
		&& ONSPlusPlayerReplicationInfo(PlayerReplicationInfo).WordFilterList.Length > 0
		&& (!PlayerReplicationInfo.bAdmin || ONSPlusPlayerReplicationInfo(PlayerReplicationinfo).bFilterAdmins))
	{
		sTempStr = Msg;

		for (i=0; i<ONSPlusPlayerReplicationInfo(PlayerReplicationInfo).WordFilterList.Length; ++i)
		{
			iTempInt = InStr(Caps(sTempStr), Caps(ONSPlusPlayerReplicationInfo(PlayerReplicationInfo).WordFilterList[i].Word));

			if (iTempInt != -1 && ONSPlusPlayerReplicationInfo(PlayerReplicationInfo).WordFilterList[i].Word != "")
			{
				sTempStr = Left(sTempStr, iTempInt)$ONSPlusPlayerReplicationInfo(PlayerReplicationInfo).WordFilterList[i].Replacement
					$Mid(sTempStr, iTempInt + Len(ONSPlusPlayerReplicationInfo(PlayerReplicationInfo).WordFilterList[i].Word));

				//ONSPlusPlayerReplicationInfo(PlayerReplicationInfo).HitWord(ONSPlusPlayerReplicationInfo(PlayerReplicationInfo).WordFilterList[i].HitCount);
				ONSPlusPlayerReplicationInfo(PlayerReplicationInfo).HitWord(i);

				// Repeat the same check in case the same word is in the list more than once
				i--;
			}
		}

		if (ONSPlusPlayerReplicationInfo(PlayerReplicationInfo).bFilterSentWords)
			Msg = sTempStr;

	}

	if (AllowTextMessage(Msg))
		ServerTeamSay(Msg);
}

// Filters received words
function TeamMessage(PlayerReplicationInfo PRI, coerce string S, name Type)
{
	local int i, iTempInt;

	if (Level.NetMode == NM_DedicatedServer || GameReplicationInfo == None)
		return;

	if (PRI != none && PlayerReplicationInfo != none && ONSPlusPlayerReplicationInfo(PlayerReplicationInfo) != none
		&& !ONSPlusPlayerReplicationInfo(PlayerReplicationInfo).bFilterSentWords && ONSPlusPlayerReplicationInfo(PlayerReplicationInfo).WordFilterList.Length > 0
		&& (!PRI.bAdmin || ONSPlusPlayerReplicationInfo(PlayerReplicationinfo).bFilterAdmins))
	{
		for (i=0; i<ONSPlusPlayerReplicationInfo(PlayerReplicationInfo).WordFilterList.Length; ++i)
		{
			iTempInt = InStr(Caps(S), Caps(ONSPlusPlayerReplicationInfo(PlayerReplicationInfo).WordFilterList[i].Word));

			if (iTempInt != -1 && ONSPlusPlayerReplicationInfo(PlayerReplicationInfo).WordFilterList[i].Word != "")
			{
				S = Left(S, iTempInt)$ONSPlusPlayerReplicationInfo(PlayerReplicationInfo).WordFilterList[i].Replacement
					$Mid(S, iTempInt + Len(ONSPlusPlayerReplicationInfo(PlayerReplicationInfo).WordFilterList[i].Word));

				// Repeat the same check in case the same word is in the list more than once
				i--;
			}
		}
	}
	

	Super.TeamMessage(PRI, S, Type);
}

// Keep this in for a while, until a few months after the swear filter has had a chance to be thoroughly playtested
/*
exec function TestList()
{
	local int i;

	for (i=0; i<ONSPlusPlayerReplicationInfo(PlayerReplicationInfo).WordFilterList.Length; ++i)
		Log("Word is:"@ONSPlusPlayerReplicationInfo(PlayerReplicationInfo).WordFilterList[i].Word
			$", Replacement is:"@ONSPlusPlayerReplicationInfo(PlayerReplicationInfo).WordFilterList[i].Replacement
			$", HitCount is:"@ONSPlusPlayerReplicationInfo(PlayerReplicationInfo).WordFilterList[i].HitCount);
}
*/

function ServerShortTimeout()
{
	if (bSSTOKicked)
		return;

	if (Level.TimeSeconds - SSTOTimestamp < 60.0)
	{
		++SSTOCalls;

		// I haven't seen this called more than 10 times in a minute before (in fact, not more than twice in an entire game)
		if (SSTOCalls > 10)
		{
			++SSTOCritical;
			SSTOCalls = 0;

			Log(PlayerReplicationInfo.PlayerName@"reached SSTOCritical"@SSTOCritical@"time(s), GUID is:"@GetPlayerIDHash()@",IP is:"@GetPlayerNetworkAddress());

			// Perhaps auto-ban the player?
			if (SSTOCritical > 5)
			{
				bSSTOKicked = True;
				Log(PlayerReplicationInfo.PlayerName@"reached SSTO kick limit, GUID is:"@GetPlayerIDHash()@",IP is:"@GetPlayerNetworkAddress());
				Destroy();
			}
		}
	}
	else
	{
		SSTOTimestamp = Level.TimeSeconds;
		SSTOCalls = 0;
	}

	Super.ServerShortTimeout();
}

// Accessed none fixes
function ServerUpdateStats(TeamPlayerReplicationInfo PRI)
{
	if (PRI == none)
		return;

	ClientSendStats(PRI, PRI.GoalsScored, PRI.bFirstBlood, PRI.kills, PRI.suicides, PRI.FlagTouches, PRI.FlagReturns, PRI.FlakCount, PRI.ComboCount, PRI.HeadCount, PRI.RanOverCount, PRI.DaredevilPoints);
}

function ServerUpdateStatArrays(TeamPlayerReplicationInfo PRI)
{
	if (PRI == none)
		return;

	ClientSendSprees(PRI, PRI.Spree[0], PRI.Spree[1], PRI.Spree[2], PRI.Spree[3], PRI.Spree[4], PRI.Spree[5]);
	ClientSendMultiKills(PRI, PRI.MultiKills[0], PRI.MultiKills[1], PRI.MultiKills[2], PRI.MultiKills[3], PRI.MultiKills[4], PRI.MultiKills[5], PRI.MultiKills[6]);
	ClientSendCombos(PRI, PRI.Combos[0], PRI.Combos[1], PRI.Combos[2], PRI.Combos[3], PRI.Combos[4]);
}

function ServerGetNextVehicleStats(TeamPlayerReplicationInfo PRI, int i)
{
	if (PRI == none || i >= PRI.VehicleStatsArray.Length)
		return;

	ClientSendVehicle(PRI, PRI.VehicleStatsArray[i].VehicleClass, PRI.VehicleStatsArray[i].Kills, PRI.VehicleStatsArray[i].Deaths, PRI.VehicleStatsArray[i].DeathsDriving, i);
}

function ServerGetNextWeaponStats(TeamPlayerReplicationInfo PRI, int i)
{
	if (PRI == none)
		return;

	if (i >= PRI.WeaponStatsArray.Length)
	{
		ServerGetNextVehicleStats(PRI, 0);
		return;
	}

	ClientSendWeapon(PRI, PRI.WeaponStatsArray[i].WeaponClass, PRI.WeaponStatsArray[i].kills, PRI.WeaponStatsArray[i].deaths, PRI.WeaponStatsArray[i].deathsholding, i);
}

function ServerThrowWeapon()
{
	local Vector TossVel;

	if (Pawn != none && Pawn.CanThrowWeapon())
	{
		TossVel = Vector(GetViewRotation());
		TossVel = TossVel * ((Pawn.Velocity Dot TossVel) + 500) + Vect(0,0,250);
		Pawn.TossWeapon(TossVel);
		ClientSwitchToBestWeapon();
	}
}

function ServerViewNextPlayer()
{
	bTempSpec = True;

	Super.ServerViewNextPlayer();

	bTempSpec = False;
}

function ServerViewPlayer(int PlayerID)
{
	local Controller C, Found;
	local bool bRealSpec, bWasSpec;
	local TeamInfo RealTeam;

	if (!IsInState('Spectating'))
		return;

	bTempSpec = True;
	bRealSpec = PlayerReplicationInfo.bOnlySpectator;
	bWasSpec = !bBehindView && ViewTarget != Pawn && ViewTarget != self;
	PlayerReplicationInfo.bOnlySpectator = True;
	RealTeam = PlayerReplicationInfo.Team;

	// Find and view the specified player
	for (c=Level.ControllerList; C!=None; C=C.NextController)
	{
		if (C.PlayerReplicationInfo != none && C.PlayerReplicationInfo.PlayerID == PlayerID)
		{
			if (bRealSpec)
				PlayerReplicationInfo.Team = C.PlayerReplicationInfo.Team;

			if (Level.Game.CanSpectate(self, bRealSpec, C))
				Found = C;

			break;
		}
	}

	PlayerReplicationInfo.Team = RealTeam;

	if (Found != None)
	{
		SetViewTarget(Found);
		ClientSetViewTarget(Found);
	}

	if (ViewTarget == self || bWasSpec)
		bBehindView = false;
	else
		bBehindView = true;

	ClientSetBehindView(bBehindView);
	PlayerReplicationInfo.bOnlySpectator = bRealSpec;
	bTempSpec = False;
}

function BecomeActivePlayer()
{
	if (!PlayerReplicationInfo.bOnlySpectator || bTempSpec)
		return;

	if (Level.TimeSeconds - SwitchTimeStamp < 60.0)
	{
		if (SwitchCount > 10)
			return;

		SwitchCount++;
	}
	else
	{
		SwitchCount = 0;
		SwitchTimeStamp = Level.TimeSeconds;
	}

	Super.BecomeActivePlayer();
}

function BecomeSpectator()
{
	if (PlayerReplicationInfo.bOnlySpectator)
		return;

	if (Level.TimeSeconds - SwitchTimeStamp < 60.0)
	{
		if (SwitchCount > 10)
			return;

		SwitchCount++;
	}
	else
	{
		SwitchCount = 0;
		SwitchTimeStamp = Level.TimeSeconds;
	}

	Super.BecomeSpectator();
}

function ServerChangeTeam(int N)
{
	if (GameReplicationInfo != none && ONSPlusGameReplicationInfo(GameReplicationInfo).bDisablePreMatchTeamSwitch && !GameReplicationInfo.bMatchHasBegun)
		return;

	if (Level.TimeSeconds - SwitchTimeStamp < 60.0)
	{
		if (SwitchCount > 10)
			return;

		SwitchCount++;
	}
	else
	{
		SwitchCount = 0;
		SwitchTimeStamp = Level.TimeSeconds;
	}

	Super.ServerChangeTeam(N);
}

function ServerGetWeaponStats(Weapon W)
{
	if (Pawn == None || Pawn.Weapon == None)
		return;

	if (W != None)
		W.StartDebugging();

	Pawn.Weapon.StartDebugging();
}

function ServerRequestRules()
{
	local GameInfo.ServerResponseLine Response;
	local int i;

	if (Level.Pauser == None && Level.TimeSeconds - LastRulesRequestTime < 3.0)
		return;

	LastRulesRequestTime = Level.TimeSeconds;
	Level.Game.GetServerDetails(Response);
	ClientReceiveRule("");

	for (i=0; i<Response.ServerInfo.Length; ++i)
		ClientReceiveRule(Response.ServerInfo[i].Key$"="$Response.ServerInfo[i].Value);
}

// Accessed none fix (happens very rarely)
function EndZoom()
{
	if (DesiredFOV != DefaultFOV && myHUD != none)
		myHUD.FadeZoom();

	bZooming = false;
	DesiredFOV = DefaultFOV;
}

// Only allow this to be called four times over the course of two seconds
function ServerUse()
{
	if (Level.TimeSeconds - SUTimeStamp < 2.0)
	{
		if (SUCalls >= 4)
			return;

		SUCalls++;
	}
	else
	{
		SUTimeStamp = Level.TimeSeconds;
		SUCalls = 0;
	}


	Super.ServerUse();
}

// Attempted fix for the frozen-spec bug
state RoundEnded
{
ignores SeePlayer, HearNoise, KilledBy, NotifyBump, HitWall, NotifyHeadVolumeChange, NotifyPhysicsVolumeChange, Falling, TakeDamage, Suicide;

	function BeginState()
	{
		local Pawn P;

		EndZoom();
		CameraDist = Default.CameraDist;
		FOVAngle = DesiredFOV;
		bFire = 0;
		bAltFire = 0;

		if (Pawn != None)
		{
			if (Vehicle(Pawn) != None)
				Pawn.StopWeaponFiring();

			Pawn.TurnOff();
			Pawn.bSpecialHUD = false;
			Pawn.SimAnim.AnimRate = 0;

			if (Pawn.Weapon != None)
			{
				Pawn.Weapon.StopFire(0);
				Pawn.Weapon.StopFire(1);
				Pawn.Weapon.bEndOfRound = true;
			}
		}


		// Shambler: Here is the attempted fix
		if (PlayerReplicationInfo == none || !PlayerReplicationInfo.bOnlySpectator)
			bFrozen = true;

		bBehindView = true;

		if (!bFixedCamera)
			FindGoodView();

		SetTimer(5, false);


		ForEach DynamicActors(class'Pawn', P)
		{
			if (P.Role == ROLE_Authority)
				P.RemoteRole = ROLE_DumbProxy;

			P.TurnOff();
		}


		StopForceFeedback();
	}
}
/*
state PlayerWalking
{
ignores SeePlayer, HearNoise;

	function bool NotifyLanded(vector HitNormal)
	{
		DodgeCount = 0;

		Log("DoubleClickDir is:"@GetEnum(Enum'eDoubleClickDir', DoubleClickDir), 'ONSPlus');

		if (Role == ROLE_Authority && xPawn(Pawn) != none && DoubleClickDir == DCLICK_Active)
			LastLandTime = Level.TimeSeconds;


		return Super.NotifyLanded(HitNormal);
	}

	function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot)
	{
		if (DoubleClickMove == DCLICK_Active && Pawn.Physics == PHYS_Falling)
		{
			DoubleClickDir = DCLICK_Active;
		}
		else if (DoubleClickMove != DCLICK_None && DoubleClickMove < DCLICK_Active)
		{
			Log("ProcessMove, DoubleClickMove:"@GetEnum(Enum'eDoubleClickDir', DoubleClickMove)$", Pre-DoubleClickDir:"@GetEnum(Enum'eDoubleClickDir', DoubleClickDir), 'ONSPlus');

			if (UnrealPawn(Pawn).Dodge(DoubleClickMove))
			{
				DoubleClickDir = DCLICK_Active;
				DodgeCount++;

				if (Role == ROLE_Authority && LastLandTime != 0.0)
					Log("Land-to-Dodge diff is:"@(Level.TimeSeconds-LastLandTime), 'ONSPlus');

				if (Role == ROLE_Authority && DodgeCount > 2)
					Log("Dodge count:"@DodgeCount, 'ONSPlus');
			}
		}

		Super(PlayerController).ProcessMove(DeltaTime, NewAccel, DoubleClickMove, DeltaRot);
	}
}
*/
// Attempted fix to stop the HUD sometimes showing the health of just one core
function ServerSendCoreTeams()
{
	local ONSOnslaughtGame GI;

	GI = ONSOnslaughtGame(level.game);

	if (GI != none && GI.PowerCores.Length > 1 && GI.PowerCores[0] != none && GI.PowerCores[1] != none)
		ClientReceiveCoreTeams(GI.PowerCores[GI.FinalCore[0]], GI.PowerCores[GI.FinalCore[1]]);
}

function ClientReceiveCoreTeams(ONSPowerCore CoreIndex0, ONSPowerCore CoreIndex1)
{
	CoreIndex0.DefenderTeamIndex = 0;
	CoreIndex1.DefenderTeamIndex = 1;
}

exec function DebugSpec()
{
	Log("***** ONSPLUS SPEC DEBUG START", 'ONSPlusDebug');
	Log("Current state is:"@GetStateName()@", bOnlySpectator is:"@PlayerReplicationInfo.bOnlySpectator, 'ONSPlusDebug');
	Log("***** ONSPLUS SPEC DEBUG END", 'ONSPlusDebug');
}

/*
function ServerUse()
{
	local Actor A;
	local Vehicle DrivenVehicle, EntryVehicle, V;

	if (Role < ROLE_Authority)
		return;

	if (Level.Pauser == PlayerReplicationInfo)
	{
		SetPause(false);
		return;
	}

	if (Pawn == None || !Pawn.bCanUse)
		return;

	DrivenVehicle = Vehicle(Pawn);

	if(DrivenVehicle != None)
	{
		DrivenVehicle.KDriverLeave(false);
		return;
	}

	// Check for nearby vehicles
	foreach Pawn.VisibleCollidingActors(class'Vehicle', V, VehicleCheckRadius)
	{
		// Found a vehicle within radius
		EntryVehicle = V.FindEntryVehicle(Pawn);

		if (EntryVehicle != None && EntryVehicle.TryToDrive(Pawn))
			return;
	}

	// Send the 'DoUse' event to each actor player is touching.
	foreach Pawn.TouchingActors(class'Actor', A)
		A.UsedBy(Pawn);

	if (Pawn.Base != None)
		Pawn.Base.UsedBy(Pawn);
}*/