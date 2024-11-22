/**
PersesTrailFLightEffects

Creation date: 2013-12-14 08:47
Last change: $Id$
Copyright (c) 2013, Wormbo
*/

class PersesOmniTrailFLightEffects extends PersesOmniRocketFlightEffects abstract;


/**
Make sure the trail emitter really reaches the explosion location and fade out
the thruster flame, then kill the emitter.
*/
function Kill()
{
	if (MeshEmitter(Emitters[0]) != None)
		Emitters[0].Disabled = True;
	AmbientSound = None;
	TrailEmitter(Emitters[1]).DistanceThreshold = 1;
	GotoState('Killed');
}

/**
Make sure the trailer no longer moves while it dies. Wait a tick first, so
TrailEmitter can reach the explosion location.
*/
state Killed
{
Begin:
	Sleep(0.0);
	SetPhysics(PHYS_None);
	SetBase(None);
	SetOwner(None);
	Sleep(0.0);
	Super.Kill();
}


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
}
