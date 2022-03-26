// ONSPlus: Coded by Shambler (Shambler__@Hotmail.com or Shambler@OldUnreal.com , ICQ:108730864)
Class ONSPlusLoginMenuVCTF extends UT2k4PlayerLoginMenu;

function AddPanels()
{
	Panels[0].ClassName = string(Class'ONSPlusTab_PlayerLoginControls');//"ONSPlus.ONSPlusTab_PlayerLoginControls";

	Super.AddPanels();
}