/******************************************************************************
StormShadowProjector

Creation date: 2013-09-10 12:16
Last change: $Id$
Copyright � 2013, Wormbo
Website: http://www.koehler-homepage.de/Wormbo/
Feel free to reuse this code. Send me a note if you found it helpful or want
to report bugs/provide improvements.
Please ask for permission first, if you intend to make money off reused code.
******************************************************************************/

class StormShadowProjector extends xScorch;


//=============================================================================
// Imports
//=============================================================================

#exec texture import file=Textures\CloudShadow.dds UClampMode=Clamp VClampMode=Clamp


function PostBeginPlay()
{
	SetRotation(Rotation + rot(0,0,2) * Rand(0x7fff));

	Super(Projector).PostBeginPlay();

	AbandonProjector(LifeSpan);
	Destroy();
}


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
     ProjTexture=Texture'StormCasterV3.CloudShadow'
     MaxTraceDistance=15000
     bProjectActor=True
     bProjectOnParallelBSP=True
     FadeInTime=1.000000
     LifeSpan=21.000000
     DrawScale=35.000000
}
