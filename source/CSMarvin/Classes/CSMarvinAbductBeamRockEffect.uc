class CSMarvinAbductBeamRockEffect extends Emitter;

simulated function Cancel()
{
	bTearOff = true;
    Emitters[0].RespawnDeadParticles = false;
    Emitters[1].RespawnDeadParticles = false;
    Emitters[2].RespawnDeadParticles = false;

	SetTimer(8.0, false);
}

simulated function Timer()
{
    Destroy();
}

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter66
         SpinParticles=True
         UniformSize=True
         Acceleration=(Z=35.000000)
         MaxParticles=30
         StartLocationRange=(X=(Min=-150.000000,Max=150.000000))
         UseRotationFrom=PTRS_Actor
         StartSpinRange=(X=(Min=0.500000,Max=0.400000))
         StartSizeRange=(X=(Min=1.000000,Max=6.000000),Y=(Min=1.000000,Max=6.000000))
         Texture=Texture'AW-2004Particles.Weapons.SparkHead'
         LifetimeRange=(Min=6.000000,Max=6.000000)
         WarmupTicksPerSecond=1.000000
         RelativeWarmupTime=1.000000
     End Object
     Emitters(0)=SpriteEmitter'CSMarvin.CSMarvinAbductBeamRockEffect.SpriteEmitter66'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter10
         SpinParticles=True
         UniformSize=True
         Acceleration=(Z=35.000000)
         MaxParticles=30
         StartLocationRange=(X=(Min=-150.000000,Max=150.000000))
         UseRotationFrom=PTRS_Actor
         StartSpinRange=(X=(Min=0.500000,Max=0.400000))
         StartSizeRange=(X=(Min=1.000000,Max=6.000000),Y=(Min=1.000000,Max=6.000000))
         Texture=Texture'AW-2004Particles.Weapons.SparkHead'
         LifetimeRange=(Min=6.000000,Max=6.000000)
         WarmupTicksPerSecond=1.000000
         RelativeWarmupTime=1.000000
     End Object
     Emitters(1)=SpriteEmitter'CSMarvin.CSMarvinAbductBeamRockEffect.SpriteEmitter10'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter12
         SpinParticles=True
         UniformSize=True
         Acceleration=(Z=31.000000)
         MaxParticles=30
         StartLocationRange=(X=(Min=-150.000000,Max=150.000000))
         UseRotationFrom=PTRS_Actor
         StartSpinRange=(X=(Min=0.500000,Max=0.400000))
         StartSizeRange=(X=(Min=2.000000,Max=8.000000),Y=(Min=2.000000,Max=8.000000))
         Texture=Texture'AW-2004Particles.Weapons.SparkHead'
         LifetimeRange=(Min=6.000000,Max=6.000000)
         WarmupTicksPerSecond=1.000000
         RelativeWarmupTime=1.000000
     End Object
     Emitters(2)=SpriteEmitter'CSMarvin.CSMarvinAbductBeamRockEffect.SpriteEmitter12'


     bNoDelete=False

    /*
     bNetTemporary=False
     bReplicateInstigator=True
     bUpdateSimulatedPosition=True
     bNetInitialRotation=True
     RemoteRole=ROLE_SimulatedProxy
     */
}
