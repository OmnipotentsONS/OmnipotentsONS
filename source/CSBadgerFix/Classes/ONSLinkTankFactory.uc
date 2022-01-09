// ============================================================================
// Link Tank factory.
// ============================================================================
class ONSLinkTankFactory extends ONSVehicleFactory
    placeable;

// ============================================================================

defaultproperties
{
     RespawnTime=45.000000
     RedBuildEffectClass=Class'Onslaught.ONSTankBuildEffectRed'
     BlueBuildEffectClass=Class'Onslaught.ONSTankBuildEffectBlue'
     VehicleClass=Class'CSBadgerFix.ONSLinkTank'
     Mesh=SkeletalMesh'AS_VehiclesFull_M.IonTankChassisSimple'
}
