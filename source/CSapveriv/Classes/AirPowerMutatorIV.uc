class AirPowerMutatorIV extends Mutator config(CSAPVerIV);

var config bool bWeapon_FighterSpawnRifle;
var localized string bSpawnRifle_AutoText,bSpawnRifle_DescText;

var config bool bTranslocator;
var localized string HaveTranslocatorDesc;
var config string FighterClassName;	// The default vehicle to replace
var config string VehicleClassName;

var config class<AirPower_Fighter> MyFighterClass;
var config class<Vehicle> MyVehicleClass;
var localized string FighterClassName_Desc,VehicleClassName_Desc;

var array<string> Vehicles;

// for ONS Vehicle Factory vehicle Replacment
	// Your vehicle class
var config string NewFactoryVehicleClassNameA;	// The default vehicle to replace
var config string NewFactoryVehicleClassNameB;
var class<AirPower_Vehicle> VehicleClassA;
var class<ONSVehicle> VehicleClassB;
    // The default vehicle to replace
var class<ONSVehicle> FactoryVehicleClassA,FactoryVehicleClassB;
var config string FactoryVehicleClassNameA;	// The default vehicle to replace
var config string FactoryVehicleClassNameB;

var localized string FactoryDisplayTextA,FactoryDisplayTextB,NewFactoryDisplayTextA,NewFactoryDisplayTextB;		// The description of the option.

//Replace Bomber gun and Avril
var() config string ReplacedWeaponClassName;
var() config class<Weapon> ReplacementWeaponClass;
var() config string ReplacementWeaponClassName;
var() config string ReplacementPickupClassName;


var config float FighterPitchSpeed;            // Speed
var config float FighterTurnSpeed;
var config float FighterRollSpeed;       // Steering Speed
var localized string FighterPitchSpeedText,FighterPitchSpeedDescText;
var localized string FighterTurnSpeedText,FighterTurnSpeedDescText;
var localized string FighterRollSpeedText,FighterRollSpeedDescText;
// called when everything begins...
function PostBeginPlay()
{
       local FighterSpawnRifle MySpawnRifle;
       local ONSVehicleFactory FactoryA,FactoryB;
       if ( Level.Game.Level.Game.bAllowVehicles==false)
        Level.Game.Level.Game.bAllowVehicles=true;

    //Type of Vehicle to Replace
    FactoryVehicleClassA = class<ONSVehicle>( DynamicLoadObject(FactoryVehicleClassNameA,class'Class') );
	FactoryVehicleClassB = class<ONSVehicle>( DynamicLoadObject(FactoryVehicleClassNameB,class'Class') );
    //Replace with this Vehicle
    VehicleClassA = class<AirPower_Vehicle>( DynamicLoadObject(NewFactoryVehicleClassNameA,class'Class') );
	VehicleClassB = class<ONSVehicle>( DynamicLoadObject(NewFactoryVehicleClassNameB,class'Class') );


    MyFighterClass = class<AirPower_Fighter>( DynamicLoadObject(FighterClassName,class'Class') );
	MyVehicleClass = class<Vehicle>( DynamicLoadObject(VehicleClassName,class'Class') );


	foreach AllActors(class'FighterSpawnRifle', MySpawnRifle)
	{
               MySpawnRifle.FighterClass = MyFighterClass;
               MySpawnRifle.VehicleClass = MyVehicleClass;
    }

  if(VehicleClassA != None)
	{
		foreach AllActors( class 'ONSVehicleFactory', FactoryA )
		{

            if (FactoryA.VehicleClass == FactoryVehicleClassA)
				FactoryA.VehicleClass = VehicleClassA;
		}
	}
   if(VehicleClassB != None)
	{
		foreach AllActors( class 'ONSVehicleFactory', FactoryB )
		{
			if (FactoryB.VehicleClass == FactoryVehicleClassB)
				FactoryB.VehicleClass =  VehicleClassB;
		}
	}
	SetTimer(1.0,true);
}

static function FillPlayInfo(PlayInfo PlayInfo)
{
	local array<CacheManager.VehicleRecord> Recs,APRecs,SRRecs,RRecs;
	local string VehicleOptions,FighterOptions,SRFOptions,RFOptions;
	local int i,F,S,R;
	local class<ONSVehicle> v,RF;
    local class<AirPower_Vehicle> APF,SRF;
	Super.FillPlayInfo(PlayInfo);

	class'CacheManager'.static.GetVehicleList(Recs);
    class'CacheManager'.static.GetVehicleList(APRecs);
    class'CacheManager'.static.GetVehicleList(SRRecs);
    class'CacheManager'.static.GetVehicleList(RRecs);
    VehicleOptions = ";";
    FighterOptions = ";";
    SRFOptions = ";";
    RFOptions = ";";
	for (i = 0; i < Recs.Length; i++)
	{
		v = class<ONSVehicle>(DynamicLoadObject(Recs[i].ClassName, class'class', false));
		if (v != None)
			VehicleOptions $= ";" $ Recs[i].ClassName $ ";" $ Recs[i].FriendlyName;
	}

	PlayInfo.AddSetting(default.RulesGroup, "FactoryVehicleClassNameA", default.FactoryDisplayTextA, 0, 1, "Select", VehicleOptions);
    PlayInfo.AddSetting(default.RulesGroup, "FactoryVehicleClassNameB", default.FactoryDisplayTextB, 0, 1, "Select", VehicleOptions);
    for (F = 0; F < APRecs.Length; F++)
	{
		APF = class<AirPower_Vehicle>(DynamicLoadObject(APRecs[F].ClassName, class'class', false));
		if (APF != None)
			FighterOptions $= ";" $ APRecs[F].ClassName $ ";" $ APRecs[F].FriendlyName;
	}
    PlayInfo.AddSetting(default.RulesGroup, "NewFactoryVehicleClassNameA", default.NewFactoryDisplayTextA, 0, 1, "Select", FighterOptions);
    PlayInfo.AddSetting(default.RulesGroup, "NewFactoryVehicleClassNameB", default.NewFactoryDisplayTextB, 0, 1, "Select", VehicleOptions);

    //Spawn Rifle Info
    PlayInfo.AddSetting(default.RulesGroup, "bWeapon_FighterSpawnRifle", default.bSpawnRifle_AutoText, 0, 1, "Check");

    for (S = 0; S < SRRecs.Length; S++)
	{
		SRF = class<AirPower_Vehicle>(DynamicLoadObject(SRRecs[S].ClassName, class'class', false));
		if (SRF != None)
			SRFOptions $= ";" $ SRRecs[S].ClassName $ ";" $ SRRecs[S].FriendlyName;
	}
	for (R = 0; R < RRecs.Length; R++)
	{
		RF = class<ONSVehicle>(DynamicLoadObject(RRecs[R].ClassName, class'class', false));
		if (RF != None)
			RFOptions $= ";" $ RRecs[R].ClassName $ ";" $ RRecs[R].FriendlyName;
	}
    PlayInfo.AddSetting(default.RulesGroup, "FighterClassName", default.FighterClassName_Desc, 0, 1, "Select",SRFOptions);
    PlayInfo.AddSetting(default.RulesGroup, "VehicleClassName", default.VehicleClassName_Desc, 0, 1, "Select",RFOptions);

    PlayInfo.AddSetting(default.RulesGroup, "bTranslocator", default.HaveTranslocatorDesc, 0, 1, "Check");

    //----Fighter Steering Configs--------------------
    PlayInfo.AddSetting(default.RulesGroup, "FighterPitchSpeed", default.FighterPitchSpeedText, 0, 5, "Text", "4;0.5:30.0");
	PlayInfo.AddSetting(default.RulesGroup, "FighterTurnSpeed", default.FighterTurnSpeedText, 0, 5, "Text", "4;0.5:30.0");
    PlayInfo.AddSetting(default.RulesGroup, "FighterRollSpeed", default.FighterRollSpeedText, 0, 5, "Text", "4;0.5:30.0");


    return;
}

static event string GetDescriptionText(string PropName)
{
    if (PropName == "FactoryVehicleClassNameA")
		return default.FactoryDisplayTextA;
    if (PropName == "FactoryVehicleClassNameB")
		return default.FactoryDisplayTextB;
	if (PropName == "NewFactoryVehicleClassNameA")
		return default.NewFactoryDisplayTextA;
	if (PropName == "NewFactoryVehicleClassNameB")
		return default.NewFactoryDisplayTextB;
	 //SpawnRifles
	 if (PropName == "bWeapon_FighterSpawnRifle")
		return default.bSpawnRifle_DescText;


     //Fighter Configs---------------------------------
    if (PropName == "FighterPitchSpeed")
		return default.FighterPitchSpeedDescText;
     if (PropName == "FighterTurnSpeed")
		return default.FighterTurnSpeedDescText;
	 if (PropName == "FighterRollSpeed")
		return default.FighterRollSpeedDescText;

	return Super.GetDescriptionText(PropName);
}

//------------------------------------------------------------------------------
function ModifyPlayer(Pawn Other)
{
  	// call the parent class
	Super.ModifyPlayer(Other);

	if  ((level.Game.bTeamGame==false)||(level.Game.bTeamGame==true))
       {

         if (bWeapon_FighterSpawnRifle && Other.Controller.IsA('PlayerController'))
             Other.CreateInventory("CSAPVerIV.FighterSpawnRifle");


         if (bTranslocator)
	         Other.CreateInventory("XWeapons.TransLauncher");

      }


	if ( NextMutator != None )
		 NextMutator.ModifyPlayer(Other);
}

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	if (Other.IsA('FighterSpawnRifle'))
	{
		FighterSpawnRifle(Other).FighterClass = MyFighterClass;
	    FighterSpawnRifle(Other).VehicleClass = MyVehicleClass;
    }

    //-----------------------------------------------------------
    //Fighter
	if (Other.IsA('AirPower_Fighter'))
	{
		AirPower_Fighter(Other).MenuPitchSpeed = FighterPitchSpeed;
	    AirPower_Fighter(Other).MenuYawSpeed = FighterTurnSpeed;
	    AirPower_Fighter(Other).MenuRollSpeed = FighterRollSpeed;
    }

		return true;
}

function string GetInventoryClassOverride(string InventoryClassName)
{
	if ( NextMutator != None )
		InventoryClassName = NextMutator.GetInventoryClassOverride(InventoryClassName);

	if( InventoryClassName == ReplacedWeaponClassName )
	{
		InventoryClassName = ReplacementWeaponClassName;
	}

	return InventoryClassName;
}

defaultproperties
{
     bWeapon_FighterSpawnRifle=True
     bSpawnRifle_AutoText="Start With a Fighter Spawn Rifle."
     bSpawnRifle_DescText="Start With a Fighter Spawn Rifle."
     bTranslocator=True
     HaveTranslocatorDesc="All GameTypes TransLocator"
     FighterClassName="CSAPVerIV.Excalibur"
     VehicleClassName="CSAPVerIV.Predator"
     FighterClassName_Desc="SpawnRifle FighterClass"
     VehicleClassName_Desc="SpawnRifle VehicleClass"
     NewFactoryVehicleClassNameA="CSAPVerIV.Excalibur"
     NewFactoryVehicleClassNameB="CSAPVerIV.Predator"
     FactoryVehicleClassNameA="Onslaught.ONSHoverTank"
     FactoryVehicleClassNameB="Onslaught.ONSMAS"
     FactoryDisplayTextA="1).Choose Vehicle Type To be Replaced:"
     FactoryDisplayTextB="2).Choose Vehicle Type To be Replaced:"
     NewFactoryDisplayTextA="1).Vehicle Type Replacement:"
     NewFactoryDisplayTextB="2).Vehicle Type Replacement:"
     ReplacedWeaponClassName="OnslaughtFull.ONSPainter"
     ReplacementWeaponClass=Class'CSAPVerIV.APPainter'
     ReplacementWeaponClassName="CSAPVerIV.APPainter"
     ReplacementPickupClassName="CSAPVerIV.APPainterPickUp"
     FighterPitchSpeedText="Fighter Pitch Speed"
     FighterPitchSpeedDescText="Higher is faster defualt is 1.5"
     FighterTurnSpeedText="Fighter Turn Speed"
     FighterTurnSpeedDescText="Higher is faster defualt is 1.0"
     FighterRollSpeedText="Fighter Roll Speed"
     FighterRollSpeedDescText="Higher is faster defualt is 16.0"
     GroupName=""
     FriendlyName="AirPowerIV Mutator (CS)"
     Description="7 New Vehicles - Excalibur Transforming Fighter, Phantom Stealth Fighter/Bomber, Predator Attack Helicopter,Reaper Stealth Helicopter, UT Human Fighter,UT Skarrj Fighter and Falcon Fighter"
}
