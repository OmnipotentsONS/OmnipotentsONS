class StirgeFlyer extends ONSLinkFlyer;


simulated function DrawHUD(Canvas C)
{
	local int LinksSave;
	  LinksSave=Links;
	  Links=0; // Don't draw Linker display since it doesn't stack.
    Super.DrawHUD(C);
    Links=LinksSave;
    
}


    // ============================================================================
    // defaultproperties
    // ============================================================================

defaultproperties
{
    DriverWeapons(0)=(WeaponClass=Class'ONSLinkFlyer.StirgeFlyerWeapon')
    RedSkin=Combiner'StirgeFlyer_Tex.Stirge.StirgeCombinerRed'
    BlueSkin=Combiner'StirgeFlyer_Tex.Stirge.StirgeCombinerBlue'
    VehiclePositionString="in a Stirge"
    VehicleNameString="Stirge 1.01"
    Mesh=SkeletalMesh'StirgeFlyer_Mesh.Stirge.StirgeFinal'
    Health=300
    HealthMax=325
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
         KMaxSpeed=2100.000000
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
     KParams=KarmaParamsRBFull'ONSLinkFlyer.StirgeFlyer.KParams0'  
}     