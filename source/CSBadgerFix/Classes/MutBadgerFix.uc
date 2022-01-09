class MutBadgerFix extends Mutator;
//var BadgerWatcher watcher;
//#exec OBJ LOAD FILE=Badger_Ani_Fixed.ukx

simulated function PostBeginPlay()
{
    super.PostBeginPlay();
    //watcher = spawn(class'BadgerWatcher', self);
}

function bool IsBadgerClass(name className)
{
    local bool isBadger;
    isBadger = className == 'Badger'
    || className == 'MyBadger'
    || className == 'BioBadger'
    || className == 'FireBadger'
    || className == 'IonPlasmaBadger'
    || className == 'LinkBadger'
    || className == 'LinkBadger2'
    || className == 'ReverseBadger'
    || className == 'StealthBadger';

    return isBadger;
}

/*
function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
    local ONSVehicle badger;
	
    badger = ONSVehicle(Other);
    if(badger != None && IsBadgerClass(badger.name))
    {
        KarmaParamsRBFull(badger.KParams).KCOMOffset = vect(0,0,-0.7);
    }

	return true;
}
*/

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
    local SVehicleFactory factory;
    factory = SVehicleFactory(Other);
	if (factory != None && factory.VehicleClass != None)
    {
        if(factory.VehicleClass.Name == 'Badger')
        {
            SVehicleFactory(Other).VehicleClass = class'CSBadgerFix.Badger';
        }
        if(factory.VehicleClass.Name == 'MyBadger')
        {
            SVehicleFactory(Other).VehicleClass = class'CSBadgerFix.MyBadger';
        }
        else if(factory.VehicleClass.Name == 'FireBadger')
        {
            SVehicleFactory(Other).VehicleClass = class'CSBadgerFix.FireBadger';
        }
        else if(factory.VehicleClass.Name == 'ReverseBadger')
        {
            SVehicleFactory(Other).VehicleClass = class'CSBadgerFix.ReverseBadger';
        }
        else if(factory.VehicleClass.Name == 'IonPlasmaBadger')
        {
           SVehicleFactory(Other).VehicleClass = class'CSBadgerFix.IonPlasmaBadger';
        }
        else if(factory.VehicleClass.Name == 'StealthBadger')
        {
            SVehicleFactory(Other).VehicleClass = class'CSBadgerFix.StealthBadger';
        }
        else if(factory.VehicleClass.Name == 'LinkBadger2')
        {
            SVehicleFactory(Other).VehicleClass = class'CSBadgerFix.LinkBadger';
        }
        else if(factory.VehicleClass.Name == 'LinkBadger')
        {
            SVehicleFactory(Other).VehicleClass = class'CSBadgerFix.LinkBadger';
        }
        else if(factory.VehicleClass.Name == 'BioBadger')
        {
            SVehicleFactory(Other).VehicleClass = class'CSBadgerFix.BioBadger';
        }
        else if(factory.VehicleClass.Name == 'BioTank')
        {
            SVehicleFactory(Other).VehicleClass = class'CSBadgerFix.BioTank';
        }
    }
	
	return true;
}

defaultproperties
{
     bAddToServerPackages=True
     FriendlyName="Badger Fix"
     Description="Fixes the badger exits and seek location"

}
