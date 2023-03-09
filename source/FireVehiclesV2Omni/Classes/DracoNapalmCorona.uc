/**
WVDraco.DracoNapalmCorona

Creation date: 2013-11-13 11:27
Last change: $Id$
Copyright (c) 2013, Wormbo
*/

class DracoNapalmCorona extends Actor;


function Kill()
{
	LifeSpan = 0.5;
	GotoState('Fading');
}

state Fading
{
	ignores Kill;
	
	function Tick(float DeltaTime)
	{
		ScaleGlow = 2.0 * LifeSpan;
		SoundVolume = default.SoundVolume * 2.0 * LifeSpan;
	}
}


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
     LightHue=25
     LightSaturation=40
     LightRadius=1000.000000
     bCorona=True
     bHighDetail=True
     Physics=PHYS_Trailer
     RemoteRole=ROLE_None
     AmbientSound=Sound'GeneralAmbience.firefx11'
     DrawScale=0.500000
     Skins(0)=Texture'EmitterTextures.Flares.EFlareOY'
     SoundVolume=190
     SoundRadius=32.000000
}
