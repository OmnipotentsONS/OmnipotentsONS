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
var() config bool bFireTank;
var() config bool bFlameTank;
var() config bool bMirageRaptor;
var() config bool bFireHound;
var() config bool bBioHound;
var() config bool bWyvern;
var() config bool bStingray;
var() config bool bShortCircuit;
var() config bool bPulseTraitor;
var() config bool bPersesMas;
var() config bool bTurtle;

   // FYI, there's a weird bug on some older randomizers where it does the cast wrong and fvfactory=None
    // Not sure why but it does, mostly Minus, AJY.
    // update 2/2025 its because the stupid mylevel obscures the loaded package and causes the cast randomizer=ONSVehicleRandomizer(Other)
    // to fail since the compiled package VehicleRandomizerOmni.ONSVehicleRandomizer != mylevel.ONSVehicleRandomizer and it won't cast.
    // fvf and rando ifs might be outdated since the mostly don't work anyway.

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
    local int i;
    local SVehicleFactory factory;
    local ONSForcedVehicleFactory fvfactory;
    local ONSVehicleRandomizer randomizer;
    local class<ONSVehicle> vehicleClass;


    factory = SVehicleFactory(Other);
    randomizer = ONSVehicleRandomizer(Other);
    fvfactory = ONSForcedVehicleFactory(Other);
    //log("CSVP Other="@Other@" ClassName"@Other.class.name, 'CSVehiclePack');
    //log("CSVP fvf="@fvfactory, 'CSVehiclePack');
    //log("CSVP VR="@randomizer, 'CSVehiclePack');
    //log("CSVP");
    
    //log("CSVP Other.IsA('ONSVehicleRandomize r')="@Other.IsA('ONSVehicleRandomizer'));
		//if (Other.IsA('ONSVehicleRandomizer'))
	//	{
			
		//randomizer = ONSVehicleRandomizer(Other);
		//log("CSVP After If True VR="@randomizer, 'CSVehiclePack');
		
	//	}
          
    //}
    //if (Other.IsA('ONSForcedVehicleFactory'))
    //      {
    //      	log("IsA('ONSForcedVehicleFactory')=True",'CSVehiclePack');
    //      	log("Other="$other,'CSVehiclePack');
    //      	log("fvfactory="$fvfactory, 'CSVehiclePack');
    //}
    
	  if (factory != None && factory.VehicleClass != None)
    {
    	  //log("factory"@factory,'CSVehiclePack');
        if(bBallista && (factory.VehicleClass.Name == 'Ballista' || factory.VehicleClass.Name == 'SniperTank'))
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
        if(bFlameTank && factory.VehicleClass.Name == 'FlameTank')
        {
            SVehicleFactory(Other).VehicleClass = class'FireVehiclesV2Omni.FlameTankV2Omni';
        }
        if(bFireTank && factory.VehicleClass.Name == 'FireTank')
        {
            SVehicleFactory(Other).VehicleClass = class'FireVehiclesV2Omni.FireTankV2Omni';
        }
        if(bFireHound && factory.VehicleClass.Name == 'FireHound')
        {
            SVehicleFactory(Other).VehicleClass = class'FireVehiclesV2Omni.FireHoundV2Omni';
        }
        if(bMirageRaptor && factory.VehicleClass.Name == 'MirageRaptor')
        {
            SVehicleFactory(Other).VehicleClass = class'MirageRaptorOmni.MirageRaptorOmni';
        }
        if(bBioHound && factory.VehicleClass.Name == 'BioHound')
        {
            SVehicleFactory(Other).VehicleClass = class'BioHoundOmni.BioHound';
        }
        if(bWyvern && factory.VehicleClass.Name == 'Wyvern')
        {
            SVehicleFactory(Other).VehicleClass = class'OmniMantas.Wyvern';
        }
        if(bStingray && factory.VehicleClass.Name == 'Stingray')
        {
            SVehicleFactory(Other).VehicleClass = class'OmniMantas.StingRay';
        }
        if(bShortCircuit && factory.VehicleClass.Name == 'LIPShortCircuit')
        {
            SVehicleFactory(Other).VehicleClass = class'OmniMantas.ShortCircuitOmni';
        }
        if(bPulseTraitor && factory.VehicleClass.Name == 'LIPPulseTraitor')
        {
            SVehicleFactory(Other).VehicleClass = class'OmniMantas.PulseTraitorOmni';
        }
        if(bPersesMas && factory.VehicleClass.Name == 'PersesMAS')
        {
            SVehicleFactory(Other).VehicleClass = class'PersesOmni.PersesOmniMAS';
        }
        if(bTurtle && factory.VehicleClass.Name == 'Turtle')
        {
            SVehicleFactory(Other).VehicleClass = class'TurtleOmni.TurtleOmni';
        }
    } // Regular Factories
    
    // Do ONSForcedVehicle Factories these are the ones ignored by Randomizers..
    // Really only matters what DefaultVehicleClass is.
 
   if (fvfactory != None && fvfactory.DefaultVehicleClass != None  && fvfactory.DefaultVehicleClass != None)
    {
    	  //log("fvfactory"@fvfactory,'CSVehiclePack');
    	  //log("fvf before Replacement"$fvfactory.DefaultVehicleClass,'CSVehiclePack');
        if(bBallista && (fvfactory.DefaultVehicleClass.Name == 'Ballista' || fvfactory.DefaultVehicleClass.Name == 'SniperTank'))
        {
           fvfactory.DefaultVehicleClass = class'CSBallista.Ballista';
        }
        if(bHellHound && fvfactory.DefaultVehicleClass.Name == 'HellHound')
        {
             fvfactory.DefaultVehicleClass = class'CSHellHound.HellHound';
        }
        if(bKingHellHound && fvfactory.DefaultVehicleClass.Name == 'KingHellHound')
        {
            fvfactory.DefaultVehicleClass = class'CSKingHellHound.KingHellHound';
        }
        if(bAlligator && fvfactory.DefaultVehicleClass.Name == 'Alligator')
        {
            fvfactory.DefaultVehicleClass = class'CSAlligator.Alligator';
        }
        if(bMinotuar && fvfactory.DefaultVehicleClass.Name == 'Omnitaur')
        {
            fvfactory.DefaultVehicleClass = class'CSMinotaur.Minotaur';
        }
        if(bMinotuar && fvfactory.DefaultVehicleClass.Name == 'Minotaur')
        {
            vehicleClass = class<ONSVehicle>(fvfactory.DefaultVehicleClass);
            if(vehicleClass != None)
            {
                if(vehicleClass.default.RedSkin==Texture'Omnitaur_Tex.OmnitaurRed')
                {
                    fvfactory.DefaultVehicleClass = class'CSMinotaur.Minotaur';
                }
            }
        }
        if(bLeviathan && fvfactory.DefaultVehicleClass.Name == 'ONSMobileAssaultStation')
        {
            fvfactory.DefaultVehicleClass = class'CSLeviathan.CSLeviathan';
        }
        if(bKraken && fvfactory.DefaultVehicleClass.Name == 'Kraken')
        {
            fvfactory.DefaultVehicleClass = class'CSKraken.Kraken';
        }
        if(bSmallKraken && fvfactory.DefaultVehicleClass.Name == 'SmallKraken')
        {
            fvfactory.DefaultVehicleClass = class'CSKraken.SmallKraken';
        }
        if(bHammerhead && fvfactory.DefaultVehicleClass.Name == 'Hammerhead')
        {
            fvfactory.DefaultVehicleClass = class'CSHammerhead.Hammerhead';
        }
        if(bArmadillo && fvfactory.DefaultVehicleClass.Name == 'ONSArmadillo')
        {
            fvfactory.DefaultVehicleClass = class'CSAdvancedArmor.ONSArmadillo';
        }
        if(bHurricane && fvfactory.DefaultVehicleClass.Name == 'ONSHurricaneTank')
        {
            fvfactory.DefaultVehicleClass = class'CSAdvancedArmor.ONSHurricaneTank';
        }
        if(bLinkTank && (fvfactory.DefaultVehicleClass.Name == 'ONSLinkTank' || fvfactory.DefaultVehicleClass.Name == 'LinkTank'))
        {
            fvfactory.DefaultVehicleClass = class'LinkVehiclesOmni.LinkTank3';
        }
        if(bFlameTank && fvfactory.DefaultVehicleClass.Name == 'FlameTank')
        {
            fvfactory.DefaultVehicleClass = class'FireVehiclesV2Omni.FlameTankV2Omni';
        }
        if(bFireTank && fvfactory.DefaultVehicleClass.Name == 'FireTank')
        {
            fvfactory.DefaultVehicleClass = class'FireVehiclesV2Omni.FireTankV2Omni';
        }
        if(bFireHound && fvfactory.DefaultVehicleClass.Name == 'FireHound')
        {
            fvfactory.DefaultVehicleClass = class'FireVehiclesV2Omni.FireHoundV2Omni';
        }
        if(bMirageRaptor && fvfactory.DefaultVehicleClass.Name == 'MirageRaptor')
        {
            fvfactory.DefaultVehicleClass = class'MirageRaptorOmni.MirageRaptorOmni';
        }
        if(bBioHound && fvfactory.DefaultVehicleClass.Name == 'BioHound')
        {
            fvfactory.DefaultVehicleClass = class'BioHoundOmni.BioHound';
        }
        if(bWyvern && fvfactory.DefaultVehicleClass.Name == 'Wyvern')
        {
            fvfactory.DefaultVehicleClass = class'OmniMantas.Wyvern';
        }
        if(bStingray && fvfactory.DefaultVehicleClass.Name == 'Stingray')
        {
            fvfactory.DefaultVehicleClass = class'OmniMantas.Stingray';
        }
        if(bPulseTraitor && fvfactory.DefaultVehicleClass.Name == 'LIPPulseTraitor')
        {
            fvfactory.DefaultVehicleClass = class'OmniMantas.PulseTraitorOmni';
        }
        if(bShortCircuit && fvfactory.DefaultVehicleClass.Name == 'LIPShortCircuit')
        {
            fvfactory.DefaultVehicleClass = class'OmniMantas.ShortCircuitOmni';
        }
       
        //log("FvF Replacement="$ONSForcedVehicleFactory(Other).VehicleClass,'CSVehiclePack');
    } // Forced Vehicle Factories
    
    
    if(randomizer != None)
    {
        for(i = 0;i<randomizer.Vehicles.length;i++)
        {
        	  log("RNDVehicle="@randomizer.Vehicles[i].VehicleClass.Name, 'CSVehiclePack');
            if(bBallista && (randomizer.Vehicles[i].VehicleClass.Name == 'Ballista' || randomizer.Vehicles[i].VehicleClass.Name == 'SniperTank'))
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
            
		        if(bFlameTank && randomizer.Vehicles[i].VehicleClass.Name == 'FlameTank')
		        {
		            randomizer.Vehicles[i].VehicleClass = class'FireVehiclesV2Omni.FlameTankV2Omni';
		        }
		        if(bFireTank && randomizer.Vehicles[i].VehicleClass.Name == 'FireTank')
		        {
		            randomizer.Vehicles[i].VehicleClass = class'FireVehiclesV2Omni.FireTankV2Omni';
		        }
		        if(bFireHound && randomizer.Vehicles[i].VehicleClass.Name == 'FireHound')
		        {
		            randomizer.Vehicles[i].VehicleClass = class'FireVehiclesV2Omni.FireHoundV2Omni';
		        }
		        if(bMirageRaptor && randomizer.Vehicles[i].VehicleClass.Name == 'MirageRaptor')
		        {
		            randomizer.Vehicles[i].VehicleClass = class'MirageRaptorOmni.MirageRaptorOmni';
		        }
		        if(bBioHound && randomizer.Vehicles[i].VehicleClass.Name == 'BioHound')
		        {
		            randomizer.Vehicles[i].VehicleClass = class'BioHoundOmni.BioHound';
		        }
		        if(bWyvern && randomizer.Vehicles[i].VehicleClass.Name == 'Wyvern')
		        {
		            randomizer.Vehicles[i].VehicleClass = class'OmniMantas.Wyvern';
		        }
		        if(bStingray && randomizer.Vehicles[i].VehicleClass.Name == 'Stingray')
		        {
		            randomizer.Vehicles[i].VehicleClass = class'OmniMantas.StingRay';
		        }
		        if(bPulseTraitor && randomizer.Vehicles[i].VehicleClass.Name == 'LIPPulseTraitor')
		        {
		            randomizer.Vehicles[i].VehicleClass = class'OmniMantas.PulseTraitorOmni';
		        }
		        if(bShortCircuit && randomizer.Vehicles[i].VehicleClass.Name == 'LIPShortCircuit')
		        {
		            randomizer.Vehicles[i].VehicleClass = class'OmniMantas.ShortCircuitOmni';
		        }
            if(bPersesMas && randomizer.Vehicles[i].VehicleClass.Name == 'PersesMAS')
            {
            randomizer.Vehicles[i].VehicleClass = class'PersesOmni.PersesOmniMAS';
            }
            if(bTurtle && randomizer.Vehicles[i].VehicleClass.Name == 'Turtle')
            {
            randomizer.Vehicles[i].VehicleClass = class'TurtleOmni.TurtleOmni';
            }
        } // for loop
    } // Randomizer
	
	return true;
}

defaultproperties
{
    bAddToServerPackages=True
    FriendlyName="Snarf's Vehicle Pack 02-01-2025"
    Description="Replaces vehicles with Snarf's and Omni's bug fixed versions - Ballista, HellHound, KingHellHound, Alligator, Minotaur/Omnitaur, Leviathan, Kraken, Tiamat, Hammerhead, Troop Carrier, Hurricane, LinkTank, FireTank, FlameTank and MirageRaptor"
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
    bFireTank=true
    bFlameTank=true
    bMirageRaptor=true
    bFireHound=true
    bBioHound=true
    bWyvern=true
    bStingray=true
    bShortCircuit=true
    bPulseTraitor=true
    bPersesMas=true
    bTurtle=true

}
