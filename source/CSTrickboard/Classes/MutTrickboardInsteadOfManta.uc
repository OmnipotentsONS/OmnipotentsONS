class MutTrickboardInsteadOfManta extends Mutator;


function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	if (SVehicleFactory(Other) != None && SVehicleFactory(Other).VehicleClass.Name == 'ONSBoard')
     {
		SVehicleFactory(Other).VehicleClass = class'CSTrickboard.CSTrickboard';
     }
	
	return true;
}

defaultproperties
{
     bAddToServerPackages=True
     FriendlyName="Trickboard instead of Locust"
     Description="Replaces the Locust with the Trickboard"
}
