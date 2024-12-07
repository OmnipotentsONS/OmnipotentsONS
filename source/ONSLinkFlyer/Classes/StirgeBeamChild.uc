
class StirgeBeamChild extends LinkBeamChild;

#exec OBJ LOAD FILE=XEffectMat.utx

defaultproperties
{
	
	   mRegenDist=150.000000
     mSpinRange(0)=55000.000000
     mSizeRange(0)=7.000000
	   mWaveAmplitude=30.000000
     mWaveShift=150000.000000
     mBendStrength=6.000000
	// defaults from LinkBeamChild
	/*
	   mMaxParticles=2
     mRegenDist=75.000000
     mSpinRange(0)=45000.000000
     mSizeRange(0)=6.000000
     mColorRange(0)=(B=180,G=180,R=180)
     mColorRange(1)=(B=180,G=180,R=180)
     mAttenuate=False
     mAttenKa=0.010000
     mWaveFrequency=0.060000
     mWaveAmplitude=15.000000
     mWaveShift=100000.000000
     mBendStrength=3.000000
     mWaveLockEnd=True
     Skins(0)=FinalBlend'XEffectMat.Link.LinkBeamGreenFB'
    */
}
