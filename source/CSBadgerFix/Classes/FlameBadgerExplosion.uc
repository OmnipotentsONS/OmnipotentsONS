/**
Badgers_V2.FlameBadgerExplosion

Creation date: 2014-01-26 14:08
Last change: $Id$
Copyright (c) 2014, Wormbo
*/

class FlameBadgerExplosion extends Emitter;

var array<Sound> ExplosionSound;

auto State Explosion
{

Begin:
	PlayUniqueRandomExplosion();
	PlayUniqueRandomExplosion();
	
	Sleep(0.33);
	PlayUniqueRandomExplosion();
}

simulated function PlayUniqueRandomExplosion()
{
	local int Num;
	
	Num = Rand(ExplosionSound.Length);
	PlaySound(ExplosionSound[Num],, 4,, 1600);
	ExplosionSound.Remove(Num, 1);
}


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
     ExplosionSound(0)=Sound'ONSVehicleSounds-S.Explosions.Explosion01'
     ExplosionSound(1)=Sound'ONSVehicleSounds-S.Explosions.Explosion02'
     ExplosionSound(2)=Sound'ONSVehicleSounds-S.Explosions.Explosion03'
     ExplosionSound(3)=Sound'ONSVehicleSounds-S.Explosions.Explosion04'
     ExplosionSound(4)=Sound'ONSVehicleSounds-S.Explosions.Explosion05'
     ExplosionSound(5)=Sound'ONSVehicleSounds-S.Explosions.Explosion06'
     ExplosionSound(6)=Sound'ONSVehicleSounds-S.Explosions.Explosion07'
     ExplosionSound(7)=Sound'ONSVehicleSounds-S.Explosions.Explosion08'
     ExplosionSound(8)=Sound'ONSVehicleSounds-S.Explosions.Explosion09'
     ExplosionSound(9)=Sound'ONSVehicleSounds-S.Explosions.Explosion10'
     ExplosionSound(10)=Sound'ONSVehicleSounds-S.Explosions.Explosion11'
     Begin Object Class=SpriteEmitter Name=SpriteEmitter0
         RespawnDeadParticles=False
         AutoDestroy=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         BlendBetweenSubdivisions=True
         MaxParticles=3
         StartLocationShape=PTLS_Sphere
         SphereRadiusRange=(Min=32.000000,Max=64.000000)
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.250000)
         StartSizeRange=(X=(Min=150.000000,Max=300.000000))
         SpawningSound=PTSC_Random
         InitialParticlesPerSecond=6.000000
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'ExplosionTex.Framed.exp7_frames'
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=1.000000,Max=1.000000)
     End Object
     Emitters(0)=SpriteEmitter'CSBadgerFix.FlameBadgerExplosion.SpriteEmitter0'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter1
         UseColorScale=True
         RespawnDeadParticles=False
         AutoDestroy=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         UseRandomSubdivision=True
         ColorScale(1)=(RelativeTime=0.250000,Color=(B=72,G=160,R=244))
         ColorScale(2)=(RelativeTime=0.670000,Color=(B=72,G=160,R=244))
         ColorScale(3)=(RelativeTime=1.000000)
         MaxParticles=1
         SpinsPerSecondRange=(X=(Min=1.000000,Max=1.000000))
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=0.750000)
         SizeScale(1)=(RelativeTime=0.200000,RelativeSize=1.500000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=1.000000)
         StartSizeRange=(X=(Min=425.000000,Max=425.000000))
         InitialParticlesPerSecond=2000.000000
         Texture=Texture'EpicParticles.Flares.SoftFlare'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=1.670000,Max=1.670000)
     End Object
     Emitters(1)=SpriteEmitter'CSBadgerFix.FlameBadgerExplosion.SpriteEmitter1'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter2
         UseCollision=True
         RespawnDeadParticles=False
         AutoDestroy=True
         UniformSize=True
         AutomaticInitialSpawning=False
         Acceleration=(Z=-750.000000)
         StartLocationShape=PTLS_Sphere
         SphereRadiusRange=(Min=48.000000,Max=64.000000)
         StartSizeRange=(X=(Min=0.000000,Max=0.000000))
         InitialParticlesPerSecond=2000.000000
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=3.000000,Max=0.670000)
         InitialDelayRange=(Min=0.250000,Max=0.250000)
         StartVelocityRadialRange=(Min=-800.000000,Max=-800.000000)
         GetVelocityDirectionFrom=PTVD_AddRadial
     End Object
     Emitters(2)=SpriteEmitter'CSBadgerFix.FlameBadgerExplosion.SpriteEmitter2'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter3
         UseColorScale=True
         RespawnDeadParticles=False
         AutoDestroy=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         ScaleSizeYByVelocity=True
         AutomaticInitialSpawning=False
         UseRandomSubdivision=True
         ColorScale(0)=(Color=(B=160,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=0.200000,Color=(B=45,G=158,R=234,A=255))
         ColorScale(2)=(RelativeTime=0.400000,Color=(B=40,G=103,R=172,A=255))
         ColorScale(3)=(RelativeTime=0.700000,Color=(B=40,G=40,R=40))
         ColorScale(4)=(RelativeTime=1.000000)
         MaxParticles=150
         AddLocationFromOtherEmitter=2
         SpinsPerSecondRange=(X=(Max=0.001000))
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=0.330000,RelativeSize=2.500000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=4.000000)
         StartSizeRange=(X=(Min=10.000000,Max=16.000000))
         InitialParticlesPerSecond=300.000000
         Texture=Texture'AW-2004Particles.Fire.MuchSmoke2t'
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=1.000000,Max=1.500000)
         InitialDelayRange=(Min=0.300000,Max=0.300000)
         AddVelocityMultiplierRange=(X=(Min=0.001000,Max=0.001000),Y=(Min=0.001000,Max=0.001000),Z=(Min=0.001000,Max=0.001000))
     End Object
     Emitters(3)=SpriteEmitter'CSBadgerFix.FlameBadgerExplosion.SpriteEmitter3'

     Begin Object Class=TrailEmitter Name=TrailEmitter0
         TrailShadeType=PTTST_Linear
         DistanceThreshold=3.000000
         UseCrossedSheets=True
         UseCollision=True
         UseColorScale=True
         RespawnDeadParticles=False
         AutoDestroy=True
         AutomaticInitialSpawning=False
         Acceleration=(Z=-750.000000)
         ColorScale(0)=(Color=(B=160,G=255,R=255))
         ColorScale(1)=(RelativeTime=1.000000)
         ColorMultiplierRange=(X=(Max=2.000000))
         DetailMode=DM_SuperHigh
         StartLocationShape=PTLS_Sphere
         SphereRadiusRange=(Min=32.000000,Max=32.000000)
         StartSizeRange=(X=(Min=2.000000,Max=7.000000))
         InitialParticlesPerSecond=30.000000
         Texture=Texture'AS_FX_TX.Trails.Trail_red'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=0.670000,Max=1.500000)
         StartVelocityRadialRange=(Min=-1200.000000,Max=-800.000000)
         GetVelocityDirectionFrom=PTVD_AddRadial
     End Object
     Emitters(4)=TrailEmitter'CSBadgerFix.FlameBadgerExplosion.TrailEmitter0'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter4
         RespawnDeadParticles=False
         AutoDestroy=True
         SpinParticles=True
         UniformSize=True
         AutomaticInitialSpawning=False
         BlendBetweenSubdivisions=True
         MaxParticles=5
         StartLocationShape=PTLS_All
         SphereRadiusRange=(Min=48.000000,Max=96.000000)
         StartSpinRange=(X=(Max=1.000000))
         StartSizeRange=(X=(Max=200.000000))
         SpawningSound=PTSC_Random
         InitialParticlesPerSecond=9.000000
         DrawStyle=PTDS_Brighten
         Texture=Texture'ExplosionTex.Framed.exp1_frames'
         TextureUSubdivisions=2
         TextureVSubdivisions=4
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=0.500000,Max=1.000000)
         InitialDelayRange=(Min=0.550000,Max=0.550000)
     End Object
     Emitters(5)=SpriteEmitter'CSBadgerFix.FlameBadgerExplosion.SpriteEmitter4'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter5
         RespawnDeadParticles=False
         AutoDestroy=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         BlendBetweenSubdivisions=True
         MaxParticles=1
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=0.670000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=2.000000)
         StartSizeRange=(X=(Min=150.000000,Max=150.000000))
         InitialParticlesPerSecond=2000.000000
         Texture=Texture'ExplosionTex.Framed.exp1_frames'
         TextureUSubdivisions=2
         TextureVSubdivisions=4
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=0.500000,Max=0.500000)
     End Object
     Emitters(6)=SpriteEmitter'CSBadgerFix.FlameBadgerExplosion.SpriteEmitter5'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter6
         UseCollision=True
         UseColorScale=True
         RespawnDeadParticles=False
         AutoDestroy=True
         SpinParticles=True
         UniformSize=True
         AutomaticInitialSpawning=False
         UseRandomSubdivision=True
         Acceleration=(Z=-750.000000)
         DampingFactorRange=(Z=(Min=0.500000,Max=0.500000))
         ColorScale(0)=(Color=(B=255,G=255,R=255))
         ColorScale(1)=(RelativeTime=0.150000,Color=(B=255,G=255,R=255,A=255))
         ColorScale(2)=(RelativeTime=0.800000,Color=(B=255,G=255,R=255,A=255))
         ColorScale(3)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255))
         FadeOutStartTime=0.750000
         MaxParticles=60
         StartLocationShape=PTLS_All
         SphereRadiusRange=(Min=64.000000,Max=64.000000)
         SpinsPerSecondRange=(X=(Min=0.500000,Max=1.500000))
         StartSpinRange=(X=(Max=2.000000))
         StartSizeRange=(X=(Min=3.000000,Max=18.000000))
         InitialParticlesPerSecond=300.000000
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'EmitterTextures.MultiFrame.rockchunks02'
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=1.500000,Max=2.500000)
         InitialDelayRange=(Min=0.100000,Max=0.100000)
         StartVelocityRadialRange=(Min=-800.000000,Max=-1200.000000)
         GetVelocityDirectionFrom=PTVD_AddRadial
     End Object
     Emitters(7)=SpriteEmitter'CSBadgerFix.FlameBadgerExplosion.SpriteEmitter6'

     Begin Object Class=MeshEmitter Name=MeshEmitter0
         StaticMesh=StaticMesh'Badgers_V2Beta3.Wreck.BadgerWreck_Turret'
         UseParticleColor=True
         FadeOut=True
         RespawnDeadParticles=False
         SpinParticles=True
         AutomaticInitialSpawning=False
         Acceleration=(Z=-900.000000)
         FadeOutStartTime=0.300000
         MaxParticles=1
         StartLocationOffset=(X=20.000000,Z=60.000000)
         UseRotationFrom=PTRS_Actor
         SpinsPerSecondRange=(X=(Max=0.300000),Y=(Max=0.500000),Z=(Max=0.300000))
         StartSpinRange=(X=(Min=0.500000,Max=0.500000))
         InitialParticlesPerSecond=100.000000
         DrawStyle=PTDS_AlphaBlend
         LifetimeRange=(Min=0.500000,Max=0.800000)
         StartVelocityRange=(X=(Min=-300.000000,Max=300.000000),Y=(Min=-300.000000,Max=300.000000),Z=(Min=600.000000,Max=800.000000))
     End Object
     Emitters(8)=MeshEmitter'CSBadgerFix.FlameBadgerExplosion.MeshEmitter0'

     Begin Object Class=MeshEmitter Name=MeshEmitter1
         StaticMesh=StaticMesh'Badgers_V2Beta3.Wreck.BadgerWreck_Minigun'
         UseParticleColor=True
         FadeOut=True
         RespawnDeadParticles=False
         SpinParticles=True
         AutomaticInitialSpawning=False
         Acceleration=(Z=-900.000000)
         FadeOutStartTime=0.300000
         MaxParticles=1
         StartLocationOffset=(X=20.000000,Z=100.000000)
         UseRotationFrom=PTRS_Actor
         SpinsPerSecondRange=(X=(Max=0.500000),Y=(Max=0.500000),Z=(Max=0.500000))
         StartSpinRange=(X=(Min=0.500000,Max=0.500000))
         InitialParticlesPerSecond=100.000000
         DrawStyle=PTDS_AlphaBlend
         LifetimeRange=(Min=0.700000,Max=1.000000)
         StartVelocityRange=(X=(Min=-300.000000,Max=300.000000),Y=(Min=-300.000000,Max=300.000000),Z=(Min=600.000000,Max=800.000000))
     End Object
     Emitters(9)=MeshEmitter'CSBadgerFix.FlameBadgerExplosion.MeshEmitter1'

     Begin Object Class=MeshEmitter Name=MeshEmitter2
         StaticMesh=StaticMesh'Badgers_V2beta3.Wreck.BadgerWreck_Wheel'
         UseParticleColor=True
         UseCollision=True
         FadeOut=True
         RespawnDeadParticles=False
         SpinParticles=True
         AutomaticInitialSpawning=False
         Acceleration=(Z=-900.000000)
         DampingFactorRange=(X=(Min=0.400000,Max=0.600000),Y=(Min=0.400000,Max=0.600000),Z=(Min=0.400000,Max=0.600000))
         FadeOutStartTime=0.300000
         MaxParticles=1
         StartLocationOffset=(X=55.000000,Y=35.000000,Z=10.000000)
         UseRotationFrom=PTRS_Normal
         SpinsPerSecondRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
         StartSpinRange=(Y=(Max=1.000000),Z=(Min=0.250000,Max=0.250000))
         InitialParticlesPerSecond=100.000000
         DrawStyle=PTDS_AlphaBlend
         LifetimeRange=(Min=0.800000,Max=1.000000)
         StartVelocityRange=(X=(Min=-300.000000,Max=300.000000),Y=(Max=500.000000),Z=(Min=-300.000000,Max=300.000000))
         StartVelocityRadialRange=(Min=-1000.000000,Max=-700.000000)
         GetVelocityDirectionFrom=PTVD_AddRadial
     End Object
     Emitters(10)=MeshEmitter'CSBadgerFix.FlameBadgerExplosion.MeshEmitter2'

     Begin Object Class=MeshEmitter Name=MeshEmitter3
         StaticMesh=StaticMesh'Badgers_V2beta3.Wreck.BadgerWreck_Wheel'
         UseParticleColor=True
         UseCollision=True
         FadeOut=True
         RespawnDeadParticles=False
         SpinParticles=True
         AutomaticInitialSpawning=False
         Acceleration=(Z=-900.000000)
         DampingFactorRange=(X=(Min=0.400000,Max=0.600000),Y=(Min=0.400000,Max=0.600000),Z=(Min=0.400000,Max=0.600000))
         FadeOutStartTime=0.300000
         MaxParticles=1
         StartLocationOffset=(X=-55.000000,Y=35.000000,Z=-10.000000)
         UseRotationFrom=PTRS_Normal
         SpinsPerSecondRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
         StartSpinRange=(Y=(Max=1.000000),Z=(Min=0.250000,Max=0.250000))
         InitialParticlesPerSecond=100.000000
         DrawStyle=PTDS_AlphaBlend
         LifetimeRange=(Min=0.800000,Max=1.000000)
         StartVelocityRange=(X=(Min=-300.000000,Max=300.000000),Y=(Max=500.000000),Z=(Min=-300.000000,Max=300.000000))
         StartVelocityRadialRange=(Min=-1000.000000,Max=-700.000000)
         GetVelocityDirectionFrom=PTVD_AddRadial
     End Object
     Emitters(11)=MeshEmitter'CSBadgerFix.FlameBadgerExplosion.MeshEmitter3'

     Begin Object Class=MeshEmitter Name=MeshEmitter4
         StaticMesh=StaticMesh'Badgers_V2beta3.Wreck.BadgerWreck_Wheel'
         UseParticleColor=True
         UseCollision=True
         FadeOut=True
         RespawnDeadParticles=False
         SpinParticles=True
         AutomaticInitialSpawning=False
         Acceleration=(Z=-900.000000)
         DampingFactorRange=(X=(Min=0.400000,Max=0.600000),Y=(Min=0.400000,Max=0.600000),Z=(Min=0.400000,Max=0.600000))
         FadeOutStartTime=0.300000
         MaxParticles=1
         StartLocationOffset=(X=55.000000,Y=-35.000000,Z=10.000000)
         UseRotationFrom=PTRS_Normal
         SpinsPerSecondRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
         StartSpinRange=(Y=(Max=1.000000),Z=(Min=-0.250000,Max=-0.250000))
         InitialParticlesPerSecond=100.000000
         DrawStyle=PTDS_AlphaBlend
         LifetimeRange=(Min=0.800000,Max=1.000000)
         StartVelocityRange=(X=(Min=-300.000000,Max=300.000000),Y=(Min=-500.000000),Z=(Min=-300.000000,Max=300.000000))
         StartVelocityRadialRange=(Min=-1000.000000,Max=-700.000000)
         GetVelocityDirectionFrom=PTVD_AddRadial
     End Object
     Emitters(12)=MeshEmitter'CSBadgerFix.FlameBadgerExplosion.MeshEmitter4'

     Begin Object Class=MeshEmitter Name=MeshEmitter5
         StaticMesh=StaticMesh'Badgers_V2beta3.Wreck.BadgerWreck_Wheel'
         UseParticleColor=True
         UseCollision=True
         FadeOut=True
         RespawnDeadParticles=False
         SpinParticles=True
         AutomaticInitialSpawning=False
         Acceleration=(Z=-900.000000)
         DampingFactorRange=(X=(Min=0.400000,Max=0.600000),Y=(Min=0.400000,Max=0.600000),Z=(Min=0.400000,Max=0.600000))
         FadeOutStartTime=0.300000
         MaxParticles=1
         StartLocationOffset=(X=-55.000000,Y=-35.000000,Z=-10.000000)
         UseRotationFrom=PTRS_Normal
         SpinsPerSecondRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
         StartSpinRange=(Y=(Max=1.000000),Z=(Min=-0.250000,Max=-0.250000))
         InitialParticlesPerSecond=100.000000
         DrawStyle=PTDS_AlphaBlend
         LifetimeRange=(Min=0.800000,Max=1.000000)
         StartVelocityRange=(X=(Min=-300.000000,Max=300.000000),Y=(Min=-500.000000),Z=(Min=-300.000000,Max=300.000000))
         StartVelocityRadialRange=(Min=-1000.000000,Max=-700.000000)
         GetVelocityDirectionFrom=PTVD_AddRadial
     End Object
     Emitters(13)=MeshEmitter'CSBadgerFix.FlameBadgerExplosion.MeshEmitter5'

     Begin Object Class=SpriteEmitter Name=FlameEmitter0
         FadeOut=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         UseRandomSubdivision=True
         Acceleration=(Z=600.000000)
         MaxParticles=200
         StartLocationShape=PTLS_Sphere
         SphereRadiusRange=(Min=10.000000,Max=50.000000)
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(1)=(RelativeTime=0.500000,RelativeSize=1.000000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=1.000000)
         InitialParticlesPerSecond=1000.000000
         Texture=Texture'EmitterTextures.MultiFrame.LargeFlames'
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         LifetimeRange=(Min=0.800000,Max=1.200000)
         StartVelocityRadialRange=(Min=-1000.000000,Max=-300.000000)
         VelocityLossRange=(X=(Min=1.000000,Max=1.000000),Y=(Min=1.000000,Max=1.000000),Z=(Min=1.000000,Max=1.000000))
         GetVelocityDirectionFrom=PTVD_AddRadial
     End Object
     Emitters(14)=SpriteEmitter'CSBadgerFix.FlameBadgerExplosion.FlameEmitter0'

     Begin Object Class=SpriteEmitter Name=FlameEmitter1
         UseColorScale=True
         FadeOut=True
         FadeIn=True
         RespawnDeadParticles=False
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         UseRandomSubdivision=True
         Acceleration=(Z=500.000000)
         ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=102,G=102,R=102,A=255))
         FadeOutStartTime=0.500000
         FadeInEndTime=0.500000
         MaxParticles=100
         AddLocationFromOtherEmitter=0
         StartLocationShape=PTLS_Sphere
         SphereRadiusRange=(Min=10.000000,Max=50.000000)
         SizeScale(1)=(RelativeTime=0.300000,RelativeSize=1.000000)
         SizeScale(2)=(RelativeTime=0.700000,RelativeSize=2.000000)
         SizeScale(3)=(RelativeTime=1.000000,RelativeSize=2.000000)
         StartSizeRange=(X=(Max=200.000000))
         InitialParticlesPerSecond=500.000000
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'EmitterTextures.MultiFrame.smoke_a2'
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         LifetimeRange=(Min=1.000000,Max=1.500000)
         InitialDelayRange=(Min=0.500000,Max=0.700000)
         VelocityLossRange=(X=(Min=1.000000,Max=1.000000),Y=(Min=1.000000,Max=1.000000),Z=(Min=1.000000,Max=1.000000))
         AddVelocityFromOtherEmitter=0
     End Object
     Emitters(15)=SpriteEmitter'CSBadgerFix.FlameBadgerExplosion.FlameEmitter1'

     AutoDestroy=True
     bNoDelete=False
}
