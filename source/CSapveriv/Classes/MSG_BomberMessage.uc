//-----------------------------------------------------------
//
//-----------------------------------------------------------
class MSG_BomberMessage extends CriticalEventPlus;

var(Message) localized string NukeBombReady;
var(Message) localized string NukeBombNotReady;

var color RedColor;
var color GreenColor;

static simulated function ClientReceive(
	PlayerController P,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	//yet another tutorial hack
	if (P.bViewingMatineeCinematic)
		return;

	Super.ClientReceive(P, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);
}

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	switch (Switch)
	{
		case 0:
			return Default.NukeBombReady;
			break;

		case 1:
			return Default.NukeBombNotReady;
			break;
	}
	return "";
}

static function color GetColor(
    optional int Switch,
    optional PlayerReplicationInfo RelatedPRI_1,
    optional PlayerReplicationInfo RelatedPRI_2
    )
{
	if (Switch == 1 )
		return Default.RedColor;
	else if (Switch == 0)
		return Default.GreenColor;

}

static function GetPos(int Switch, out EDrawPivot OutDrawPivot, out EStackMode OutStackMode, out float OutPosX, out float OutPosY)
{
	Super.GetPos(Switch, OutDrawPivot, OutStackMode, OutPosX, OutPosY);
	if (Switch == 12)
		OutPosY = 0.75;
	else if (Switch == 29)
		OutPosY = 0.90;
	else if (Switch == 30)
		OutPosY = 0.30;
}

static function float GetLifeTime(int Switch)
{
	if (Switch == 0)
		return 1.0;

    if (Switch == 1)
		return 1.0;
	return default.LifeTime;
}

static function bool IsConsoleMessage(int Switch)
{
 	if (Switch < 5 || (Switch > 12 && Switch < 18) || (Switch > 19 && Switch < 24 && Switch != 22) || Switch > 25)
 		return true;

 	return false;
}

defaultproperties
{
     NukeBombReady="Nuclear Missile Ready!"
     NukeBombNotReady="Loading Nuclear Missile"
     RedColor=(R=255,A=255)
     GreenColor=(G=255,A=255)
     bIsUnique=False
     bIsPartiallyUnique=True
     Lifetime=2
     StackMode=SM_Down
     PosY=0.100000
}
