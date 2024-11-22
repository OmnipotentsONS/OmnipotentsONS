/**
PersesArtilleryTrajectory

Creation date: 2013-12-16 09:26
Last change: $Id$
Copyright (c) 2013, Wormbo
*/

class PersesOmniArtilleryTrajectory extends Emitter;


var vector GoodColor, BadColor;


/**
Spawn the initial trajectory beam particle.
*/
function PostBeginPlay()
{
	Emitters[0].SpawnParticle(1);
	Emitters[1].SpawnParticle(1);
}


/**
Update the trajectory arc according to the given parameters.
*/
function UpdateTrajectory(bool bVisible, optional vector StartLocation, optional vector StartVelocity, optional float Gravity, optional float MinZ, optional bool bCanHitTarget)
{
	local float tMax, tDelta, t;
	local BeamEmitter Arc;
	local int i;
	
	Emitters[0].Disabled = !bVisible;
	
	// check if we need the bounding box hack
	if (bVisible && Normal(StartVelocity).Z > 0)
	{
		// need to calculate apex point (actually only apex height)
		Emitters[1].Disabled = False;
		Emitters[1].Particles[0].Location = StartLocation;
		Emitters[1].Particles[0].Location.Z -= 0.5 * Square(StartVelocity.Z) / Gravity;
	}
	else
	{
		// horizontal or downward initial velocity, so no hack required
		Emitters[1].Disabled = True;
	}
	
	if (!bVisible)
		return;
	
	if (bCanHitTarget)
		Emitters[0].Particles[0].ColorMultiplier = GoodColor;
	else
		Emitters[0].Particles[0].ColorMultiplier = BadColor;
	
	Arc = BeamEmitter(Emitters[0]);
	
	tMax = (StartVelocity.Z + Sqrt(Square(StartVelocity.Z) + 2 * Gravity * (StartLocation.Z - MinZ))) / Gravity;
	tDelta = tMax / (Arc.HighFrequencyPoints - 1);
	
	Arc.HFPoints[0].Location = StartLocation;
	for (i = 1; i < Arc.HighFrequencyPoints; ++i)
	{
		t += tDelta;
		Arc.HFPoints[i].Location = StartLocation + StartVelocity * t - vect(0,0,0.5) * Gravity * Square(t);
	}
}


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
     GoodColor=(Y=1.000000)
     BadColor=(X=1.000000)
     Begin Object Class=BeamEmitter Name=Trajectory
         DetermineEndPointBy=PTEP_Offset
         HighFrequencyPoints=50
         AlphaTest=False
         AutomaticInitialSpawning=False
         Opacity=0.750000
         CoordinateSystem=PTCS_Absolute
         MaxParticles=1
         StartSizeRange=(X=(Min=5.000000,Max=5.000000))
         Texture=Texture'EpicParticles.Beams.DanGradient'
         LifetimeRange=(Min=999999.000000,Max=999999.000000)
     End Object
     Emitters(0)=BeamEmitter'PersesOmni.PersesOmniArtilleryTrajectory.Trajectory'

     Begin Object Class=SpriteEmitter Name=BoundingBoxHack
         UniformSize=True
         AutomaticInitialSpawning=False
         CoordinateSystem=PTCS_Absolute
         MaxParticles=1
         StartSizeRange=(X=(Min=0.000000,Max=0.000000))
         LifetimeRange=(Min=999999.000000,Max=999999.000000)
     End Object
     Emitters(1)=SpriteEmitter'PersesOmni.PersesOmniArtilleryTrajectory.BoundingBoxHack'

     bNoDelete=False
}
