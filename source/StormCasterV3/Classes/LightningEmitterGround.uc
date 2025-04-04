/******************************************************************************
GroundLightningEmitter

Creation date: 2013-09-09 10:07
Last change: $Id$
Copyright � 2013, Wormbo
Website: http://www.koehler-homepage.de/Wormbo/
Feel free to reuse this code. Send me a note if you found it helpful or want
to report bugs/provide improvements.
Please ask for permission first, if you intend to make money off reused code.
******************************************************************************/

class LightningEmitterGround extends Emitter;


//=============================================================================
// Variables
//=============================================================================

var vector LightningStart;


//=============================================================================
// Replication
//=============================================================================

replication
{
	reliable if (bNetInitial)
		LightningStart;
}


simulated function PostNetBeginPlay()
{
	if (Role < ROLE_Authority)
		UpdateLightningStart();
}


function SetLightningStart(vector NewLightningStart)
{
	LightningStart = NewLightningStart;
	if (Level.NetMode != NM_DedicatedServer)
		UpdateLightningStart();
}


simulated function UpdateLightningStart()
{
	local vector Offset;
	local BeamEmitter BE;
	local vector HitLocation, HitNormal;
	local Actor HitActor;

	Offset = LightningStart - Location;
	BE = BeamEmitter(Emitters[1]);
	BE.BeamEndPoints[0].Offset.X.Min = Offset.X;
	BE.BeamEndPoints[0].Offset.X.Max = Offset.X;
	BE.BeamEndPoints[0].Offset.Y.Min = Offset.Y;
	BE.BeamEndPoints[0].Offset.Y.Max = Offset.Y;
	BE.BeamEndPoints[0].Offset.Z.Min = Offset.Z;
	BE.BeamEndPoints[0].Offset.Z.Max = Offset.Z;

	if (Level.DetailMode == DM_Low)
		return;

	HitActor = Trace(HitLocation, HitNormal, Location - 100 * Normal(Offset), LightningStart, True, vect(0,0,0));

	if (PhysicsVolume(HitActor) != None && PhysicsVolume(HitActor).bWaterVolume)
		Spawn(class'WaterSplash',,, HitLocation, rot(0,0,0));
	else if (HitActor != None && HitActor.bWorldGeometry && !PhysicsVolume.bWaterVolume)
		Spawn(class'LightningImpactEmitterGround',,, HitLocation, rotator(-HitNormal));
}


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
     Begin Object Class=BeamEmitter Name=LightningBranches
         BeamEndPoints(0)=(offset=(X=(Min=-700.000000,Max=700.000000),Y=(Min=-700.000000,Max=700.000000),Z=(Min=-1500.000000)))
         DetermineEndPointBy=PTEP_Offset
         RotatingSheets=2
         LowFrequencyNoiseRange=(X=(Min=-50.000000,Max=50.000000),Y=(Min=-50.000000,Max=50.000000),Z=(Min=-10.000000,Max=10.000000))
         HighFrequencyNoiseRange=(X=(Min=-10.000000,Max=10.000000),Y=(Min=-10.000000,Max=10.000000))
         NoiseDeterminesEndPoint=True
         UseColorScale=True
         RespawnDeadParticles=False
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=255,G=255,R=255))
         ColorScale(1)=(RelativeTime=0.100000,Color=(B=255,G=255,R=255))
         ColorScale(2)=(RelativeTime=0.300000,Color=(B=64,G=64,R=64))
         ColorScale(3)=(RelativeTime=0.400000,Color=(B=255,G=255,R=255))
         ColorScale(4)=(RelativeTime=1.000000)
         ColorMultiplierRange=(X=(Min=0.700000,Max=0.800000),Y=(Min=0.800000,Max=0.900000))
         MaxParticles=50
         StartSizeRange=(X=(Min=20.000000,Max=25.000000),Y=(Min=20.000000,Max=25.000000),Z=(Min=20.000000,Max=25.000000))
         DrawStyle=PTDS_Brighten
         Texture=Texture'EpicParticles.Beams.HotBolt04aw'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=0.500000,Max=0.500000)
     End Object
     Emitters(0)=BeamEmitter'StormCasterV3.LightningEmitterGround.LightningBranches'

     Begin Object Class=BeamEmitter Name=MainLightning
         BeamEndPoints(0)=(offset=(X=(Min=-1000.000000,Max=1000.000000),Y=(Min=-1000.000000,Max=1000.000000),Z=(Min=5000.000000,Max=5000.000000)))
         DetermineEndPointBy=PTEP_Offset
         BeamTextureUScale=4.000000
         RotatingSheets=2
         LowFrequencyNoiseRange=(X=(Min=-300.000000,Max=300.000000),Y=(Min=-300.000000,Max=300.000000))
         LowFrequencyPoints=5
         HighFrequencyNoiseRange=(X=(Min=-80.000000,Max=80.000000),Y=(Min=-80.000000,Max=80.000000))
         HighFrequencyPoints=20
         UseBranching=True
         BranchProbability=(Min=0.300000,Max=0.300000)
         BranchHFPointsRange=(Min=5.000000)
         BranchEmitter=0
         BranchSpawnAmountRange=(Min=1.000000,Max=1.000000)
         LinkupLifetime=True
         UseColorScale=True
         RespawnDeadParticles=False
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=255,G=255,R=255))
         ColorScale(1)=(RelativeTime=0.100000,Color=(B=255,G=255,R=255))
         ColorScale(2)=(RelativeTime=0.300000,Color=(B=64,G=64,R=64))
         ColorScale(3)=(RelativeTime=0.400000,Color=(B=255,G=255,R=255))
         ColorScale(4)=(RelativeTime=1.000000)
         ColorMultiplierRange=(X=(Min=0.700000,Max=0.800000),Y=(Min=0.800000,Max=0.900000))
         MaxParticles=1
         StartSizeRange=(X=(Min=40.000000,Max=40.000000),Y=(Min=40.000000,Max=40.000000),Z=(Min=40.000000,Max=40.000000))
         Sounds(0)=(Sound=Sound'StormCasterV3.StormThunder1',Radius=(Min=2000.000000,Max=3000.000000),Pitch=(Min=0.800000,Max=1.200000),Weight=1,Volume=(Min=1.000000,Max=1.800000),Probability=(Min=1.000000,Max=1.000000))
         Sounds(1)=(Sound=Sound'StormCasterV3.StormThunder2',Radius=(Min=2000.000000,Max=3000.000000),Pitch=(Min=0.800000,Max=1.200000),Weight=1,Volume=(Min=1.000000,Max=1.600000),Probability=(Min=1.000000,Max=1.000000))
         Sounds(2)=(Sound=Sound'StormCasterV3.StormThunder3',Radius=(Min=2000.000000,Max=3000.000000),Pitch=(Min=0.800000,Max=1.200000),Weight=1,Volume=(Min=1.000000,Max=1.600000),Probability=(Min=1.000000,Max=1.000000))
         Sounds(3)=(Sound=Sound'StormCasterV3.StormThunder4',Radius=(Min=2000.000000,Max=3000.000000),Pitch=(Min=0.800000,Max=1.200000),Weight=1,Volume=(Min=1.000000,Max=1.800000),Probability=(Min=1.000000,Max=1.000000))
         SpawningSound=PTSC_Random
         SpawningSoundIndex=(Max=4.000000)
         SpawningSoundProbability=(Min=1.000000,Max=1.000000)
         InitialParticlesPerSecond=1000.000000
         DrawStyle=PTDS_Brighten
         Texture=Texture'EpicParticles.Beams.HotBolt03aw'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=0.500000,Max=0.500000)
     End Object
     Emitters(1)=BeamEmitter'StormCasterV3.LightningEmitterGround.MainLightning'

     AutoDestroy=True
     bNoDelete=False
     bNetTemporary=True
     bAlwaysRelevant=True
     RemoteRole=ROLE_SimulatedProxy
     LifeSpan=1.000000
     bNotOnDedServer=False
     bTraceWater=True
}
