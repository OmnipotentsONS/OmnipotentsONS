class CSTrickboardEnterMessage extends CriticalEventPlus;

var(Message) localized string DeployMessageString;

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
    return Default.DeployMessageString;
}

defaultproperties
{
     DeployMessageString="Fire for Grapple Beam"
}
