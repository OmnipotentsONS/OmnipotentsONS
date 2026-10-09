/******************************************************************************
ThunderStormEmitterBlue

Blue Team visual variant of ThunderStormEmitter.
Only overrides the existing Clouds SpriteEmitter color scale.
******************************************************************************/

class ThunderStormEmitterBlue extends ThunderStormEmitter;

defaultproperties
{
    Begin Object Class=SpriteEmitter Name=BlueClouds
        UseColorScale=True
        FadeOut=True
        FadeIn=True
        RespawnDeadParticles=False
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        UseRandomSubdivision=True

        ColorScale(0)=(Color=(B=245,G=145,R=100,A=255))
        ColorScale(1)=(RelativeTime=0.200000,Color=(B=125,G=55,R=24,A=255))
        ColorScale(2)=(RelativeTime=0.800000,Color=(B=150,G=70,R=32,A=255))
        ColorScale(3)=(RelativeTime=1.000000,Color=(B=190,G=105,R=65,A=255))

        FadeOutStartTime=16.000000
        FadeInEndTime=2.000000
        MaxParticles=45

        StartLocationRange=(X=(Min=-1500.000000,Max=1500.000000),Y=(Min=-150.000000,Max=1500.000000))
        StartLocationShape=PTLS_All
        SphereRadiusRange=(Min=200.000000,Max=500.000000)
        StartLocationPolarRange=(X=(Max=65536.000000),Y=(Min=16384.000000,Max=16384.000000),Z=(Min=1000.000000,Max=2000.000000))

        SpinsPerSecondRange=(X=(Min=0.010000,Max=0.030000))
        StartSpinRange=(X=(Max=1.000000))

        SizeScale(0)=(RelativeSize=0.500000)
        SizeScale(1)=(RelativeTime=0.200000,RelativeSize=1.500000)
        SizeScale(2)=(RelativeTime=1.000000,RelativeSize=2.000000)

        StartSizeRange=(X=(Min=1000.000000,Max=2500.000000))
        InitialParticlesPerSecond=6.000000

        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'EmitterTextures.MultiFrame.smoke_a2'
        TextureUSubdivisions=4
        TextureVSubdivisions=4

        SecondsBeforeInactive=0.000000
        LifetimeRange=(Min=17.000000,Max=19.000000)
    End Object

    // Replaces only the inherited neutral Clouds emitter.
    // Emitters(1) and Emitters(2), the lightning effects, remain inherited.
    Emitters(0)=SpriteEmitter'StormCasterV3.ThunderStormEmitterBlue.BlueClouds'
}