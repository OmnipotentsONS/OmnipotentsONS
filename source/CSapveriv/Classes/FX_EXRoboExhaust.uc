//=============================================================================
// ONSAttackCraftExhaust.
//=============================================================================
// Placement offsets are:
// X=147.695313,Y=-25.922363,Z=51.000000
// and
// X=147.612320,Y=27.779526,Z=51.000000
//=============================================================================

class FX_EXRoboExhaust extends Emitter
	placeable;

#exec OBJ LOAD FILE="..\Textures\AW-2004Particles.utx"
#exec OBJ LOAD FILE="..\Sounds\APVerIV_Snd.uax"                            APVerIV_Snd.enginesA
var sound  	IgniteSound;
var sound 	FlightSound;

simulated function SetThrustEnabled(bool bDoThrust)
{
	if(bDoThrust)
	{
		Emitters[0].Disabled = false;
		Emitters[1].Disabled = false;
		PlaySound(IgniteSound, SLOT_Misc, 255, true, 512);
		AmbientSound=FlightSound;
	}
	else
	{
		Emitters[0].Disabled = true;
		Emitters[1].Disabled = true;
		AmbientSound=none;
	}
}

defaultproperties
{
     IgniteSound=Sound'CicadaSnds.Missile.MissileIgnite'
     FlightSound=Sound'APVerIV_Snd.enginesA'
     Begin Object Class=MeshEmitter Name=MeshEmitter2
         StaticMesh=StaticMesh'AW-2004Particles.Weapons.TurretFlash'
         UseMeshBlendMode=False
         RenderTwoSided=True
         UseParticleColor=True
         UseColorScale=True
         SpinParticles=True
         UniformSize=True
         ColorScale(1)=(RelativeTime=0.330000,Color=(B=32,G=112,R=255))
         ColorScale(2)=(RelativeTime=0.660000,Color=(B=32,G=112,R=255))
         ColorScale(3)=(RelativeTime=1.000000)
         CoordinateSystem=PTCS_Relative
         MaxParticles=3
         UseRotationFrom=PTRS_Normal
         StartSpinRange=(Z=(Max=1.000000))
         StartSizeRange=(X=(Min=-0.500000,Max=-1.750000))
         LifetimeRange=(Min=0.100000,Max=0.200000)
     End Object
     Emitters(0)=MeshEmitter'CSAPVerIV.FX_EXRoboExhaust.MeshEmitter2'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter3
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
         StartSizeRange=(X=(Min=20.000000,Max=25.000000))
         ParticlesPerSecond=100.000000
         InitialParticlesPerSecond=100.000000
         Texture=Texture'AW-2004Particles.Weapons.SmokePanels1'
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         LifetimeRange=(Min=0.200000,Max=0.200000)
         StartVelocityRange=(X=(Min=1000.000000,Max=1000.000000))
     End Object
     Emitters(1)=SpriteEmitter'CSAPVerIV.FX_EXRoboExhaust.SpriteEmitter3'

     AutoDestroy=True
     CullDistance=12000.000000
     bNoDelete=False
     Rotation=(Pitch=-16384)
     AmbientGlow=140
     bHardAttach=True
     SoundVolume=255
     SoundRadius=556.000000
     TransientSoundVolume=1.000000
     TransientSoundRadius=784.000000
     bDirectional=True
}
