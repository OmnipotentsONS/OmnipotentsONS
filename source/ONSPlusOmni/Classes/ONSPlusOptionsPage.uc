// ONSPlus: Coded by Shambler (Shambler__@Hotmail.com or Shambler@OldUnreal.com , ICQ:108730864)
Class ONSPlusOptionsPage extends FloatingWindow;

var automated GUITabControl MainTab;

var automated moCheckBox ch_AllowBeaconDisplay, ch_AllowExitSelection, ch_AllowEnhancedRadar;
var automated ONSPlusEditKeyBox kb_BeaconDisplayKey, kb_PreferredExitToggle;

var automated GUILabel l_ExitSideHeader;
var automated ONSPlusEditKeyBox kb_ExitSelLeft, kb_ExitSelRight, kb_ExitSelFront, kb_ExitSelBack, kb_ClearExit;

var automated GUIButton b_ONSPlusServerRules;

function InitComponent(GUIController MyController, GUIComponent MyComponent)
{
	Super.InitComponent(MyController, MyComponent);

	WindowName="ONS Plus";

	t_WindowTitle.SetCaption(WindowName);
}

function Closed(GUIComponent Sender, bool bCancelled)
{
	Super.Closed(Sender, bCancelled);

	if (!bCancelled)
		SaveSettings();
}

function SaveSettings()
{
	PlayerOwner().SaveConfig();
	ONSPlusxPlayer(PlayerOwner()).OPSaveConfig();
}

function InternalOnLoadINI(GUIComponent Sender, string s)
{
	if (Sender == ch_AllowBeaconDisplay)
		ch_AllowBeaconDisplay.SetComponentValue(!ONSPlusxPlayer(PlayerOwner()).bDisableExitPointDisplay);
	else if (Sender == ch_AllowExitSelection)
		ch_AllowExitSelection.SetComponentValue(!ONSPlusxPlayer(PlayerOwner()).bDisableSelectableExits);
	else if (Sender == ch_AllowEnhancedRadar)
		ch_AllowEnhancedRadar.SetComponentValue(!ONSPlusxPlayer(PlayerOwner()).bDisableEnhancedRadarMap);
	else
		GUIMenuOption(Sender).SetComponentValue(s, true);
}

function InternalOnChange(GUIComponent Sender)
{
	if (Sender == ch_AllowBeaconDisplay)
	{
		ONSPlusxPlayer(PlayerOwner()).bDisableExitPointDisplay = !ch_AllowBeaconDisplay.IsChecked();
	}
	else if (Sender == ch_AllowExitSelection)
	{
		ONSPlusxPlayer(PlayerOwner()).bDisableSelectableExits = !ch_AllowExitSelection.Ischecked();

		if (!ch_AllowExitSelection.IsChecked())
			ONSPlusxPlayer(PlayerOwner()).EmptyExitSelections();
	}
	else if (Sender == ch_AllowEnhancedRadar)
	{
		ONSPlusxPlayer(PlayerOwner()).bDisableEnhancedRadarMap = !ch_AllowEnhancedRadar.IsChecked();
	}

	ONSPlusxPlayer(PlayerOwner()).OPSaveConfig();
}

function bool ButtonClicked(GUIComponent Sender)
{
	local PlayerController PC;

	PC = PlayerOwner();

	if (Sender == b_ONSPlusServerRules)
		Controller.OpenMenu(/*"ONSPlus.ONSPlusRulesPage"*/ string(Class'ONSPlusRulesPage'));
	else
		return False;

	return True;
}

defaultproperties
{
	Begin Object Class=moCheckBox Name=AllowExitSelection
		WinWidth=0.550000
		WinHeight=0.040000
		WinLeft=0.0450000
		WinTop=0.100000
		Caption="Selectable exits"
		Hint="Enable selectable exits in ONSPlus"
		OnLoadINI=InternalOnLoadIni
		IniOption="@Internal"
		IniDefault="False"
		CaptionWidth=0.940000
		bSquare=True
		ComponentJustification=TXTA_Left
		TabOrder=21
		OnChange=InternalOnChange
	End Object
	ch_AllowExitSelection=AllowExitSelection

	Begin Object Class=moCheckBox Name=AllowBeaconDisplay
		WinWidth=0.550000
		WinHeight=0.040000
		WinLeft=0.0450000
		WinTop=0.150000
		Caption="Allow glowing exits"
		Hint="Enable glowing exit points on your vehicle"
		OnLoadINI=InternalOnLoadIni
		IniOption="@Internal"
		IniDefault="False"
		CaptionWidth=0.940000
		bSquare=True
		ComponentJustification=TXTA_Left
		TabOrder=22
		OnChange=InternalOnChange
	End Object
	ch_AllowBeaconDisplay=AllowBeaconDisplay


	Begin Object Class=ONSPlusEditKeyBox Name=DisplayAllBeacons
		WinWidth=0.550000
		WinHeight=0.040000
		WinLeft=0.045000
		WinTop=0.200000
		ComponentWidth=0.710000
		KeyCommand="DisplayExitPoints"
		Caption="Beacon Toggle Key  "
		Hint="The key which toggles showing of all vehicle beacons"
		CaptionWidth=0.940000
		ComponentJustification=TXTA_Left
		TabOrder=23
	End Object
	kb_BeaconDisplayKey=DisplayAllBeacons


	Begin Object Class=ONSPlusEditKeyBox Name=PreferredExitToggle
		WinWidth=0.550000
		WinHeight=0.040000
		WinLeft=0.045000
		WinTop=0.250000
		ComponentWidth=0.710000
		KeyCommand="TogglePreferredExit"
		Caption="Exit Toggle Key    "
		Hint="The key which switches through the vehicle exits, the selected exit is your preferred exit"
		CaptionWidth=0.940000
		ComponentJustification=TXTA_Left
		TabOrder=24
	End Object
	kb_PreferredExitToggle=PreferredExitToggle


	Begin Object Class=GUILabel Name=ExitSideHeaderLabel
		WinWidth=0.620000
		WinHeight=0.040000
		WinLeft=0.045000
		WinTop=0.325000
		Caption="Exit Side Selection Keys"
		Hint="The keys which set your preferred exit point for the specified direction"
		TabOrder=25
		FontScale=FNS_Small
		StyleName="DarkTextLabel"
	End Object
	l_ExitSideHeader=ExitSideHeaderLabel

	Begin Object Class=ONSPlusEditKeyBox Name=ExitSideLeft
		WinWidth=0.550000
		WinHeight=0.040000
		WinLeft=0.245000
		WinTop=0.375000
		ComponentWidth=0.710000
		KeyCommand="SetPreferredExit Left 1"
		Caption="Left"
		Hint="The key which sets your preferred exit to the left side of vehicle"
		CaptionWidth=0.577000
		ComponentJustification=TXTA_Left
		TabOrder=26
	End Object
	kb_ExitSelLeft=ExitSideLeft

	Begin Object Class=ONSPlusEditKeyBox Name=ExitSideRight
		WinWidth=0.550000
		WinHeight=0.040000
		WinLeft=0.245000
		WinTop=0.425000
		ComponentWidth=0.710000
		KeyCommand="SetPreferredExit Right 1"
		Caption="Right"
		Hint="The key which sets your preferred exit to the right side of vehicle"
		CaptionWidth=0.577000
		ComponentJustification=TXTA_Left
		TabOrder=27
	End Object
	kb_ExitSelRight=ExitSideRight

	Begin Object Class=ONSPlusEditKeyBox Name=ExitSideFront
		WinWidth=0.550000
		WinHeight=0.040000
		WinLeft=0.245000
		WinTop=0.475000
		ComponentWidth=0.710000
		KeyCommand="SetPreferredExit Forward 1"
		Caption="Front"
		Hint="The key which sets your preferred exit to the front side of vehicle"
		CaptionWidth=0.577000
		ComponentJustification=TXTA_Left
		TabOrder=28
	End Object
	kb_ExitSelFront=ExitSideFront

	Begin Object Class=ONSPlusEditKeyBox Name=ExitSideBack
		WinWidth=0.550000
		WinHeight=0.040000
		WinLeft=0.245000
		WinTop=0.525000
		ComponentWidth=0.710000
		KeyCommand="SetPreferredExit Back 1"
		Caption="Back"
		Hint="The key which sets your preferred exit to the back side of vehicle"
		CaptionWidth=0.577000
		ComponentJustification=TXTA_Left
		TabOrder=29
	End Object
	kb_ExitSelBack=ExitSideBack


	Begin Object Class=ONSPlusEditKeyBox Name=ClearPreferredExit
		WinWidth=0.550000
		WinHeight=0.040000
		WinLeft=0.045000
		WinTop=0.597500
		ComponentWidth=0.710000
		KeyCommand="EmptyExitSelections"
		Caption="Clear exits key"
		Hint="The key which will erase your currently preferred exits"
		CaptionWidth=0.940000
		ComponentJustification=TXTA_Left
		TabOrder=30
	End Object
	kb_ClearExit=ClearPreferredExit

	Begin Object Class=moCheckBox Name=AllowEnhancedRadarMap
		WinWidth=0.550000
		WinHeight=0.040000
		WinLeft=0.045000
		WinTop=0.792500
		Caption="Enhanced Radar"
		Hint="Enable the enhanced radar on the menu which shows (and lets you select) available vehicle spawns"
		OnLoadINI=InternalOnLoadIni
		IniOption="@Internal"
		IniDefault="False"
		CaptionWidth=0.940000
		bSquare=True
		ComponentJustification=TXTA_Left
		TabOrder=33
		OnChange=InternalOnChange
	End Object
	ch_AllowEnhancedRadar=AllowEnhancedRadarMap

	Begin Object Class=GUIButton Name=ONSPlusServerRules
		WinWidth=0.200000
		WinHeight=0.050000
		WinLeft=0.045000
		WinTop=0.050000
		Caption="ONSPlus Rules"
		Hint="The serverside configuration of the ONSPlus options"
		StyleName="SquareButton"
		bAutoSize=True
		TabOrder=34
		OnClick=ButtonClicked
	End Object
	b_ONSPlusServerRules=ONSPlusServerRules


	DefaultWidth=0.250000
	DefaultHeight=0.300000
	DefaultLeft=0.110313
	DefaultTop=0.057916
	WinWidth=0.500000
	WinHeight=0.600000
	WinLeft=0.110313
	WinTop=0.057916

	bRenderWorld=true
	bAllowedAsLast=true
	bCaptureInput=true
	bResizeWidthAllowed=False
	bResizeHeightAllowed=False
}