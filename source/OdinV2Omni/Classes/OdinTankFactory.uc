/******************************************************************************
OdinTankFactory

Creation date: 2012-08-14 10:24
Last change: $Id$
Copyright © 2012, Wormbo
Website: http://www.koehler-homepage.de/Wormbo/
Feel free to reuse this code. Send me a note if you found it helpful or want
to report bugs/provide improvements.
Please ask for permission first, if you intend to make money off reused code.
******************************************************************************/

class OdinTankFactory extends HoverTankFactory;


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
     RespawnTime=45.000000
     VehicleClass=Class'WVHoverTankV2.OdinHoverTank'
     DrawScale=1.200000
     Skins(0)=Shader'WVHoverTankV2.Skins.TankShaderRed'
     CollisionRadius=300.000000
}
