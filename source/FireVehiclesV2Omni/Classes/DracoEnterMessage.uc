class DracoEnterMessage extends CriticalEventPlus;

var(Message) localized string DeployMessageString;

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
    /* 
	switch (Switch)
	{
		case 0:
			return Default.DeployMessageString;
            break;
        default:
            return Default.DeployMessageString;
            break;
    }

    return "";
    */
        return Default.DeployMessageString;
}

defaultproperties
{
     DeployMessageString="After Alt-Fire Smoke Bomb, Flamethrower takes 3s to recharge"
}
