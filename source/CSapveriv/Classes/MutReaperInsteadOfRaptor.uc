class MutReaperInsteadOfRaptor extends Mutator;


function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	if (SVehicleFactory(Other) != None 
     && (class<ONSAttackCraft>(SVehicleFactory(Other).VehicleClass) != None 
     || SVehicleFactory(Other).VehicleClass != None && SVehicleFactory(Other).VehicleClass.Name == 'Reaper'))
     {
		SVehicleFactory(Other).VehicleClass = class'Reaper';
     }
	
	return true;
}

defaultproperties
{
     bAddToServerPackages=True
     FriendlyName="Reaper instead of Raptor (CS)"
     Description="Replaces the Raptor (and its various variants) with the Reaper"
}
