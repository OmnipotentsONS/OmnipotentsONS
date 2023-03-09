class FireTank extends ONSHoverTank
	placeable;

#exec OBJ LOAD FILE=..\Animations\ONSVehicles-A.ukx
#exec OBJ LOAD FILE=InterfaceContent.utx
#exec OBJ LOAD FILE=..\textures\VMVehicles-TX.utx
#exec OBJ LOAD FILE=..\textures\FireTank_Tex.utx
#exec OBJ LOAD FILE=..\Sounds\CuddlyArmor_Sound.uax

simulated function PostBeginPlay()
{
	super.PostBeginPlay();

	if ( Level.NetMode != NM_DedicatedServer )
		SetupTreads();
}

simulated function Destroyed()
{
	DestroyTreads();
	super.Destroyed();
}

function bool ImportantVehicle()
{
	return true;
}

replication
{
	reliable if (Role == ROLE_Authority)
		ReduceShake;
}


simulated function ReduceShake()
{
	local float ShakeScaling;
	local PlayerController Player;

	if (Controller == None || PlayerController(Controller) == None)
		return;

	Player = PlayerController(Controller);
	ShakeScaling = VSize(Player.ShakeRotMax) / 7500;

	if (ShakeScaling > 1)
	{
		Player.ShakeRotMax /= ShakeScaling;
		Player.ShakeRotTime /= ShakeScaling;
		Player.ShakeOffsetMax /= ShakeScaling;
	}
}


function TakeDamage(int Damage, Pawn instigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> DamageType)
{

  if (DamageType.name == 'DamTypeBioGlob')
     Damage *= 3.0;

	if (DamageType == class'DamTypeHoverBikePlasma')
		Damage *= 0.70;

	if (DamageType == class'DamTypeONSCicadaRocket')
		Damage *= 0.70;

	if (DamageType.name == 'AuroraLaser' || DamageType.name == 'WaspFlak')
		Damage *= 0.70;


	if (DamageType == class'DamTypeShockBeam')
		Damage *= 0.75;

	if (DamageType.name == 'DamTypeMinotaurClassicTurret')
		Damage *= 0.50;

	if (DamageType.name == 'DamTypeMinotaurClassicSecondaryTurret')
		Damage *= 0.50;

if (DamageType.name == 'OmnitaurTurretkill')
		Damage *= 0.50;

	if (DamageType.name == 'OmnitaurSecondaryTurretKill')
		Damage *= 0.50;

if (DamageType.name == 'MinotaurTurretkill')
		Damage *= 0.50;

	if (DamageType.name == 'MinotaurSecondaryTurretKill')
		Damage *= 0.50;

if (DamageType.name == 'FireKill')
		Damage *= 0.10;

if (DamageType.name == 'FlameKill')
		Damage *= 0.25;
				
if (DamageType.name == 'Burned')
		Damage *= 0.15;
		
if (DamageType.name == 'DamTypeFirebugFlame')
		Damage *= 0.50;

if (DamageType.name == 'FireBall')
		Damage *= 0.15;

if (DamageType.name == 'FlameKillRaptor')
		Damage *= 0.10;

if (DamageType.name == 'HeatRay')
		Damage *= 0.10;

if (DamageType.name == 'DamTypeDracoFlamethrower')
		Damage *= 0.30;

if (DamageType.name == 'DamTypeDracoNapalmRocket')
		Damage *= 0.20;

if (DamageType.name == 'DamTypeDracoNapalmGlob')
		Damage *= 0.20;



	//Momentum *= 0.00;

    Super.TakeDamage(Damage, instigatedBy, Hitlocation, Momentum, damageType);
	ReduceShake();
}



	
function KDriverEnter(Pawn p)
{
    Super.KDriverEnter(p);

    SVehicleUpdateParams();
}

function AltFire(optional float F)
{
    super(ONSTreadCraft).AltFire();
}

function ClientVehicleCeaseFire(bool bWasAltFire)
{
	super(ONSTreadCraft).ClientVehicleCeaseFire(bWasAltFire);
}

simulated function ClientKDriverLeave(PlayerController PC)
{
	super(ONSTreadCraft).ClientKDriverLeave(PC);
}

function DriverLeft()
{
    Super.DriverLeft();

    SVehicleUpdateParams();
}

static function StaticPrecache(LevelInfo L)
{
    Super.StaticPrecache(L);

	L.AddPrecacheStaticMesh(StaticMesh'ONSDeadVehicles-SM.TANKexploded.TankTurret');
	L.AddPrecacheStaticMesh(StaticMesh'AW-2004Particles.Debris.Veh_Debris2');
	L.AddPrecacheStaticMesh(StaticMesh'AW-2004Particles.Debris.Veh_Debris1');
	L.AddPrecacheStaticMesh(StaticMesh'WeaponStaticMesh.RocketProj');

    L.AddPrecacheMaterial(Material'AW-2004Particles.Energy.SparkHead');
    L.AddPrecacheMaterial(Material'ExplosionTex.Framed.exp2_frames');
    L.AddPrecacheMaterial(Material'ExplosionTex.Framed.exp1_frames');
    L.AddPrecacheMaterial(Material'ExplosionTex.Framed.we1_frames');
    L.AddPrecacheMaterial(Material'ExplosionTex.Framed.SmokeReOrdered');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Fire.MuchSmoke1');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Fire.NapalmSpot');
    L.AddPrecacheMaterial(Material'EpicParticles.Fire.SprayFire1');
    L.AddPrecacheMaterial(Material'VMVehicles-TX.HoverTankGroup.tankTreads');
    L.AddPrecacheMaterial(Material'VMParticleTextures.EJECTA.Tex');
	L.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.TrailBlur');
    L.AddPrecacheMaterial(Material'Engine.GRADIENT_Fade');
    L.AddPrecacheMaterial(Material'AW-2004Explosions.Fire.Fireball3');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Fire.SmokeFragment');
}

simulated function UpdatePrecacheStaticMeshes()
{
	Level.AddPrecacheStaticMesh(StaticMesh'ONSDeadVehicles-SM.TANKexploded.TankTurret');
	Level.AddPrecacheStaticMesh(StaticMesh'AW-2004Particles.Debris.Veh_Debris2');
	Level.AddPrecacheStaticMesh(StaticMesh'AW-2004Particles.Debris.Veh_Debris1');
	Level.AddPrecacheStaticMesh(StaticMesh'WeaponStaticMesh.RocketProj');

    Super.UpdatePrecacheStaticMeshes();
}

simulated function UpdatePrecacheMaterials()
{
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Energy.SparkHead');
    Level.AddPrecacheMaterial(Material'ExplosionTex.Framed.exp2_frames');
    Level.AddPrecacheMaterial(Material'ExplosionTex.Framed.exp1_frames');
    Level.AddPrecacheMaterial(Material'ExplosionTex.Framed.we1_frames');
    Level.AddPrecacheMaterial(Material'ExplosionTex.Framed.SmokeReOrdered');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Fire.MuchSmoke1');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Fire.NapalmSpot');
    Level.AddPrecacheMaterial(Material'EpicParticles.Fire.SprayFire1');
    Level.AddPrecacheMaterial(Material'FireTank_Tex.FireTank.FireTankBlue');
    Level.AddPrecacheMaterial(Material'FireTank_Tex.FireTank.FireTankRed');
    Level.AddPrecacheMaterial(Material'VMVehicles-TX.HoverTankGroup.tankTreads');
    Level.AddPrecacheMaterial(Material'VMParticleTextures.EJECTA.Tex');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.TrailBlur');
    Level.AddPrecacheMaterial(Material'Engine.GRADIENT_Fade');
    Level.AddPrecacheMaterial(Material'AW-2004Explosions.Fire.Fireball3');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Fire.SmokeFragment');

	Super.UpdatePrecacheMaterials();
}

defaultproperties
{
     TreadVelocityScale=550.000000
     MaxGroundSpeed=750.000000
     MaxAirSpeed=9000.000000
     MaxThrust=160.000000
     MaxSteerTorque=130.000000
     DriverWeapons(0)=(WeaponClass=Class'FireVehiclesV2Omni.FireTankCannon')
     PassengerWeapons(0)=(WeaponPawnClass=Class'FireVehiclesV2Omni.FireTankTurretPawn')
     PassengerWeapons(1)=(WeaponPawnClass=Class'FireVehiclesV2Omni.FireTankSecondaryTurretPawn',WeaponBone="MachineGunTurret")
     bHasAltFire=True
     RedSkin=Texture'FireTank_Tex.FireTank.FireTankRed'
     BlueSkin=Texture'FireTank_Tex.FireTank.FireTankBlue'
     IdleSound=Sound'CuddlyArmor_Sound.FireTank.FireTankEngine'
     VehicleMass=19.000000
     VehiclePositionString="in a Fire Tank"
     VehicleNameString="Fire Tank 2.62"
     RanOverDamageType=Class'FireVehiclesV2Omni.FireTankDamTypeRoadkill'
     HornSounds(0)=Sound'CuddlyArmor_Sound.Horns.FireTankHorn'
     HornSounds(1)=Sound'CuddlyArmor_Sound.Horns.Horn3'
     GroundSpeed=600.000000
     HealthMax=1000.000000
     Health=1000
     Begin Object Class=KarmaParamsRBFull Name=KarmaParamsRBFull8
         KInertiaTensor(0)=1.300000
         KInertiaTensor(3)=4.000000
         KInertiaTensor(5)=4.500000
         KLinearDamping=0.000000
         KAngularDamping=0.000000
         KStartEnabled=True
         KMaxSpeed=800.000000
         bHighDetailOnly=False
         bClientOnly=False
         bKDoubleTickRate=True
         bKStayUpright=True
         bKAllowRotate=True
         bDestroyOnWorldPenetrate=True
         bDoSafetime=True
         KFriction=0.500000
     End Object
     KParams=KarmaParamsRBFull'FireVehiclesV2Omni.FireTank.KarmaParamsRBFull8'

     bSelected=True
}
