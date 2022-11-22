//=============================================================================
// Master of the UltimateRadarVehicleLRIs
// $ckr1: Copyright 2011  by D. 'Crusha K. Rool' I.$
// $ckr2: <Mapping.Crocodile@googlemail.com>$
// $ckr3: Release date: 14.08.2011 00:24:54 in Package: UltimateMappingTools$
//
// Serves as anchor for the first node in the linked list of UltimateRadarVehicleLRIs.
// Contains functions to add or remove new nodes at the correct position in the list.
//=============================================================================
class UltimateRadarVehicleLRIMaster extends ReplicationInfo;

var UltimateRadarVehicleLRI FirstVehicleLRI;
/* The first LRI referenced by this anchor. Used to have a fixed starting point
 * that is the same for all HUDOverlays that want to draw vehicles on the Radar.
 */



// ============================================================================
// AddVehicleLRI
//
// Add a VehicleLRI to the linked list by using a handwritten stack algorithm.
// Hope it works correct. The LinkedReplicationInfo-system of the PlayerController
// can't be used because it's static and can't be modified after startup.
// ============================================================================

simulated function AddVehicleLRI(UltimateRadarVehicleLRI VehicleLRI)
{
    local UltimateRadarVehicleLRI tempLRI;

    if (FirstVehicleLRI == None)
    {
        FirstVehicleLRI = VehicleLRI;
    }
    else
    {
        tempLRI = FirstVehicleLRI;
        while (tempLRI.NextVehicleLRI != None) // Set the pointer to the LRI that has no successor yet.
            tempLRI = tempLRI.NextVehicleLRI;

        tempLRI.NextVehicleLRI = VehicleLRI; // Make our pending LRI the successor of that LRI.
    }
}


// ============================================================================
// RemoveVehicleLRI
//
// Removes the LRI from the list that stores the informations for this vehicle.
// Again a handwritten algorithm, again I hope that all works fine.
// ============================================================================

simulated function RemoveVehicleLRI(UltimateRadarVehicleLRI U)
{
    local UltimateRadarVehicleLRI tempLRI;

    if (FirstVehicleLRI == U)
        FirstVehicleLRI = U.NextVehicleLRI;
    else
    {
        for (tempLRI = FirstVehicleLRI; tempLRI != None; tempLRI = tempLRI.NextVehicleLRI)
        {
            if (tempLRI.NextVehicleLRI == U)
            {
                tempLRI.NextVehicleLRI = U.NextVehicleLRI;
                break;
            }
        }
    }
}

defaultproperties
{
     NetPriority=2.000000
}
