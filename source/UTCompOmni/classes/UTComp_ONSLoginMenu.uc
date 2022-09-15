Class UTComp_ONSLoginMenu extends UT2k4OnslaughtLoginMenu;

function InitComponent(GUIController MyController, GUIComponent MyComponent)
{
	// Moved from defaultproperties so I can easily recompile the package with a different packagename
	OnslaughtMapPanel.ClassName = string(Class'UTComp_TabOnslaughtMap');

	Super.InitComponent(MyController, MyComponent);
}

function AddPanels()
{
	Panels.Insert(0,1);
	Panels[0] = OnslaughtMapPanel;
	//Panels[1].ClassName = string(Class'ONSPlusTab_PlayerLoginControls');//"ONSPlus.ONSPlusTab_PlayerLoginControls";
    Panels[1].ClassName = "GUI2K4.UT2K4Tab_PlayerLoginControlsOnslaught";

	Super(UT2k4PlayerLoginMenu).AddPanels();
}

defaultProperties
{
	OnslaughtMapPanel=(/*ClassName="ONSPlus.ONSPlusTab_OnslaughtMap",*/Caption="Map",Hint="Map of the area")
}