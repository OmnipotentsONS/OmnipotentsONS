class MutBastion extends Mutator;

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
     VehicleClass=Class'ShieldVehiclesOmni.Bastion'
     ReplacedVehicleClass=Class'OnslaughtBP.ONSShockTank'
     GroupName="VehicleArena"
     FriendlyName="Bastion"
     Description="Replace the Paladin with the Bastion"
}
