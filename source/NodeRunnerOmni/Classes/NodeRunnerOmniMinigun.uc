//-----------------------------------------------------------
//    VEHICLE: NodeRunner for Unreal Tournament 2004
//    DESIGNED & CODED BY: Mark Rossmore / April 2004
//    COPYRIGHT: ©2004 Wicked Penguin Corporation
//
//-----------------------------------------------------------
class NodeRunnerOmniMinigun extends ONSHoverBike;

// Not Used Pooty
// NEW STUFF
//var()   array<vector>	TrailEffectPositions;
//var     class<ONSAttackCraftExhaust>	TrailEffectClass;
//var     array<ONSAttackCraftExhaust>	TrailEffects;

//var()	array<vector>	StreamerEffectOffset;
//var     class<ONSAttackCraftStreamer>	StreamerEffectClass;
//var	array<ONSAttackCraftStreamer>	StreamerEffect;
// NEW STUFF END

simulated function CheckJumpDuck()
{
    local KarmaParams KP;
    local Emitter JumpEffect, DuckEffect;
    local bool bOnGround;
    local int i;

    KP = KarmaParams(KParams);

    // Can only start a jump when in contact with the ground.
    bOnGround = false;
    for(i=0; i<KP.Repulsors.Length; i++)
    {
        if( KP.Repulsors[i] != None && KP.Repulsors[i].bRepulsorInContact )
            bOnGround = true;
    }

    // If we are on the ground, and press Rise, and we not currently in the middle of a jump, start a new one.
    if (JumpCountdown <= 0.0 && Rise > 0 && bOnGround && !bHoldingDuck && Level.TimeSeconds - JumpDelay >= LastJumpTime)
    {
        PlaySound(JumpSound,,1.0);

        if (Role == ROLE_Authority)
           DoBikeJump = !DoBikeJump;

        if(Level.NetMode != NM_DedicatedServer)
        {
            JumpEffect = Spawn(class'NodeRunOmniJumpEffect');
            JumpEffect.SetBase(Self);
            ClientPlayForceFeedback(JumpForce);
        }

        if ( AIController(Controller) != None )
            Rise = 0;

        LastJumpTime = Level.TimeSeconds;
    }
    //else if (DuckCountdown <= 0.0 && (Rise < 0 || bWeaponIsAltFiring))
    else if (DuckCountdown <= 0.0 && Rise < 0)
    {
        if (!bHoldingDuck)
        {
            bHoldingDuck = True;

            PlaySound(DuckSound,,1.0);

            if(Level.NetMode != NM_DedicatedServer)
            {
                DuckEffect = Spawn(class'NodeRunOmniDuckEffect');
                DuckEffect.SetBase(Self);
            }

            if ( AIController(Controller) != None )
                Rise = 0;

            JumpCountdown = 0.0; // Stops any jumping that was going on.
        }
    }
    else
       bHoldingDuck = False;
}




static function StaticPrecache(LevelInfo L)
{
    Super.StaticPrecache(L);

	L.AddPrecacheStaticMesh(StaticMesh'ONSDeadVehicles-SM.HoverExploded.HoverWing');
	L.AddPrecacheStaticMesh(StaticMesh'ONSDeadVehicles-SM.HoverExploded.HoverChair');
	//L.AddPrecacheStaticMesh(StaticMesh'ONSNodeRunnerDead.NodeRunnerDead.NodeRunnerBurnt');
	L.AddPrecacheStaticMesh(StaticMesh'AW-2004Particles.Debris.Veh_Debris2');
	L.AddPrecacheStaticMesh(StaticMesh'AW-2004Particles.Debris.Veh_Debris1');
	L.AddPrecacheStaticMesh(StaticMesh'ONSWeapons-SM.PC_MantaJumpBlast');

	L.AddPrecacheMaterial(Material'ExplosionTex.Framed.exp2_frames');
    L.AddPrecacheMaterial(Material'ExplosionTex.Framed.exp1_frames');
    L.AddPrecacheMaterial(Material'ExplosionTex.Framed.we1_frames');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Fire.MuchSmoke1');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Fire.NapalmSpot');
    L.AddPrecacheMaterial(Material'EpicParticles.Fire.SprayFire1');
    L.AddPrecacheMaterial(Material'WeaponSkins.Skins.RocketTex0');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Energy.JumpDuck');
    L.AddPrecacheMaterial(Material'VMVehicles-TX.HoverBikeGroup.hovercraftFANSblurTEX');

    //L.AddPrecacheMaterial(Material'NodeRunnerTex..NRtexture');
    //L.AddPrecacheMaterial(Material'NodeRunnerTex..NRtexture');
    L.AddPrecacheMaterial(Texture'NodeRunnerTex.NRtextureRed');
    L.AddPrecacheMaterial(Texture'NodeRunnerTex.NRtextureBlue');
    //L.AddPrecacheMaterial(Material'VMVehicles-TX.HoverBikeGroup.hoverCraftRED');
    //L.AddPrecacheMaterial(Material'VMVehicles-TX.HoverBikeGroup.hoverCraftBLUE');
    L.AddPrecacheMaterial(Material'VMVehicles-TX.HoverBikeGroup.NewHoverCraftNOcolor');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Energy.AirBlast');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.SmokePanels2');
    L.AddPrecacheMaterial(Material'Engine.GRADIENT_Fade');

}

simulated function UpdatePrecacheStaticMeshes()
{
	Level.AddPrecacheStaticMesh(StaticMesh'ONSDeadVehicles-SM.HoverExploded.HoverWing');
	Level.AddPrecacheStaticMesh(StaticMesh'ONSDeadVehicles-SM.HoverExploded.HoverChair');
	Level.AddPrecacheStaticMesh(StaticMesh'AW-2004Particles.Debris.Veh_Debris2');
	Level.AddPrecacheStaticMesh(StaticMesh'AW-2004Particles.Debris.Veh_Debris1');
	// Precaching NR mesh!!!!
	// Level.AddPrecacheStaticMesh(StaticMesh'ONSNodeRunnerDead.NodeRunnerDead.NodeRunnerBurnt');
	Level.AddPrecacheStaticMesh(StaticMesh'ONSWeapons-SM.PC_MantaJumpBlast');
    Level.AddPrecacheMaterial(Material'VMVehicles-TX.HoverBikeGroup.hovercraftFANSblurTEX');

	Super.UpdatePrecacheStaticMeshes();
}

simulated function UpdatePrecacheMaterials()
{
    Level.AddPrecacheMaterial(Material'ExplosionTex.Framed.exp2_frames');
    Level.AddPrecacheMaterial(Material'ExplosionTex.Framed.exp1_frames');
    Level.AddPrecacheMaterial(Material'ExplosionTex.Framed.we1_frames');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Fire.MuchSmoke1');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Fire.NapalmSpot');
    Level.AddPrecacheMaterial(Material'EpicParticles.Fire.SprayFire1');
    Level.AddPrecacheMaterial(Material'WeaponSkins.Skins.RocketTex0');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Energy.JumpDuck');
    //Level.AddPrecacheMaterial(Material'NodeRunnerTex..NRtexture');
    //Level.AddPrecacheMaterial(Material'NodeRunnerTex..NRtexture');
    Level.AddPrecacheMaterial(Texture'NodeRunnerTex.NRtextureRed');
    Level.AddPrecacheMaterial(Texture'NodeRunnerTex.NRtextureBlue');
    //Level.AddPrecacheMaterial(Material'VMVehicles-TX.HoverBikeGroup.hoverCraftRED');
    //Level.AddPrecacheMaterial(Material'VMVehicles-TX.HoverBikeGroup.hoverCraftBLUE');
    Level.AddPrecacheMaterial(Material'VMVehicles-TX.HoverBikeGroup.NewHoverCraftNOcolor');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Energy.AirBlast');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.SmokePanels2');
    Level.AddPrecacheMaterial(Material'Engine.GRADIENT_Fade');

	Super.UpdatePrecacheMaterials();
}

defaultproperties
{
     MaxPitchSpeed=2000.000000
     JumpDuration=0.30000
     JumpForceMag=215.000000
     JumpDelay=3.000000
     DuckForceMag=150.000000
     BikeDustOffset(0)=(X=25.000000,Y=20.000000,Z=-20.000000)
     BikeDustOffset(1)=(X=25.000000,Y=-20.000000,Z=-20.000000)
     BikeDustTraceDistance=200.000000
     JumpSound=Sound'ONSVehicleSounds-S.HoverBike.HoverBikeJump05'
     DuckSound=Sound'ONSVehicleSounds-S.HoverBike.HoverBikeTurbo01'
     JumpForce="HoverBikeJump"
     ThrusterOffsets(0)=(X=95.000000,Z=10.000000)
     ThrusterOffsets(1)=(X=-10.000000,Y=80.000000,Z=10.000000)
     ThrusterOffsets(2)=(X=-10.000000,Y=-80.000000,Z=10.000000)
     HoverSoftness=0.090000
     HoverPenScale=1.000000
     HoverCheckDist=200.000000
     UprightStiffness=500.000000
     UprightDamping=300.000000
     MaxThrustForce=150.000000
     LongDamping=0.020000
     MaxStrafeForce=15.000000
     LatDamping=0.100000
     TurnTorqueFactor=1000.000000
     TurnTorqueMax=125.000000
     TurnDamping=40.000000
     MaxYawRate=1.500000
     PitchTorqueFactor=200.000000
     PitchTorqueMax=9.000000
     PitchDamping=20.000000
     RollTorqueTurnFactor=450.000000
     RollTorqueStrafeFactor=50.000000
     RollTorqueMax=12.500000
     RollDamping=30.000000
     StopThreshold=100.000000
     DriverWeapons(0)=(WeaponClass=Class'NodeRunnerOmni.NodeRunOmniGun',WeaponBone="GunFireLeft")
     bHasAltFire=True
     PassengerWeapons(0)=(WeaponPawnClass=Class'NodeRunnerOmni.NodeRunOmniRearMiniGunPawn',WeaponBone="Turret")
     RedSkin=Texture'NodeRunnerOmniTex.NRTextureRed'
     BlueSkin=Texture'NodeRunnerOmniTex.NRTextureBlue'
     IdleSound=Sound'ONSVehicleSounds-S.AttackCraft.AttackCraftIdle'
     StartUpSound=Sound'ONSVehicleSounds-S.AttackCraft.AttackCraftStartUp'
     ShutDownSound=Sound'ONSVehicleSounds-S.AttackCraft.AttackCraftShutDown'
     StartUpForce="AttackCraftStartUp"
     ShutDownForce="AttackCraftShutDown"
     DestroyedVehicleMesh=StaticMesh'ONSNodeRunnerDead.NodeRunnerDead.NodeRunnerBurnt'
     DestructionEffectClass=Class'Onslaught.ONSSmallVehicleExplosionEffect'
     DisintegrationEffectClass=Class'Onslaught.ONSVehDeathHoverBike'
     DestructionLinearMomentum=(Min=62000.000000,Max=100000.000000)
     DestructionAngularMomentum=(Min=25.000000,Max=75.000000)
     DamagedEffectScale=0.600000
     DamagedEffectOffset=(X=50.000000,Y=-25.000000,Z=10.000000)
     ImpactDamageMult=0.000100
     HeadlightCoronaOffset(0)=(X=65.000000,Y=5.000000,Z=14.000000)
     HeadlightCoronaOffset(1)=(X=65.000000,Y=5.000000,Z=14.000000)
     HeadlightCoronaMaterial=Texture'EpicParticles.Flares.FlashFlare1'
     HeadlightCoronaMaxSize=60.000000
     bDrawDriverInTP=True
     bTurnInPlace=True
     bShowDamageOverlay=True
     bScriptedRise=True
     bDriverHoldsFlag=False
     bCanCarryFlag=False
     DrivePos=(X=-45.000000,Z=50.000000)
     ExitPositions(0)=(Y=300.000000,Z=100.000000)
     ExitPositions(1)=(Y=-300.000000,Z=100.000000)
     ExitPositions(2)=(X=350.000000,Z=100.000000)
     ExitPositions(3)=(X=-350.000000,Z=100.000000)
     ExitPositions(4)=(X=-350.000000,Z=-100.000000)
     ExitPositions(5)=(X=350.000000,Z=-100.000000)
     ExitPositions(6)=(Y=300.000000,Z=-100.000000)
     ExitPositions(7)=(Y=-300.000000,Z=-100.000000)
     EntryRadius=180.000000
     FPCamPos=(Z=50.000000)
     TPCamDistance=550.000000
     TPCamLookat=(X=0.000000,Z=0.000000)
     TPCamWorldOffset=(Z=120.000000)
     VehiclePositionString="in a NodeRunner Omni"
     VehicleNameString="NodeRunner Omni Minigun 2.01"
     RanOverDamageType=Class'Onslaught.DamTypeHoverBikeHeadshot'
     CrushedDamageType=Class'Onslaught.DamTypeHoverBikePancake'
     ObjectiveGetOutDist=750.000000
     FlagBone="HoverCraft"
     FlagOffset=(Z=45.000000)
     FlagRotation=(Yaw=32768)
     HornSounds(0)=Sound'ONSVehicleSounds-S.Horns.Horn02'
     HornSounds(1)=Sound'ONSVehicleSounds-S.Horns.La_Cucharacha_Horn'
     bCanStrafe=True
     MeleeRange=-100.000000
     GroundSpeed=3000.000000  // Orig NR was 4000, Raptor is 2000  Not sure this applies, need KMaxSpeed
     HealthMax=275.000000
     Health=275
     Mesh=SkeletalMesh'ONSNodeRunner.NodeRunner'
     SoundRadius=900.000000
     Begin Object Class=KarmaParamsRBFull Name=KParams0
         KInertiaTensor(0)=1.300000
         KInertiaTensor(3)=4.000000
         KInertiaTensor(5)=4.500000
         KLinearDamping=0.150000
         KAngularDamping=0.000000
         KStartEnabled=True
         bHighDetailOnly=False
         KMaxSpeed=3000.000000
         bClientOnly=False
         bKDoubleTickRate=True
         bKStayUpright=True
         bKAllowRotate=True
         bDestroyOnWorldPenetrate=True
         bDoSafetime=True
         KFriction=0.500000
         KImpactThreshold=700.000000
     End Object
     KParams=KarmaParamsRBFull'NodeRunnerOmni.NodeRunnerOmniMinigun.KParams0'

}
