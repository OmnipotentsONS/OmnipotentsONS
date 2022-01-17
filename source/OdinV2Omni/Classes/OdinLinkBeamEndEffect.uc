/******************************************************************************
AmbientHitSound

Creation date: 2012-10-25 16:33
Last change: $Id$
Copyright © 2012, Wormbo
Website: http://www.koehler-homepage.de/Wormbo/
Feel free to reuse this code. Send me a note if you found it helpful or want
to report bugs/provide improvements.
Please ask for permission first, if you intend to make money off reused code.
******************************************************************************/

class OdinLinkBeamEndEffect extends Effects;


//=============================================================================
// Imports
//=============================================================================

#exec audio import file=Sounds\OdinLinkHitAmbient.wav


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
     LightType=LT_Steady
     LightEffect=LE_NonIncidence
     LightHue=40
     LightSaturation=100
     LightBrightness=240.000000
     LightRadius=10.000000
     bHidden=True
     AmbientSound=Sound'WVHoverTankV2.OdinLinkHitAmbient'
     SoundVolume=200
     SoundRadius=400.000000
}
