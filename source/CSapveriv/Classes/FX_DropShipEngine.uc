class FX_DropShipEngine extends FX_AirPowerEngineEffects
	placeable;

simulated function SetInvisable()
{
   //Turn off Engine Emitters
     Emitters[0].Disabled=True;
     Emitters[1].Disabled=True;
     bHidden=true;
}

simulated function SetVisable()
{
      //Turn on Engine Emitters
      Emitters[0].Disabled=False;
      Emitters[1].Disabled=False;
      bHidden=False;
}

defaultproperties
{
     Begin Object Class=MeshEmitter Name=MeshEmitter0
         StaticMesh=StaticMesh'AW-2004Particles.Weapons.TurretFlash'
         UseMeshBlendMode=False
         UseParticleColor=True
         UseColorScale=True
         SpinParticles=True
         UniformSize=True
         ColorScale(1)=(RelativeTime=0.330000,Color=(B=32,G=112,R=255))
         ColorScale(2)=(RelativeTime=0.660000,Color=(B=32,G=112,R=255))
         ColorScale(3)=(RelativeTime=1.000000)
         CoordinateSystem=PTCS_Relative
         MaxParticles=3
         StartSpinRange=(Z=(Max=1.000000))
         StartSizeRange=(X=(Min=-1.000000,Max=-1.250000))
         LifetimeRange=(Min=0.100000,Max=0.200000)
     End Object
     Emitters(0)=MeshEmitter'CSAPVerIV.FX_DropShipEngine.MeshEmitter0'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter1
         UseColorScale=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         UseRandomSubdivision=True
         ColorScale(1)=(RelativeTime=0.125000,Color=(B=28,G=192,R=250))
         ColorScale(2)=(RelativeTime=0.400000,Color=(B=26,G=112,R=255))
         ColorScale(3)=(RelativeTime=1.000000)
         CoordinateSystem=PTCS_Relative
         MaxParticles=30
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=0.250000)
         StartSizeRange=(X=(Min=20.000000,Max=20.000000))
         ParticlesPerSecond=100.000000
         InitialParticlesPerSecond=100.000000
         Texture=Texture'AW-2004Particles.Weapons.SmokePanels1'
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         LifetimeRange=(Min=0.200000,Max=0.200000)
         StartVelocityRange=(X=(Min=750.000000,Max=800.000000))
     End Object
     Emitters(1)=SpriteEmitter'CSAPVerIV.FX_DropShipEngine.SpriteEmitter1'

}
