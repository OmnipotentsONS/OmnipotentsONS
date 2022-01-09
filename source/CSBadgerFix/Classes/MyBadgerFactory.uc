//=============================================================================
// BadgerFactory.
//=============================================================================
class MyBadgerFactory extends ONSVehicleFactory
	placeable;

defaultproperties
{
     RedBuildEffectClass=Class'Onslaught.ONSPRVBuildEffectRed'
     BlueBuildEffectClass=Class'Onslaught.ONSPRVBuildEffectBlue'
     VehicleClass=Class'CSBadgerFix.MyBadger'
     Mesh=SkeletalMesh'CSBadgerFix.BadgerChassis'
     bSelected=True
}
