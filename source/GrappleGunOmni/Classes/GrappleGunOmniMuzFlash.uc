class GrappleGunOmniMuzFlash extends xEmitter;

event Trigger( Actor Other, Pawn EventInstigator )
{
    mStartParticles += 1;
}

defaultproperties
{
     mMaxParticles=5
     mLifeRange(0)=0.250000
     mLifeRange(1)=0.250000
     mRegenRange(0)=0.000000
     mRegenRange(1)=0.000000
     mSpeedRange(0)=0.000000
     mSpeedRange(1)=0.000000
     mPosRelative=True
     mRandOrient=True
     mSpinRange(0)=-100.000000
     mSpinRange(1)=100.000000
     mSizeRange(0)=14.000000
     mSizeRange(1)=18.000000
     mColorRange(0)=(B=180,G=180,R=180)
     mColorRange(1)=(B=180,G=180,R=180)
     bHidden=True
     bOnlyOwnerSee=True
     Physics=PHYS_Trailer
     Skins(0)=Texture'GrappleGunOmni_Tex.Weapon.link_muz_purple'
     Style=STY_Translucent
}