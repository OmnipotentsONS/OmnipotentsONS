/******************************************************************************
DamTypeStormCasterLightning

Creation date: 2013-09-09 10:10
Last change: $Id$
Copyright © 2013, Wormbo
Website: http://www.koehler-homepage.de/Wormbo/
Feel free to reuse this code. Send me a note if you found it helpful or want
to report bugs/provide improvements.
Please ask for permission first, if you intend to make money off reused code.
******************************************************************************/

class DamTypeStormCasterLightning extends WeaponDamageType abstract;


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
     WeaponClass=Class'StormCasterV3.StormCaster'
     DeathString="%o got lost in %k's thunderstorm"
     FemaleSuicide="%o got lost in her own thunderstorm"
     MaleSuicide="%o got lost in his own thunderstorm"
     bArmorStops=False
     bLocationalHit=False
     bCauseConvulsions=True
     bSuperWeapon=True
     bCausesBlood=False
     bDelayedDamage=True
     bNeverSevers=True
     DamageOverlayMaterial=Shader'XGameShaders.PlayerShaders.LightningHit'
     DamageOverlayTime=1.000000
}
