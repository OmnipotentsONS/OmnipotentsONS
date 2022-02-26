//-----------------------------------------------------------
//Replaces the Goliath with the MirageTank
//-----------------------------------------------------------
class MutMirageTankV3Omni extends Mutator;



function bool CheckReplacement( Actor Other, out byte bSuperRelevant )
{
	if ( ONSVehicleFactory(Other) != None )
	{
		if ( ONSVehicleFactory(Other).VehicleClass == class'Onslaught.ONSHoverTank' )
		{
			ONSVehicleFactory(Other).VehicleClass = class'MirageTankV3Omni.MirageTankV3Omni';
		}
		else
			return true;
	}
	else
		return true;
}

defaultproperties
{
     FriendlyName="Mirage Panzer 3.0 Replaces Goliath"
     Description="Replaces the Goliath with the Mirage Panzer 3.0"
}
