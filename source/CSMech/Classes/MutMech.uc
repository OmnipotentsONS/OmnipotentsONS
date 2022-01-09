class MutMech extends Mutator;

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
    if (SVehicleFactory(Other) != None && SVehicleFactory(Other).VehicleClass != None)
    {
        if(SVehicleFactory(Other).VehicleClass == class'ONSHoverTank')
        {
            SVehicleFactory(Other).VehicleClass = class'CSRocketMech';
        }
        if(SVehicleFactory(Other).VehicleClass == class'ONSAttackCraft')
        {
            SVehicleFactory(Other).VehicleClass = class'CSLinkMech';
        }
        if(SVehicleFactory(Other).VehicleClass == class'ONSHoverBike')
        {
            SVehicleFactory(Other).VehicleClass = class'CSBombMech';
        }
        if(SVehicleFactory(Other).VehicleClass == class'ONSPRV')
        {
            SVehicleFactory(Other).VehicleClass = class'CSBioMech';
        }
        if(SVehicleFactory(Other).VehicleClass == class'ONSRV')
        {
            SVehicleFactory(Other).VehicleClass = class'CSShieldMech';
        }
        if(SVehicleFactory(Other).VehicleClass == class'ONSMobileAssaultStation')
        {
            SVehicleFactory(Other).VehicleClass = class'CSSniperMech';
        }
        //SVehicleFactory(Other).VehicleClass = class'CSSniperMech';
    }
	
	return true;
}

defaultproperties
{
     bAddToServerPackages=True
     FriendlyName="CSMech test"
     Description="Test out mech, replaces goliath, raptor, bender, scorpion "
}
