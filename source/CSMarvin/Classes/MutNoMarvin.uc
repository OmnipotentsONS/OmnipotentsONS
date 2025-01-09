class MutNoMarvin extends Mutator;


function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	if (SVehicleFactory(Other) != None && 
       (class<CSMarvin>(SVehicleFactory(Other).VehicleClass) != None))
     {
		SVehicleFactory(Other).VehicleClass = class'CSFlyingSaucer';
     }
	
	return true;
}

defaultproperties
{
     bAddToServerPackages=True
     FriendlyName="No Marvin"
     Description="Replaces the Marvin with the shitty old UFO"
}
