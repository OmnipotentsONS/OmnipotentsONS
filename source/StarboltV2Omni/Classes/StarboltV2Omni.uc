class StarboltV2Omni extends ONSAttackCraft;

function TakeDamage(int Damage, Pawn instigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> DamageType)
{


if (DamageType == class'DamTypeShockBeam')
		Damage *= 2;
		
if (DamageType == class'DamTypeMinigunBullet')
 		Damage *= 2;

if (DamageType == class'DamTypeSniperShot')
 		Damage *= 2;

    Super.TakeDamage(Damage, instigatedBy, Hitlocation, Momentum, damageType);
	
}

defaultproperties
{
     MaxPitchSpeed=5000.000000
     StreamerOpacityRamp=(Min=2000.000000,Max=6000.000000)
     MaxThrustForce=230.000000
     LongDamping=0.350000
     MaxStrafeForce=30.000000
     LatDamping=0.500000
     MaxRiseForce=180.000000
     UpDamping=0.300000
     TurnTorqueFactor=900.000000
     TurnTorqueMax=350.000000
     TurnDamping=75.000000
     MaxYawRate=3.000000
     DriverWeapons(0)=(WeaponClass=Class'StarboltV2Omni.StarboltGun')
     RedSkin=Shader'Starbolt_Tex.Starbolt.ShieldBodyRed'
     BlueSkin=Shader'Starbolt_Tex.Starbolt.ShieldBodyBlue'
     ImpactDamageMult=0.0010000
     VehiclePositionString="in a Starbolt"
     VehicleNameString="Starbolt 2.4"
     GroundSpeed=3550.000000
     HealthMax=200.000000
     Health=200
     CollisionRadius=130.000000
     Begin Object Class=KarmaParamsRBFull Name=KParams0
         KInertiaTensor(0)=1.000000
         KInertiaTensor(3)=3.000000
         KInertiaTensor(5)=3.500000
         KCOMOffset=(X=-0.250000)
         KLinearDamping=0.000000
         KAngularDamping=0.000000
         KStartEnabled=True
         bKNonSphericalInertia=True
         KActorGravScale=0.000000
         KMaxSpeed=3750.000000
         bHighDetailOnly=False
         bClientOnly=False
         bKDoubleTickRate=True
         bKStayUpright=True
         bKAllowRotate=True
         bDestroyOnWorldPenetrate=True
         bDoSafetime=True
         KFriction=0.500000
         KImpactThreshold=800.000000
     End Object
     KParams=KarmaParamsRBFull'StarboltV2Omni.StarboltV2Omni.KParams0'

}
