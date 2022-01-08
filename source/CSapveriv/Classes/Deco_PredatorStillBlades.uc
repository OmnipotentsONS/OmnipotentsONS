//=============================================================================
// PredatorStillBladesDeco.
//=============================================================================
class Deco_PredatorStillBlades extends Decoration;


singular function BaseChange();

defaultproperties
{
     bStatic=False
     bStasis=False
     RemoteRole=ROLE_SimulatedProxy
     Mesh=SkeletalMesh'APVerIV_Anim.HeliStillBlade'
     Style=STY_Additive
     bShouldBaseAtStartup=False
     bHardAttach=True
     Mass=0.000000
}
