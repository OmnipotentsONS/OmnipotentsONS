//-----------------------------------------------------------
//
//-----------------------------------------------------------
class StingRayJumpEffect extends Emitter;

defaultproperties
{
     Begin Object Class=MeshEmitter Name=MeshEmitter14
         StaticMesh=StaticMesh'ONSWeapons-SM.PC_MantaJumpBlast'
         UseMeshBlendMode=False
         RenderTwoSided=True
         UseColorScale=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         Acceleration=(Z=-50.000000)
         ColorScale(1)=(RelativeTime=0.250000,Color=(B=255,G=255,R=255))
         ColorScale(2)=(RelativeTime=1.000000)
         Opacity=0.500000
         CoordinateSystem=PTCS_Relative
         MaxParticles=2
         StartLocationOffset=(X=21.000000,Y=75.000000,Z=-20.000000)
         SpinsPerSecondRange=(X=(Min=0.750000,Max=1.000000))
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.250000)
         StartSizeRange=(X=(Min=0.800000),Y=(Min=0.800000),Z=(Min=0.500000,Max=1.500000))
         InitialParticlesPerSecond=50.000000
         DrawStyle=PTDS_Brighten
         LifetimeRange=(Min=0.500000,Max=0.750000)
     End Object
     Emitters(0)=MeshEmitter'OmniMantas.StingRayJumpEffect.MeshEmitter14'

     Begin Object Class=MeshEmitter Name=MeshEmitter15
         StaticMesh=StaticMesh'ONSWeapons-SM.PC_MantaJumpBlast'
         UseMeshBlendMode=False
         RenderTwoSided=True
         UseColorScale=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         Acceleration=(Z=-50.000000)
         ColorScale(1)=(RelativeTime=0.250000,Color=(B=255,G=255,R=255))
         ColorScale(2)=(RelativeTime=1.000000)
         Opacity=0.500000
         CoordinateSystem=PTCS_Relative
         MaxParticles=2
         StartLocationOffset=(X=21.000000,Y=-75.000000,Z=-20.000000)
         SpinsPerSecondRange=(X=(Min=0.750000,Max=1.000000))
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.250000)
         StartSizeRange=(X=(Min=0.800000),Y=(Min=0.800000),Z=(Min=0.500000,Max=1.500000))
         InitialParticlesPerSecond=50.000000
         DrawStyle=PTDS_Brighten
         LifetimeRange=(Min=0.500000,Max=0.750000)
     End Object
     Emitters(1)=MeshEmitter'OmniMantas.StingRayJumpEffect.MeshEmitter15'

     AutoDestroy=True
     CullDistance=5000.000000
     bNoDelete=False
     Physics=PHYS_Trailer
     bHardAttach=True
}
