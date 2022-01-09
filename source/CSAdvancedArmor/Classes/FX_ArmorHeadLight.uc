//=============================================================================
// FX_ArmorHeadLight.
//=============================================================================
class FX_ArmorHeadLight extends ScaledSprite;

var() float ExtinguishTime;
singular function BaseChange();

defaultproperties
{
     ExtinguishTime=1.500000
     bStatic=False
     bStasis=False
     RemoteRole=ROLE_SimulatedProxy
     Texture=Texture'EpicParticles.Flares.FlashFlare1'
     DrawScale=0.300000
     Style=STY_Additive
     bShouldBaseAtStartup=False
     bHardAttach=True
     Mass=0.000000
}
