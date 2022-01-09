//=============================================================================
// BadgerFactory.
//=============================================================================
class BadgerFactory extends ONSVehicleFactory
	placeable;

defaultproperties
{
     RedBuildEffectClass=Class'Onslaught.ONSPRVBuildEffectRed'
     BlueBuildEffectClass=Class'Onslaught.ONSPRVBuildEffectBlue'
     VehicleClass=Class'CSBadgerFix.Badger'
     Mesh=SkeletalMesh'CSBadgerFix.BadgerChassis'
     bSelected=True
}
