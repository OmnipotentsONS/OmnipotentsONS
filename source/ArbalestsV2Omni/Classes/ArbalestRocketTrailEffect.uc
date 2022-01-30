//--------------------------------------------------------------
//
//--------------------------------------------------------------
class ArbalestRocketTrailEffect extends Emitter;

#exec OBJ LOAD FILE="..\Textures\AW-2004Particles.utx"

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter8
         UseColorScale=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=210,G=157,R=85))
         ColorScale(1)=(RelativeTime=0.200000,Color=(B=130,G=226,R=255))
         ColorScale(2)=(RelativeTime=0.300000,Color=(G=135,R=225))
         ColorScale(3)=(RelativeTime=1.000000)
         MaxParticles=8
         UseRotationFrom=PTRS_Actor
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=2.000000)
         StartSizeRange=(X=(Min=10.000000,Max=10.000000))
         ParticlesPerSecond=120.000000
         InitialParticlesPerSecond=120.000000
         Texture=Texture'AW-2004Particles.Weapons.PlasmaFlare'
         LifetimeRange=(Min=0.300000,Max=0.300000)
     End Object
     Emitters(0)=SpriteEmitter'ArbalestsV2Omni.ArbalestRocketTrailEffect.SpriteEmitter8'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter9
         UseColorScale=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         UseRandomSubdivision=True
         Acceleration=(Z=1.000000)
         ColorScale(0)=(Color=(B=220,G=220,R=220,A=70))
         ColorScale(1)=(RelativeTime=2.000000,Color=(B=200,G=200,R=200,A=50))
         ColorScale(2)=(RelativeTime=4.000000,Color=(B=180,G=180,R=180,A=30))
         MaxParticles=1000
         StartLocationShape=PTLS_Sphere
         SphereRadiusRange=(Max=8.000000)
         SpinsPerSecondRange=(X=(Max=0.050000))
         StartSpinRange=(X=(Min=0.550000,Max=0.450000))
         SizeScale(0)=(RelativeSize=0.500000)
         SizeScale(1)=(RelativeTime=0.500000,RelativeSize=4.000000)
         SizeScale(2)=(RelativeTime=2.000000,RelativeSize=8.000000)
         StartSizeRange=(X=(Min=10.000000,Max=15.000000))
         ParticlesPerSecond=100.000000
         InitialParticlesPerSecond=100.000000
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'AW-2004Particles.Fire.MuchSmoke1'
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         LifetimeRange=(Min=0.500000)
         StartVelocityRange=(X=(Min=-5.000000,Max=-5.000000),Y=(Min=-5.000000,Max=-5.000000),Z=(Min=-5.000000,Max=-5.000000))
     End Object
     Emitters(1)=SpriteEmitter'ArbalestsV2Omni.ArbalestRocketTrailEffect.SpriteEmitter9'

     AutoDestroy=True
     bNoDelete=False
     Physics=PHYS_Trailer
     AmbientSound=Sound'WeaponSounds.RocketLauncher.RocketLauncherProjectile'
     bHardAttach=True
     SoundVolume=255
     SoundRadius=100.000000
     bDirectional=True
}
