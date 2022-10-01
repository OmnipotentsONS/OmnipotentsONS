//-----------------------------------------------------------
//	Human Viper Speedboat
//	Colt Wohlers (aka CMan)
//	Beta 4.0 (July 2/2004)
//-----------------------------------------------------------
//Replaces the manta with the HumanViper
//-----------------------------------------------------------
class HumanViperMut extends Mutator;

function bool CheckReplacement( Actor Other, out byte bSuperRelevant )
{
	if ( ONSVehicleFactory(Other) != None )
	{
		if ( ONSVehicleFactory(Other).VehicleClass == class'Onslaught.ONSHoverBike' )
		{
			ONSVehicleFactory(Other).VehicleClass = class'KopholusV2Omni.HumanViper';
		}
		else
			return true;
	}
	else
		return true;
}

defaultproperties
{
     FriendlyName="Human Viper"
     Description="Replaces the manta with the Human Viper"
}
