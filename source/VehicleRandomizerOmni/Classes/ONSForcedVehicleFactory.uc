//=============================================================================
// ONSForcedVehicleFactory.
//=============================================================================
class ONSForcedVehicleFactory extends ONSVehicleFactory
	placeable;

var() class<Vehicle> DefaultVehicleClass;
var() float DefaultSpawnTime;
var() bool bIgnoreVehicleRandomizer;

defaultproperties
{
	Mesh=SkeletalMesh'ONSVehicles-A.HoverTank'
}