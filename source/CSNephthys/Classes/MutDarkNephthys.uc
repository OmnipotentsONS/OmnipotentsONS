class MutDarkNephthys extends Mutator;


function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	if (SVehicleFactory(Other) != None 
     && SVehicleFactory(Other).VehicleClass != None 
     && SVehicleFactory(Other).VehicleClass.Name == 'NephthysTank')
     {
		SVehicleFactory(Other).VehicleClass = class'CSNephthys.CSNephthys';
     }
	
	return true;
}

defaultproperties
{
     bAddToServerPackages=True
     FriendlyName="Dark Nephthys instead of Nephthys"
     Description="Replaces the Nephthys with the Dark Nephthys"
}
