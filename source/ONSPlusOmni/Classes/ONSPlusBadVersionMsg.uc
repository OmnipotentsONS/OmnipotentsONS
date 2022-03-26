// ONSPlus: Coded by Shambler (Shambler__@Hotmail.com or Shambler@OldUnreal.com , ICQ:108730864)
Class ONSPlusBadVersionMsg extends UT2k4NetworkStatusMsg;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.InitComponent(Mycontroller, MyOwner);

	b_Cancel.SetVisibility(true);
	b_Cancel.Caption = "Download";
}

function bool InternalOnClick(GUIComponent Sender)
{
	if (Sender == b_OK)
	{
		Controller.CloseMenu(false);
		return true;
	}

	if (Sender == b_Cancel)
	{
		Controller.LaunchURL("http://downloads.unrealadmin.org/UT2004/Patches/");
		return true;
	}

	return false;
}

defaultproperties
{
	WindowName="Incompatable Patch Version"
	bAllowedAsLast=True
}