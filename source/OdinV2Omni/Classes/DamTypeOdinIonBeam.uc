/******************************************************************************
DamTypeOdinIonBeam

Creation date: 2012-10-24 10:47
Last change: $Id$
Copyright © 2012, Wormbo
Website: http://www.koehler-homepage.de/Wormbo/
Feel free to reuse this code. Send me a note if you found it helpful or want
to report bugs/provide improvements.
Please ask for permission first, if you intend to make money off reused code.
******************************************************************************/

class DamTypeOdinIonBeam extends VehicleProxyDamageType abstract;


static function GetHitEffects(out class<xEmitter> HitEffects[4], int VictimHealth)
{
	HitEffects[0] = class'HitSmoke';
}


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
     MessageSourceDamageType=Class'XWeapons.DamTypeIonBlast'
     VehicleClass=Class'OdinV2Omni.OdinV2Omni'
     bDetonatesGoop=True
     bSkeletize=True
     GibModifier=0.000000
     DamageOverlayMaterial=Shader'UT2004Weapons.Shaders.ShockHitShader'
     DamageOverlayTime=1.000000
     VehicleDamageScaling=1.333333
}
