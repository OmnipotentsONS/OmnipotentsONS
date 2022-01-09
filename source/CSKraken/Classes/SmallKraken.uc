//=============================================================================
// SmallKraken.
//=============================================================================
class SmallKraken extends Kraken;

defaultproperties
{
     VehiclePositionString="in a Tiamat"
     VehicleNameString="Tiamat"
     HealthMax=5000.000000
     Health=5000
     DrawScale=0.800000
     Begin Object Class=KarmaParamsRBFull Name=KarmaParamsRBFull5
         KInertiaTensor(0)=1.300000
         KInertiaTensor(3)=4.000000
         KInertiaTensor(5)=4.500000
         KLinearDamping=0.150000
         KAngularDamping=0.000000
         KStartEnabled=True
         bHighDetailOnly=False
         bClientOnly=False
         bKDoubleTickRate=True
         bKStayUpright=True
         bKAllowRotate=True
         bDestroyOnWorldPenetrate=True
         bDoSafetime=True
         KFriction=0.500000
         KImpactThreshold=700.000000
     End Object
     KParams=KarmaParamsRBFull'CSKraken.KarmaParamsRBFull5'

}
