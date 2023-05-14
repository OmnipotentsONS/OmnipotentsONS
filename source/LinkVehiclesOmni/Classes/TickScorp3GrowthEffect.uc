
class TickScorp3GrowthEffect extends Emitter;


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{

	

	
	
 /* Begin Object Class=SpriteEmitter Name=GlowingCorona
         SpinParticles=True
         UniformSize=True
         AutomaticInitialSpawning=False
         RespawnDeadParticles=False  //this plus autodestroy ends it
         Opacity=0.500000
         CoordinateSystem=PTCS_Relative
         MaxParticles=3
         SpinsPerSecondRange=(X=(Min=0.500000,Max=1.000000))
         //StartSpinRange=(X=(Max=1.000000))
         StartSpinRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
         StartSizeRange=(X=(Min=75.000000,Max=475.000000))
         SphereRadiusRange=(Min=110.000000,Max=450.000000)
         InitialParticlesPerSecond=10.000000
         DrawStyle=PTDS_Brighten
         Texture=Texture'AW-2k4XP.Weapons.ShockTankEffectCore2a'
         LifetimeRange=(Min=0.500000,Max=0.500000)
     End Object
     Emitters(0)=SpriteEmitter'LinkVehiclesOmni.TickScorp3GrowthEffect.GlowingCorona'
  */
  
     Begin Object Class=SpriteEmitter Name=Flashes
         FadeOut=True
         SpinParticles=True
         UniformSize=True
         RespawnDeadParticles=False
         MaxParticles=3
         ColorMultiplierRange=(X=(Min=0.000000),Y=(Min=0.500000),Z=(Min=0.800000))
         Opacity=0.500000
         CoordinateSystem=PTCS_Relative
         StartSpinRange=(X=(Max=1.000000))
         StartSizeRange=(X=(Min=200.000000,Max=275.000000))
         SphereRadiusRange=(Min=110.000000,Max=250.000000)
         Texture=Texture'AW-2004Particles.Energy.ElecPanels'
         TextureUSubdivisions=2
         TextureVSubdivisions=2
         LifetimeRange=(Min=0.200000,Max=0.450000)
     End Object
     Emitters(0)=SpriteEmitter'LinkVehiclesOmni.TickScorp3GrowthEffect.Flashes'


     AutoDestroy=True
     bNoDelete=False
     RemoteRole=ROLE_DumbProxy
     bDirectional=True
}
