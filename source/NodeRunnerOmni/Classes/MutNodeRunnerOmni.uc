//-----------------------------------------------------------
//
//-----------------------------------------------------------
class MutNodeRunnerOmni extends Mutator;

var () config class<ONSHoverCraft> ReplaceWithThis;
var () config class<ONSVehicle> ReplaceWhat;
var localized string NodeRunnerDisplayText[3], NodeRunnerDescText[3];
var() config bool UseCharge, UseHighPower;

static function FillPlayInfo(PlayInfo PlayInfo)
{
	local array<CacheManager.VehicleRecord> Recs;
	local string WeaponOptions;
	local int i;

	Super.FillPlayInfo(PlayInfo);

	class'CacheManager'.static.GetVehicleList(Recs);
	for (i = 0; i < Recs.Length; i++)
	{
		if (WeaponOptions != "")
			WeaponOptions $= ";";

		WeaponOptions $= Recs[i].ClassName $ ";" $ Recs[i].FriendlyName;
	}
    PlayInfo.AddSetting(default.RulesGroup, "UseCharge", default.NodeRunnerDisplayText[1], 0, 1, "Check");
	PlayInfo.AddSetting(default.RulesGroup, "ReplaceWhat", default.NodeRunnerDisplayText[0], 0, 1, "Select", WeaponOptions);
    PlayInfo.AddSetting(default.RulesGroup, "UseHighPower", default.NodeRunnerDisplayText[2], 0, 1, "Check");
}

static event string GetDescriptionText(string PropName)
{
	if (PropName == "ReplaceWhat")
		return default.NodeRunnerDescText[0];
	if (PropName == "UseCharge")
		return default.NodeRunnerDescText[1];
	if (PropName == "UseHighPower")
		return default.NodeRunnerDescText[2];

	return Super.GetDescriptionText(PropName);
}

function bool CheckReplacement( Actor Other, out byte bSuperRelevant )
{
 bSuperRelevant=0;
 //What v
 if (UseCharge)
 {
  ReplaceWithThis=class'NodeRunnerOmni.NodeRunnerOmniTwinBeam';
  // ReplaceWithThis=class'NodeRunnerFinal105.ONSNodeRunnerCharge';
 }
 else
 {
   ReplaceWithThis=class'NodeRunnerOmni.NodeRunnerOmniMinigun';
 }
 //End of what v

 //Replaceing The stuff
 if ( ONSVehicleFactory(Other) != None )
 {
  if ( ONSVehicleFactory(Other).VehicleClass == ReplaceWhat )
  {
   ONSVehicleFactory(Other).VehicleClass = ReplaceWithThis;
  }
 }
 //End of replacing
 if (UseHighPower)
 {
  if ( NodeRunOmniGun(Other) != None )
  {
  NodeRunOmniGun(Other).FireInterval=0.1;  // 0.075
  NodeRunOmniGun(Other).AltFireInterval=1.5;
  }

  if ( NodeRunOmniRearMiniGun(Other) != None )
  {
  NodeRunOmniRearMiniGun(Other).DamageMax=26;
  NodeRunOmniRearMiniGun(Other).DamageMin=24;
  }
 }
 return true;
}

defaultproperties
{
     ReplaceWithThis=Class'NodeRunnerOmni.NodeRunnerOmniMinigun'
     ReplaceWhat=Class'Onslaught.ONSHoverBike'
     NodeRunnerDisplayText(0)="What Vehicle Would You like To Replace?"
     NodeRunnerDisplayText(1)="Charge Beam Turret instead of Minigun Turret?"
     NodeRunnerDisplayText(2)="More Powerful (Beta3.1-strength) Weapons?"
     NodeRunnerDescText(0)="Select which vehicle you want to replace with the NodeRunner"
     NodeRunnerDescText(1)="If selected it will use the Charge Beam NodeRunner"
     NodeRunnerDescText(2)="If selected it will use the high-powered Versions of the Minigun NodeRunner"
     UseHighPower=True
     FriendlyName="NodeRunner Omni Mutator"
     Description="Lets you select which NodeRunner turret version you want (Minigun or TwinBeam), which vehicle the NR replaces, and what weapon strength to use (weaker, balanced Final strength or overpowered Beta 3.1 strength"
}
