//=============================================================================
// Deco_PredatorGears.
// Decoration Gears for Predator
//=============================================================================
class Deco_PredatorGears extends Decoration;


singular function BaseChange();

defaultproperties
{
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'APVerIV_ST.Predator_ST.PredatorGearsST'
     bStatic=False
     bStasis=False
     RemoteRole=ROLE_SimulatedProxy
     Style=STY_Additive
     bShouldBaseAtStartup=False
     bHardAttach=True
     Mass=0.000000
}
