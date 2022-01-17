/******************************************************************************
OdinIonBlastEmitter

Creation date: 2012-10-23 22:02
Last change: $Id$
Copyright © 2012, Wormbo
Website: http://www.koehler-homepage.de/Wormbo/
Feel free to reuse this code. Send me a note if you found it helpful or want
to report bugs/provide improvements.
Please ask for permission first, if you intend to make money off reused code.
******************************************************************************/

class OdinIonBlastEmitter extends Emitter;


//#exec texture import file=Textures\OdinMainBeam.dds
// not need this depends on Wormbos original


var() float MaxLength;
var vector HitLocation;


replication
{
	reliable if (bNetInitial)
		HitLocation;
}


simulated function PostNetBeginPlay()
{
	local BeamEmitter Beam;

	if (Role != ROLE_Authority)
	{
		SetRotation(rotator(HitLocation - Location));
		SetBeamLength(VSize(HitLocation - Location));
	}

	// tone down amount of smoke
	Beam = BeamEmitter(Emitters[1]);
	if (Level.DetailMode != DM_SuperHigh)
	{
		Beam.BranchProbability *= 0.5;
	}
	if (Level.bDropDetail)
	{
		Beam.BranchProbability *= 0.6;
	}
	if (Level.bAggressiveLOD)
	{
		Beam.BranchProbability *= 0.6;
	}
}


function SetBeamLength(float length)
{
	local BeamEmitter Beam;

	Length = FMax(Length, 20.0);

	Beam = BeamEmitter(Emitters[1]);
	Beam.BeamDistanceRange.Min = length;
	Beam.BeamDistanceRange.Max = length;
	Beam.HighFrequencyPoints *= length / MaxLength;
	Beam.BranchHFPointsRange.Max = Beam.HighFrequencyPoints;
}

static final operator(16) range *= (out range A, float B)
{
	A.Min *= B;
	A.Max *= B;

	return A;
}

//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
     MaxLength=30000.000000
     Begin Object Class=SpriteEmitter Name=BeamSmoke
         FadeOut=True
         FadeIn=True
         UseActorForces=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         UseRandomSubdivision=True
         LowDetailFactor=1.000000
         Acceleration=(Z=30.000000)
         Opacity=0.250000
         FadeOutStartTime=0.350000
         FadeInEndTime=0.350000
         MaxParticles=1000
         DetailMode=DM_High
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=0.300000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
         StartSizeRange=(X=(Max=130.000000))
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'AW-2004Particles.Fire.MuchSmoke1'
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=0.700000)
         InitialDelayRange=(Min=0.200000,Max=0.200000)
         StartVelocityRange=(X=(Min=-20.000000,Max=20.000000),Y=(Min=-30.000000,Max=30.000000),Z=(Min=-10.000000,Max=30.000000))
     End Object
     Emitters(0)=SpriteEmitter'WVHoverTankV2.OdinIonBlastEmitter.BeamSmoke'

     Begin Object Class=BeamEmitter Name=MainBeam
         BeamDistanceRange=(Min=30000.000000,Max=30000.000000)
         DetermineEndPointBy=PTEP_Distance
         RotatingSheets=5
         LowFrequencyPoints=2
         HighFrequencyPoints=1000
         UseBranching=True
         BranchProbability=(Min=1.000000,Max=1.000000)
         BranchEmitter=0
         BranchSpawnAmountRange=(Min=1.000000,Max=1.000000)
         FadeOut=True
         RespawnDeadParticles=False
         AutomaticInitialSpawning=False
         ColorMultiplierRange=(Y=(Min=0.400000,Max=0.400000))
         MaxParticles=1
         UseRotationFrom=PTRS_Actor
         StartSizeRange=(X=(Min=120.000000,Max=120.000000))
         InitialParticlesPerSecond=1000.000000
         DrawStyle=PTDS_Brighten
         Texture=Texture'WVHoverTankV2.OdinMainBeam'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=1.000000,Max=1.000000)
         StartVelocityRange=(X=(Min=1.000000,Max=1.000000))
     End Object
     Emitters(1)=BeamEmitter'WVHoverTankV2.OdinIonBlastEmitter.MainBeam'

     Begin Object Class=BeamEmitter Name=MuzzleFlash
         BeamDistanceRange=(Min=150.000000,Max=150.000000)
         DetermineEndPointBy=PTEP_Distance
         RotatingSheets=3
         LowFrequencyPoints=2
         HighFrequencyPoints=2
         FadeOut=True
         RespawnDeadParticles=False
         AutomaticInitialSpawning=False
         MaxParticles=1
         StartLocationOffset=(X=-50.000000)
         UseRotationFrom=PTRS_Actor
         StartSizeRange=(X=(Min=300.000000,Max=300.000000))
         InitialParticlesPerSecond=1000.000000
         DrawStyle=PTDS_Brighten
         Texture=Texture'AW-2004Particles.Weapons.PlasmaHeadDesat'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=0.500000,Max=0.500000)
         StartVelocityRange=(X=(Min=1.000000,Max=1.000000))
     End Object
     Emitters(2)=BeamEmitter'WVHoverTankV2.OdinIonBlastEmitter.MuzzleFlash'

     AutoDestroy=True
     bNoDelete=False
     bNetTemporary=True
     bAlwaysRelevant=True
     RemoteRole=ROLE_SimulatedProxy
     NetPriority=3.000000
     LifeSpan=5.000000
}
