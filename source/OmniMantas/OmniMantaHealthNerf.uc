class OmniMantaHealthNerf extends Mutator config;
var config bool bDebug;
var config int MaxMantaHealth;


function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
     local ONSHoverBike manta;
     if(Other.IsA('ONSHoverBike')) // Mechs are HoverCraft, not hoverbikes && !Other.IsA('CSHoverMech'))
     {
          manta = ONSHoverBike(Other);
          if(manta.default.HealthMax > MaxMantaHealth || manta.default.Health > MaxMantaHealth) {
              if (bDebug) log("Changing Health on"@manta@" from "@manta.default.Health@" to "@MaxMantaHealth,'OmniMantas');
              manta.default.HealthMax = MaxMantaHealth;
              manta.default.Health = MaxMantaHealth;
              manta.HealthMax = MaxMantaHealth;
              manta.Health = MaxMantaHealth;
              if (bDebug) log("Health on"@manta@" now "@manta.default.Health@" and max "@manta.default.HealthMax,'OmniMantas');
          }    
     }
     
     return true;
}

static function FillPlayInfo (PlayInfo PlayInfo)
{
	PlayInfo.AddClass(Default.Class);
	PlayInfo.AddSetting("Omni Manta Health Nerf", "MaxMantaHealth", "Maximum health for any Manta", 0, 0, "Text","4;1:5000");
	PlayInfo.AddSetting("Omni Manta Health Nerf", "bDebug", "Enable Debug Logging", 0, 1, "Check");
  
    
  PlayInfo.PopClass();
  super.FillPlayInfo(PlayInfo);
}



defaultproperties
{
     bAddToServerPackages=True
     bDebug=False
     FriendlyName="Omni Manta Health Nerf"
     Description="Nerf the health of any Manta to 325 (default) or less..."
     MaxMantaHealth=325
}