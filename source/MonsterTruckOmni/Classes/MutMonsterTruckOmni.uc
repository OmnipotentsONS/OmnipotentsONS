//-----------------------------------------------------------
//Replaces the Hellbender with the Monster Truck II
//-----------------------------------------------------------
class MutMonsterTruckOmni extends Mutator;


function bool CheckReplacement( Actor Other, out byte bSuperRelevant )
{
	if ( ONSVehicleFactory(Other) != None )
	{
		if ( ONSVehicleFactory(Other).VehicleClass == class'Onslaught.ONSPRV' )
		{
			ONSVehicleFactory(Other).VehicleClass = class'MonsterTruckOmni.MonsterTruckIIOmni';
		}
		else
			return true;
	}
	else
		return true;
}

defaultproperties
{
     FriendlyName="MonsterTruck II Omni Replaces Hellbender"
     Description="Replaces the Hellbender with the MonsterTruck II Omni"
}
