//-----------------------------------------------------------
//
//-----------------------------------------------------------
class BadgerMiniGunFireEffect extends ONSWeaponAmbientEmitter;

simulated function SetEmitterStatus(bool bEnabled)
{
	Emitters[0].UseCollision = ( !Level.bDropDetail && (Level.DetailMode != DM_Low) && (VSize(Level.GetLocalPlayerController().ViewTarget.Location - Location) < 1600));
	if(bEnabled)
	{
		Emitters[0].ParticlesPerSecond = 20.0;
		Emitters[0].InitialParticlesPerSecond = 20.0;
		Emitters[0].AllParticlesDead = false;

		Emitters[1].ParticlesPerSecond = 30.0;
		Emitters[1].InitialParticlesPerSecond = 30.0;
		Emitters[1].AllParticlesDead = false;
	}
	else
	{
		Emitters[0].ParticlesPerSecond = 0.0;
		Emitters[0].InitialParticlesPerSecond = 0.0;

		Emitters[1].ParticlesPerSecond = 0.0;
		Emitters[1].InitialParticlesPerSecond = 0.0;
	}
}

defaultproperties
{
     Begin Object Class=MeshEmitter Name=MeshEmitter0
         StaticMesh=StaticMesh'VMmeshEmitted.EJECTA.EjectedBRASSsm'
         UseCollision=True
         RespawnDeadParticles=False
         SpawnOnlyInDirectionOfNormal=True
         SpinParticles=True
         AutomaticInitialSpawning=False
         Acceleration=(Z=-500.000000)
         DampingFactorRange=(X=(Min=0.500000,Max=0.500000),Y=(Min=0.500000,Max=0.500000),Z=(Min=0.500000,Max=0.500000))
         MaxParticles=30
         StartLocationOffset=(X=-209.000000,Y=-10.000000,Z=-10.500000)
         MeshNormal=(Z=0.000000)
         UseRotationFrom=PTRS_Actor
         SpinsPerSecondRange=(X=(Min=0.100000,Max=1.000000),Y=(Min=0.100000,Max=1.000000),Z=(Min=0.100000,Max=1.000000))
         StartSizeRange=(X=(Min=0.060000,Max=0.060000),Y=(Min=0.060000,Max=0.060000),Z=(Min=0.060000,Max=0.060000))
         LifetimeRange=(Min=1.500000,Max=1.500000)
         StartVelocityRange=(X=(Min=-175.000000,Max=100.000000),Y=(Min=-150.000000,Max=-175.000000),Z=(Min=200.000000,Max=250.000000))
         StartVelocityRadialRange=(Min=-250.000000,Max=250.000000)
     End Object
     Emitters(0)=MeshEmitter'CSBadgerFix.BadgerMinigunFireEffect.MeshEmitter0'

     Begin Object Class=MeshEmitter Name=MeshEmitter1
         StaticMesh=StaticMesh'XEffects.MinigunFlashMesh'
         UseParticleColor=True
         UseColorScale=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=255,G=255,R=255))
         ColorScale(1)=(RelativeTime=1.000000)
         Opacity=0.850000
         CoordinateSystem=PTCS_Relative
         MaxParticles=1
         StartLocationOffset=(X=-195.000000,Z=4.000000)
         StartSpinRange=(Z=(Max=2.000000))
         StartSizeRange=(X=(Min=0.300000,Max=0.500000),Y=(Min=0.200000,Max=0.400000),Z=(Min=0.200000,Max=0.400000))
         InitialParticlesPerSecond=2000.000000
         LifetimeRange=(Min=0.030000,Max=0.080000)
     End Object
     Emitters(1)=MeshEmitter'CSBadgerFix.BadgerMinigunFireEffect.MeshEmitter1'

     CullDistance=4000.000000
     bNoDelete=False
     DrawScale3D=(X=0.250000,Y=0.250000,Z=0.250000)
     bUnlit=False
     bHardAttach=True
}
