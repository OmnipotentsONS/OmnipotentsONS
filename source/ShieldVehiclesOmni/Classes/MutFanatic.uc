class MutFanatic extends Mutator;

var class<SVehicle> VehicleClass, ReplacedVehicleClass;

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	local ONSVehicleFactory F;

	bSuperRelevant = 0;

	if(Other.IsA('ONSVehicleFactory'))
	{
		F = ONSVehicleFactory(Other);

		if(F.VehicleClass == ReplacedVehicleClass)
			F.VehicleClass = VehicleClass;
	}

	return true;
}

defaultproperties
{
     VehicleClass=Class'ShieldVehiclesOmni.Fanatic'
     ReplacedVehicleClass=Class'Onslaught.ONSRV'
     GroupName="VehicleArena"
     FriendlyName="Fanatic"
     Description="Replace the Paladin with the Fanatic"
}
