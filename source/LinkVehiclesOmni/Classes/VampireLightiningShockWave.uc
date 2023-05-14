
class VampireLightiningShockWave extends Emitter;


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{

	 Begin Object Class=MeshEmitter Name=PurpleSphere
         StaticMesh=StaticMesh'AW-2004Particles.Weapons.PlasmaSphere'
         CoordinateSystem=PTCS_Relative
         UseParticleColor=True
         UseColorScale=True
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=255,R=108))
         ColorScale(1)=(RelativeTime=0.700000,Color=(B=255,G=57,R=94))
         ColorScale(2)=(RelativeTime=1.000000)
         MaxParticles=2
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=10.000000)
         InitialParticlesPerSecond=500.000000
         LifetimeRange=(Min=0.7500000,Max=1.2500000)
     End Object
   Emitters(0)=MeshEmitter'LinkVehiclesOmni.VampireLightiningShockWave.PurpleSphere'


	
	Begin Object Class=MeshEmitter Name=TSphere
         StaticMesh=StaticMesh'AW-2004Particles.Weapons.PlasmaSphere'
         CoordinateSystem=PTCS_Relative
         UseParticleColor=True
         UseColorScale=True
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         DrawStyle=PTDS_Brighten
         ColorScale(0)=(Color=(B=0,R=204))
         ColorScale(1)=(RelativeTime=0.500000,Color=(B=0,G=0,R=204))
         ColorScale(2)=(RelativeTime=1.000000)
         MaxParticles=3
         SizeScale(1)=(RelativeTime=0.7500000,RelativeSize=9.500000)
         InitialParticlesPerSecond=500.000000
         LifetimeRange=(Min=0.7500000,Max=1.50000)
     End Object
   Emitters(1)=MeshEmitter'LinkVehiclesOmni.VampireLightiningShockWave.TSphere'
   
     /*Begin Object Class=SpriteEmitter Name=GlowingCorona
         SpinParticles=True
         UniformSize=True
         AutomaticInitialSpawning=False
         RespawnDeadParticles=False  //this plus autodestroy ends it
         Opacity=0.500000
         CoordinateSystem=PTCS_Relative
         MaxParticles=6
         SpinsPerSecondRange=(X=(Min=0.500000,Max=1.000000))
         //StartSpinRange=(X=(Max=1.000000))
         StartSpinRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
         StartSizeRange=(X=(Min=75.000000,Max=775.000000))
         SphereRadiusRange=(Min=110.000000,Max=750.000000)
         InitialParticlesPerSecond=10.000000
         DrawStyle=PTDS_Brighten
         Texture=Texture'AW-2k4XP.Weapons.ShockTankEffectCore2a'
         LifetimeRange=(Min=0.500000,Max=0.500000)
     End Object
     Emitters(0)=SpriteEmitter'LinkVehiclesOmni.VampireLightiningShockWave.GlowingCorona'
   */
  
     Begin Object Class=SpriteEmitter Name=BlackHole
         SpinParticles=True
         UniformSize=True
         AutomaticInitialSpawning=False
         RespawnDeadParticles=False
         CoordinateSystem=PTCS_Relative
         MaxParticles=2
         SpinsPerSecondRange=(X=(Min=1.000000,Max=2.000000))
         //StartSpinRange=(X=(Max=1.000000))
         StartSpinRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
         StartSizeRange=(X=(Min=80.000000,Max=600.000000))
         SphereRadiusRange=(Min=110.000000,Max=550.000000)
         InitialParticlesPerSecond=10.000000
         DrawStyle=PTDS_Darken
         Texture=Texture'AW-2004Particles.Weapons.PlasmaFlare'
         LifetimeRange=(Min=0.500000,Max=0.7500000)
     End Object
     Emitters(2)=SpriteEmitter'LinkVehiclesOmni.VampireLightiningShockWave.BlackHole'
     
     Begin Object Class=MeshEmitter Name=BlackSphere
         StaticMesh=StaticMesh'AW-2004Particles.Weapons.PlasmaSphere'
         CoordinateSystem=PTCS_Relative
         UseParticleColor=True
         UseColorScale=True
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         DrawStyle=PTDS_Darken
         ColorScale(0)=(Color=(B=0,R=0,G=0))
         ColorScale(1)=(RelativeTime=0.500000,Color=(B=0,G=0,R=51))
         ColorScale(2)=(RelativeTime=1.000000,Color=(B=51,G=0,R=0))
         MaxParticles=2
         SizeScale(1)=(RelativeTime=0.500000,RelativeSize=9.000000)
         InitialParticlesPerSecond=500.000000
         LifetimeRange=(Min=0.7500000,Max=1.50000)
     End Object
   Emitters(3)=MeshEmitter'LinkVehiclesOmni.VampireLightiningShockWave.BlackSphere'
     
     
     /*
     Begin Object Class=SpriteEmitter Name=Flashes
         FadeOut=True
         SpinParticles=True
         UniformSize=True
         RespawnDeadParticles=False
         MaxParticles=20
         ColorMultiplierRange=(X=(Min=0.000000),Y=(Min=0.500000),Z=(Min=0.800000))
         Opacity=0.500000
         CoordinateSystem=PTCS_Relative
         StartSpinRange=(X=(Max=1.000000))
         StartSizeRange=(X=(Min=200.000000,Max=875.000000))
         SphereRadiusRange=(Min=110.000000,Max=850.000000)
         Texture=Texture'AW-2004Particles.Energy.ElecPanels'
         TextureUSubdivisions=2
         TextureVSubdivisions=2
         LifetimeRange=(Min=0.200000,Max=0.450000)
     End Object
     Emitters(3)=SpriteEmitter'LinkVehiclesOmni.VampireLightiningShockWave.Flashes'
*/

  /*   Begin Object Class=SpriteEmitter Name=SuckingStreaks
         //UseDirectionAs=PTDU_RightAndNormal
         UseDirectionAs=PTDU_RightAndNormal
         FadeOut=True
         FadeIn=True
         UniformSize=True
         RespawnDeadParticles=False
         Opacity=0.250000
         FadeOutStartTime=0.200000
         FadeInEndTime=0.200000
         CoordinateSystem=PTCS_Relative
         MaxParticles=30
         DetailMode=DM_High
         StartLocationShape=PTLS_Sphere
         SphereRadiusRange=(Min=110.000000,Max=850.000000)
         StartSizeRange=(X=(Min=100.000000,Max=900.000000))
         StartSpinRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
         Texture=Texture'EpicParticles.Beams.WhiteStreak01aw'
         LifetimeRange=(Min=0.400000,Max=0.400000)
         StartVelocityRadialRange=(Min=-300.000000,Max=-300.000000)
         GetVelocityDirectionFrom=PTVD_AddRadial
     End Object
     Emitters(3)=SpriteEmitter'LinkVehiclesOmni.VampireLightiningShockWave.SuckingStreaks'
*/
/*
     Begin Object Class=SpriteEmitter Name=LightningBranches
         BeamEndPoints(0)=(offset=(X=(Min=-800.000000,Max=800.000000),Y=(Min=-800.000000,Max=800.000000),Z=(Min=-600.000000,Max=600.000000)))
         DetermineEndPointBy=PTEP_Offset
         RotatingSheets=2
         LowFrequencyNoiseRange=(X=(Min=-50.000000,Max=50.000000),Y=(Min=-50.000000,Max=50.000000),Z=(Min=-50.000000,Max=50.000000))
         HighFrequencyNoiseRange=(X=(Min=-10.000000,Max=10.000000),Y=(Min=-10.000000,Max=10.000000),Z=(Min=10.000000,Max=10.000000))
         HighFrequencyPoints=5
         NoiseDeterminesEndPoint=True
         UseColorScale=True
         RespawnDeadParticles=False
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=255,G=255,R=255))
         ColorScale(1)=(RelativeTime=0.100000,Color=(B=255,G=255,R=255))
         ColorScale(2)=(RelativeTime=0.300000,Color=(B=64,G=64,R=64))
         ColorScale(3)=(RelativeTime=0.400000,Color=(B=255,G=255,R=255))
         ColorScale(4)=(RelativeTime=1.000000)
         ColorMultiplierRange=(X=(Min=0.700000,Max=0.800000),Y=(Min=0.800000,Max=0.900000))
         MaxParticles=50
         StartSizeRange=(X=(Min=20.000000,Max=25.000000),Y=(Min=20.000000,Max=25.000000),Z=(Min=20.000000,Max=25.000000))
         StartSpinRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
         DrawStyle=PTDS_Brighten
         Texture=Texture'EpicParticles.Beams.HotBolt04aw'
         SecondsBeforeInactive=0.000000
        LifetimeRange=(Min=0.670000,Max=0.670000)
     End Object
     Emitters(3)=BeamEmitter'LinkVehiclesOmni.VampireLightiningShockWave.LightningBranches'
*/
 



     AutoDestroy=True
     bNoDelete=False
     RemoteRole=ROLE_DumbProxy
     bDirectional=True
}
