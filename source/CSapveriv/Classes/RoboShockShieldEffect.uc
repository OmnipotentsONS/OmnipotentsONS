//-----------------------------------------------------------
//
//-----------------------------------------------------------
class RoboShockShieldEffect extends Emitter;

#exec OBJ LOAD FILE="..\Textures\AW-2004Particles.utx"
#exec OBJ LOAD FILE="..\Textures\AW-2k4XP.utx"

defaultproperties
{
     Begin Object Class=MeshEmitter Name=MeshEmitter18
         StaticMesh=StaticMesh'AW-2k4XP.Weapons.ShockShield2'
         UseParticleColor=True
         UseColorScale=True
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=255,G=138,R=182))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=138,R=182))
         CoordinateSystem=PTCS_Relative
         MaxParticles=1
         StartSizeRange=(X=(Min=0.500000,Max=0.500000),Y=(Min=0.500000,Max=0.500000),Z=(Min=2.000000,Max=2.000000))
         InitialParticlesPerSecond=5000.000000
         LifetimeRange=(Min=0.100000,Max=0.100000)
     End Object
     Emitters(0)=MeshEmitter'CSAPVerIV.RoboShockShieldEffect.MeshEmitter18'

     bNoDelete=False
     AmbientGlow=254
     bHardAttach=True
}
