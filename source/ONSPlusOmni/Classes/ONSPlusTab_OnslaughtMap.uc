// ONSPlus: Coded by Shambler (Shambler__@Hotmail.com or Shambler@OldUnreal.com , ICQ:108730864)
Class ONSPlusTab_OnslaughtMap extends UT2k4Tab_OnslaughtMap;

var actor SelectedSpawn;
var float LastVInfoUpdate;

// Why make it so difficult to change the colour of a font...*grumbles*
function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	MyController.RegisterStyle(class'ONSPlusSTY_GUI_SYS_IS_SHIT');

	Super.InitComponent(MyController, MyOwner);
}

function bool InternalOnPreDraw(Canvas C)
{
	local ONSPlusHUD ONSHUD;
	local actor TempSelectedSpawn;

	ONSHUD = ONSPlusHUD(PlayerOwner().myHud);

	TempSelectedSpawn = ONSHud.LocateSpawnArea(Controller.MouseX - OnslaughtMapCenterX + 3.5, Controller.MouseY - OnslaughtMapCenterY + 3.5, OnslaughtMapRadius);

	if (TempSelectedSpawn == none || (ONSPowerCore(TempSelectedSpawn) != none
		&& (ONSPowerCore(TempSelectedSpawn).CoreStage == 255 || ONSPowerCore(TempSelectedSpawn).PowerLinks.Length == 0)))
	{
		l_HintText.Caption = "";
		l_HelpText.Caption = "";
		i_HintImage.Image = None;

		l_TeamText.SetVisibility(True);
	}
	else
	{
		l_TeamText.SetVisibility(False);

		if (ONSPowerCore(TempSelectedSpawn) != none)
		{
			if (ONSPowerCore(TempSelectedSpawn).bUnderAttack || (ONSPowerCore(TempSelectedSpawn).CoreStage == 0 && ONSPowerCore(TempSelectedSpawn).bSevered))
			{
				DrawAttackHint();
			}
			else if (PRI != none && TempSelectedSpawn == PRI.StartCore)
			{
				DrawSpawnHint();
			}
			else if (ONSPowerCore(TempSelectedSpawn).bFinalCore)
			{
				if (PlayerOwner() != none && PlayerOwner().PlayerReplicationInfo != none && PlayerOwner().PlayerReplicationInfo.Team != none &&
					ONSPowerCore(TempSelectedSpawn).DefenderTeamIndex == PlayerOwner().PlayerReplicationInfo.Team.TeamIndex)
				{
					DrawCoreHint(True);
				}
				else
				{
					DrawCoreHint(False);
				}
			}
			else
			{
				DrawNodeHint(ONSHUD, ONSPowerCore(TempSelectedSpawn));
			}
		}
		else if (ONSVehicleFactory(TempSelectedSpawn) != none && PRI != none && ONSPlusPlayerReplicationInfo(PRI) != none)
		{
			DrawVehicleFactoryHint(ONSPlusPlayerReplicationInfo(PRI), ONSVehicleFactory(TempSelectedSpawn), ONSHUD);
		}
	}

	return false;
}

function DrawVehicleFactoryHint(ONSPlusPlayerReplicationInfo OPPRI, ONSVehicleFactory Factory, optional ONSPlusHUD OwnerHUD)
{
	local int i;
	local color TempColour;

	for (i=0; i<OPPRI.ClientVSpawnList.Length; i++)
	{
		if (Factory == OPPRI.ClientVSpawnList[i].Factory)
		{
			l_HintText.Caption = "Click to spawn near this vehicle";
			l_HelpText.Caption = OPPRI.ClientVSpawnList[i].VehicleClass.default.VehicleNameString;
			i_HintImage.Image = None;

			if (OwnerHUD != none)
				OwnerHUD.SetVehicleData(OPPRI.ClientVSpawnList[i].VehicleClass, TempColour);

			TempColour.A = 255;

			l_HelpText.Style.FontColors[0] = TempColour;
			l_HelpText.Style.FontColors[1] = TempColour;
			l_HelpText.Style.FontColors[2] = TempColour;
			l_HelpText.Style.FontColors[3] = TempColour;
			l_HelpText.Style.FontColors[4] = TempColour;

			break;
		}
	}
}

function PostDrawHintText(canvas Canvas)
{
	l_HelpText.Style.FontColors[0] = l_HelpText.Style.default.FontColors[0];
	l_HelpText.Style.FontColors[1] = l_HelpText.Style.default.FontColors[1];
	l_HelpText.Style.FontColors[2] = l_HelpText.Style.default.FontColors[2];
	l_HelpText.Style.FontColors[3] = l_HelpText.Style.default.FontColors[3];
	l_HelpText.Style.FontColors[4] = l_HelpText.Style.default.FontColors[4];

	Super.OnRendered(Canvas);
}

// Left Click, Overrides normal spawn selection for clicking nodes
function bool SpawnClick(GUIComponent Sender)
{
	local PlayerController PC;

	if (bInit || PRI == None || ONSPlusPlayerReplicationInfo(PRI) == none || PRI.bOnlySpectator)
		return true;

	PC = PlayerOwner();
	SetSelectedSpawn();

	if (SelectedSpawn == none)
		return True;

	if (bNodeTeleporting)
	{
		if (SelectedSpawn != None)
		{
			Controller.CloseMenu(false);
			ONSPlusPlayerReplicationInfo(PRI).ONSPlusTeleportTo(SelectedSpawn);
		}
	}
	else
	{
		Controller.CloseMenu(false);
		ONSPlusPlayerReplicationInfo(PRI).ONSPlusSetStartCore(SelectedSpawn, true, PC);
	}
}

// Right click
function bool SelectClick(GUIComponent Sender)
{
	local PlayerController PC;

	if (bInit || PRI == None || ONSPlusPlayerReplicationInfo(PRI) == none || PRI.bOnlySpectator)
		return true;

	PC = PlayerOwner();
	SetSelectedSpawn(True);

	if (SelectedSpawn == none || ONSPowerCore(SelectedSpawn) == none)
		return True;

	if (SelectedSpawn == ONSPlusPlayerReplicationInfo(PRI).StartSpawn)
		ONSPlusPlayerReplicationInfo(PRI).ONSPlusSetStartCore(None, false);
	else if (ONSPowerCore(SelectedSpawn) != none)
		ONSPlusPlayerReplicationInfo(PRI).ONSPlusSetStartCore(ONSPowerCore(SelectedSpawn), false);
}

function SetSelectedSpawn(optional bool bPowerCoreOnly)
{
	local actor Spawn;

	if (bPowerCoreOnly)
		Spawn = ONSPlusHUD(PlayerOwner().myHUD).LocatePowerCore(Controller.MouseX - OnslaughtMapCenterX + 3.5, Controller.MouseY - OnslaughtMapCenterY + 3.5, OnslaughtMapRadius);
	else
		Spawn = ONSPlusHUD(PlayerOwner().myHUD).LocateSpawnArea(Controller.MouseX - OnslaughtMapCenterX + 3.5, Controller.MouseY - OnslaughtMapCenterY + 3.5, OnslaughtMapRadius);

	if (ValidSpawnArea(Spawn))
		SelectedSpawn = Spawn;
	else
		SelectedSpawn = None;
}

function bool ValidSpawnArea(actor SpawnArea)
{
	if (SpawnArea == none)
		return false;

	if (ONSVehicleFactory(SpawnArea) != none)
		return true;

	if (ONSPowerCore(SpawnArea) != none && ONSPowerCore(SpawnArea).DefenderTeamIndex == PRI.Team.TeamIndex && ONSPowerCore(SpawnArea).CoreStage == 0
		&& (!ONSPowerCore(SpawnArea).bUnderAttack || ONSPowerCore(SpawnArea).bFinalCore) && ONSPowerCore(SpawnArea).PowerLinks.Length > 0)
		return true;

	return false;
}

function Free()
{
	Super.Free();

	SelectedSpawn = None;
}

function LevelChanged()
{
	Super.LevelChanged();

	SelectedSpawn = None;
}

function bool DrawMap(Canvas C)
{
	local ONSPowerCore Core;
	local ONSPlusHUD ONSHUD;
	local float HS;

	// Request an update of the vehicle info, only happens here (for efficiency)
	if (PlayerOwner().Level.TimeSeconds - LastVInfoUpdate > 3.0)
	{
		LastVInfoUpdate = PlayerOwner().Level.TimeSeconds;

		if (ONSPlusxPlayer(PlayerOwner()) != none && !ONSPlusxPlayer(PlayerOwner()).bDebugFreezeRadar)
			ONSPlusxPlayer(PlayerOwner()).GetVInfoUpdate();
	}

	if (PRI != None)
		Core = PRI.StartCore;

	ONSHUD = ONSPlusHUD(PlayerOwner().myHud);
	HS = ONSHUD.HudScale;
	ONSHUD.HudScale = 1.0;
	ONSHUD.ONSPlusDrawRadarMap(C, OnslaughtMapCenterX, OnslaughtMapCenterY, OnslaughtMapRadius, false, true);
	ONSHUD.HudScale = HS;

	if (Core != None)
		ONSHUD.DrawSpawnIcon(C, Core.HUDLocation, Core.bFinalCore, ONSHUD.IconScale, ONSHUD.HUDScale);

	return true;
}

defaultproperties
{
	Begin Object Class=GUILabel Name=HelpText
		TextAlign=TXTA_Left
		TextColor=(B=255,G=255,R=255)
		Caption=""
		StyleName="DifferentFontColour_Equals_PainInMyAss"
		WinWidth=0.274188
		WinLeft=0.719388
		WinTop=0.035141
		bBoundToParent=false
		bScaleToParent=false
		OnRendered=PostDrawHintText
	End Object
	l_HelpText=HelpText
}