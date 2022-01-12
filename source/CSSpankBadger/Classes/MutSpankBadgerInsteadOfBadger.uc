class MutSpankBadgerInsteadOfBadger extends Mutator;

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
    local SVehicleFactory factory;
    factory = SVehicleFactory(Other);
	if (factory != None && factory.VehicleClass != None)
    {
        if(factory.VehicleClass.Name == 'Badger')
        {
            SVehicleFactory(Other).VehicleClass = class'CSSpankBadger.CSSpankBadger';
        }
        if(factory.VehicleClass.Name == 'MyBadger')
        {
            SVehicleFactory(Other).VehicleClass = class'CSSpankBadger.CSSpankBadger';
        }
    }
	
	return true;
}

defaultproperties
{
     bAddToServerPackages=True
     FriendlyName="Spank Badger"
     Description="replaces regular badger with spank badger"

}
