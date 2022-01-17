/******************************************************************************
DamTypeBansheeLinkPlasma

Creation date: 2012-10-24 18:46
Last change: $Id$
Copyright © 2012, Wormbo
Website: http://www.koehler-homepage.de/Wormbo/
Feel free to reuse this code. Send me a note if you found it helpful or want
to report bugs/provide improvements.
Please ask for permission first, if you intend to make money off reused code.
******************************************************************************/

class DamTypeBansheeLinkPlasma extends MessageProxyDamageType abstract;


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
     MessageSourceDamageType=Class'XWeapons.DamTypeLinkPlasma'
     VehicleClass=Class'PVWraith.BansheeBellyGunPawn'
     bDetonatesGoop=True
     bDelayedDamage=True
     FlashFog=(X=700.000000)
}
