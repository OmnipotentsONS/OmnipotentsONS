class RopeBeamEffect extends xEmitter;

#exec OBJ LOAD FILE=XEffectMat.utx

var Vector	EndEffect;
var bool bBendy;
replication
{
    unreliable if ( (Role == ROLE_Authority) && (!bNetOwner || bDemoRecording || bRepClientDemo)  )
         EndEffect;
}


simulated function Destroyed()
{
     Super.Destroyed();
}

simulated function Vector SetBeamRotation()
{
        SetRotation( Rotator(EndEffect - Location) );

	return Normal(EndEffect - Location);
}


simulated function Tick(float dt)
{
    local Vector BeamDir;
	BeamDir = SetBeamRotation();

    if ( Level.bDropDetail || Level.DetailMode == DM_Low )
    {
		bDynamicLight = false;
        LightType = LT_None;
    }
    else if ( bDynamicLight )
        LightType = LT_Steady;

     mSpawnVecA = EndEffect;
     if(bBendy==true)
       {
        mBendStrength=0.000000;
        mWaveAmplitude=8.00000;
       }
     else
      {
       mWaveAmplitude = FMax(0.0, mWaveAmplitude - (mWaveAmplitude+5)*4.0*dt);
       mBendStrength=3.000000;
      }
}

defaultproperties
{
     mParticleType=PT_Beam
     mMaxParticles=3
     mRegenDist=65.000000
     mSpinRange(0)=45000.000000
     mSizeRange(0)=11.000000
     mColorRange(0)=(B=240,G=240,R=240)
     mColorRange(1)=(B=240,G=240,R=240)
     mAttenuate=False
     mAttenKa=0.000000
     mWaveFrequency=0.060000
     mWaveAmplitude=8.000000
     mWaveShift=100000.000000
     mBendStrength=3.000000
     mWaveLockEnd=True
     LightType=LT_Steady
     LightHue=100
     LightSaturation=100
     LightBrightness=255.000000
     LightRadius=4.000000
     bDynamicLight=True
     bNetTemporary=False
     bReplicateInstigator=True
     RemoteRole=ROLE_SimulatedProxy
     Skins(0)=Texture'APVerIV_Tex.AP_FX.RopeSkin'
     Style=STY_Subtractive
}
