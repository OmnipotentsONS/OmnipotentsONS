/******************************************************************************
FireHoundTurretFlameEitter taken from FirebugPilotFlameEmitter

Taken from Firebug for FireHound
******************************************************************************/

class FireHoundDriverFlameEmitter extends ONSWeaponAmbientEmitter;



//#exec audio import file=Sounds\FirebugFireStart.wav
//#exec audio import file=Sounds\FirebugFireStop.wav


var bool bActive;


simulated function Tick(float DeltaTime)
{
	local ONSWeapon Gun;
	local vector NewLocation;
	local coords WeaponBoneCoords;

	Gun = ONSWeapon(Owner);
	if (Gun != None)
	{
		WeaponBoneCoords = Gun.GetBoneCoords(Gun.WeaponFireAttachmentBone);
		NewLocation = WeaponBoneCoords.Origin + Gun.WeaponFireOffset * WeaponBoneCoords.XAxis;
		SetLocation(NewLocation);
		SetRotation(OrthoRotation(WeaponBoneCoords.XAxis, WeaponBoneCoords.YAxis, WeaponBoneCoords.ZAxis));
	}
}

simulated function SetEmitterStatus(bool bEnabled)
{
	if (bEnabled)
	{
		if (!bActive)
		{
			bActive = True;
			PlaySound(Sound'WVHoverTankV2.FirebugFireStart',, 2.0,, 300.0);
		}

		Emitters[0].ParticlesPerSecond = 0.0;
		Emitters[0].InitialParticlesPerSecond = 0.0;

		Emitters[1].ParticlesPerSecond = 0.0;
		Emitters[1].InitialParticlesPerSecond = 0.0;

		Emitters[2].ParticlesPerSecond = 20.0;
		Emitters[2].InitialParticlesPerSecond = 20.0;
		Emitters[2].AllParticlesDead = false;

		Emitters[3].ParticlesPerSecond = 20.0;
		Emitters[3].InitialParticlesPerSecond = 20.0;
		Emitters[3].AllParticlesDead = false;

		Emitters[4].ParticlesPerSecond = 20.0;
		Emitters[4].InitialParticlesPerSecond = 20.0;
		Emitters[4].AllParticlesDead = false;

		Emitters[5].ParticlesPerSecond = 20.0;
		Emitters[5].InitialParticlesPerSecond = 20.0;
		Emitters[5].AllParticlesDead = false;
	}
	else
	{
		if (bActive)
		{
			bActive = False;
			PlaySound(Sound'WVHoverTankV2.FirebugFireStop',, 2.0,, 300.0);
		}

		Emitters[0].ParticlesPerSecond = 10.0;
		Emitters[0].InitialParticlesPerSecond = 10.0;
		Emitters[0].AllParticlesDead = false;

		Emitters[1].ParticlesPerSecond = 10.0;
		Emitters[1].InitialParticlesPerSecond = 10.0;
		Emitters[1].AllParticlesDead = false;

		Emitters[2].ParticlesPerSecond = 0.0;
		Emitters[2].InitialParticlesPerSecond = 0.0;

		Emitters[3].ParticlesPerSecond = 0.0;
		Emitters[3].InitialParticlesPerSecond = 0.0;

		Emitters[4].ParticlesPerSecond = 0.0;
		Emitters[4].InitialParticlesPerSecond = 0.0;

		Emitters[5].ParticlesPerSecond = 0.0;
		Emitters[5].InitialParticlesPerSecond = 0.0;
	}
}


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=PilotFlameRight
         FadeOut=True
         FadeIn=True
         RespawnDeadParticles=False
         SpinParticles=True
         UniformSize=True
         AutomaticInitialSpawning=False
         UseRandomSubdivision=True
         AddVelocityFromOwner=True
         Acceleration=(Z=500.000000)
         FadeOutStartTime=0.100000
         FadeInEndTime=0.050000
         StartLocationOffset=(X=2.000000,Y=5.500000,Z=12.000000)
         UseRotationFrom=PTRS_Actor
         StartSpinRange=(X=(Min=-0.130000,Max=-0.120000))
         StartSizeRange=(X=(Min=5.000000,Max=10.000000))
         ParticlesPerSecond=10.000000
         InitialParticlesPerSecond=10.000000
         Texture=Texture'EmitterTextures.MultiFrame.LargeFlames'
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         LifetimeRange=(Min=0.200000,Max=0.200000)
         StartVelocityRange=(X=(Min=30.000000,Max=50.000000),Y=(Min=-15.000000,Max=15.000000),Z=(Min=-10.000000,Max=10.000000))
         AddVelocityMultiplierRange=(X=(Min=0.900000,Max=0.950000),Y=(Min=0.900000,Max=0.950000),Z=(Min=0.900000,Max=0.950000))
     End Object
     Emitters(0)=SpriteEmitter'FireVehiclesV2Omni.FireHoundDriverFlameEmitter.PilotFlameRight'

     Begin Object Class=SpriteEmitter Name=PilotFlameLeft
         FadeOut=True
         FadeIn=True
         RespawnDeadParticles=False
         SpinParticles=True
         UniformSize=True
         AutomaticInitialSpawning=False
         UseRandomSubdivision=True
         AddVelocityFromOwner=True
         Acceleration=(Z=500.000000)
         FadeOutStartTime=0.100000
         FadeInEndTime=0.050000
         StartLocationOffset=(X=2.000000,Y=-5.500000,Z=12.000000)
         UseRotationFrom=PTRS_Actor
         StartSpinRange=(X=(Min=-0.130000,Max=-0.120000))
         StartSizeRange=(X=(Min=5.000000,Max=10.000000))
         ParticlesPerSecond=10.000000
         InitialParticlesPerSecond=10.000000
         Texture=Texture'EmitterTextures.MultiFrame.LargeFlames'
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         LifetimeRange=(Min=0.200000,Max=0.200000)
         StartVelocityRange=(X=(Min=30.000000,Max=50.000000),Y=(Min=-15.000000,Max=15.000000),Z=(Min=-10.000000,Max=10.000000))
         AddVelocityMultiplierRange=(X=(Min=0.900000,Max=0.950000),Y=(Min=0.900000,Max=0.950000),Z=(Min=0.900000,Max=0.950000))
     End Object
     Emitters(1)=SpriteEmitter'FireVehiclesV2Omni.FireHoundDriverFlameEmitter.PilotFlameLeft'

     Begin Object Class=SpriteEmitter Name=FireSprayRight
         UseDirectionAs=PTDU_Right
         UseCollision=True
         UseMaxCollisions=True
         UseColorScale=True
         FadeOut=True
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         AddVelocityFromOwner=True
         Acceleration=(Z=-100.000000)
         ColorScale(0)=(Color=(B=255))
         ColorScale(1)=(RelativeTime=0.300000,Color=(G=255,R=255))
         ColorScale(2)=(RelativeTime=1.000000,Color=(G=255,R=255))
         StartLocationOffset=(X=2.000000,Y=5.500000,Z=12.000000)
         UseRotationFrom=PTRS_Actor
         SizeScale(0)=(RelativeSize=0.300000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
         Texture=Texture'EpicParticles.Beams.WhiteStreak01aw'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=0.500000,Max=0.500000)
         StartVelocityRange=(X=(Min=1400.000000,Max=1800.000000),Y=(Max=20.000000),Z=(Min=-20.000000,Max=20.000000))
         AddVelocityMultiplierRange=(X=(Min=0.900000,Max=0.900000),Y=(Min=0.900000,Max=0.900000),Z=(Min=0.900000,Max=0.900000))
     End Object
     Emitters(2)=SpriteEmitter'FireVehiclesV2Omni.FireHoundDriverFlameEmitter.FireSprayRight'

     Begin Object Class=SpriteEmitter Name=FireCloudRight
         UseCollision=True
         UseColorScale=True
         FadeOut=True
         FadeIn=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         UseRandomSubdivision=True
         AddVelocityFromOwner=True
         Acceleration=(Z=200.000000)
         DampingFactorRange=(X=(Min=0.100000,Max=0.200000),Y=(Min=0.100000,Max=0.200000),Z=(Min=0.100000,Max=0.200000))
         ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=0.700000,Color=(G=255,R=255,A=255))
         ColorScale(2)=(RelativeTime=1.000000,Color=(R=255,A=255))
         FadeOutStartTime=0.500000
         FadeInEndTime=0.100000
         MaxParticles=60
         StartLocationOffset=(X=2.000000,Y=5.500000,Z=12.000000)
         UseRotationFrom=PTRS_Actor
         StartSpinRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
         SizeScale(1)=(RelativeTime=0.500000,RelativeSize=1.200000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=2.000000)
         Texture=Texture'EmitterTextures.MultiFrame.LargeFlames'
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=1.000000,Max=1.000000)
         StartVelocityRange=(X=(Min=2800.000000,Max=3000.000000),Y=(Max=100.000000),Z=(Min=-50.000000,Max=50.000000))
         VelocityLossRange=(X=(Min=0.900000,Max=1.000000),Y=(Min=0.900000,Max=1.000000),Z=(Min=0.900000,Max=1.000000))
         AddVelocityMultiplierRange=(X=(Min=0.900000,Max=0.900000),Y=(Min=0.900000,Max=0.900000),Z=(Min=0.900000,Max=0.900000))
     End Object
     Emitters(3)=SpriteEmitter'FireVehiclesV2Omni.FireHoundDriverFlameEmitter.FireCloudRight'

     Begin Object Class=SpriteEmitter Name=FireSprayLeft
         UseDirectionAs=PTDU_Right
         UseCollision=True
         UseMaxCollisions=True
         UseColorScale=True
         FadeOut=True
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         AddVelocityFromOwner=True
         Acceleration=(Z=-100.000000)
         ColorScale(0)=(Color=(B=255))
         ColorScale(1)=(RelativeTime=0.300000,Color=(G=255,R=255))
         ColorScale(2)=(RelativeTime=1.000000,Color=(G=255,R=255))
         StartLocationOffset=(X=2.000000,Y=-5.500000,Z=12.000000)
         UseRotationFrom=PTRS_Actor
         SizeScale(0)=(RelativeSize=0.300000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
         Texture=Texture'EpicParticles.Beams.WhiteStreak01aw'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=0.500000,Max=0.500000)
         StartVelocityRange=(X=(Min=1400.000000,Max=1800.000000),Y=(Min=-20.000000),Z=(Min=-20.000000,Max=20.000000))
         AddVelocityMultiplierRange=(X=(Min=0.900000,Max=0.900000),Y=(Min=0.900000,Max=0.900000),Z=(Min=0.900000,Max=0.900000))
     End Object
     Emitters(4)=SpriteEmitter'FireVehiclesV2Omni.FireHoundDriverFlameEmitter.FireSprayLeft'

     Begin Object Class=SpriteEmitter Name=FireCloudLeft
         UseCollision=True
         UseColorScale=True
         FadeOut=True
         FadeIn=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         UseRandomSubdivision=True
         AddVelocityFromOwner=True
         Acceleration=(Z=200.000000)
         DampingFactorRange=(X=(Min=0.100000,Max=0.200000),Y=(Min=0.100000,Max=0.200000),Z=(Min=0.100000,Max=0.200000))
         ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=0.700000,Color=(G=255,R=255,A=255))
         ColorScale(2)=(RelativeTime=1.000000,Color=(R=255,A=255))
         FadeOutStartTime=0.500000
         FadeInEndTime=0.100000
         MaxParticles=60
         StartLocationOffset=(X=2.000000,Y=-5.500000,Z=12.000000)
         UseRotationFrom=PTRS_Actor
         StartSpinRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
         SizeScale(1)=(RelativeTime=0.500000,RelativeSize=1.200000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=2.000000)
         Texture=Texture'EmitterTextures.MultiFrame.LargeFlames'
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=1.000000,Max=1.000000)
         StartVelocityRange=(X=(Min=2800.000000,Max=3000.000000),Y=(Min=-100.000000),Z=(Min=-50.000000,Max=50.000000))
         VelocityLossRange=(X=(Min=0.900000,Max=1.000000),Y=(Min=0.900000,Max=1.000000),Z=(Min=0.900000,Max=1.000000))
         AddVelocityMultiplierRange=(X=(Min=0.900000,Max=0.900000),Y=(Min=0.900000,Max=0.900000),Z=(Min=0.900000,Max=0.900000))
     End Object
     Emitters(5)=SpriteEmitter'FireVehiclesV2Omni.FireHoundDriverFlameEmitter.FireCloudLeft'

     bNoDelete=False
}
