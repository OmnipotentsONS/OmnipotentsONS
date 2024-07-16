//=============================================================================
// ONSShockTankProximityExplosion
//=============================================================================
// Created by Alan Willard (C) 2004 Epic Games
//=============================================================================
// Should be offset from Paladin origin by 70 units along Z axis.
//=============================================================================
// Modified for Hospitaler, pooty.

class HospitalerProximityExplosion extends Emitter;

#exec OBJ LOAD FILE="..\Textures\AW-2004Particles.utx"
#exec OBJ LOAD FILE="..\Textures\AW-2k4XP.utx"


function PostBeginPlay()
{
    local PlayerController PC;

    if (Level.NetMode == NM_DedicatedServer)
    {
       LifeSpan = 0.2;
       return;
    }

    PC = Level.GetLocalPlayerController();
    if ( PC == None )
    {
        Destroy();
        return;
    }
    if ( Level.bDropDetail || (Level.DetailMode == DM_Low) || (PC.ViewTarget == None) || (VSize(PC.ViewTarget.Location - Location) > 6000) )
    {
        Emitters[3].Disabled = true;
        Emitters[4].Disabled = true;
    }
}

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter3
         UseDirectionAs=PTDU_Normal
         UseColorScale=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(1)=(RelativeTime=0.500000,Color=(B=112,G=255,R=152))
         ColorScale(2)=(RelativeTime=1.000000)
         MaxParticles=2
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=0.500000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=8.500000)
         InitialParticlesPerSecond=5000.000000
         Texture=Texture'AW-2004Particles.Energy.SmoothRing'
         LifetimeRange=(Min=0.500000,Max=0.500000)
     End Object
     Emitters(0)=SpriteEmitter'HospitalerV3Omni.HospitalerProximityExplosion.SpriteEmitter3'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter4
         UseColorScale=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(1)=(RelativeTime=0.200000,Color=(B=112,G=255,R=147))
         ColorScale(2)=(RelativeTime=1.000000)
         MaxParticles=5
         StartLocationShape=PTLS_Polar
         SphereRadiusRange=(Min=32.000000,Max=64.000000)
         StartLocationPolarRange=(X=(Max=65536.000000),Y=(Min=16384.000000,Max=16384.000000),Z=(Min=100.000000,Max=100.000000))
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=0.500000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=3.000000)
         InitialParticlesPerSecond=5000.000000
         Texture=Texture'AW-2004Particles.Fire.SmokeFragment'
         LifetimeRange=(Min=0.500000,Max=0.600000)
         StartVelocityRadialRange=(Min=-200.000000,Max=-250.000000)
         GetVelocityDirectionFrom=PTVD_AddRadial
     End Object
     Emitters(1)=SpriteEmitter'HospitalerV3Omni.HospitalerProximityExplosion.SpriteEmitter4'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter8
         UseColorScale=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         BlendBetweenSubdivisions=True
         ColorScale(1)=(RelativeTime=0.200000,Color=(B=128,G=255,R=128))
         ColorScale(2)=(RelativeTime=1.000000)
         MaxParticles=5
         StartLocationShape=PTLS_Polar
         SphereRadiusRange=(Min=32.000000,Max=64.000000)
         StartLocationPolarRange=(X=(Max=65536.000000),Y=(Min=16384.000000,Max=16384.000000),Z=(Min=100.000000,Max=100.000000))
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=0.500000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=2.000000)
         InitialParticlesPerSecond=5000.000000
         Texture=Texture'AW-2004Particles.Energy.ElecPanelsP'
         TextureUSubdivisions=2
         TextureVSubdivisions=2
         LifetimeRange=(Min=0.500000,Max=0.600000)
         StartVelocityRadialRange=(Min=-200.000000,Max=-250.000000)
         GetVelocityDirectionFrom=PTVD_AddRadial
     End Object
     Emitters(2)=SpriteEmitter'HospitalerV3Omni.HospitalerProximityExplosion.SpriteEmitter8'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter6
         UseColorScale=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(1)=(RelativeTime=0.200000,Color=(B=187,G=187,R=187))
         ColorScale(2)=(RelativeTime=1.000000)
         MaxParticles=8
         DetailMode=DM_High
         StartLocationShape=PTLS_Polar
         SphereRadiusRange=(Min=32.000000,Max=64.000000)
         StartLocationPolarRange=(X=(Max=65536.000000),Y=(Min=16384.000000,Max=16384.000000),Z=(Min=100.000000,Max=100.000000))
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=0.500000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=3.000000)
         InitialParticlesPerSecond=5000.000000
         DrawStyle=PTDS_Darken
         Texture=Texture'AW-2004Particles.Fire.SmokeFragment'
         LifetimeRange=(Min=0.600000,Max=0.700000)
         StartVelocityRadialRange=(Min=-300.000000,Max=-300.000000)
         GetVelocityDirectionFrom=PTVD_AddRadial
     End Object
     Emitters(3)=SpriteEmitter'HospitalerV3Omni.HospitalerProximityExplosion.SpriteEmitter6'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter10
         UseColorScale=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         UseRandomSubdivision=True
         ColorScale(0)=(Color=(B=255,G=255,R=255))
         ColorScale(1)=(RelativeTime=0.700000,Color=(B=128,G=255,R=128))
         ColorScale(2)=(RelativeTime=1.000000)
         CoordinateSystem=PTCS_Relative
         MaxParticles=25
         DetailMode=DM_High
         StartLocationOffset=(Z=30.000000)
         StartLocationRange=(X=(Min=-255.000000,Max=225.000000),Y=(Min=-50.000000,Max=50.000000),Z=(Min=-15.000000,Max=15.000000))
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=4.000000)
         StartSizeRange=(X=(Min=20.000000,Max=50.000000))
         Texture=Texture'AW-2004Particles.Energy.ElecPanelsP'
         TextureUSubdivisions=2
         TextureVSubdivisions=2
         LifetimeRange=(Min=0.200000,Max=0.200000)
     End Object
     Emitters(4)=SpriteEmitter'HospitalerV3Omni.HospitalerProximityExplosion.SpriteEmitter10'

     AutoDestroy=True
     bNoDelete=False
     bNetTemporary=True
     RemoteRole=ROLE_DumbProxy
     bDirectional=True
}