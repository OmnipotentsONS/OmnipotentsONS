/******************************************************************************
IonTurretSocket

Creation date: 2012-10-21 16:20
Last change: $Id$
Copyright © 2012, Wormbo
Website: http://www.koehler-homepage.de/Wormbo/
Feel free to reuse this code. Send me a note if you found it helpful or want
to report bugs/provide improvements.
Please ask for permission first, if you intend to make money off reused code.
******************************************************************************/

class IonTurretSocket extends OVTurretSocket;


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
     RedSkin=Shader'WVHoverTankV2.Skins.IonTurretLit1Red'
     BlueSkin=Shader'WVHoverTankV2.Skins.IonTurretLit1Blue'
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'WVHoverTankV2.Odin.IonSwivelNoBase'
     DrawScale=0.200000
     DrawScale3D=(Y=2.000000)
}
