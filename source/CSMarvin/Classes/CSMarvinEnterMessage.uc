class CSMarvinEnterMessage extends CriticalEventPlus;

var(Message) localized string DeployMessageString;
var(Message) localized string LaserMessageString;
var(Message) localized string PortalGunMessageString;

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
			return Default.DeployMessageString;
          break;
       
     case 1:      
     		 return default.LaserMessageString;
         break;  
     case 2:      
     	    return default.PortalGunMessageString;
     	    break;
     
     default:
          return Default.DeployMessageString;
          break;
    }

// should never get called but jic
    return default.DeployMessageString;
}

defaultproperties
{
     DeployMessageString="1: TwistyLasers/AbuctionBeam 2: Portal Gun"
     LaserMessageString="TwistyLasers/AbductionBeam Active";
     PortalGunMessageString= "Portal Gun Active...";
}
