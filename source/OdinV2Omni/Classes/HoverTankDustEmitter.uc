/******************************************************************************
HoverTankDustEmitter

Creation date: 2011-08-05 17:43
Last change: $Id$
Copyright © 2011, Wormbo
Website: http://www.koehler-homepage.de/Wormbo/
Feel free to reuse this code. Send me a note if you found it helpful or want
to report bugs/provide improvements.
Please ask for permission first, if you intend to make money off reused code.
******************************************************************************/

class HoverTankDustEmitter extends Emitter;


#exec OBJ LOAD FILE=..\Textures\AW-2004Particles.utx


var() float RingSize;
var() color DefaultDustColor;

var bool bDustActive;


simulated function SetDustColor(color DustColor)
{
	local color BlackColor;

	// Ignore if dust color if black.
	if (DustColor.R == 0 && DustColor.G == 0 && DustColor.B == 0) {
		DustColor.R = 128;
		DustColor.G = 100;
		DustColor.B = 64;
	}

	DustColor.A = 192;

	BlackColor.R = 0;
	BlackColor.G = 0;
	BlackColor.B = 0;
	BlackColor.A = 0;

	Emitters[0].ColorMultiplierRange.X.Min = DustColor.R / 255.0;
	Emitters[0].ColorMultiplierRange.X.Max = DustColor.R / 255.0;
	Emitters[0].ColorMultiplierRange.Y.Min = DustColor.G / 255.0;
	Emitters[0].ColorMultiplierRange.Y.Max = DustColor.G / 255.0;
	Emitters[0].ColorMultiplierRange.Z.Min = DustColor.B / 255.0;
	Emitters[0].ColorMultiplierRange.Z.Max = DustColor.B / 255.0;

	Emitters[1].ColorScale[0].Color = BlackColor;
	Emitters[1].ColorScale[1].Color = DustColor;
	Emitters[1].ColorScale[2].Color = DustColor;
	Emitters[1].ColorScale[3].Color = BlackColor;
}

simulated function UpdateHoverDust(bool bActive, float HoverHeight)
{
	local float Force;

	Force = 1 - HoverHeight;

	if (!bActive) {
		Emitters[0].ParticlesPerSecond = 0;
		Emitters[0].InitialParticlesPerSecond = 0;
		Emitters[1].Disabled = true;
		return;
	}

	Emitters[0].ParticlesPerSecond = Emitters[0].MaxParticles;
	Emitters[0].InitialParticlesPerSecond = Emitters[0].MaxParticles;
	Emitters[0].AllParticlesDead = false;

	// Dust
	Emitters[0].StartVelocityRadialRange.Min = -600 - (Force * 100);
	Emitters[0].StartVelocityRadialRange.Max = Emitters[0].StartVelocityRadialRange.Min * 0.8;

	Emitters[0].StartLocationPolarRange.Z.Min = 0.125 * RingSize + (0.375 * HoverHeight * RingSize);
	Emitters[0].StartLocationPolarRange.Z.Max = Emitters[0].StartLocationPolarRange.Z.Min;

	// Rings
	Emitters[1].Disabled = (Level.DetailMode == DM_Low);
	Emitters[1].StartSizeRange.X.Min = RingSize + (0.75 * HoverHeight * RingSize);
	Emitters[1].StartSizeRange.X.Max = Emitters[1].StartSizeRange.X.Min * 1.2;
	Emitters[1].Opacity = FClamp(2.5 * Force, 0, 0.8);
}


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
     RingSize=25.000000
     DefaultDustColor=(B=64,G=100,R=128)
     Begin Object Class=SpriteEmitter Name=DustSprites
         UseColorScale=True
         FadeOut=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         BlendBetweenSubdivisions=True
         UseRandomSubdivision=True
         TriggerDisabled=False
         UseVelocityScale=True
         Acceleration=(Z=500.000000)
         ColorScale(0)=(Color=(B=255,G=255,R=255))
         ColorScale(1)=(RelativeTime=0.200000,Color=(B=255,G=255,R=255,A=255))
         ColorScale(2)=(RelativeTime=0.500000,Color=(B=255,G=255,R=255,A=255))
         ColorScale(3)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255))
         ColorMultiplierRange=(X=(Min=0.500000,Max=0.500000),Y=(Min=0.390000,Max=0.390000),Z=(Min=0.250000,Max=0.250000))
         MaxParticles=30
         StartLocationShape=PTLS_Polar
         StartLocationPolarRange=(X=(Min=16384.000000,Max=16384.000000),Y=(Max=65536.000000),Z=(Min=1.000000,Max=25.000000))
         UseRotationFrom=PTRS_Actor
         SizeScale(0)=(RelativeSize=0.300000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
         StartSizeRange=(X=(Min=75.000000,Max=110.000000),Y=(Min=0.000000,Max=0.000000),Z=(Min=0.000000,Max=0.000000))
         ParticlesPerSecond=40.000000
         InitialParticlesPerSecond=40.000000
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'AW-2004Particles.Weapons.SmokePanels2'
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         LifetimeRange=(Min=0.800000,Max=1.200000)
         StartVelocityRange=(X=(Min=70.000000,Max=70.000000))
         StartVelocityRadialRange=(Min=-600.000000,Max=-800.000000)
         GetVelocityDirectionFrom=PTVD_AddRadial
         VelocityScale(0)=(RelativeVelocity=(X=1.000000,Y=1.000000,Z=1.000000))
         VelocityScale(1)=(RelativeTime=0.200000,RelativeVelocity=(X=0.350000,Y=0.350000,Z=0.350000))
         VelocityScale(2)=(RelativeTime=0.500000,RelativeVelocity=(X=0.100000,Y=0.100000,Z=0.100000))
         VelocityScale(3)=(RelativeTime=1.000000)
     End Object
     Emitters(0)=SpriteEmitter'WVHoverTankV2.HoverTankDustEmitter.DustSprites'

     Begin Object Class=SpriteEmitter Name=RingSprites
         UseDirectionAs=PTDU_Normal
         ProjectionNormal=(X=1.000000,Z=0.000000)
         UseColorScale=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         TriggerDisabled=False
         ColorScale(1)=(RelativeTime=0.450000,Color=(B=64,G=100,R=128))
         ColorScale(2)=(RelativeTime=0.550000,Color=(B=64,G=100,R=128))
         ColorScale(3)=(RelativeTime=1.000000)
         Opacity=0.750000
         CoordinateSystem=PTCS_Relative
         MaxParticles=3
         StartLocationOffset=(Z=6.000000)
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=0.500000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=2.500000)
         StartSizeRange=(X=(Min=120.000000,Max=150.000000))
         Texture=Texture'AW-2004Particles.Energy.AirBlast'
         LifetimeRange=(Min=0.300000,Max=0.300000)
     End Object
     Emitters(1)=SpriteEmitter'WVHoverTankV2.HoverTankDustEmitter.RingSprites'

     CullDistance=8000.000000
     bNoDelete=False
     bHardAttach=True
}
