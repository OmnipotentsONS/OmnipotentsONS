/******************************************************************************
DamTypeHoverTankShockwave

Creation date: 2011-08-07 13:42
Last change: $Id$
Copyright © 2011, Wormbo
Website: http://www.koehler-homepage.de/Wormbo/
Feel free to reuse this code. Send me a note if you found it helpful or want
to report bugs/provide improvements.
Please ask for permission first, if you intend to make money off reused code.
******************************************************************************/

class DamTypePoltergeistShockwave extends VehicleDamageType abstract;


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
     VehicleClass=Class'WVHoverTankV2.PoltergeistTank'
     DeathString="%o was caught by %k's energy shockwave."
     FemaleSuicide="%o stood in the way of her own energy shockwave."
     MaleSuicide="%o stood in the way of his own energy shockwave."
     bDelayedDamage=True
     DamageOverlayMaterial=Shader'UT2004Weapons.Shaders.ShockHitShader'
     DeathOverlayMaterial=Shader'UT2004Weapons.Shaders.ShockHitShader'
     DamageOverlayTime=0.800000
     DeathOverlayTime=1.500000
     VehicleDamageScaling=1.500000
     VehicleMomentumScaling=2.000000
}
