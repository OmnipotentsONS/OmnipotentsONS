class FX_TurretBeamEffect extends Emitter;

simulated function SpawnEffects(vector HitLocation, vector HitNormal)
{
	local rotator HitRotation;
	local PlayerController PC;
	local bool bFogDist;

	HitRotation = rotator(HitNormal);

	PC = Level.GetLocalPlayerController();
	if ( !PC.BeyondViewDistance(HitLocation, 0) )
	{
		bFogDist = true;
		Spawn(class'ShockImpactFlareB',,, HitLocation, HitRotation);
		Spawn(class'ShockExplosionCoreB',,, HitLocation+HitNormal*8, HitRotation);
	}

	if ( (PC.ViewTarget == None) || (VSize(PC.ViewTarget.Location - Location) > 4000) )
	{
		Emitters[2].Disabled = true;
		Emitters[3].Disabled = true;
		Emitters[4].Disabled = true;
	}
	if ( bFogDist && !PC.BeyondViewDistance(HitLocation, 4000) )
	{
		Spawn(class'ShockImpactRingB',,, HitLocation, HitRotation);
		Spawn(class'ShockImpactScorch',,, HitLocation, rotator(-HitNormal));
	}
}

defaultproperties
{
     Begin Object Class=BeamEmitter Name=BeamEmitter0
         BeamDistanceRange=(Min=512.000000,Max=512.000000)
         DetermineEndPointBy=PTEP_Distance
         RotatingSheets=3
         LowFrequencyPoints=2
         HighFrequencyPoints=2
         BranchProbability=(Max=1.000000)
         BranchSpawnAmountRange=(Max=2.000000)
         UseColorScale=True
         RespawnDeadParticles=False
         AlphaTest=False
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=32,G=32,R=192))
         ColorScale(1)=(RelativeTime=0.800000,Color=(B=128,G=128,R=255))
         ColorScale(2)=(RelativeTime=1.000000)
         MaxParticles=1
         UseRotationFrom=PTRS_Actor
         SizeScale(0)=(RelativeSize=2.000000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.200000)
         StartSizeRange=(X=(Min=80.000000,Max=80.000000),Y=(Min=40.000000,Max=40.000000))
         InitialParticlesPerSecond=5000.000000
         Texture=Texture'TurretParticles.Beams.TurretBeam5'
         LifetimeRange=(Min=0.150000,Max=0.150000)
         StartVelocityRange=(X=(Min=500.000000,Max=500.000000))
     End Object
     Emitters(0)=BeamEmitter'CSAPVerIV.FX_TurretBeamEffect.BeamEmitter0'

     Begin Object Class=BeamEmitter Name=BeamEmitter1
         BeamDistanceRange=(Min=512.000000,Max=512.000000)
         DetermineEndPointBy=PTEP_Distance
         RotatingSheets=3
         LowFrequencyPoints=2
         HighFrequencyPoints=2
         BranchProbability=(Max=1.000000)
         BranchSpawnAmountRange=(Max=2.000000)
         UseColorScale=True
         RespawnDeadParticles=False
         AlphaTest=False
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=64,G=64,R=255))
         ColorScale(1)=(RelativeTime=0.800000,Color=(B=255,R=255))
         ColorScale(2)=(RelativeTime=1.000000)
         Opacity=0.800000
         MaxParticles=1
         UseRotationFrom=PTRS_Actor
         SizeScale(0)=(RelativeSize=2.000000)
         SizeScale(1)=(RelativeTime=1.000000)
         StartSizeRange=(Y=(Min=35.000000,Max=35.000000))
         InitialParticlesPerSecond=5000.000000
         Texture=Texture'EpicParticles.Flares.SoftFlare'
         LifetimeRange=(Min=0.500000,Max=0.500000)
         StartVelocityRange=(X=(Min=500.000000,Max=500.000000))
     End Object
     Emitters(1)=BeamEmitter'CSAPVerIV.FX_TurretBeamEffect.BeamEmitter1'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter17
         UseDirectionAs=PTDU_Normal
         ProjectionNormal=(X=1.000000,Z=0.000000)
         UseColorScale=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=128,G=128,R=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=64,G=64,R=255))
         MaxParticles=2
         UseRotationFrom=PTRS_Actor
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=2.000000)
         SizeScale(1)=(RelativeTime=1.000000)
         StartSizeRange=(X=(Min=200.000000,Max=250.000000))
         InitialParticlesPerSecond=20.000000
         Texture=Texture'AW-2004Particles.Weapons.PlasmaStar2'
         LifetimeRange=(Min=0.200000,Max=0.200000)
     End Object
     Emitters(2)=SpriteEmitter'CSAPVerIV.FX_TurretBeamEffect.SpriteEmitter17'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter19
         UseColorScale=True
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         BlendBetweenSubdivisions=True
         UseRandomSubdivision=True
         Acceleration=(Z=20.000000)
         ColorScale(0)=(Color=(B=128,G=128,R=255))
         ColorScale(1)=(RelativeTime=0.650000,Color=(G=23,R=132))
         ColorScale(2)=(RelativeTime=1.000000)
         MaxParticles=8
         StartLocationOffset=(X=16.000000)
         StartLocationRange=(X=(Max=64.000000),Z=(Max=2.000000))
         UseRotationFrom=PTRS_Actor
         StartSpinRange=(X=(Max=0.025000))
         SizeScale(0)=(RelativeSize=0.750000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.800000)
         StartSizeRange=(X=(Min=40.000000))
         InitialParticlesPerSecond=900.000000
         Texture=Texture'AW-2004Particles.Weapons.SmokePanels1'
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         LifetimeRange=(Min=1.500000,Max=1.500000)
         StartVelocityRange=(Z=(Max=15.000000))
         WarmupTicksPerSecond=1.000000
         RelativeWarmupTime=0.200000
     End Object
     Emitters(3)=SpriteEmitter'CSAPVerIV.FX_TurretBeamEffect.SpriteEmitter19'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter20
         UseColorScale=True
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         BlendBetweenSubdivisions=True
         UseRandomSubdivision=True
         ColorScale(0)=(Color=(B=32,G=32,R=255))
         ColorScale(1)=(RelativeTime=0.100000,Color=(B=32,G=32,R=255))
         ColorScale(2)=(RelativeTime=0.800000,Color=(B=64,G=64,R=255))
         ColorScale(3)=(RelativeTime=1.000000)
         MaxParticles=3
         StartLocationOffset=(X=10.000000)
         StartLocationRange=(X=(Max=20.000000))
         UseRotationFrom=PTRS_Actor
         SizeScale(0)=(RelativeSize=0.400000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.600000)
         StartSizeRange=(X=(Min=60.000000,Max=80.000000))
         InitialParticlesPerSecond=3000.000000
         Texture=Texture'AW-2004Particles.Weapons.SmokePanels1'
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         LifetimeRange=(Min=0.200000,Max=0.200000)
     End Object
     Emitters(4)=SpriteEmitter'CSAPVerIV.FX_TurretBeamEffect.SpriteEmitter20'

     AutoDestroy=True
     bNoDelete=False
}
