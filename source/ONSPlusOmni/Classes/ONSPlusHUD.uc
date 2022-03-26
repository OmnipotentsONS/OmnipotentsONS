// ONSPlus: Coded by Shambler (Shambler__@Hotmail.com or Shambler@OldUnreal.com , ICQ:108730864)
Class ONSPlusHUD extends ONSHUDOnslaught
	config(User);

//#exec OBJ LOAD FILE="..\StaticMeshes\ScrTexTestMesh.usx" PACKAGE=ONSPlus

// Turns on/off the small side menu which shows what your team is doing in regards to attack/defence
/*var config bool bShowTeamActionPlan;
var float LastDebugLog;

// Struct for handling action plan drawing
struct OpenNodes
{
	var int NodeIndex; // The node number
	var byte NodeTeam; // The team which owns the node
	var string PlayerObjective; // i.e. 'Attackers' 'Defenders', this is set depending on the team owning the node
	var string AssignedPlayers; // The players on your team who are attacking/defending the specified node
};

var array<OpenNodes> ActionPlanList;*/

struct VehicleDescription
{
	var class VehicleClass;
	var color RadarColour;
};

var array<VehicleDescription> VehicleData;
var color TempColour;

var ONSPlusPlayerReplicationInfo OPPRI;

var array<object> DataHolders;

/*struct BeaconData
{
	var vector PlayerLoc;
	var float FadeMult;
};

var array<BeaconData> BeaconInfo;*/


// Small optimisations
/*simulated function Tick(float DeltaTime)
{
	Super.Tick(DeltaTime);

	if (bShowTeamActionPlan)
		ONSPlusDrawActionPlanTick(DeltaTime);
}*/

// Debug variable
//var bool bOldRadarCode;

struct NodeData
{
	var ONSPowerCore CurNode;
	var bool bDontShowNode;
};

var array<NodeData> NodeDataList;

var float RadarWidth, CenterRadarPosX, CenterRadarPosY;

var float LastCoreCheck;

// Manages the radar data for specific vehicle classes
//
// I have decided to use a 'slightly' complicated system for managing vehicle radar data (that supports custom packages)
// If you can dynamicly load an object named:	PackageName$"VehicleRadarData" (or Left(PackageName, InStr(PackageName, "_")), if your package has _ in the name...use that when
// appending version numbers...horrible I know :/) then you use GetPropertyText to obtain the data:
//	VehicleClass$"RadarColour"	if that fails then default the colour
function SetVehicleData(class<Vehicle> VehicleClass, out color RadarColour)
{
	local int i, j;
	local class CurDataHolderClass;
	local object CurDataHolder;
	local string sTempStr, CurClass, CurPackage, CurColour, CurDataPrefix;

	for (i=0; i<VehicleData.Length; ++i)
	{
		if (VehicleData[i].VehicleClass == VehicleClass)
		{
			RadarColour = VehicleData[i].RadarColour;
			return;
		}
	}

	// If the code reaches here that means the vehicle is not yet listed
	VehicleData.Length = VehicleData.Length + 1;
	i = VehicleData.Length - 1;

	VehicleData[i].VehicleClass = VehicleClass;

	// Get the raw string representation of the package the current vehicle class is located in and the classname of the vehicle
	sTempStr = string(VehicleClass);

	CurClass = GetItemName(sTempStr);

	CurPackage = Left(sTempStr, Len(sTempStr) - 1 - Len(CurClass));


	CurDataHolder = none;

	// Check if the current package already has a dataholder
	for (j=0; j<DataHolders.Length; j++)
	{
		if (Left(GetItemName(string(DataHolders[j].Class)), Len(CurPackage)) ~= CurPackage)
		{
			CurDataHolder = DataHolders[j];
			break;
		}
	}

	// If the current package is not currently in the dataholder list see if there is a dataholder object in that package and if so, add it to the list
	if (CurDataHolder == none)
	{
		j = InStr(CurPackage, "_");

		if (j == -1)
			CurDataPrefix = CurPackage;
		else
			CurDataPrefix = Left(CurPackage, j);

		CurDataHolderClass = Class(DynamicLoadObject(CurPackage$"."$CurDataPrefix$"VehicleRadarData", Class'Class'));

		// If the class exists try to create the data object and if that is created successfully then add it to the list
		if (CurDataHolderClass != none)
		{
			CurDataHolder = new(none, "ONSPlus") CurDataHolderClass;

			if (CurDataHolder != none)
				DataHolders[DataHolders.Length] = CurDataHolder;
		}
	}

	// If this is true then we know that we are dealing with a custom vehicle, default its colour
	if (CurDataHolder == none)
	{
		VehicleData[i].RadarColour.R = 0;
		VehicleData[i].RadarColour.G = 0;
		VehicleData[i].RadarColour.B = 0;

		VehicleName = VehicleClass.default.VehicleNameString;
		RadarColour = VehicleData[i].RadarColour;

		return;
	}

	// If the code reaches this point then we know the DataHolder was created, check if the current vehicle class has an entry in the data holder
	CurColour = CurDataHolder.GetPropertyText(CurClass$"RadarColour");

	// If it does then gather the data and add the data to the list, if not then treat it like a custom vehicle
	if (CurColour != "")
	{
		// If the colour hasn't been entered into the data holder then default it
		if (CurColour != "")
		{
			// A hack for my laziness (actually...upon further thought this is FASTER than any other alternative)
			SetPropertyText("TempColour", CurColour);

			VehicleData[i].RadarColour = TempColour;
		}
		else
		{
			VehicleData[i].RadarColour.R = 0;
			VehicleData[i].RadarColour.G = 0;
			VehicleData[i].RadarColour.B = 0;
		}
	}
	else
	{
		VehicleData[i].RadarColour.R = 0;
		VehicleData[i].RadarColour.G = 0;
		VehicleData[i].RadarColour.B = 0;
	}

	VehicleName = VehicleClass.default.VehicleNameString;
	RadarColour = VehicleData[i].RadarColour;
}

// Handle setting up the required data here (N.B. Perhaps limit this so it only redo's data every 3 or so seconds?)
/*simulated function ONSPlusDrawActionPlanTick(float DeltaTime)
{
	local ONSPowerCore CurCore;
	local int i, j;
	local array<OpenNodes> NewActionPlanList;
	local bool bStartLoop;

	if (PawnOwnerPRI.Team == none)
		return;

	// Clean out the list
	ActionPlanList.Length = 0;

	bStartLoop = True;

	// Iterate all the powernodes and find out which ones are open, add them to the list as you go
	for (CurCore=Node; CurCore!=None; CurCore=CurCore.NextCore)
	{
		if (!bStartLoop && CurCore == Node)
			break;

		bStartLoop = False;

		// Skip unused nodes
		if (((CurCore.CoreStage == 255 || CurCore.PowerLinks.Length == 0) && (PlayerOwner == none || !PlayerOwner.bDemoOwner)) || (!PowerCoreAttackable(CurCore)
			&& CurCore.CoreStage != 5 && CurCore.CoreStage != 2))
			continue;

		// Increase the list length and setup a new entry
		ActionPlanList.Length = ActionPlanList.Length + 1;

		// If CurCore is a powercore then set its index to -1
		if (CurCore.bFinalCore)
			ActionPlanList[ActionPlanList.Length - 1].NodeIndex = -1;
		else
			ActionPlanList[ActionPlanList.Length - 1].NodeIndex = CurCore.NodeNum;

		// Setup the nodes team
		ActionPlanList[ActionPlanList.Length - 1].NodeTeam = CurCore.DefenderTeamIndex;

		// Now setup the objective name (if the node is owned by your own team the active player objective string is 'defenders' etc.)
		if (CurCore.DefenderTeamIndex == PawnOwnerPRI.Team.TeamIndex)
			ActionPlanList[ActionPlanList.Length - 1].PlayerObjective = "Defenders";
		else
			ActionPlanList[ActionPlanList.Length - 1].PlayerObjective = "Attackers";
	}

	// Sort the nodes so that enemy nodes come first and so that they are arranged by number
	for (i=0; i<ActionPlanList.Length; ++i)
	{
		// Check through the current list and sort by number (this loop halts as soon as it finds a suitable space)
		for (j=0; j<NewActionPlanList.Length; ++j)
		{
			// You have reached your own teams node in the new list and the current node in the list is owned by the enemy team, assign the current element and halt
			// OR The current node is OWNED BY THE SAME TEAM and has a HIGHER node number, so it's safe to place it prior to that node and halt
			if ((ActionPlanList[i].NodeTeam != PawnOwnerPRI.Team.TeamIndex && NewActionPlanList[j].NodeTeam != ActionPlanList[i].NodeTeam)
				|| NewActionPlanList[j].NodeIndex > ActionPlanList[i].NodeIndex)
			{
				NewActionPlanList.Insert(j, 1);
				CopyActionPlanElement(NewActionPlanList[j], ActionPlanList[i]);

				break;
			}

			// If you have reached the end of the list, then put the current element in at the end
			if (j == NewActionPlanList.Length - 1)
			{
				NewActionPlanList.Length = NewActionPlanList.Length + 1;
				CopyActionPlanElement(NewActionPlanList[NewActionPlanList.Length - 1], ActionPlanList[i]);

				break;
			}
			
		}

		// If nothing was in the current list then assign the current element to the list
		if (NewActionPlanList.Length == 0)
		{
			NewActionPlanList.Length = NewActionPlanList.Length + 1;
			CopyActionPlanElement(NewActionPlanList[0], ActionPlanList[i]);
		}
	}

	ActionPlanList = NewActionPlanList;


	// Now setup the list of assigned players, iterate the PRI list
	for (i=0; i<PlayerOwner.GameReplicationInfo.PRIArray.Length; ++i)
	{
		// Check that the current player is on your team
		if (ONSPlusPlayerReplicationInfo(PlayerOwner.GameReplicationInfo.PRIArray[i]) == none || PlayerOwner.GameReplicationInfo.PRIArray[i].Team == none
			|| PlayerOwner.GameReplicationInfo.PRIArray[i].Team.TeamIndex != PawnOwnerPRI.Team.TeamIndex)
			continue;

		// Check if the node this player is assigned to is actually open
		for (j=0; j<ActionPlanList.Length; ++j)
		{
			// Improve this code later, so the list looks better
			if (ONSPlusPlayerReplicationInfo(PlayerOwner.GameReplicationInfo.PRIArray[i]).AssignedNode == ActionPlanList[ActionPlanList.Length - 1].NodeIndex)
			{
				if (ActionPlanList[j].AssignedPlayers == "")
					ActionPlanList[j].AssignedPlayers = PlayerOwner.GameReplicationInfo.PRIArray[i].PlayerName;
				else
					ActionPlanList[j].AssignedPlayers = ActionPlanList[j].AssignedPlayers$","@PlayerOwner.GameReplicationInfo.PRIArray[i].PlayerName;

				if (Len(ActionPlanList[j].AssignedPlayers) > 30)
					ActionPlanList[j].AssignedPlayers = Left(ActionPlanList[j].AssignedPlayers, 27)$"...";

				break;
			}
		}
	}
}

simulated function CopyActionPlanElement(out OpenNodes Destination, OpenNodes Location)
{
	Destination.NodeIndex = Location.NodeIndex;
	Destination.NodeTeam = Location.NodeTeam;
	Destination.PlayerObjective = Location.PlayerObjective;
	Destination.AssignedPlayers = Location.AssignedPlayers;
}

// Handle drawing data here
simulated function ONSPlusDrawActionPlan(Canvas C)
{
	local int i;
	local string NodeType;

	if (Level.TimeSeconds - LastDebugLog > 10)
	{
		LastDebugLog = Level.TimeSeconds;

		Log("ACTION PLAN LIST +++START+++");

		// Print out some debug data to the log, just to see the structure of the current code
		for (i=0; i<ActionPlanList.Length; ++i)
		{
			if (ActionPlanList[i].NodeIndex == -1)
				NodeType = "PowerCore";
			else
				NodeType = "Node"@ActionPlanList[i].NodeIndex;

			if (ActionPlanList[i].PlayerObjective != "")
				NodeType = NodeType@"("$ActionPlanList[i].PlayerObjective$")";

			Log(NodeType);
			Log("---"$ActionPlanList[i].AssignedPlayers);
		}

		Log("ACTION PLAN LIST +++END+++");
	}
}*/

/*simulated function Tick(float DeltaTime)
{
	Super.Tick(DeltaTime);

	if (!bOldRadarCode)
		ONSPlusDrawRadarMapTick(CenterRadarPosX, CenterRadarPosY, RadarWidth, false, false);
}

simulated function ONSPlusDrawRadarMapTick(float CenterPosX, float CenterPosY, float RadarWidth, bool bShowDisabledNodes, optional bool bShowSpawnedVehicles)
{
	local ONSPowerCore CurCore;
	local int i;

	if (Node == none)
		return;

	// Iterate the core list and compute + store the data (this should only need to be done once, TODO: Check if disabled nodes need to be here)
	if (NodeDataList.Length == 0)
	{
		CurCore = Node;

		do
		{
			NodeDataList.Length = NodeDataList.Length + 1;


			NodeDataList[NodeDataList.Length - 1].CurNode = CurCore;

			CurCore = CurCore.NextCore;
		}
		until (CurCore == None || CurCore == Node);
	}


	// Setup dynamic node data
	for (i=0; i<NodeDataList.Length; ++i)
	{
		NodeDataList[i].bDontShowNode = !bShowDisabledNodes && (NodeDataList[i].CurNode.CoreStage == 255 || NodeDataList[i].CurNode.PowerLinks.Length == 0)
						&& (PlayerOwner == none || !PlayerOwner.bDemoOwner);

		// TODO: Tweak this
		NodeDataList[i].CurNode.HUDLocation.X = CenterPosX + (NodeDataList[i].CurNode.Location - MapCenter).X * (RadarWidth / RadarRange);
		NodeDataList[i].CurNode.HUDLocation.Y = CenterPosY + (NodeDataList[i].CurNode.Location - MapCenter).Y * (RadarWidth / RadarRange);
	}
}

simulated function ONSPlusDrawRadarMapNew(Canvas C, float CenterPosX, float CenterPosY, float RadarWidth, bool bShowDisabledNodes, optional bool bShowSpawnedVehicles)
{
	local float PlayerIconSize, MapScale;
	local plane SavedModulation;
	local FinalBlend PlayerIcon;
	local vector HUDLocation;
	local byte SavedAlpha;
	local Actor A;
	local int i;

	SavedModulation = C.ColorModulate;

	C.ColorModulate.X = 1;
	C.ColorModulate.Y = 1;
	C.ColorModulate.Z = 1;
	C.ColorModulate.W = 1;

	// Make sure the canvas style is alpha
	C.Style = ERenderStyle.STY_Alpha;

	if (PawnOwner != none)
	{
		MapCenter.X = 0.0;
		MapCenter.Y = 0.0;
	}
	else
	{
		MapCenter = vect(0,0,0);
	}


	// Draw the radar map background (greatly simplified Epic code)
	if (Level.RadarMapImage != none)
	{
		SavedAlpha = C.DrawColor.A;

		C.DrawColor = default.WhiteColor;
		C.DrawColor.A = RadarTrans;

		C.SetPos(CenterPosX - RadarWidth, CenterPosY - RadarWidth);
		C.DrawTile(Level.RadarMapImage, RadarWidth * 2.0, RadarWidth * 2.0, 0, 0, Level.RadarMapImage.MaterialUSize(), Level.RadarMapImage.MaterialUSize());

		C.DrawColor.A = SavedAlpha;
	}


	// Setup some values (TODO: Move this to a relevant part of this function, where these variables are first used)
	PlayerIconSize = IconScale * 24 * C.ClipX * HUDScale/1600;
	MapScale = RadarWidth / RadarRange;
	C.Font = GetConsoleFont(C);


	// Draw the health bar (TODO: Dissect the DrawHealthBar function and tweak this)
	for (i=0; i<NodeDataList.Length; ++i)
		if (NodeDataList[i].CurNode.HasHealthBar())
			DrawHealthBar(C, NodeDataList[i].CurNode, NodeDataList[i].CurNode.Health, NodeDataList[i].CurNode.DamageCapacity, HealthBarPosition);


	// Draw node links (TODO: Dissect the PowerLink.Render function and tweak this)
	for (i=0; i<PowerLinks.Length; ++i)
		PowerLinks[i].Render(C, ColorPercent, bShowDisabledNodes);


	// Draw node data (TODO: Dissect and tweak)
	for (i=0; i<NodeDataList.Length; ++i)
	{
		if (NodeDataList[i].bDontShowNode)
			continue;

		C.DrawColor = LinkColor[NodeDataList[i].CurNode.DefenderTeamIndex];

		if (NodeDataList[i].CurNode.bUnderAttack || (NodeDataList[i].CurNode.CoreStage == 0 && NodeDataList[i].CurNode.bSevered))
			DrawAttackIcon(C, NodeDataList[i].CurNode, NodeDataList[i].CurNode.HUDLocation, IconScale, HUDScale, ColorPercent);


		if (NodeDataList[i].CurNode.bFinalCore)
			DrawCoreIcon(C, NodeDataList[i].CurNode.HUDLocation, PowerCoreAttackable(NodeDataList[i].CurNode), IconScale, HUDScale, ColorPercent);
		else
			DrawNodeIcon(C, NodeDataList[i].CurNode.HUDLocation, PowerCoreAttackable(NodeDataList[i].CurNode), NodeDataList[i].CurNode.CoreStage, IconScale, HUDScale, ColorPercent);
	}


	// Draw node numbers (TODO: Dissect and tweak)
	for (i=0; i<NodeDataList.Length; ++i)
		if (!NodeDataList[i].bDontShowNode && !NodeDataList[i].CurNode.bFinalCore)
			DrawNodeLabel(C, NodeDataList[i].CurNode.HUDLocation, IconScale, HUDScale, C.DrawColor, NodeDataList[i].CurNode.NodeNum);


	// N.B. Skipped vehicle radar code for now


	// Draw PlayerIcon (TODO: Tweak all code past here)
	if (PawnOwner != None)
		A = PawnOwner;
	else if (PlayerOwner.IsInState('Spectating'))
		A = PlayerOwner;
	else if (PlayerOwner.Pawn != None)
		A = PlayerOwner.Pawn;

	if (A != None)
	{
		PlayerIcon = FinalBlend'CurrentPlayerIconFinal';
		TexRotator(PlayerIcon.Material).Rotation.Yaw = -A.Rotation.Yaw - 16384;
		HUDLocation = A.Location - MapCenter;

		if (HUDLocation.X < (RadarRange * 0.95) && HUDLocation.Y < (RadarRange * 0.95))
		{
			C.SetPos(CenterPosX + HUDLocation.X * MapScale - PlayerIconSize * 0.5, CenterPosY + HUDLocation.Y * MapScale - PlayerIconSize * 0.5);

			C.DrawColor = C.MakeColor(40,255,40);
			C.DrawTile(PlayerIcon, PlayerIconSize, PlayerIconSize, 0, 0, 64, 64);
		}
	}

	// Draw Border
	C.DrawColor = C.MakeColor(200,200,200);
	C.SetPos(CenterPosX - RadarWidth, CenterPosY - RadarWidth);
	C.DrawTile(BorderMat, RadarWidth * 2.0, RadarWidth * 2.0, 0, 0, 256, 256);

	C.ColorModulate = SavedModulation;
}*/

/*simulated function ONSPlusDrawScriptedRadar(ScriptedTexture Tex)
{
	local float RadarWidth;

	RadarWidth = 0.5 * RadarScale * HUDScale;
}*/

simulated function ONSPlusDrawRadarMap(Canvas C, float CenterPosX, float CenterPosY, float RadarWidth, bool bShowDisabledNodes, optional bool bShowSpawnedVehicles)
{
	local float PawnIconSize, PlayerIconSize, CoreIconSize, MapScale;
	local vector HUDLocation;
	local FinalBlend PlayerIcon;
	local Actor A;
	local ONSPowerCore CurCore;
	local int i;
	local plane SavedModulation;

	// A slightly messy fix for when cores are given the wrong team number
	if (Level.TimeSeconds - LastCoreCheck > 10.0 && FinalCore[0] != none && FinalCore[1] != none)
	{
		if (FinalCore[0].DefenderTeamIndex == FinalCore[1].DefenderTeamIndex)
			ONSPlusxPlayer(PlayerOwner).ServerSendCoreTeams();

		LastCoreCheck = Level.TimeSeconds;
	}


	SavedModulation = C.ColorModulate;

	C.ColorModulate.X = 1;
	C.ColorModulate.Y = 1;
	C.ColorModulate.Z = 1;
	C.ColorModulate.W = 1;

	// Make sure that the canvas style is alpha
	C.Style = ERenderStyle.STY_Alpha;

	if (PawnOwner != None)
	{
		MapCenter.X = 0.0;
		MapCenter.Y = 0.0;
	}
	else
	{
		MapCenter = vect(0,0,0);
	}

	HUDLocation.X = RadarWidth;
	HUDLocation.Y = RadarRange;
	HUDLocation.Z = RadarTrans;

	DrawMapImage(C, Level.RadarMapImage, CenterPosX, CenterPosY, MapCenter.X, MapCenter.Y, HUDLocation);

	if (Node == None)
		return;

	// ===== moved

	CoreIconSize = IconScale * 16 * C.ClipX * HUDScale/1600;
	PawnIconSize = CoreIconSize * 0.5;
	PlayerIconSize = CoreIconSize * 1.5;

	MapScale = RadarWidth / RadarRange;
	C.Font = GetConsoleFont(C);
	// ===== end moved

	CurCore = Node;

	do
	{
		if (CurCore.HasHealthBar())
			DrawHealthBar(C, CurCore, CurCore.Health, CurCore.DamageCapacity, HealthBarPosition);

		// Moved update HUD location code
		CurCore.HUDLocation.X = CenterPosX + (CurCore.Location - MapCenter).X * (RadarWidth / RadarRange);
		CurCore.HUDLocation.Y = CenterPosY + (CurCore.Location - MapCenter).Y * (RadarWidth / RadarRange);

		CurCore = CurCore.NextCore;
	} until (CurCore == None || CurCore == Node);

	for (i=0; i<PowerLinks.Length; i++)
		PowerLinks[i].Render(C, ColorPercent, bShowDisabledNodes);

	CurCore = Node;

	do
	{
		// hide unused powernodes
		if (!bShowDisabledNodes && (CurCore.CoreStage == 255 || CurCore.PowerLinks.Length == 0) && (PlayerOwner == none || !PlayerOwner.bDemoOwner))
		{
			CurCore = CurCore.NextCore;
			continue;
		}

		C.DrawColor = LinkColor[CurCore.DefenderTeamIndex];

		// Draw appropriate icon to represent the current state of this node
		if (CurCore.bUnderAttack || (CurCore.CoreStage == 0 && CurCore.bSevered))
			DrawAttackIcon(C, CurCore, CurCore.HUDLocation, IconScale, HUDScale, ColorPercent);

		if (CurCore.bFinalCore)
			DrawCoreIcon(C, CurCore.HUDLocation, PowerCoreAttackable(CurCore), IconScale, HUDScale, ColorPercent);
		else
			DrawNodeIcon(C, CurCore.HUDLocation, PowerCoreAttackable(CurCore), CurCore.CoreStage, IconScale, HUDScale, ColorPercent);

		CurCore = CurCore.NextCore;

	} until (CurCore == None || CurCore == Node);


	// Draw border (moved so numbers are always drawn on top
	C.DrawColor = C.MakeColor(200,200,200);
	C.SetPos(CenterPosX - RadarWidth, CenterPosY - RadarWidth);
	C.DrawTile(BorderMat, RadarWidth * 2.0, RadarWidth * 2.0, 0, 0, 256, 256);


	// Tweak, this makes sure the node number is drawn last, so maps like Maelstrom don't have overlapping icon problem (could use some tweaking for speed?)
	CurCore = Node;

	do
	{
		if (!bShowDisabledNodes && (CurCore.CoreStage == 255 || CurCore.PowerLinks.Length == 0) && (PlayerOwner == none || !PlayerOwner.bDemoOwner))
		{
			CurCore = CurCore.NextCore;
			continue;
		}

		if (!CurCore.bFinalCore)
			DrawNodeLabel(C, CurCore.HUDLocation, IconScale, HUDScale, C.DrawColor, CurCore.NodeNum);

		CurCore = CurCore.NextCore;
	} until (CurCore == none || CurCore == Node);


	if (OPPRI == none && PlayerOwner != none && PlayerOwner.PlayerReplicationInfo != none && ONSPlusPlayerReplicationInfo(PlayerOwner.PlayerReplicationInfo) != none)
		OPPRI = ONSPlusPlayerReplicationInfo(PlayerOwner.PlayerReplicationInfo);

	// System for displaying spawned vehicles
	if (bShowSpawnedVehicles && OPPRI != none && (ONSPlusxPlayer(PlayerOwner) == none || !ONSPlusxPlayer(PlayerOwner).bDisableEnhancedRadarMap))
	{
		for (i=0; i<OPPRI.ClientVSpawnList.Length; i++)
		{
			if (OPPRI.ClientVSpawnList[i].CurFactoryTeam == PlayerOwner.GetTeamNum() && OPPRI.ClientVSpawnList[i].bSpawned)
			{
				HUDLocation = OPPRI.ClientVSpawnList[i].Factory.Location - MapCenter;

				SetVehicleData(OPPRI.ClientVSpawnList[i].VehicleClass, C.DrawColor);
				C.DrawColor.A = 255;

				C.SetPos(CenterPosX + (HUDLocation.X * MapScale) - (PlayerIconSize * 0.25), CenterPosY + (HUDLocation.Y * MapScale) - (PlayerIconSize * 0.25));
				C.DrawTile(Material'NewHUDIcons', PlayerIconSize * 0.25, PlayerIconSize * 0.25, 0, 0, 32, 32);
			}
		}
	}

	// Draw PlayerIcon
	if (PawnOwner != None)
		A = PawnOwner;
	else if (PlayerOwner.IsInState('Spectating'))
		A = PlayerOwner;
	else if (PlayerOwner.Pawn != None)
		A = PlayerOwner.Pawn;

	if (A != None)
	{
		PlayerIcon = FinalBlend'CurrentPlayerIconFinal';
		TexRotator(PlayerIcon.Material).Rotation.Yaw = -A.Rotation.Yaw - 16384;
		HUDLocation = A.Location - MapCenter;

		if (HUDLocation.X < (RadarRange * 0.95) && HUDLocation.Y < (RadarRange * 0.95))
		{
			C.SetPos(CenterPosX + HUDLocation.X * MapScale - PlayerIconSize * 0.5, CenterPosY + HUDLocation.Y * MapScale - PlayerIconSize * 0.5);

			C.DrawColor = C.MakeColor(40,255,40);
			C.DrawTile(PlayerIcon, PlayerIconSize, PlayerIconSize, 0, 0, 64, 64);
		}
	}

	// Draw Border *moved*
	/*C.DrawColor = C.MakeColor(200,200,200);
	C.SetPos(CenterPosX - RadarWidth, CenterPosY - RadarWidth);
	C.DrawTile(BorderMat, RadarWidth * 2.0, RadarWidth * 2.0, 0, 0, 256, 256);*/

	C.ColorModulate = SavedModulation;
}

// Modified 'LocatePowerCore' function that accounts for vehicle spawns
simulated function Actor LocateSpawnArea(float PosX, float PosY, float RadarWidth)
{
	local float WorldToMapScaleFactor, Distance, LowestDistance;
	local vector WorldLocation, DistanceVector;
	local ONSPowerCore Core;
	local int i;
	local actor BestSpawnArea;

	if (Node == none)
		return None;

	WorldToMapScaleFactor = RadarRange / RadarWidth;

	WorldLocation.X = PosX * WorldToMapScaleFactor;
	WorldLocation.Y = PosY * WorldToMapScaleFactor;

	LowestDistance = 2500.0;


	// Search for nearest powercore
	Core = Node;

	do
	{
		DistanceVector = Core.Location - WorldLocation;
		DistanceVector.Z = 0;
		Distance = VSize(DistanceVector);

		if (Distance < LowestDistance)
		{
			BestSpawnArea = Core;
			LowestDistance = Distance;
		}

		Core = Core.NextCore;
	} until (Core == None || Core == Node);


	if (PlayerOwner == none || ONSPlusxPlayer(PlayerOwner) == none || ONSPlusxPlayer(PlayerOwner).bDisableEnhancedRadarMap)
		return BestSpawnArea;

	// If the lowest distance hasn't changed then set it to a half of the original size so that vehicle factory selection area is smaller
	LowestDistance = 1250;

	if (OPPRI == none && PlayerOwner != none && PlayerOwner.PlayerReplicationInfo != none && ONSPlusPlayerReplicationInfo(PlayerOwner.PlayerReplicationInfo) != none)
		OPPRI = ONSPlusPlayerReplicationInfo(PlayerOwner.PlayerReplicationInfo);

	// See if there is a vehiclespawn even closer-by (note: this will also account for team-based selections)
	for (i=0; i<OPPRI.ClientVSpawnList.Length; i++)
	{
		if (OPPRI.ClientVSpawnList[i].CurFactoryTeam == PlayerOwner.GetTeamNum() && OPPRI.ClientVSpawnList[i].bSpawned)
		{
			DistanceVector = OPPRI.ClientVSpawnList[i].Factory.Location - WorldLocation;
			DistanceVector.Z = 0;
			Distance = VSize(DistanceVector);

			if (Distance < LowestDistance)
			{
				BestSpawnArea = OPPRI.ClientVSpawnList[i].Factory;
				LowestDistance = Distance;
			}
		}
	}

	return BestSpawnArea;
}

simulated function ShowTeamScorePassC(Canvas C)
{
	//local float RadarWidth, CenterRadarPosX, CenterRadarPosY;

	if (Level.bShowRadarMap && !bMapDisabled)
	{
		RadarWidth = 0.5 * RadarScale * HUDScale * C.ClipX;
		CenterRadarPosX = (RadarPosX * C.ClipX) - RadarWidth;
		CenterRadarPosY = (RadarPosY * C.ClipY) + RadarWidth;

		//if (bOldRadarCode)
			ONSPlusDrawRadarMap(C, CenterRadarPosX, CenterRadarPosY, RadarWidth, false, false);
		//else
		//	ONSPlusDrawRadarMapNew(C, CenterRadarPosX, CenterRadarPosY, RadarWidth, false, false);
	}
}

// Added to fix some spectating problems
// NOTE: For some reason this works fine with Mantas and Scorps, but not with Raptors and Goliaths
/*
simulated function LinkActors()
{
	local bool bSetPOPRI;

	PlayerOwner = PlayerController(Owner);

	if (PlayerOwner == None)
	{
		PlayerConsole = None;
		PawnOwner = None;
		PawnOwnerPRI = None;
		return;
	}

	if (PlayerOwner.Player != None)
		PlayerConsole = PlayerOwner.Player.Console;
	else
		PlayerConsole = None;

	if (Pawn(PlayerOwner.ViewTarget) != None && Pawn(PlayerOwner.ViewTarget).Health > 0)
	{
		PawnOwner = Pawn(PlayerOwner.ViewTarget);

		// Shambler: Fix for vehicle spectating
		if (PawnOwner.DrivenVehicle != none)
		{
			if (PawnOwner.PlayerReplicationInfo != None)
				PawnOwnerPRI = PawnOwner.PlayerReplicationInfo;
			else
				PawnOwnerPRI = PlayerOwner.PlayerReplicationInfo;

			bSetPOPRI = true;

			PawnOwner = PawnOwner.DrivenVehicle;
		}
	}
	else if (PlayerOwner.Pawn != None)
	{
		PawnOwner = PlayerOwner.Pawn;
	}
	else
	{
		PawnOwner = None;
	}


	if (!bSetPOPRI)
	{
		if (PawnOwner != None && PawnOwner.PlayerReplicationInfo != None)
			PawnOwnerPRI = PawnOwner.PlayerReplicationInfo;
		else
			PawnOwnerPRI = PlayerOwner.PlayerReplicationInfo;
	}
}
*/

// debug command to figure out what happens with the HUD only showing health of one core
exec function CheckCoreHealth()
{
	Log("***** Core Health Check", 'ONSPlusDebug');

	if (FinalCore[0] == none)
		Log("Core 0 is not set", 'ONSPlusDebug');

	if (FinalCore[1] == none)
		Log("Core 1 is not set", 'ONSPlusDebug');

	if (FinalCore[0] != none && FinalCore[1] != none)
		Log("Core 0's DefenderTeamIndex is"@FinalCore[0].DefenderTeamIndex@", Core 1's DefenderTeamIndex is"@FinalCore[1].DefenderTeamIndex, 'ONSPlusDebug');
}

/*defaultproperties
{
	bShowTeamActionPlan=True
}*/

/*defaultproperties
{
	bOldRadarCode=True
}*/