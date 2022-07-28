class MutDarkLeviathan extends Mutator;


function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	if (SVehicleFactory(Other) != None && SVehicleFactory(Other).VehicleClass != None)
     {
         if(SVehicleFactory(Other).VehicleClass.name == 'ONSMobileAssaultStation')
         {
            SVehicleFactory(Other).VehicleClass = class'CSDarkLeviathan';
         }

     }
	
	return true;
}

defaultproperties
{
     bAddToServerPackages=True
     FriendlyName="CSDarkLeviathan test"
     Description="Test out dark levi"
}