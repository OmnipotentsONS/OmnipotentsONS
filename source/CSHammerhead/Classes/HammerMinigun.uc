//=============================================================================
// HammerMinigun - This weapon is passive; It obeys the MinigunMaster!
//=============================================================================
class HammerMinigun extends ONSWeapon;

function byte BestMode()
{
    return 0;
}

defaultproperties
{
     YawBone="minigunrotate"
     PitchBone="minigunrotate"
     PitchUpLimit=0
     PitchDownLimit=55000
     WeaponFireAttachmentBone="MinigunFire"
     RotationsPerSecond=2.000000
     bInstantFire=True
     bIsRepeatingFF=True
     Spread=0.030000
     RedSkin=Texture'CSHammerhead.hummertex_red'
     BlueSkin=Texture'CSHammerhead.hummertex_blue'
     FireInterval=0.100000
     AmbientEffectEmitterClass=Class'Onslaught.ONSRVChainGunFireEffect'
     FireSoundClass=Sound'CSHammerhead.HammerMiniFire'
     FireSoundVolume=150.000000
     AmbientSoundScaling=0.500000
     FireForce="minifireb"
     DamageType=Class'CSHammerhead.DamTypeHammerMinigun'
     DamageMin=11
     DamageMax=11
     TraceRange=15000.000000
     ShakeRotMag=(X=50.000000,Y=50.000000,Z=50.000000)
     ShakeRotRate=(X=10000.000000,Y=10000.000000,Z=10000.000000)
     ShakeRotTime=2.000000
     ShakeOffsetMag=(X=1.000000,Y=1.000000,Z=1.000000)
     ShakeOffsetRate=(X=1000.000000,Y=1000.000000,Z=1000.000000)
     ShakeOffsetTime=2.000000
     AIInfo(0)=(bInstantHit=True,aimerror=750.000000)
     CullDistance=8000.000000
     //Mesh=SkeletalMesh'CSHammerhead.HammerMinigun'
     Mesh=SkeletalMesh'CSHammerhead.Minigun'
}
