/******************************************************************************
GaussFireEffect

Creation date: 2010-09-21 09:49
Last change: $Id$
Copyright (c) 2010, Wormbo
******************************************************************************/

class GaussFireEffect extends Emitter;


//=============================================================================
// Imports
//=============================================================================

#exec load file=VMmeshEmitted.usx


simulated function PostBeginPlay()
{
	Emitters[1].StartSpinRange.X.Min = Rotation.Yaw / 65535.0;
	Emitters[1].StartSpinRange.X.Max = Rotation.Yaw / 65535.0;
	Emitters[1].StartSpinRange.Y.Min = Rotation.Pitch / 65535.0;
	Emitters[1].StartSpinRange.Y.Max = Rotation.Pitch / 65535.0;
	Emitters[1].StartSpinRange.Z.Min = Rotation.Roll / 65535.0;
	Emitters[1].StartSpinRange.Z.Max = Rotation.Roll / 65535.0;
}


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
     Begin Object Class=MeshEmitter Name=MeshEmitter0
         StaticMesh=StaticMesh'VMmeshEmitted.EJECTA.minelayerMuzzleFlashSM'
         RespawnDeadParticles=False
         SpinParticles=True
         AutomaticInitialSpawning=False
         CoordinateSystem=PTCS_Relative
         MaxParticles=3
         UseRotationFrom=PTRS_Actor
         StartSpinRange=(Z=(Max=1.000000))
         StartSizeRange=(Y=(Min=0.250000,Max=0.300000),Z=(Min=0.250000,Max=0.300000))
         InitialParticlesPerSecond=100.000000
         LifetimeRange=(Min=0.050000,Max=0.100000)
     End Object
     Emitters(0)=MeshEmitter'WVHoverTankV2.GaussFireEffect.MeshEmitter0'

     Begin Object Class=MeshEmitter Name=MeshEmitter1
         StaticMesh=StaticMesh'VMmeshEmitted.EJECTA.EjectedBRASSsm'
         UseCollision=True
         UseMaxCollisions=True
         RespawnDeadParticles=False
         SpinParticles=True
         AutomaticInitialSpawning=False
         Acceleration=(Z=-900.000000)
         DampingFactorRange=(X=(Min=0.500000,Max=0.500000),Y=(Min=0.500000,Max=0.500000),Z=(Min=0.500000,Max=0.500000))
         MaxCollisions=(Min=5.000000,Max=5.000000)
         MaxParticles=1
         StartLocationOffset=(X=-80.000000,Z=5.000000)
         UseRotationFrom=PTRS_Actor
         SpinsPerSecondRange=(X=(Min=-0.300000,Max=0.300000),Y=(Min=-0.300000,Max=0.300000),Z=(Min=-0.300000,Max=0.300000))
         StartSizeRange=(X=(Min=0.150000,Max=0.150000),Y=(Min=0.150000,Max=0.150000),Z=(Min=0.100000,Max=0.150000))
         InitialParticlesPerSecond=1000.000000
         StartVelocityRange=(Y=(Min=-400.000000,Max=400.000000),Z=(Min=300.000000,Max=400.000000))
     End Object
     Emitters(1)=MeshEmitter'WVHoverTankV2.GaussFireEffect.MeshEmitter1'

     AutoDestroy=True
     bNoDelete=False
     bNetTemporary=True
     LifeSpan=4.000000
}
