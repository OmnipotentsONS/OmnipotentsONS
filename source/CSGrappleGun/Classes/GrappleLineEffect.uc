class GrappleLineEffect extends Emitter;

var bool bCancel;
var vector EffectOffset;
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
	BeamEmitter(Emitters[0]).LifeTimeRange.Min = 1.25;
	BeamEmitter(Emitters[0]).LifeTimeRange.Max = 1.25;
	SetTimer(0.5, false);
}

//delayed to make sure the fading beam is spawned before we turn it off
simulated function Timer()
{
	if (Level.NetMode != NM_DedicatedServer)
		BeamEmitter(Emitters[0]).RespawnDeadParticles = false;
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

	if (Instigator == None)
		return;

    StartTrace = Owner.Location;
    EndEffect = Instigator.Location;

	SetLocation(StartTrace);
	SetRotation(rotator(EndEffect - StartTrace));
	Dist = VSize(EndEffect - StartTrace);
	BeamEmitter(Emitters[0]).BeamDistanceRange.Min = Dist;
	BeamEmitter(Emitters[0]).BeamDistanceRange.Max = Dist;
}

defaultproperties
{
     EffectOffset=(X=-5.000000,Y=15.000000,Z=20.000000)
     Begin Object Class=BeamEmitter Name=GrappleBeamEmitter
         BeamDistanceRange=(Min=10000.000000,Max=10000.000000)
         DetermineEndPointBy=PTEP_Distance
         BeamTextureUScale=16.000000
         RotatingSheets=3
         LowFrequencyPoints=2
         HighFrequencyPoints=2
         UseColorScale=True
         AutomaticInitialSpawning=False
         ColorScale(1)=(RelativeTime=0.500000,Color=(B=255,G=255,R=255))
         ColorScale(2)=(RelativeTime=0.800000,Color=(B=255,G=255,R=255))
         ColorScale(3)=(RelativeTime=1.000000)
         ColorMultiplierRange=(X=(Min=0.300000,Max=0.400000),Y=(Min=0.300000,Max=0.300000))
         MaxParticles=1
         UseRotationFrom=PTRS_Actor
         StartSizeRange=(X=(Min=10.000000,Max=10.000000),Y=(Min=10.000000,Max=10.000000))
         InitialParticlesPerSecond=5000.000000
         Texture=Texture'AW-2004Particles.Weapons.BeamFragment'
         LifetimeRange=(Min=0.020000,Max=0.020000)
         StartVelocityRange=(X=(Min=1.000000,Max=1.000000))
     End Object
     Emitters(0)=BeamEmitter'GrappleBeamEmitter'

     AutoDestroy=True
     bNoDelete=False
     bReplicateInstigator=True
     bUpdateSimulatedPosition=True
     bNetInitialRotation=True
     RemoteRole=ROLE_SimulatedProxy
     bHardAttach=True
}
