//-----------------------------------------------------------
//
//-----------------------------------------------------------
class HospitilarShieldEffect extends Emitter;

#exec OBJ LOAD FILE="..\Textures\AW-2004Particles.utx"
#exec OBJ LOAD FILE="..\Textures\AW-2k4XP.utx"

defaultproperties
{
     Begin Object Class=MeshEmitter Name=MeshEmitter18
         StaticMesh=StaticMesh'ShieldVehicles-SM.ShieldS.CrossShield'
         UseParticleColor=True
         UseColorScale=True
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=255,G=138,R=182))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=138,R=182))
         CoordinateSystem=PTCS_Relative
         MaxParticles=1
         StartSizeRange=(X=(Min=2.000000,Max=2.000000),Y=(Min=3.000000,Max=3.000000),Z=(Min=3.000000,Max=3.000000))
         InitialParticlesPerSecond=5000.000000
         LifetimeRange=(Min=0.100000,Max=0.100000)
     End Object
     Emitters(0)=MeshEmitter'HospitalerV2.HospitilarShieldEffect.MeshEmitter18'

     bNoDelete=False
     AmbientGlow=254
     bHardAttach=True
}
