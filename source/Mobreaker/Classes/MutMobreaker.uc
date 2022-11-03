class MutMobreaker extends Mutator;

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
     VehicleClass=Class'Mobreaker.ONSMobreaker'
     ReplacedVehicleClass=Class'Onslaught.ONSHoverTank'
     GroupName="VehicleArena"
     FriendlyName="Mobreaker"
     Description="Replace the Goliath Tank with the Mobreaker Tank."
}
