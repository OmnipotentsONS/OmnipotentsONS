class FX_NukeEngine extends FX_AirPowerEngineEffects
	placeable;

simulated function SetBlueColor()
{
	Emitters[0].ColorScale[0].Color = class'Canvas'.static.MakeColor(0, 0, 255);
	Emitters[1].ColorScale[1].Color = class'Canvas'.static.MakeColor(0, 255, 255);
}

simulated function SetRedColor()
{
	Emitters[0].ColorScale[0].Color = class'Canvas'.static.MakeColor(255, 0, 0);
	Emitters[1].ColorScale[1].Color = class'Canvas'.static.MakeColor(255, 0, 0);
}

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter0
         UseDirectionAs=PTDU_Right
         UseColorScale=True
         FadeOut=True
         UseSizeScale=True
         UseAbsoluteTimeForSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         ColorScale(0)=(RelativeTime=1.000000,Color=(R=255))
         Opacity=0.500000
         CoordinateSystem=PTCS_Relative
         MaxParticles=20
         SpinCCWorCW=(X=0.000000,Y=0.000000,Z=0.000000)
         SpinsPerSecondRange=(X=(Min=3.000000,Max=3.000000))
         SizeScale(0)=(RelativeTime=1.000000,RelativeSize=0.100000)
         StartSizeRange=(X=(Min=25.000000,Max=25.000000),Y=(Min=800.000000,Max=800.000000))
         Texture=Texture'AW-2004Particles.Energy.EclipseCircle'
         LifetimeRange=(Min=0.500000,Max=0.500000)
         StartVelocityRange=(X=(Min=-600.000000,Max=-600.000000))
         AddVelocityMultiplierRange=(Y=(Min=0.000000,Max=0.000000),Z=(Min=0.000000,Max=0.000000))
     End Object
     Emitters(0)=SpriteEmitter'CSAPVerIV.FX_NukeEngine.SpriteEmitter0'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter1
         UseColorScale=True
         FadeOut=True
         UniformSize=True
         ColorScale(1)=(RelativeTime=0.400000,Color=(R=255))
         ColorScaleRepeats=1.000000
         FadeOutStartTime=2.000000
         CoordinateSystem=PTCS_Relative
         StartSizeRange=(X=(Min=20.000000,Max=20.000000),Y=(Min=400.000000,Max=400.000000),Z=(Min=400.000000,Max=400.000000))
         Texture=Texture'jwDecemberArchitecture.Coronas.Corona1'
         LifetimeRange=(Min=0.100000,Max=0.100000)
         StartVelocityRange=(X=(Min=250.000000,Max=250.000000))
     End Object
     Emitters(1)=SpriteEmitter'CSAPVerIV.FX_NukeEngine.SpriteEmitter1'

}
