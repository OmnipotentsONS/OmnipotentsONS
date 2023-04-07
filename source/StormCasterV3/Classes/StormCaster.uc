/******************************************************************************
The Storm Caster Ion Painter weapon.

Copyright © 2013, Wormbo
Website: http://www.koehler-homepage.de/Wormbo/
Feel free to reuse this code. Send me a note if you found it helpful or want
to report bugs/provide improvements.
Please ask for permission first, if you intend to make money off reused code.
******************************************************************************/


class StormCaster extends Painter;


//=============================================================================
// Default properties
//=============================================================================

defaultproperties
{
     FireModeClass(0)=Class'StormCasterV3.StormCasterFire'
     Description="This weapon is basically identical to the standard Ion Painter. But instead of activating the VAPOR Ion Cannon satellite, it is linked to the orbital 'Storm Caster', a modified ion cannon satellite that causes a thunderstorm to form above the target area."
     GroupOffset=48
     PickupClass=Class'StormCasterV3.StormCasterPickup'
     ItemName="Storm Caster"
}
