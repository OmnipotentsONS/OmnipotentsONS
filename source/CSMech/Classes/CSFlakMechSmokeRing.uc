class CSFlakMechSmokeRing extends RocketSmokeRing;

defaultproperties 
{
	Skins(0)=Texture'SmokeAlphab_t'
	Style=STY_Alpha
    
    mParticleType=PT_Sprite
    mSpawningType=ST_ExplodeRing
	mLifeRange(0)=1.3
	mLifeRange(1)=1.7
    mRegenRange(0)=0
    mRegenRange(1)=0
    mMaxParticles=15
    mStartParticles=15
	mRegen=false
    mPosDev=(X=20,Y=20,Z=20)

    mAirResistance=1.9
    mPosRelative=true
    mSpeedRange(0)=100
    mSpeedRange(1)=100
	mSpinRange(0)=-50
	mSpinRange(1)=50

    mAttenFunc=ATF_SmoothStep
    mAttenKa=0
    mAttenKb=0.5
    mGrowthRate=40
    mNumTileColumns=4
    mNumTileRows=4
    mRandOrient=true
    mRandTextures=true
    //mSizeRange(0)=20
    //mSizeRange(1)=30
    mSizeRange(0)=80
    mSizeRange(1)=120
    DrawScale=4.0
    DrawScale3D=(X=4.0,Y=4.0,Z=4.0)

	bForceAffected=false
}
