//=============================================================================
// FX_IonPlasmaTank_AimLaser
//=============================================================================
// Created by Laurent Delayen (C) 2003 Epic Games
//=============================================================================

class IonTankTeamColorAimLaserBlue extends FX_IonPlasmaTank_AimLaser;

defaultproperties
{
     Begin Object Class=BeamEmitter Name=AimLaserBlue
         BeamDistanceRange=(Min=500.000000,Max=500.000000)
         DetermineEndPointBy=PTEP_Distance
         RotatingSheets=3
         LowFrequencyPoints=2
         HighFrequencyPoints=2
         UseColorScale=True
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=255,G=32,R=32))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=200,G=32,R=32))
         Opacity=0.330000
         CoordinateSystem=PTCS_Relative
         MaxParticles=1
         StartSizeRange=(X=(Min=30.000000,Max=35.000000))
         InitialParticlesPerSecond=2000.000000
         Texture=Texture'EpicParticles.Beams.WhiteStreak01aw'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=0.080000,Max=0.160000)
         StartVelocityRange=(X=(Min=0.001000,Max=0.001000))
     End Object
     Emitters(0)=BeamEmitter'CSBadgerFix.IonTankTeamColorAimLaserBlue.AimLaserBlue'

}
