class MutPallasInsteadOfLeviathan extends Mutator;


function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	if (SVehicleFactory(Other) != None 
     && (class<ONSMobileAssaultStation>(SVehicleFactory(Other).VehicleClass) != None 
     || SVehicleFactory(Other).VehicleClass != None && SVehicleFactory(Other).VehicleClass.Name == 'CSPallasVehicle'))
     {
		SVehicleFactory(Other).VehicleClass = class'CSPallasVehicle';
     }
	
	return true;
}

defaultproperties
{
     bAddToServerPackages=True
     FriendlyName="Pallas instead of Leviathan"
     Description="Replaces the Leviathan (and its various variants) with the Pallas (V2)"
}
