class MutMarvinTest extends Mutator;


function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	if (SVehicleFactory(Other) != None && 
       (class<ONSAttackCraft>(SVehicleFactory(Other).VehicleClass) != None))
     {
		SVehicleFactory(Other).VehicleClass = class'CSMarvin';
     }

	if (SVehicleFactory(Other) != None && 
       (class<ONSHoverBike>(SVehicleFactory(Other).VehicleClass) != None))
     {
		SVehicleFactory(Other).VehicleClass = class'FlyingSaucer';
     }
	
	return true;
}

defaultproperties
{
     bAddToServerPackages=True
     FriendlyName="CSMarvin test"
     Description="Replaces the Raptor with the Marvin, Manta with the Flying Saucer"
}
