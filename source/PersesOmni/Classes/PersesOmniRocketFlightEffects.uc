/**
PersesRocketFlightEffects

Creation date: 2013-12-12 13:39
Last change: $Id$
Copyright (c) 2013, Wormbo
*/

class PersesOmniRocketFlightEffects extends Emitter abstract notplaceable;


function Kill()
{
	if (MeshEmitter(Emitters[0]) != None)
		Emitters[0].Disabled = True;
	Super.Kill();
}


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
     bNoDelete=False
     AmbientGlow=32
}
