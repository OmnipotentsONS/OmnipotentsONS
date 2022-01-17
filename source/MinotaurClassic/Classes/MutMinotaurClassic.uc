class MutMinotaurClassic extends Mutator;

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
     VehicleClass=Class'MinotaurClassic.MinotaurClassic'
     ReplacedVehicleClass=Class'Onslaught.ONSHoverTank'
     GroupName="VehicleArena"
     FriendlyName="MinotaurClassic"
     Description="Replace the Goliath with the Classic Minotaur. "
}
