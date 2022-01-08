class MutPredatorInsteadOfRaptor extends Mutator;


function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	if (SVehicleFactory(Other) != None 
     && (class<ONSAttackCraft>(SVehicleFactory(Other).VehicleClass) != None 
     || SVehicleFactory(Other).VehicleClass != None && SVehicleFactory(Other).VehicleClass.Name == 'Predator'))
     {
		SVehicleFactory(Other).VehicleClass = class'Predator';
     }
	
	return true;
}

defaultproperties
{
     bAddToServerPackages=True
     FriendlyName="Predator instead of Raptor (CS)"
     Description="Replaces the Raptor (and its various variants) with the Predator"
}
