// ONSPlus: Coded by Shambler (Shambler__@Hotmail.com or Shambler@OldUnreal.com , ICQ:108730864)
Class ONSPlusTab_PlayerLoginControls extends UT2k4Tab_PlayerLoginControlsOnslaught;

var automated GUIButton b_ONSPlusOptions;

function bool ButtonClicked(GUIComponent Sender)
{
	local PlayerController PC;

	PC = PlayerOwner();

	if (GUITabControl(MenuOwner) != None && GUITabControl(MenuOwner).TabStack.Length > 0 && GUITabControl(MenuOwner).TabStack[0] != None
		&& GUITabControl(MenuOwner).TabStack[0].MyPanel != None)
	{
		if (Sender == b_ONSPlusOptions)
			Controller.OpenMenu(/*"ONSPlus.ONSPlusOptionsPage"*/ string(Class'ONSPlusOptionsPage'));
		else
			return Super.ButtonClicked(Sender);
	}
	else
	{
		return False;
	}

	return True;
}


// Added "Spectate player" option to right-click context menu
function bool ContextMenuOpened(GUIContextMenu Menu)
{
	local GUIList List;
	local PlayerReplicationInfo PRI;
	local byte Restriction;
	local GameReplicationInfo GRI;
	local int PlayerID;

	GRI = GetGRI();

	if (GRI == None)
		return false;

	List = GUIList(Controller.ActiveControl);

	if (List == None)
	{
		Log(Name@"ContextMenuOpened active control was not a list - active:"$Controller.ActiveControl.Name);
		return False;
	}

	if (!List.IsValid())
		return False;

	PlayerID = int(List.GetExtra());
	PRI = GRI.FindPlayerByID(PlayerID);

	if (PRI == None || PRI.bBot || PlayerIDIsMine(PlayerID))
		return False;

	Restriction = PlayerOwner().ChatManager.GetPlayerRestriction(PlayerID);

	if (bool(Restriction & 1))
		Menu.ContextItems[0] = ContextItems[0];
	else
		Menu.ContextItems[0] = DefaultItems[0];

	if (bool(Restriction & 2))
		Menu.ContextItems[1] = ContextItems[1];
	else
		Menu.ContextItems[1] = DefaultItems[1];

	if (bool(Restriction & 4))
		Menu.ContextItems[2] = ContextItems[2];
	else
		Menu.ContextItems[2] = DefaultItems[2];

	if (bool(Restriction & 8))
		Menu.ContextItems[3] = ContextItems[3];
	else
		Menu.ContextItems[3] = DefaultItems[3];

	Menu.ContextItems[4] = "-";
	Menu.ContextItems[5] = "Spectate Player";
	Menu.ContextItems[6] = BuddyText;

	if (PlayerOwner().PlayerReplicationInfo.bAdmin)
	{
		Menu.ContextItems[7] = "-";
		Menu.ContextItems[8] = KickPlayer$"["$List.Get()$"]";
		Menu.ContextItems[9] = BanPlayer$"["$List.Get()$"]";
	}
	else if (Menu.ContextItems.Length > 7)
	{
		Menu.ContextItems.Remove(7, Menu.ContextItems.Length - 7);
	}

	return True;
}

function ContextClick(GUIContextMenu Menu, int ClickIndex)
{
	local bool bUndo;
	local byte Type;
	local GUIList List;
	local PlayerController PC;
	local PlayerReplicationInfo PRI;
	local GameReplicationInfo GRI;
	local int PlayerID;

	GRI = GetGRI();

	if (GRI == None)
		return;

	PC = PlayerOwner();
	bUndo = Menu.ContextItems[ClickIndex] == ContextItems[ClickIndex];
	List = GUIList(Controller.ActiveControl);

	if (List == None)
		return;

	PlayerID = int(List.GetExtra());
	PRI = GRI.FindPlayerById(PlayerID);

	if (PRI == None)
		return;

	if (ClickIndex > 6)	// Admin stuff
	{
		switch (ClickIndex)
		{
			case 7:
			case 8:
				PC.AdminCommand("admin kick"@List.GetExtra());
				break;

			case 9:
				PC.AdminCommand("admin kickban"@List.GetExtra());
				break;
		}

		return;
	}

	if (ClickIndex > 3)
	{
		switch (ClickIndex)
		{
			case 5:
				if (!PC.PlayerReplicationInfo.bOnlySpectator)
					PC.BecomeSpectator();

				if (ONSPlusxPlayer(PC) != none)
					ONSPlusxPlayer(PC).ServerViewPlayer(PlayerID);

				break;
			case 6:
				Controller.AddBuddy(List.Get());
				break;
			case 4:
		}

		return;
	}

	Type = 1 << ClickIndex;

	if (bUndo)
	{
		if (PC.ChatManager.ClearRestrictionID(PRI.PlayerID, Type))
		{
			PC.ServerChatRestriction(PRI.PlayerID, PC.ChatManager.GetPlayerRestriction(PRI.PlayerID));
			ModifiedChatRestriction(Self, PRI.PlayerID);
		}
	}
	else
	{
		if (PC.ChatManager.AddRestrictionID(PRI.PlayerID, Type))
		{
			PC.ServerChatRestriction(PRI.PlayerID, PC.ChatManager.GetPlayerRestriction(PRI.PlayerID));
			ModifiedChatRestriction(Self, PRI.PlayerID);
		}
	}
}


defaultproperties
{
	Begin Object Class=GUIButton Name=ONSPlusButton
		Caption="ONSPlus"
		Hint="Configure settings for ONSPlus"
		StyleName="SquareButton"
		OnClick=ButtonClicked
		WinWidth=0.200000
		WinHeight=0.050000
		WinLeft=0.112345
		WinTop=0.825000
		bAutoSize=True
		TabOrder=14
	End Object
	b_ONSPlusOptions=ONSPlusButton
}