class CSShieldMechForceRing extends xEmitter;

simulated function Trigger( Actor Other, Pawn EventInstigator )
{
    mRegenRange[0] = 16.0;
    mRegenRange[1] = 16.0;
    //mRegenRange[0] = 160.0;
    //mRegenRange[1] = 160.0;
    SetTimer(0.2, false);
    //SetTimer(1.2, false);
}

simulated function Timer()
{
    mRegenRange[0] = 0.0;
    mRegenRange[1] = 0.0;
}

defaultproperties
{
    Skins(0)=Texture'XEffectMat.Shock.shock_ring_b'
    Style=STY_Additive
    mStartParticles=0
    mMaxParticles=10
    //mMaxParticles=100
    mRegen=true
    mRegenRange(0)=0.0
    mRegenRange(1)=0.0
    mLifeRange(0)=0.25
    mLifeRange(1)=0.25
    //mLifeRange(0)=1.25
    //mLifeRange(1)=1.25
    mSpeedRange(0)=100.0
    mSpeedRange(1)=100.0
    //mSizeRange(0)=1.0
    //mSizeRange(1)=1.0
    mSizeRange(0)=10.0
    mSizeRange(1)=10.0
    //mGrowthRate=100.0
    mGrowthRate=1500.0
    mSpinRange(0)=0.0
    mSpinRange(1)=0.0
    mParticleType=PT_Disc
    mPosRelative=true
    mAttenKa=0.0
    mColorRange(0)=(R=32,G=255,B=32,A=255)
    mColorRange(1)=(R=32,G=255,B=32,A=255)
    bOnlyOwnerSee=false

    /*
    RemoteRole=ROLE_DumbProxy
	bNetTemporary=true
    bReplicateInstigator=true
    bReplicateMovement=true
    NetPriority=3.0
    */
}
