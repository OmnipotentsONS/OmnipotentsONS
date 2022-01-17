/******************************************************************************
BallTurretSocket

Creation date: 2012-10-11 21:01
Last change: $Id$
Copyright © 2012, Wormbo
Website: http://www.koehler-homepage.de/Wormbo/
Feel free to reuse this code. Send me a note if you found it helpful or want
to report bugs/provide improvements.
Please ask for permission first, if you intend to make money off reused code.
******************************************************************************/

class TurretSocket extends Actor abstract;


//=============================================================================
// Properties
//=============================================================================

var() Material RedSkin;
var() Material BlueSkin;


simulated function SetTeam(byte T)
{
	if (T == 0 && RedSkin != None)
	{
		Skins[0] = RedSkin;
	}
	else if (T == 1 && BlueSkin != None)
	{
		Skins[0] = BlueSkin;
	}
}


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
     RemoteRole=ROLE_None
     bUseLightingFromBase=True
}
