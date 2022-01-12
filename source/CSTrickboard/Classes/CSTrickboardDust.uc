class CSTrickboardDust extends Emitter;

#exec OBJ LOAD FILE=..\Textures\AW-2004Particles.utx

var	bool	bDustActive;

simulated function SetDustColor(color DustColor)
{
	local color DustColorZeroAlpha, BlackColor, DustColor2;
//	local int highestColor;

	// Ignore if dust color is black.
	if(DustColor.R == 0 && DustColor.G == 0 && DustColor.B == 0)
		return;

	DustColor.A = 255;

	DustColor2 = DustColor;
/*
	// Desaturate the Dust
	highestColor = DustColor2.R;
	if (DustColor2.G > highestColor) {
	   highestColor = DustColor2.G;
	}
	if (DustColor2.B > highestColor) {
	   highestColor = DustColor2.B;
	}

        DustColor2.R = (DustColor2.R + highestColor) / 2;
        DustColor2.G = (DustColor2.G + highestColor) / 2;
        DustColor2.B = (DustColor2.B + highestColor) / 2;
*/
        DustColor2.R = 215;
        DustColor2.G = 205;
        DustColor2.B = 225;


	DustColorZeroAlpha = DustColor2;
	DustColorZeroAlpha.A = 0;


	BlackColor.R = 0;
	BlackColor.G = 0;
	BlackColor.B = 0;
	BlackColor.A = 0;

	Emitters[0].ColorScale[0].Color = DustColorZeroAlpha;
	Emitters[0].ColorScale[1].Color = DustColor2;
	Emitters[0].ColorScale[2].Color = DustColor2;
	Emitters[0].ColorScale[3].Color = DustColorZeroAlpha;

	Emitters[1].ColorScale[0].Color = BlackColor;
	Emitters[1].ColorScale[1].Color = DustColor;
	Emitters[1].ColorScale[2].Color = DustColor;
	Emitters[1].ColorScale[3].Color = BlackColor;
}

simulated function UpdateHoverDust(bool bActive, float HoverHeight, bool bAttacking)
{
	local float Force;

	Force = 1 - HoverHeight;

        if (!bAttacking)
        {
        	if(!bActive)
	        {
         		Emitters[0].ParticlesPerSecond = 0;
	        	Emitters[0].InitialParticlesPerSecond = 0;
	         	Emitters[1].Disabled = true;
	         	Emitters[2].Disabled = true;
           		return;
             	}
              	else
               	{
	         	Emitters[0].Disabled = false;
	         	Emitters[1].Disabled = false;
	        	Emitters[0].ParticlesPerSecond = 100;
          		Emitters[0].InitialParticlesPerSecond = 100;
	        	Emitters[0].AllParticlesDead = false;
	         	Emitters[1].Disabled = (Level.DetailMode == DM_Low);
	         	Emitters[2].Disabled = true;
           	}

            	// Dust
             	Emitters[0].StartVelocityRadialRange.Min = -150 + (Force * -100);
              	Emitters[0].StartVelocityRadialRange.Max = Emitters[0].StartVelocityRadialRange.Min - 100;

               	Emitters[0].StartLocationPolarRange.Z.Min = 10 + (HoverHeight * 30);
                	Emitters[0].StartLocationPolarRange.Z.Max = Emitters[0].StartLocationPolarRange.Z.Min;

                // Rings
                Emitters[1].StartSizeRange.X.Min = 30 + (HoverHeight * 40);
                Emitters[1].StartSizeRange.X.Max = Emitters[1].StartSizeRange.X.Min + 20;
                Emitters[1].Opacity = FClamp(2.5 * Force, 0, 0.8);
	}
	else
	{
        	if(!bActive)
	        {
	         	Emitters[0].Disabled = true;
	         	Emitters[1].Disabled = true;
           		return;
             	}
              	else
               	{
	         	Emitters[0].Disabled = true;
	         	Emitters[1].Disabled = true;
	         	Emitters[2].Disabled = false;
                        Emitters[2].StartSizeRange.X.Min = 20 + (HoverHeight * 60);
                        Emitters[2].StartSizeRange.X.Max = Emitters[2].StartSizeRange.X.Min + 120;
                        Emitters[2].Opacity = FClamp(1.5 * Force, 0, 0.8);
           	}

	}

}

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter0
         UseColorScale=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         BlendBetweenSubdivisions=True
         UseRandomSubdivision=True
         UseVelocityScale=True
         Acceleration=(Z=500.000000)
         ColorScale(0)=(Color=(B=96,G=128,R=164))
         ColorScale(1)=(RelativeTime=0.200000,Color=(B=96,G=128,R=164,A=255))
         ColorScale(2)=(RelativeTime=0.500000,Color=(B=64,G=100,R=128,A=255))
         ColorScale(3)=(RelativeTime=1.000000,Color=(B=68,G=104,R=125))
         FadeOutStartTime=0.800000
         FadeInEndTime=0.350000
         MaxParticles=50
         StartLocationShape=PTLS_Polar
         StartLocationPolarRange=(X=(Min=16384.000000,Max=16384.000000),Y=(Max=65536.000000),Z=(Min=20.000000,Max=20.000000))
         UseRotationFrom=PTRS_Actor
         SizeScale(0)=(RelativeSize=0.300000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
         StartSizeRange=(X=(Min=50.000000,Max=90.000000),Y=(Min=0.000000,Max=0.000000),Z=(Min=0.000000,Max=0.000000))
         ParticlesPerSecond=10.000000
         InitialParticlesPerSecond=50.000000
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'AW-2004Particles.Weapons.SmokePanels2'
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         LifetimeRange=(Min=1.000000,Max=1.500000)
         StartVelocityRange=(X=(Min=70.000000,Max=70.000000))
         StartVelocityRadialRange=(Min=-600.000000,Max=-800.000000)
         GetVelocityDirectionFrom=PTVD_AddRadial
         VelocityScale(0)=(RelativeVelocity=(X=1.000000,Y=1.000000,Z=1.000000))
         VelocityScale(1)=(RelativeTime=0.200000,RelativeVelocity=(X=0.350000,Y=0.350000,Z=0.350000))
         VelocityScale(2)=(RelativeTime=0.500000,RelativeVelocity=(X=0.100000,Y=0.100000,Z=0.100000))
         VelocityScale(3)=(RelativeTime=1.000000)
     End Object
     Emitters(0)=SpriteEmitter'CSTrickboard.CSTrickboardDust.SpriteEmitter0'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter1
         UseDirectionAs=PTDU_Normal
         ProjectionNormal=(X=1.000000,Z=0.000000)
         UseColorScale=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         ColorScale(1)=(RelativeTime=0.450000,Color=(B=64,G=100,R=128))
         ColorScale(2)=(RelativeTime=0.550000,Color=(B=64,G=100,R=128))
         ColorScale(3)=(RelativeTime=1.000000)
         Opacity=0.750000
         CoordinateSystem=PTCS_Relative
         MaxParticles=3
         StartLocationOffset=(Z=6.000000)
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=0.250000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.500000)
         Texture=Texture'AW-2004Particles.Weapons.GrenExpl'
         LifetimeRange=(Min=0.300000,Max=0.300000)
     End Object
     Emitters(1)=SpriteEmitter'CSTrickboard.CSTrickboardDust.SpriteEmitter1'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter2
         UseDirectionAs=PTDU_Normal
         ProjectionNormal=(X=1.000000,Z=0.000000)
         UseColorScale=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         ColorScale(1)=(RelativeTime=0.450000,Color=(B=230,G=180,R=230))
         ColorScale(2)=(RelativeTime=0.950000,Color=(B=64,G=100,R=128))
         ColorScale(3)=(RelativeTime=1.000000)
         Opacity=0.750000
         CoordinateSystem=PTCS_Relative
         MaxParticles=3
         StartLocationOffset=(Z=6.000000)
         StartSpinRange=(X=(Max=3.000000))
         SizeScale(0)=(RelativeSize=0.800000)
         StartSizeRange=(X=(Min=70.000000,Max=95.000000))
         Texture=Texture'AW-2004Particles.Energy.AirBlast'
         LifetimeRange=(Min=0.300000,Max=0.300000)
     End Object
     Emitters(2)=SpriteEmitter'CSTrickboard.CSTrickboardDust.SpriteEmitter2'

     CullDistance=8000.000000
     bNoDelete=False
     bHardAttach=True
}
