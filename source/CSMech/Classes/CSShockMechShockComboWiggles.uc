class CSShockMechShockComboWiggles extends ShockComboWiggles;


defaultproperties
{
	Skins(0)=Texture'XEffectMat.shock_sparkle'
	Style=STY_Translucent
    LifeSpan=2.0
	mSpawningType=ST_Explode
    mParticleType=PT_Disc
	mStartParticles=25
	mMaxParticles=25
	mLifeRange(0)=0.75
	mLifeRange(1)=0.75
    mRegenPause=true
	mRegenRange(0)=25.0
	mRegenRange(1)=25.0
	//mSpeedRange(0)=300.0
	//mSpeedRange(1)=300.0
	mSpeedRange(0)=1200.0
	mSpeedRange(1)=1200.0
	//mSizeRange(0)=120.0
	//mSizeRange(1)=120.0
	mSizeRange(0)=480.0
	mSizeRange(1)=480.0
	mGrowthRate=0.0
	//mPosDev=(X=20.0,Y=20.0,Z=20.0)
	mPosDev=(X=80.0,Y=80.0,Z=80.0)
    //DrawScale=4.0
    DrawScale3D=(X=6.0,Y=6.0,Z=6.0)
    mAttenuate=true
    mAttenKa=0.2
    mColorRange(0)=(B=80,G=100,R=80)
    mColorRange(1)=(B=120,G=100,R=120)
}
