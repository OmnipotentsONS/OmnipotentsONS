/******************************************************************************
HoverTankWeapon

Creation date: 2013-02-16 13:27
Last change: $Id$
Copyright © 2013, Wormbo
Website: http://www.koehler-homepage.de/Wormbo/
Feel free to reuse this code. Send me a note if you found it helpful or want
to report bugs/provide improvements.
Please ask for permission first, if you intend to make money off reused code.
******************************************************************************/

class HoverTankWeapon extends ONSWeapon abstract;


var bool bTurnedOff;


simulated function Tick(float DeltaTime)
{
	if (bTurnedOff)
		return;

	if (Instigator != None && Instigator.PlayerReplicationInfo != None)
	{
		bForceCenterAim = False;
	}
	else if (!bActive && CurrentAim != rot(0,0,0))
	{
		bForceCenterAim = True;
		bActive = True;
	}
	else if (bActive && CurrentAim == rot(0,0,0))
	{
		bActive = False;
	}
}


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
}
