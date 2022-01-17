class OnFireMessage extends LocalMessage;

var(Messages) localized string IgnitedString, BurningString, ExtinguishedString;

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject 
	)
{
	if(Switch == 0)
		return Default.IgnitedString;
	else if(Switch == 1)
		return Default.BurningString;
	else
		return Default.ExtinguishedString;
}

defaultproperties
{
     IgnitedString="You have been set on fire!"
     BurningString="You are burning nicely."
     ExtinguishedString="You are no longer on fire."
     bIsUnique=True
     bFadeMessage=True
     Lifetime=2
     DrawColor=(B=0,G=0)
     StackMode=SM_Down
     PosY=0.800000
     FontSize=2
}
