class CSShockMechShockComboExpRing extends ShockComboExpRing;

defaultproperties
{
    DrawScale=4.0
    //DrawScale3D=(X=4.0,Y=4.0,Z=4.0)
	bHighDetail=True
    Skins(0)=Texture'XEffectMat.shock_ring_a'
    Style=STY_Additive
    mParticleType=PL_Sprite
    mLifeRange(0)=0.5
    mLifeRange(1)=0.5
    mSizeRange(0)=0.0
    mSizeRange(1)=0.0
    mGrowthRate=500
    mSpinRange(0)=0.0
    mSpinRange(1)=0.0
    mStartParticles=1
    mMaxParticles=1
    mRandOrient=true
    mRegen=false
    mAttenuate=true
    mAttenKa=0.4
}
