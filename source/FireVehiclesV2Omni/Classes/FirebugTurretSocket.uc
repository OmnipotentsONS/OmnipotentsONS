/******************************************************************************
BallTurretSocket

Creation date: 2012-10-21 16:19
Last change: $Id$
Copyright © 2012, Wormbo
Website: http://www.koehler-homepage.de/Wormbo/
Feel free to reuse this code. Send me a note if you found it helpful or want
to report bugs/provide improvements.
Please ask for permission first, if you intend to make money off reused code.
******************************************************************************/

class FirebugTurretSocket extends TurretSocket;


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
     RedSkin=Texture'WVHoverTankV2.Skins.ASTurret_Base_Red'
     BlueSkin=Texture'AS_Weapons_TX.Turret.ASTurret_Base'
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'AS_Weapons_SM.Turret.ASTurret_Base'
     CullDistance=5000.000000
     DrawScale=3.966667
     PrePivot=(Z=-3.000000)
}
