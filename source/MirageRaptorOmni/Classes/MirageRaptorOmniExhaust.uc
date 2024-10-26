//=============================================================================
// MirageRaptorOmniExhaust.
//=============================================================================


class MirageRaptorOmniExhaust extends ONSAttackCraftExhaust
	placeable;

defaultproperties
{
     Begin Object Class=MeshEmitter Name=MeshEmitter2
         StaticMesh=StaticMesh'AW-2004Particles.Weapons.TurretFlash'
         UseMeshBlendMode=False
         UseParticleColor=True
         UseColorScale=True
         SpinParticles=True
         UniformSize=True
         ColorScale(1)=(RelativeTime=0.125000,Color=(B=255,G=32,R=30))
         ColorScale(2)=(RelativeTime=0.400000,Color=(B=156,G=12,R=40))
         ColorScale(3)=(RelativeTime=1.000000)
         CoordinateSystem=PTCS_Relative
         MaxParticles=3
         StartSpinRange=(Z=(Max=1.000000))
         StartSizeRange=(X=(Min=-0.500000,Max=-0.750000))
         LifetimeRange=(Min=0.100000,Max=0.200000)
     End Object
     Emitters(0)=MeshEmitter'MirageRaptorOmni.MirageRaptorOmniExhaust.MeshEmitter2'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter3
         UseColorScale=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         UseRandomSubdivision=True
         ColorScale(1)=(RelativeTime=0.125000,Color=(B=128,G=92,R=30))
         ColorScale(2)=(RelativeTime=0.400000,Color=(B=126,G=12,R=35))
         ColorScale(3)=(RelativeTime=1.000000)
         CoordinateSystem=PTCS_Relative
         MaxParticles=30
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=0.250000)
         StartSizeRange=(X=(Min=10.000000,Max=10.000000))
         ParticlesPerSecond=100.000000
         InitialParticlesPerSecond=100.000000
         Texture=Texture'XEffectMat.Link.link_muz_blue'
         LifetimeRange=(Min=0.200000,Max=0.200000)
         StartVelocityRange=(X=(Min=150.000000,Max=150.000000))
     End Object
     Emitters(1)=SpriteEmitter'MirageRaptorOmni.MirageRaptorOmniExhaust.SpriteEmitter3'

}
