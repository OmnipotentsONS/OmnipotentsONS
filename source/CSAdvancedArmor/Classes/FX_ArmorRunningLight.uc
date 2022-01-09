//=============================================================================
// FX_ArmorRunningLight.
//=============================================================================
class FX_ArmorRunningLight extends ScaledSprite;

var() float ExtinguishTime;
var int Team;
singular function BaseChange();

simulated function SetBlueColor()
{
    Team=1;
	Texture=Texture'BlueMarker_t';
}

simulated function SetRedColor()
{
    Team=0;
	Texture=Texture'RedMarker_t';
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
     Texture=Texture'XEffects.RedMarker_t'
     DrawScale=0.500000
     Style=STY_Additive
     bShouldBaseAtStartup=False
     bHardAttach=True
     Mass=0.000000
}
