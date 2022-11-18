/******************************************************************************
DamTypeOdinLinkBeam

Creation date: 2012-10-24 18:45
Last change: $Id$
Copyright © 2012, Wormbo
Website: http://www.koehler-homepage.de/Wormbo/
Feel free to reuse this code. Send me a note if you found it helpful or want
to report bugs/provide improvements.
Please ask for permission first, if you intend to make money off reused code.
******************************************************************************/

class DamTypeOdinLinkBeam extends OVVehicleProxyDamageType abstract;


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
     MessageSourceDamageType=Class'XWeapons.DamTypeLinkShaft'
     VehicleClass=Class'OdinV2Omni.OdinLinkTurretPawn'
     bDetonatesGoop=True
     bSkeletize=True
     bCausesBlood=False
     bLeaveBodyEffect=True
}
