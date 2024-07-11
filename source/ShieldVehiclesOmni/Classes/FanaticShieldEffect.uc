//-----------------------------------------------------------
//
//-----------------------------------------------------------
class FanaticShieldEffect extends Emitter;

#exec OBJ LOAD FILE="..\Textures\AW-2004Particles.utx"
#exec OBJ LOAD FILE="..\Textures\AW-2k4XP.utx"

defaultproperties
{
     Begin Object Class=MeshEmitter Name=MeshEmitter18
         StaticMesh=StaticMesh'ShieldVehicles-SM.ShieldS.CrossShield'
         UseParticleColor=True
         UseColorScale=True
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=255,G=64,R=64))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=64,R=64))
         CoordinateSystem=PTCS_Relative
         MaxParticles=1
         StartSizeRange=(X=(Min=0.900000,Max=0.900000),Y=(Min=1.200000,Max=1.200000),Z=(Min=1.200000,Max=1.200000))
         InitialParticlesPerSecond=5000.000000
         LifetimeRange=(Min=0.100000,Max=0.100000)
     End Object
     Emitters(0)=MeshEmitter'ShieldVehiclesOmni.FanaticShieldEffect.MeshEmitter18'

     bNoDelete=False
     AmbientGlow=254
     bHardAttach=True
}
