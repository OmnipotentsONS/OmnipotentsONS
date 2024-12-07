

class StirgeSparksPurple extends LinkSparks;
#exec OBJ LOAD FILE=LinkScorpion3Tex.utx

simulated function SetLinkStatus(int Links, bool bLinking, float ls)
{
    mSizeRange[0] = default.mSizeRange[0] * (ls*1.0 + 1);
    mSizeRange[1] = default.mSizeRange[1] * (ls*1.0 + 1);
    mSpeedRange[0] = default.mSpeedRange[0] * (ls*0.7 + 1);
    mSpeedRange[1] = default.mSpeedRange[1] * (ls*0.7 + 1);
    mLifeRange[0] = default.mLifeRange[0] * (ls + 1);
    mLifeRange[1] = mLifeRange[0];
    DesiredRegen = default.mRegenRange[0] * (ls + 1);
    Skins[0] = Texture'LinkScorpion3Tex.link_spark_purple';
    
}

defaultproperties
{
     LightHue=179
     LightSaturation=90
     LightBrightness=153.000000
     Skins(0)=Texture'LinkScorpion3Tex.link_spark_purple'
}
