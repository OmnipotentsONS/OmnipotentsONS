class MirageTankTrailSmoke extends xEmitter;

#exec OBJ LOAD File=XGameShadersB.utx

defaultproperties
{
     mStartParticles=0
     mMaxParticles=150
     mLifeRange(0)=1.250000
     mLifeRange(1)=1.250000
     mRegenRange(0)=90.000000
     mRegenRange(1)=90.000000
     mSpeedRange(0)=0.000000
     mSpeedRange(1)=0.000000
     mMassRange(0)=-0.080000
     mMassRange(1)=-0.100000
     mRandOrient=True
     mSpinRange(0)=-75.000000
     mSpinRange(1)=75.000000
     mSizeRange(0)=30.000000
     mSizeRange(1)=40.000000
     mGrowthRate=13.000000
     mColorRange(0)=(B=30,G=10,R=10)
     mColorRange(1)=(B=30,G=30,R=30)
     mAttenFunc=ATF_ExpInOut
     mRandTextures=True
     mNumTileColumns=4
     mNumTileRows=4
     CullDistance=10000.000000
     Physics=PHYS_Trailer
     Skins(0)=Texture'XEffects.SmokeAlphab_t'
     Style=STY_Translucent
}
