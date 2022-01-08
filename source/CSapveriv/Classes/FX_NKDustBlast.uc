class FX_NKDustBlast extends xEmitter;

simulated function PostBeginPlay()
{
    local rotator rot;

    rot.pitch=16384;
    setrotation(rot);

    Settimer(1.5, false);
}

simulated function Timer()
{
    mRegen=false;
}

defaultproperties
{
     mSpawningType=ST_ExplodeRing
     mStartParticles=10
     mMaxParticles=600
     mLifeRange(1)=2.000000
     mRegenRange(0)=100.000000
     mRegenRange(1)=150.000000
     mPosDev=(X=500.000000,Y=500.000000)
     mSpeedRange(0)=3000.000000
     mSpeedRange(1)=1000.000000
     mPosRelative=True
     mAirResistance=0.200000
     mRandOrient=True
     mSpinRange(0)=-100.000000
     mSpinRange(1)=100.000000
     mSizeRange(0)=500.000000
     mSizeRange(1)=750.000000
     mGrowthRate=250.000000
     mAttenKa=0.100000
     mAttenKb=0.500000
     mAttenFunc=ATF_SmoothStep
     mRandTextures=True
     mNumTileColumns=4
     mNumTileRows=4
     RemoteRole=ROLE_SimulatedProxy
     LifeSpan=7.000000
     Skins(0)=Texture'XEffects.SmokeAlphab_t'
     Style=STY_Alpha
}
