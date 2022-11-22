//-----------------------------------------------------------------------------
// UltimateRadarMapInteraction
// $ckr1: Copyright 2011  by D. 'Crusha K. Rool' I.$
// $ckr2: <Mapping.Crocodile@googlemail.com>$
// $ckr3: Release date: 12.10.2011 23:22:35 in Package: UltimateMappingTools$
//
// Used by the UltimateRadarMapHUDOverlay to toggle the RadarMap on or off
// with F12.
//-----------------------------------------------------------------------------
class UltimateRadarMapInteraction extends Interaction;


var UltimateRadarMapHUDOverlay ParentRadarMapHUDOverlay; // Set by the Overlay that created us.


// ============================================================================
// ToggleRadarMap
//
// Toggle the UltimateRadarMap on or off.
// ============================================================================

exec function ToggleRadarMap()
{
    if (ParentRadarMapHUDOverlay != None)
    {
        ParentRadarMapHUDOverlay.ToggleRadarMap();
    }
}

defaultproperties
{
}
