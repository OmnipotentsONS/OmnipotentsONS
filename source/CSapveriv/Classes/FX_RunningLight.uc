//=============================================================================
// FX_RunningLight.
//=============================================================================
class FX_RunningLight extends ScaledSprite;
#exec OBJ LOAD FILE=APVerIV_Tex.utx
var() float ExtinguishTime;
var int Team;
singular function BaseChange();

simulated function SetBlueColor()
{
    Team=1;
	Texture=Texture'APVerIV_Tex.AP_FX.BlueFlash';
}

simulated function SetRedColor()
{
    Team=0;
	Texture=Texture'APVerIV_Tex.AP_FX.RedFlash';
}

simulated function SetInvisable()
{
   bHidden=true;
}

simulated function SetVisable()
{
   bHidden=False;
}

defaultproperties
{
     ExtinguishTime=1.500000
     bStatic=False
     bStasis=False
     Texture=Texture'APVerIV_Tex.AP_FX.RedFlash'
     DrawScale=0.500000
     Style=STY_Additive
     bShouldBaseAtStartup=False
     bHardAttach=True
     Mass=0.000000
     RemoteRole=ROLE_SimulatedProxy
}
