class FireHoundFireEmitter extends xEmitter;

var config int FireDensity;
var config bool bNeverDropDetail;

function PreBeginPlay()
{
        if(!bNeverDropDetail && Level.bDropDetail)
		FireDensity *= 0.6;

	FireDensity = FMax(FireDensity, 1);
	Default.mStartParticles = FireDensity;
	Default.mPosDev.X = FMin(FireDensity * 15, 50);
	Default.mAttenKa = FMin(FireDensity * 0.07, 0.2);
}

defaultproperties
{
     FireDensity=3
     bNeverDropDetail=True
     mRegen=False
     mStartParticles=2
     mLifeRange(0)=1.600000
     mLifeRange(1)=1.700000
     mPosDev=(X=30.000000)
     mSpeedRange(0)=0.000000
     mSpeedRange(1)=0.000000
     mPosRelative=True
     mRandOrient=True
     mSpinRange(0)=-50.000000
     mSpinRange(1)=50.000000
     mSizeRange(0)=1.000000
     mSizeRange(1)=1.000000
     mGrowthRate=120.000000
     mAttenKa=0.100000
     mNumTileColumns=2
     mNumTileRows=2
     mLifeColorMap=Texture'FireHound_Tex.FireHound.HoundFireMap'
     bNetTemporary=False
     RemoteRole=ROLE_DumbProxy
     LifeSpan=1.500000
     Skins(0)=Texture'FireHound_Tex.FireHound.FireTex'
     Style=STY_Additive
}
