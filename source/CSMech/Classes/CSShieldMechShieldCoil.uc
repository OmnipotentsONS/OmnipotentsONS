class CSShieldMechShieldCoil extends ShockBeamCoil;

defaultproperties
{
	bHighDetail=true
    RemoteRole=ROLE_None
    LifeSpan=0.75

    mParticleType=PT_Beam
    mStartParticles=1
    mAttenuate=true
    //mSizeRange(0)=0.3
    //mSizeRange(1)=0.6
    mSizeRange(0)=0.6
    mSizeRange(1)=1.0
    //mRegenDist=90.0
    //mRegenDist=360.0
    mRegenDist=90.0
    mLifeRange(0)=1.0
    mMaxParticles=1
    mMeshNodes(0)=StaticMesh'ShockCoil'
    mSpinRange[0]=32000
    mColorRange(0)=(R=50,G=50,B=50)
    mColorRange(1)=(R=50,G=50,B=50)

    DrawScale=1.0
    //DrawScale3D=(X=3,Y=15,Z=15)
    //DrawScale3D=(X=12,Y=60,Z=60)
    DrawScale3D=(X=12,Y=60,Z=60)
    //Skins(0)=FinalBlend'XEffectMat.ShockCoilFB'
    Skins(0)=FinalBlend'CSMech.ShieldCoilFB'
    //Skins(0)=FinalBlend'XEffectMat.ShockDarkFB'
    bUnlit=true
}
