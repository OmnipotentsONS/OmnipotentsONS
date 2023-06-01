class MutSnarfVehiclePack extends Mutator config(CSVehiclePack);

var() config bool bBallista;
var() config bool bHellHound;
var() config bool bKingHellHound;
var() config bool bAlligator;
var() config bool bMinotuar;
var() config bool bLeviathan;
var() config bool bKraken;
var() config bool bSmallKraken;
var() config bool bHammerhead;
var() config bool bArmadillo;
var() config bool bHurricane;
var() config bool bLinkTank;

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
    local int i;
    local SVehicleFactory factory;
    local CSVehicleRandomizer randomizer;
    local class<ONSVehicle> vehicleClass;

    factory = SVehicleFactory(Other);
    randomizer = CSVehicleRandomizer(Other);
	if (factory != None && factory.VehicleClass != None)
    {
        if(bBallista && factory.VehicleClass.Name == 'Ballista')
        {
            SVehicleFactory(Other).VehicleClass = class'CSBallista.Ballista';
        }
        if(bHellHound && factory.VehicleClass.Name == 'HellHound')
        {
            SVehicleFactory(Other).VehicleClass = class'CSHellHound.HellHound';
        }
        if(bKingHellHound && factory.VehicleClass.Name == 'KingHellHound')
        {
            SVehicleFactory(Other).VehicleClass = class'CSKingHellHound.KingHellHound';
        }
        if(bAlligator && factory.VehicleClass.Name == 'Alligator')
        {
            SVehicleFactory(Other).VehicleClass = class'CSAlligator.Alligator';
        }
        if(bMinotuar && factory.VehicleClass.Name == 'Omnitaur')
        {
            SVehicleFactory(Other).VehicleClass = class'CSMinotaur.Minotaur';
        }
        if(bMinotuar && factory.VehicleClass.Name == 'Minotaur')
        {
            vehicleClass = class<ONSVehicle>(factory.VehicleClass);
            if(vehicleClass != None)
            {
                if(vehicleClass.default.RedSkin==Texture'Omnitaur_Tex.OmnitaurRed')
                {
                    SVehicleFactory(Other).VehicleClass = class'CSMinotaur.Minotaur';
                }
            }
        }
        if(bLeviathan && factory.VehicleClass.Name == 'ONSMobileAssaultStation')
        {
            SVehicleFactory(Other).VehicleClass = class'CSLeviathan.CSLeviathan';
        }
        if(bKraken && factory.VehicleClass.Name == 'Kraken')
        {
            SVehicleFactory(Other).VehicleClass = class'CSKraken.Kraken';
        }
        if(bSmallKraken && factory.VehicleClass.Name == 'SmallKraken')
        {
            SVehicleFactory(Other).VehicleClass = class'CSKraken.SmallKraken';
        }
        if(bHammerhead && factory.VehicleClass.Name == 'Hammerhead')
        {
            SVehicleFactory(Other).VehicleClass = class'CSHammerhead.Hammerhead';
        }
        if(bArmadillo && factory.VehicleClass.Name == 'ONSArmadillo')
        {
            SVehicleFactory(Other).VehicleClass = class'CSAdvancedArmor.ONSArmadillo';
        }
        if(bHurricane && factory.VehicleClass.Name == 'ONSHurricaneTank')
        {
            SVehicleFactory(Other).VehicleClass = class'CSAdvancedArmor.ONSHurricaneTank';
        }
        if(bLinkTank && (factory.VehicleClass.Name == 'ONSLinkTank' || factory.VehicleClass.Name == 'LinkTank'))
        {
            SVehicleFactory(Other).VehicleClass = class'LinkVehiclesOmni.LinkTank3';
        }
    }
    if(randomizer != None)
    {
        for(i = 0;i<randomizer.Vehicles.length;i++)
        {
            if(bBallista && randomizer.Vehicles[i].VehicleClass.Name == 'Ballista')
            {
                randomizer.Vehicles[i].VehicleClass = class'CSBallista.Ballista';
            }
            if(bHellHound && randomizer.Vehicles[i].VehicleClass.Name == 'HellHound')
            {
                randomizer.Vehicles[i].VehicleClass = class'CSHellHound.HellHound';
            }
            if(bKingHellHound && randomizer.Vehicles[i].VehicleClass.Name == 'KingHellHound')
            {
                randomizer.Vehicles[i].VehicleClass = class'CSKingHellHound.KingHellHound';
            }
            if(bAlligator && randomizer.Vehicles[i].VehicleClass.Name == 'Alligator')
            {
                randomizer.Vehicles[i].VehicleClass = class'CSAlligator.Alligator';
            }
            if(bMinotuar && randomizer.Vehicles[i].VehicleClass.Name == 'Omnitaur')
            {
                randomizer.Vehicles[i].VehicleClass = class'CSMinotaur.Minotaur';
            }
            if(bLeviathan && randomizer.Vehicles[i].VehicleClass.Name == 'ONSMobileAssaultStation')
            {
                randomizer.Vehicles[i].VehicleClass = class'CSLeviathan.CSLeviathan';
            }
            if(bKraken && randomizer.Vehicles[i].VehicleClass.Name == 'Kraken')
            {
                randomizer.Vehicles[i].VehicleClass = class'CSKraken.Kraken';
            }
            if(bSmallKraken && randomizer.Vehicles[i].VehicleClass.Name == 'SmallKraken')
            {
                randomizer.Vehicles[i].VehicleClass = class'CSKraken.SmallKraken';
            }
            if(bHammerhead && randomizer.Vehicles[i].VehicleClass.Name == 'Hammerhead')
            {
                randomizer.Vehicles[i].VehicleClass = class'CSHammerhead.Hammerhead';
            }
            if(bArmadillo && randomizer.Vehicles[i].VehicleClass.Name == 'ONSArmadillo')
            {
                randomizer.Vehicles[i].VehicleClass = class'CSAdvancedArmor.ONSArmadillo';
            }
            if(bHurricane && randomizer.Vehicles[i].VehicleClass.Name == 'ONSHurricaneTank')
            {
                randomizer.Vehicles[i].VehicleClass = class'CSAdvancedArmor.ONSHurricaneTank';
            }
            if(bLinkTank && (randomizer.Vehicles[i].VehicleClass.Name == 'ONSLinkTank' || randomizer.Vehicles[i].VehicleClass.Name == 'LinkTank'))
            {
                randomizer.Vehicles[i].VehicleClass = class'LinkVehiclesOmni.LinkTank3';
            }
        }
    }
	
	return true;
}

defaultproperties
{
    bAddToServerPackages=True
    FriendlyName="Snarf's Vehicle Pack"
    Description="Replaces vehicles with Snarf's and Omni's bug fixed versions - Ballista, HellHound, KingHellHound, Alligator, Minotaur/Omnitaur, Leviathan, Kraken, Tiamat, Hammerhead, Troop Carrier, Hurricane and LinkTank"
    bBallista=true
    bHellHound=true
    bKingHellHound=true
    bAlligator=true
    bMinotuar=true
    bLeviathan=true
    bKraken=true
    bSmallKraken=true
    bHammerhead=true
    bArmadillo=true
    bHurricane=true
    bLinkTank=true
}
