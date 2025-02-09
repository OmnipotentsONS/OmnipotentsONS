class CSMarvinPoisonedMessage extends LocalMessage;

var localized string PoisonedMessage;

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
    return Default.PoisonedMessage;
}

defaultproperties
{
    PoisonedMessage="Poisoned!!!"
    bIsUnique=True
    bFadeMessage=True
    DrawColor=(B=0,G=0)
    StackMode=SM_Down
    PosY=0.242000
    FontSize=1
}