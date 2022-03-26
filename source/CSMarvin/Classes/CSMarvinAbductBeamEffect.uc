class CSMarvinAbductBeamEffect extends Emitter;
#exec OBJ LOAD FILE="..\Textures\AW-2004Particles.utx"

var bool bCancel;
var vector EndEffect;

replication
{
	reliable if (bNetDirty && Role == ROLE_Authority)
		bCancel, EndEffect;
}

function SetInitialState()
{
	Super.SetInitialState();

	if (Level.NetMode == NM_DedicatedServer)
		disable('Tick');
}

simulated function Cancel()
{
	bCancel = true;
	bTearOff = true;
	BeamEmitter(Emitters[0]).FadeOut = true;
	BeamEmitter(Emitters[0]).LifeTimeRange.Min = 0.2;
	BeamEmitter(Emitters[0]).LifeTimeRange.Max = 0.2;

	SetTimer(0.2, false);
}

simulated function Timer()
{
	if (Level.NetMode != NM_DedicatedServer)
    {
		BeamEmitter(Emitters[0]).RespawnDeadParticles = false;
	}
	else
		Destroy();
}

simulated function Tick(float deltaTime)
{
	local vector StartTrace;
	local float Dist;

	if (bCancel)
	{
		Cancel();
		disable('Tick');
		return;
	}

	StartTrace = Location;
	Dist = VSize(EndEffect - StartTrace);
	BeamEmitter(Emitters[0]).BeamDistanceRange.Min = Dist;
	BeamEmitter(Emitters[0]).BeamDistanceRange.Max = Dist;
}

defaultproperties
{
     Begin Object Class=BeamEmitter Name=BeamEmitter0
         BeamDistanceRange=(Min=10000.000000,Max=10000.000000)
         DetermineEndPointBy=PTEP_Distance
         RotatingSheets=3
         LowFrequencyPoints=2
         HighFrequencyPoints=2
         BranchProbability=(Max=1.000000)
         BranchSpawnAmountRange=(Max=2.000000)
         UseColorScale=True
         AlphaTest=True
         DrawStyle=PTDS_Translucent
         Opacity=0.5
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
         CoordinateSystem=PTCS_Relative
         MaxParticles=1
         SizeScale(0)=(RelativeSize=1.00000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=0.750000)
         StartSizeRange=(X=(Min=260.000000,Max=260.000000),Y=(Min=260.000000,Max=260.000000))
         InitialParticlesPerSecond=5000.000000
         Texture=Texture'AW-2004Particles.Energy.PowerBeam'
         LifetimeRange=(Min=0.020000,Max=0.020000)
         StartVelocityRange=(X=(Min=1.000000,Max=1.000000))
     End Object
     Emitters(0)=BeamEmitter'CSMarvin.CSMarvinAbductBeamEffect.BeamEmitter0'

     AutoDestroy=True
     bNoDelete=False
     bReplicateInstigator=True
     bUpdateSimulatedPosition=True
     bNetInitialRotation=True
     RemoteRole=ROLE_SimulatedProxy
     bHardAttach=True
}
