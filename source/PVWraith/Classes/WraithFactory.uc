/******************************************************************************
BansheeFactory

Creation date: 2010-11-11 08:19
Last change: $Id$
Copyright © 2010, Wormbo
Website: http://www.koehler-homepage.de/Wormbo/
Feel free to reuse this code. Send me a note if you found it helpful or want
to report bugs/provide improvements.
Please ask for permission first, if you intend to make money off reused code.
******************************************************************************/

class WraithFactory extends ONSVehicleFactory;


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
     RespawnTime=30.000000
     RedBuildEffectClass=Class'Onslaught.ONSAttackCraftBuildEffectRed'
     BlueBuildEffectClass=Class'Onslaught.ONSAttackCraftBuildEffectBlue'
     VehicleClass=Class'PVWraith.Wraith'
     Mesh=SkeletalMesh'ONSBPAnimations.DualAttackCraftMesh'
}
