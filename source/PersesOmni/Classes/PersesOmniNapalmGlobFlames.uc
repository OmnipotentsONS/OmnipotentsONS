/**
PersesNapalmGlobFlightEffects

Creation date: 2013-12-12 13:42
Last change: $Id$
Copyright (c) 2013, Wormbo
*/

class PersesOmniNapalmGlobFlames extends Emitter;


var float ParticlesPerSecond;


function PreBeginPlay()
{
	ParticlesPerSecond = Emitters[0].InitialParticlesPerSecond;
	
	if (Level.DetailMode == DM_Low || Level.bDropDetail)
	{
		ParticlesPerSecond *= Emitters[0].LowDetailFactor;
		Emitters[0].InitialParticlesPerSecond = ParticlesPerSecond;
		Emitters[0].ParticlesPerSecond        = ParticlesPerSecond;
	}
	bDynamicLight = False;
	if (Level.bAggressiveLOD)
	{
		LightType = LT_None;
	}
	if (Level.bLowSoundDetail)
		AmbientSound = None;
}

function SetOnGround()
{
	Emitters[0].StartLocationShape = PTLS_Polar;
}

function SetFlying()
{
	Emitters[0].StartLocationShape = PTLS_Sphere;
}

function Kill()
{
	Super.Kill();
	AutoDestroy = false;
	LifeSpan = 0.5;
	GotoState('Fading');
}

function PhysicsVolumeChange(PhysicsVolume NewVolume)
{
	if (NewVolume.bWaterVolume)
	{
		Emitters[0].InitialParticlesPerSecond = 0.0;
		Emitters[0].ParticlesPerSecond = 0.0;
		SoundVolume = 0;
	}
	else
	{
		Emitters[0].InitialParticlesPerSecond = ParticlesPerSecond;
		Emitters[0].ParticlesPerSecond = ParticlesPerSecond;
		Emitters[0].AllParticlesDead = false;
		SoundVolume = default.SoundVolume;
	}
}

state Fading
{
	ignores Kill;
	
	function Tick(float DeltaTime)
	{
		ScaleGlow = 2.0 * LifeSpan;
		SoundVolume = default.SoundVolume * 2.0 * LifeSpan;
		LightRadius = default.LightRadius * 2.0 * LifeSpan;
		LightBrightness = default.LightBrightness * 2.0 * LifeSpan;
	}
}


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=FlameSprites
         FadeOut=True
         FadeIn=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UniformSize=True
         AutomaticInitialSpawning=False
         UseRandomSubdivision=True
         Acceleration=(Z=300.000000)
         FadeInEndTime=0.100000
         MaxParticles=16
         StartLocationShape=PTLS_Sphere
         SphereRadiusRange=(Min=4.000000,Max=8.000000)
         StartLocationPolarRange=(X=(Min=-16384.000000,Max=16384.000000),Y=(Max=32768.000000),Z=(Min=4.000000,Max=8.000000))
         UseRotationFrom=PTRS_Actor
         StartSpinRange=(X=(Min=0.250000,Max=0.500000))
         SizeScale(1)=(RelativeTime=0.500000,RelativeSize=1.000000)
         SizeScale(2)=(RelativeTime=1.000000)
         StartSizeRange=(X=(Min=10.000000,Max=20.000000))
         ParticlesPerSecond=40.000000
         InitialParticlesPerSecond=40.000000
         Texture=Texture'EmitterTextures.MultiFrame.LargeFlames'
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=0.250000,Max=0.400000)
         StartVelocityRadialRange=(Min=-25.000000,Max=-15.000000)
         GetVelocityDirectionFrom=PTVD_AddRadial
     End Object
     Emitters(0)=SpriteEmitter'PersesOmni.PersesOmniNapalmGlobFlames.FlameSprites'

     LightType=LT_Steady
     LightEffect=LE_NonIncidence
     LightHue=25
     LightSaturation=40
     LightBrightness=150.000000
     LightRadius=3.000000
     bNoDelete=False
     bDynamicLight=False
     bTrailerSameRotation=True
     Physics=PHYS_Trailer
     AmbientSound=Sound'GeneralAmbience.firefx11'
     SoundVolume=190
     SoundRadius=32.000000
}
