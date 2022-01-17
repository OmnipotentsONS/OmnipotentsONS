//=============================================================================
// Class made by:
//
// Rens2Sea
// Rens2Serious@hotmail.com
// www.Rens2Sea.com
//
// Code for a mutator to replace any vehicle with your own.
// Most of the code is from the game itself, i just modified it a bit.
// The most important defaultproperty is ArenaVehicleClassName wich
// indicates what the vehicle is that will be used.
//=============================================================================

class HelixMut extends Mutator
    config;

var string ArenaVehicleClassName;		// Your vehicle class
var config string FactoryVehicleClassName;	// The default vehicle to replace

var class<SVehicle> ArenaVehicleClass;
var class<SVehicle> FactoryVehicleClass;
var localized string ArenaDisplayText;		// The line that shows up in the config menu (ie: "Replace this vehicle with the Flak Scorpion")
var localized string ArenaDescText;		// The description of the option.

function PostBeginPlay()
{
	local ONSVehicleFactory Factory;

	FactoryVehicleClass = class<SVehicle>( DynamicLoadObject(FactoryVehicleClassName,class'Class') );
	ArenaVehicleClass = class<SVehicle>( DynamicLoadObject(ArenaVehicleClassName,class'Class') );

	if(ArenaVehicleClass != None)
	{
		foreach AllActors( class 'ONSVehicleFactory', Factory )
		{
			if (Factory.VehicleClass == FactoryVehicleClass)
				Factory.VehicleClass = ArenaVehicleClass;
		}
	}

	Super.PostBeginPlay();
}

static function FillPlayInfo(PlayInfo PlayInfo)
{
	local array<CacheManager.VehicleRecord> Recs;
	local string VehicleOptions;
	local int i;
	local class<SVehicle> v;

	Super.FillPlayInfo(PlayInfo);

	class'CacheManager'.static.GetVehicleList(Recs);

	VehicleOptions = ";";

	for (i = 0; i < Recs.Length; i++)
	{
		v = class<SVehicle>(DynamicLoadObject(Recs[i].ClassName, class'class', false));
		if (v != None)
			VehicleOptions $= ";" $ Recs[i].ClassName $ ";" $ Recs[i].FriendlyName;
	}

	PlayInfo.AddSetting(default.RulesGroup, "FactoryVehicleClassName", default.ArenaDisplayText, 0, 1, "Select", VehicleOptions);

	return;
}


static event string GetDescriptionText(string PropName)
{
	if (PropName == "FactoryVehicleClassName")
		return default.ArenaDescText;

	return Super.GetDescriptionText(PropName);
}

/*
	The defaults of my Helix
*/

defaultproperties
{
     ArenaVehicleClassName="helixesvOmni.HelixESVNew"
     FactoryVehicleClassName="helixesvOmni.HelixFactory"
     ArenaDisplayText="Replace this with the Helix:"
     ArenaDescText="Replace any vehicle with the Helix Extended support vehicle (version 2)."
     GroupName="VehicleArena"
     FriendlyName="Helix2"
     Description="Replace any vehicles with the Helix Extended support vehicle (version 2)."
}
