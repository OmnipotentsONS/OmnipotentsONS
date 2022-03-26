// ONSPlus: Coded by Shambler (Shambler__@Hotmail.com or Shambler@OldUnreal.com , ICQ:108730864)
Class ONSPlusEditKeyBox extends moEditBox;

var() string KeyCommand;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	ComponentClassName = string(Class'ONSPlusGUIEditKeyBox');

	Super.InitComponent(MyController, MyOwner);

	ONSPlusGUIEditKeyBox(MyComponent).KeyCommand = KeyCommand;
	MyComponent.OnClick = ONSPlusGUIEditKeyBox(MyComponent).InternalOnClick;
	ONSPlusGUIEditKeyBox(MyComponent).InternalActivate();
}

/*
defaultproperties
{
	ComponentClassName="ONSPlus.ONSPlusGUIEditKeyBox"
}
*/