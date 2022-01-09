//=============================================================================
// Flame Tank.
//=============================================================================
class FlameTank extends ONSHoverTank
	placeable;

#exec OBJ LOAD FILE=..\Animations\ONSVehicles-A.ukx
#exec OBJ LOAD FILE=..\Sounds\ONSVehicleSounds-S.uax
#exec OBJ LOAD FILE=InterfaceContent.utx
#exec OBJ LOAD FILE=..\textures\VMVehicles-TX.utx
#exec OBJ LOAD FILE=..\textures\FireTank_Tex.utx
#exec OBJ LOAD FILE=..\textures\SieEng_TexExtra.utx

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

function TakeDamage(int Damage, Pawn instigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> DamageType)
{
        if (DamageType == class'DamTypeBioGlob')
                Damage *= 3.0;

	if (DamageType == class'FlameKill')
		Damage *= 0.30;

	if (DamageType == class'DamTypeTankShell')
		Damage *= 0.80;

	if (DamageType == class'DamTypeHoverBikePlasma')
		Damage *= 0.80;

	if (DamageType == class'DamTypeONSCicadaRocket')
		Damage *= 0.80;

	if (DamageType == class'DamTypeAttackCraftPlasma')
		Damage *= 0.80;

	if (DamageType == class'DamTypeFlakChunk')
		Damage *= 0.80;

	if (DamageType == class'DamTypeShockBeam')
		Damage *= 0.80;

	if (DamageType == class'HeatRay')
		Damage *= 0.30;

        Super.TakeDamage(Damage, instigatedBy, Hitlocation, Momentum, damageType);
}

function KDriverEnter(Pawn p)
{
    Super.KDriverEnter(p);

    SVehicleUpdateParams();
}

function AltFire(optional float F)
{
//    if (FlameTankCannon(Weapons[ActiveWeapon]).ChargeLevel >= 0.9 )
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
     MaxAirSpeed=10000.000000
     MaxThrust=160.000000
     MaxSteerTorque=130.000000
     DriverWeapons(0)=(WeaponClass=Class'CSBadgerFix.FlameTankCannon')
     PassengerWeapons(0)=(WeaponPawnClass=Class'CSBadgerFix.FlameTankTurretPawn')
     PassengerWeapons(1)=(WeaponPawnClass=Class'CSBadgerFix.FlameTankSecondaryTurretPawn',WeaponBone="MachineGunTurret")
     bHasAltFire=True
     RedSkin=Texture'SieEng_TexExtra.Fire.FireTankRed'
     BlueSkin=Texture'SieEng_TexExtra.Fire.FireTankBlue'
     IdleSound=Sound'BioAegis_Sound.BioTank.BioTankEngine'
     VehicleMass=19.000000
     VehiclePositionString="in a Fire Tank"
     VehicleNameString="Fire Tank"
     HornSounds(0)=Sound'BioAegis_Sound.BioTank.BioTankHorn0'
     HornSounds(1)=Sound'BioAegis_Sound.BioTank.BioTankHorn1'
     GroundSpeed=600.000000
     HealthMax=1200.000000
     Health=1200
     Skins(1)=Texture'SieEng_TexExtra.Treads.Goliath_DarkTreads'
     Skins(2)=Texture'SieEng_TexExtra.Treads.Goliath_DarkTreads'
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
     KParams=KarmaParamsRBFull'CSBadgerFix.FlameTank.KarmaParamsRBFull8'

     bSelected=True
}
