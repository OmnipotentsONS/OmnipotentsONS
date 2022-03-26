// ONSPlus: Coded by Shambler (Shambler__@Hotmail.com or Shambler@OldUnreal.com , ICQ:108730864)
class ONSPlusExitMarker extends xEmitter;

#exec OBJ LOAD File=XMiscEffects.utx

var bool bGlowing;

// Added this code here to (hopefully) solve the problem of the exit beacons not disappearing (also, they get destroyed after a minute..more memory efficient)
function Nudge(optional int PreferenceLife)
{
	if (PreferenceLife == 0)
		PreferenceLife = 3;

	bGlowing = True;
	mRegen = True;

	SetTimer(PreferenceLife, False);
}

function Timer()
{
	if (bGlowing)
	{
		mRegen = False;
		bGlowing = False;
		SetTimer(60, False);
	}
	else
	{
		Destroy();
	}
}

defaultproperties
{
	Skins(0)=Texture'EmitSmoke_t'
	Style=STY_Additive
	mParticleType=PT_Sprite
	mLifeRange(0)=1.25
	mLifeRange(1)=1.25
	mSpeedRange(0)=0.0
	mSpeedRange(1)=0.0
	mSpinRange(0)=-75.0
	mSpinRange(1)=75.0
	mSizeRange(0)=25.0
	mSizeRange(1)=30.0
	mRegenRange(0)=90.0
	mRegenRange(1)=90.0
	mRandOrient=True
	mRandTextures=True
	mStartParticles=0
	mMaxParticles=150
	mGrowthRate=13.0
	mAttenuate=True
	mAttenFunc=ATF_ExpInOut
	mAttenKa=0.2
	mRegen=True
	mNumTileColumns=4
	mNumTileRows=4
	mMassRange(0)=-0.03
	mMassRange(1)=-0.01
	mColorRange(0)=(R=255,G=40,B=40,A=255)
	mColorRange(1)=(R=255,G=40,B=40,A=255)
}