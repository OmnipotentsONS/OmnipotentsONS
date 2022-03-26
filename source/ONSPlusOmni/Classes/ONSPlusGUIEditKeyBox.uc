// ONSPlus: Coded by Shambler (Shambler__@Hotmail.com or Shambler@OldUnreal.com , ICQ:108730864)
Class ONSPlusGUIEditKeyBox extends GUIEditBox;

var bool bPendingRawInput;
var string KeyCommand;

event SetText(string NewText);
function DeleteChar();

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super(GUIButton).InitComponent(MyController, MyOwner);
}

// Grab current binding and assign here or assign it as 'None' if there isn't a set key
function InternalActivate()
{
	CaretPos = -1;

	TextStr = PlayerOwner().ConsoleCommand("BindingToKey"@"\""$KeyCommand$"\"");

	if (TextStr == "")
		TextStr = "None";

	LastCaret = -1;
}

function InternalDeactivate()
{
	CaretPos = -1;
	LastCaret = -1;
	bAllSelected = False;
	bPendingRawInput = False;

	if (Controller != none)
	{
		Controller.OnNeedRawKeyPress = none;
		Controller.Master.bRequireRawJoystick = false;
	}
}

function bool InternalOnKeyType(out byte Key, optional string Unicode)
{
	if (bPendingRawInput)
		return True;

	return False;
}

function bool InternalOnKeyEvent(out byte Key, out byte State, float delta)
{
	if (bReadOnly || State != 3)
		return false;

	return false;
}

function bool InternalOnClick(GUIComponent Sender)
{
	BeginRawInput(None);

	return false;
}

function bool BeginRawInput(GUIComponent Sender)
{
	local int i;
	local string sTempStr;

	bPendingRawInput = true;

	for (i=0; i<16; i++)
	{
		sTempStr = PlayerOwner().ConsoleCommand("BindingToKey"@"\""$KeyCommand$"\"");

		if (sTempStr != "")
			PlayerOwner().ConsoleCommand("Set Input"@sTempStr);
		else
			break;
	}

	Controller.OnNeedRawKeyPress = RawKey;
	Controller.Master.bRequireRawJoystick = true;
	TextStr = "";

	PlayerOwner().ClientPlaySound(Controller.EditSound);
	PlayerOwner().ConsoleCommand("toggleime 0");

	return true;
}

function bool RawKey(byte NewKey)
{
	bPendingRawInput = false;
	Controller.OnNeedRawKeyPress = none;
	Controller.Master.bRequireRawJoystick = false;

	PlayerOwner().ClientPlaySound(Controller.ClickSound);

	if (EInputKey(NewKey) == IK_Escape)
	{
		TextStr = "None";
		return true;
	}

	TextStr = Mid(string(GetEnum(Enum'EInputKey', NewKey)), 3);
	PlayerOwner().ConsoleCommand("Set Input"@TextStr@KeyCommand);

	return true;
}