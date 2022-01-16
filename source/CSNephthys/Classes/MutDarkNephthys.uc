class MutDarkNephthys extends Mutator;


function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	if (SVehicleFactory(Other) != None 
     && SVehicleFactory(Other).VehicleClass != None
     && SVehicleFactory(Other).VehicleClass.Name == 'ONSHoverTank')
     {
		SVehicleFactory(Other).VehicleClass = class'CSNephthys.CSNephthys';
     }
	if (SVehicleFactory(Other) != None 
     && SVehicleFactory(Other).VehicleClass != None
     && SVehicleFactory(Other).VehicleClass.Name == 'ONSAttackCraft')
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
