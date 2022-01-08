class MutKarmaInsteadOfRaptor extends Mutator;


function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	if (SVehicleFactory(Other) != None 
     && (class<ONSAttackCraft>(SVehicleFactory(Other).VehicleClass) != None 
     || SVehicleFactory(Other).VehicleClass != None && SVehicleFactory(Other).VehicleClass.Name == 'DropShipKarma'))
     {
		SVehicleFactory(Other).VehicleClass = class'DropShipKarma';
     }
	
	return true;
}

defaultproperties
{
     bAddToServerPackages=True
     FriendlyName="DropShipKarma instead of Raptor (CS)"
     Description="Replaces the Raptor (and its various variants) with the DropShipKarma"
}
