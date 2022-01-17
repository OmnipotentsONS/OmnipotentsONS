// ============================================================================
// LinkFlyer                                                        ItsMeAgain
// Mutator for Replace Raptor
// ============================================================================
class MutRaptorLinkFlyer extends Mutator;

// ============================================================================
// Internal vars
// ============================================================================
var class<SVehicle> VehicleClass, ReplacedVehicleClass;

// ============================================================================
function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
    {
    local ONSVehicleFactory F;
    bSuperRelevant=0;
    if (Other.IsA('ONSVehicleFactory'))
        {
        F=ONSVehicleFactory(Other);

        if (F.VehicleClass==ReplacedVehicleClass)
            F.VehicleClass=VehicleClass;
        }
    return true;
    }

// ============================================================================
// defaultproperties
// ============================================================================

defaultproperties
{
     VehicleClass=Class'ONSLinkFlyer.ONSLinkFlyer'
     ReplacedVehicleClass=Class'Onslaught.ONSAttackCraft'
     bAddToServerPackages=True
     GroupName="VehicleArena"
     FriendlyName="Chupacabra 1.0"
     Description="Replace the Raptor with the Chupacabra(LinkFlyer) 1.0"
}
