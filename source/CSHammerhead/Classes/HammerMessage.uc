class HammerMessage extends LocalMessage;

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject 
	)
{
	if(Switch == 0)
		return "Artillery";
	else if(Switch == 1)
		return "Miniguns";
	else
		return "";
}

defaultproperties
{
     bIsUnique=True
     bFadeMessage=True
     Lifetime=2
     StackMode=SM_Down
     PosY=0.800000
     FontSize=2
}
