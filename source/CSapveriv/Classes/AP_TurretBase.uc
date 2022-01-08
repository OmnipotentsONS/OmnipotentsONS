//=============================================================================
// AP_TurretBase
//=============================================================================

class AP_TurretBase extends Actor
	Abstract;

simulated function UpdateSwivelRotation( Rotator TurretRotation );
//=============================================================================
// defaultproperties
//=============================================================================

defaultproperties
{
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'AS_Weapons_SM.Turret.ASTurret_Base'
     bIgnoreEncroachers=True
     RemoteRole=ROLE_None
     DrawScale=5.000000
     AmbientGlow=64
     bMovable=False
     bCollideActors=True
     bBlockActors=True
     bBlockZeroExtentTraces=False
     bBlockNonZeroExtentTraces=False
     bBlockKarma=True
}
