class Turtle extends ONSShockTank
	placeable;

#exec OBJ LOAD FILE=..\textures\Reptiles_Tex.utx
#exec OBJ LOAD FILE=..\Sounds\CuddlyArmor_Sound.uax

function bool ImportantVehicle()
{
	return true;
}

function ShouldTargetMissile(Projectile P)
{
	local AIController C;

	C = AIController(Controller);
	if ( (C != None) && (C.Skill >= 2.0) )
		TurtleCannon(Weapons[0]).ShieldAgainstIncoming(P);
}

function bool Dodge(eDoubleClickDir DoubleClickMove)
{
	TurtleCannon(Weapons[0]).ShieldAgainstIncoming();
	return false;
}

function VehicleCeaseFire(bool bWasAltFire)
{
    Super.VehicleCeaseFire(bWasAltFire);

    if (bWasAltFire && TurtleCannon(Weapons[ActiveWeapon]) != None)
        TurtleCannon(Weapons[ActiveWeapon]).CeaseAltFire();
}

simulated function Tick(float deltatime)
{
	if (Vsize(Velocity) < 500)
	{
		wheels[1].SteerType = VST_Steered;   
		wheels[5].SteerType = VST_Steered;
		wheels[6].SteerType = VST_Inverted;   
		wheels[2].SteerType = VST_Inverted;
	}
	Else if (Vsize(Velocity) >=500)
	{
		wheels[1].SteerType = VST_Fixed;   
		wheels[5].SteerType = VST_Fixed;
		wheels[6].SteerType = VST_Fixed;   
		wheels[2].SteerType = VST_Fixed;
	}
	if (Role == ROLE_Authority 
    && Weapons.Length > 0 
    && TurtleCannon(Weapons[0]) != None 
    && TurtleCannon(Weapons[0]).bShieldActive)
		{
		    NumForwardGears=3;
		}
		Else
		{
		    NumForwardGears=4;
		}
    Super.tick(deltatime);
}


event TakeDamage(int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType)
{
	local vector ShieldHitLocation, ShieldHitNormal;

	if (DamageType.name == 'MinotaurTurretkill' && !TurtleCannon(Weapons[0]).bShieldActive)
		Damage *= 0.20;

	if (DamageType.name == 'MinotaurSecondaryTurretKill' && !TurtleCannon(Weapons[0]).bShieldActive)
		Damage *= 0.20;

	if (DamageType.name == 'HeatRay' && !TurtleCannon(Weapons[0]).bShieldActive)
		Damage *= 0.20;

  if (DamageType.name == 'BallistaShell') 
     if (TurtleCannon(Weapons[0]).bShieldActive) 
         Damage *=0.33;
     else    
         Damage *= 0.50; 

	if (DamageType.name == 'FireKill'
	    || DamageType.name == 'Burned'
	    || DamageType.name == 'FlameKill'
	    || DamageType.name == 'Fireball'
	    || DamageType.name == 'DamTypeDracoFlameThrower'
	    || DamageType.name == 'DamTypeDracoNapalmRocket'
	    || DamageType.name == 'DamTypeDracoNapalmGlob'
	    || DamageType.name == 'DamTypeTurretFlames'
	    || DamageType.name == 'DamTypeFirebugFlame'
	    ) 	
	    if (TurtleCannon(Weapons[0]).bShieldActive) 
         Damage *=0.33;
      else    
         Damage *= 1.15; 
	    
	if (DamageType.name == 'DamTypeFirebugExplosion') Damage *= 2.0;

  if (DamageType.name == 'ArbalestClusterBomb_Kill' || DamageType.name == 'ArbalestRocketNova') Damage *= 0.50; 

  if (DamageType.name == 'DamTypeIonTankBlast') 
    	if (TurtleCannon(Weapons[0]).bShieldActive) 
    	   Damage *= 0.33;
    	else
    	   Damage *= 0.50; 


	if ( (Weapons.Length > 0) && TurtleCannon(Weapons[0]).bShieldActive && (TurtleCannon(Weapons[0]).TShield != None) && (Momentum != vect(0,0,0))
		&& (HitLocation != Location) && (DamageType != None) && (ClassIsChildOf(DamageType,class'WeaponDamageType') || ClassIsChildOf(DamageType,class'VehicleDamageType')) 
		&& !TurtleCannon(Weapons[0]).TShield.TraceThisActor(ShieldHitLocation,ShieldHitNormal,HitLocation,HitLocation - 2000*Normal(Momentum)) )
		return;

	Momentum *= 0.00;

  if (DamageType == class'TurtleDamTypeProximityExplosion' && EventInstigator != None && EventInstigator == self)
     return;

  if (DamageType == class'TurtleKill' && EventInstigator != None && EventInstigator == self)
     return;

  Super.TakeDamage(Damage, EventInstigator, HitLocation, Momentum, DamageType);
}

simulated function vector GetTargetLocation()
{
	return Location + vect(0,0,1)*CollisionHeight;
}

static function StaticPrecache(LevelInfo L)
{
    Super.StaticPrecache(L);

    L.AddPrecacheMaterial(Material'Reptiles_Tex.Turtle.RedTurtle');
    L.AddPrecacheMaterial(Material'Reptiles_Tex.Turtle.BlueTurtle');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Fire.SmokeFragment');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Fire.NapalmSpot');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Energy.ElecPanelsP');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Energy.ElecPanels');
    L.AddPrecacheMaterial(Material'ExplosionTex.Framed.exp2_framesP');
    L.AddPrecacheMaterial(Material'ONSInterface-TX.tankBarrelAligned');
    L.AddPrecacheMaterial(Material'AW-2k4XP.Weapons.ShockTankEffectCore2');
    L.AddPrecacheMaterial(Material'AW-2k4XP.Weapons.ShockTankEffectSwirl');
    L.AddPrecacheMaterial(Material'AW-2k4XP.Weapons.ShockBallTrail');
    L.AddPrecacheMaterial(Material'AW-2k4XP.Weapons.ShockTankEffectCore2a');
    L.AddPrecacheMaterial(Material'AW-2k4XP.Weapons.ShockRingTex');
    L.AddPrecacheMaterial(Material'AW-2k4XP.Weapons.ShockTankEffectCore');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Energy.SmoothRing');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Fire.Ripples1P');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Fire.Ripples2P');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.BoloBlob');
    L.AddPrecacheMaterial(Material'AW-2k4XP.Weapons.ElectricShockTexG');
    L.AddPrecacheMaterial(Material'AW-2k4XP.Weapons.ElectricShockTexG2');
    L.AddPrecacheMaterial(Material'VehicleFX.Particles.DustyCloud2');
    L.AddPrecacheMaterial(Material'VMParticleTextures.DirtKICKGROUP.dirtKICKTEX');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.SoftFade');
    L.AddPrecacheMaterial(Material'AbaddonArchitecture.Base.bas27go');
}

simulated function UpdatePrecacheStaticMeshes()
{
    Super.UpdatePrecacheStaticMeshes();
}

simulated function UpdatePrecacheMaterials()
{
    Level.AddPrecacheMaterial(Material'Reptiles_Tex.Turtle.RedTurtle');
    Level.AddPrecacheMaterial(Material'Reptiles_Tex.Turtle.BlueTurtle');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Fire.SmokeFragment');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Fire.NapalmSpot');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Energy.ElecPanelsP');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Energy.ElecPanels');
    Level.AddPrecacheMaterial(Material'ExplosionTex.Framed.exp2_framesP');
    Level.AddPrecacheMaterial(Material'ONSInterface-TX.tankBarrelAligned');
    Level.AddPrecacheMaterial(Material'AW-2k4XP.Weapons.ShockTankEffectCore2');
    Level.AddPrecacheMaterial(Material'AW-2k4XP.Weapons.ShockTankEffectSwirl');
    Level.AddPrecacheMaterial(Material'AW-2k4XP.Weapons.ShockBallTrail');
    Level.AddPrecacheMaterial(Material'AW-2k4XP.Weapons.ShockTankEffectCore2a');
    Level.AddPrecacheMaterial(Material'AW-2k4XP.Weapons.ShockRingTex');
    Level.AddPrecacheMaterial(Material'AW-2k4XP.Weapons.ShockTankEffectCore');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Energy.SmoothRing');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Fire.Ripples1P');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Fire.Ripples2P');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.BoloBlob');
    Level.AddPrecacheMaterial(Material'AW-2k4XP.Weapons.ElectricShockTexG');
    Level.AddPrecacheMaterial(Material'AW-2k4XP.Weapons.ElectricShockTexG2');
    Level.AddPrecacheMaterial(Material'VehicleFX.Particles.DustyCloud2');
    Level.AddPrecacheMaterial(Material'VMParticleTextures.DirtKICKGROUP.dirtKICKTEX');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.SoftFade');
    Level.AddPrecacheMaterial(Material'AbaddonArchitecture.Base.bas27go');

	Super.UpdatePrecacheMaterials();
}

defaultproperties
{
     WheelLongFrictionScale=5.000000
     WheelLatFrictionScale=2.000000
     MinBrakeFriction=2.000000
     GearRatios(1)=0.470000
     GearRatios(2)=0.730000
     GearRatios(3)=0.960000
     GearRatios(4)=1.490000
     MaxBrakeTorque=10.000000
     EngineRPMSoundRange=10000.000000
     DriverWeapons(0)=(WeaponClass=Class'TurtleOmni.TurtleCannon')
     RedSkin=Texture'Reptiles_Tex.Turtle.RedTurtle'
     BlueSkin=Texture'Reptiles_Tex.Turtle.BlueTurtle'
     IdleSound=Sound'CuddlyArmor_Sound.Turtle.TurtleEngine'
     bEjectPassengersWhenFlipped=False
     ImpactDamageMult=0.000000
     Begin Object Class=SVehicleWheel Name=RWheel1
         bPoweredWheel=True
         SteerType=VST_Steered
         BoneName="8WheelerWheel01"
         BoneRollAxis=AXIS_Y
         BoneOffset=(Y=7.000000)
         WheelRadius=44.000000
         SupportBoneName="Suspension_Right1"
         SupportBoneAxis=AXIS_X
     End Object
     Wheels(0)=SVehicleWheel'TurtleOmni.Turtle.RWheel1'

     Begin Object Class=SVehicleWheel Name=RWheel2
         bPoweredWheel=True
         BoneName="8WheelerWheel03"
         BoneRollAxis=AXIS_Y
         BoneOffset=(Y=7.000000)
         WheelRadius=44.000000
         SupportBoneName="Suspension_Right2"
         SupportBoneAxis=AXIS_X
     End Object
     Wheels(1)=SVehicleWheel'TurtleOmni.Turtle.RWheel2'

     Begin Object Class=SVehicleWheel Name=RWheel3
         bPoweredWheel=True
         BoneName="8WheelerWheel05"
         BoneRollAxis=AXIS_Y
         BoneOffset=(Y=7.000000)
         WheelRadius=44.000000
         SupportBoneName="Suspension_Right3"
         SupportBoneAxis=AXIS_X
     End Object
     Wheels(2)=SVehicleWheel'TurtleOmni.Turtle.RWheel3'

     Begin Object Class=SVehicleWheel Name=RWheel4
         bPoweredWheel=True
         SteerType=VST_Inverted
         BoneName="8WheelerWheel07"
         BoneRollAxis=AXIS_Y
         BoneOffset=(Y=7.000000)
         WheelRadius=44.000000
         SupportBoneName="Suspension_Right4"
         SupportBoneAxis=AXIS_X
     End Object
     Wheels(3)=SVehicleWheel'TurtleOmni.Turtle.RWheel4'

     Begin Object Class=SVehicleWheel Name=LWheel1
         bPoweredWheel=True
         SteerType=VST_Steered
         BoneName="8WheelerWheel02"
         BoneRollAxis=AXIS_Y
         BoneOffset=(Y=7.000000)
         WheelRadius=44.000000
         SupportBoneName="Suspension_Left1"
         SupportBoneAxis=AXIS_X
     End Object
     Wheels(4)=SVehicleWheel'TurtleOmni.Turtle.LWheel1'

     Begin Object Class=SVehicleWheel Name=LWheel2
         bPoweredWheel=True
         BoneName="8WheelerWheel04"
         BoneRollAxis=AXIS_Y
         BoneOffset=(Y=7.000000)
         WheelRadius=44.000000
         SupportBoneName="Suspension_Left2"
         SupportBoneAxis=AXIS_X
     End Object
     Wheels(5)=SVehicleWheel'TurtleOmni.Turtle.LWheel2'

     Begin Object Class=SVehicleWheel Name=LWheel3
         bPoweredWheel=True
         BoneName="8WheelerWheel06"
         BoneRollAxis=AXIS_Y
         BoneOffset=(Y=7.000000)
         WheelRadius=44.000000
         SupportBoneName="Suspension_Left3"
         SupportBoneAxis=AXIS_X
     End Object
     Wheels(6)=SVehicleWheel'TurtleOmni.Turtle.LWheel3'

     Begin Object Class=SVehicleWheel Name=LWheel4
         bPoweredWheel=True
         SteerType=VST_Inverted
         BoneName="8WheelerWheel08"
         BoneRollAxis=AXIS_Y
         BoneOffset=(Y=7.000000)
         WheelRadius=44.000000
         SupportBoneName="Suspension_Left4"
         SupportBoneAxis=AXIS_X
     End Object
     Wheels(7)=SVehicleWheel'TurtleOmni.Turtle.LWheel4'

     VehicleMass=9.000000
     bPCRelativeFPRotation=False
     TPCamDistance=100.000000
     DriverDamageMult=0.000000
     VehiclePositionString="in an Turtle"
     VehicleNameString="Turtle 1.0"
     RanOverDamageType=Class'TurtleOmni.TurtleDamTypeRoadkill'
     CrushedDamageType=Class'TurtleOmni.TurtleDamTypePancake'
     HornSounds(0)=Sound'CuddlyArmor_Sound.Horns.Horn6'
     HornSounds(1)=Sound'CuddlyArmor_Sound.Horns.Bighorn'
     HealthMax=1150.000000
     Health=1150
     Begin Object Class=KarmaParamsRBFull Name=KarmaParamsRBFull1
         KInertiaTensor(0)=1.000000
         KInertiaTensor(3)=3.000000
         KInertiaTensor(5)=3.000000
         KCOMOffset=(X=-0.250000,Z=-1.350000)
         KLinearDamping=0.050000
         KAngularDamping=0.050000
         KStartEnabled=True
         bKNonSphericalInertia=True
         bHighDetailOnly=False
         bClientOnly=False
         bKDoubleTickRate=True
         bDestroyOnWorldPenetrate=True
         bDoSafetime=True
         KFriction=0.500000
         KImpactThreshold=700.000000
     End Object
     KParams=KarmaParamsRBFull'TurtleOmni.Turtle.KarmaParamsRBFull1'

}
