class OmniMantaHealthNerf extends Mutator;

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
     local ONSHoverBike manta;
     if(Other.IsA('ONSHoverBike')) // Mechs are HoverCraft, not hoverbikes && !Other.IsA('CSHoverMech'))
     {
          manta = ONSHoverBike(Other);
          if(manta.default.HealthMax > 325 || manta.default.Health > 325) {
              manta.default.HealthMax = 325;
              manta.default.Health = 325;
          }    
     }
     
     return true;
}

defaultproperties
{
     FriendlyName="Omni Manta Health Nerf"
     Description="Nerf the health of any Manta to 325 or less..."
}