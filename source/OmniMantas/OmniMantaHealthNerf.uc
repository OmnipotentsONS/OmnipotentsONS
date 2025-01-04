class OmniMantaHealthNerf extends Mutator config;
var() config bool bDebug;
var() config int MaxMantaHealth;

function Initialize()
{

	  Log("Mutator "@ FriendlyName@" Initialized",'OmniMantas');
	  
}


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
          }    
     }
     
     return true;
}

defaultproperties
{
     bAddToServerPackages=True
     FriendlyName="Omni Manta Health Nerf"
     Description="Nerf the health of any Manta to 325 or less..."
     MaxMantaHealth=325
}