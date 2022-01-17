/******************************************************************************
Dummy controller for keeping hover damping active when only turrets are manned.

Creation date: 2013-02-16 12:50
Last change: $Id$
Copyright © 2013, Wormbo
Website: http://www.koehler-homepage.de/Wormbo/
Feel free to reuse this code. Send me a note if you found it helpful or want
to report bugs/provide improvements.
Please ask for permission first, if you intend to make money off reused code.
******************************************************************************/

class DummyController extends Controller;


static function Controller GetDummy(LevelInfo L)
{
	local Controller C;

	if (L == None)
		return None;

	for (C = L.ControllerList; C != None; C = C.NextController)
	{
		if (C.Class == default.Class)
			return C;
	}

	return L.Spawn(default.Class);
}


state GameEnded
{
	function BeginState()
	{
		LifeSpan = 0.001;
	}
}

state RoundEnded
{
	function BeginState()
	{
		LifeSpan = 0.001;
	}
}


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
}
