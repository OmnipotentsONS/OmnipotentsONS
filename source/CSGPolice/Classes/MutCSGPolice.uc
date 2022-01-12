class MutCSGPolice extends Mutator;


function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	if (SVehicleFactory(Other) != None && SVehicleFactory(Other).VehicleClass != None)
    {
        if(SVehicleFactory(Other).VehicleClass.Name == 'ONSPRV')
        {
            SVehicleFactory(Other).VehicleClass = class'CSRhino';
        }
        if(SVehicleFactory(Other).VehicleClass.Name == 'ONSAttackCraft')
        {
            SVehicleFactory(Other).VehicleClass = class'CSVenom';
        }
        if(SVehicleFactory(Other).VehicleClass.Name == 'ONSRV')
        {
            SVehicleFactory(Other).VehicleClass = class'CSHavoc';
        }
    }
	
	return true;
}

defaultproperties
{
     bAddToServerPackages=True
     FriendlyName="GPolice (cs)"
     Description="GPolice test"
}
