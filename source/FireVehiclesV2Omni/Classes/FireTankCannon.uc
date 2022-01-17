class FireTankCannon extends ONSHoverTankCannon;

simulated function ShakeView();

simulated function float ChargeBar()
{
	return FClamp(0.999 - (FireCountDown / AltFireInterval), 0.0, 0.999);
}

defaultproperties
{
     PitchUpLimit=9000
     WeaponFireOffset=210.000000
     RotationsPerSecond=0.200000
     bShowChargingBar=True
     RedSkin=Texture'FireTank_Tex.FireTank.FireTankRed'
     BlueSkin=Texture'FireTank_Tex.FireTank.FireTankBlue'
     FireInterval=1.300000
     AltFireInterval=5.300000
     EffectEmitterClass=Class'FireVehiclesV2Omni.FireTankFireEffect'
     FireSoundClass=Sound'WeaponSounds.BaseImpactAndExplosions.BExplosion2'
     FireSoundVolume=600.000000
     AltFireSoundClass=Sound'ONSVehicleSounds-S.Tank.TankFire01'
     AltFireSoundVolume=800.000000
     RotateSound=Sound'CuddlyArmor_Sound.BioTank.BiotankTurret'
     ProjectileClass=Class'FireVehiclesV2Omni.FireballProjectile'
     AltFireProjectileClass=Class'FireVehiclesV2Omni.FireballIncendiary'
}
