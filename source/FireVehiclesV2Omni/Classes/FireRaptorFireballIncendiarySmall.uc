class FireRaptorFireballIncendiarySmall extends FireBallIncendiarySmall;


simulated function Timer()
{
	local float VelMag;
	local vector ForceDir;

	if (HomingTarget == None)
		return;

	ForceDir = Normal(HomingTarget.Location - Location);
	if (ForceDir dot InitialDir > 0)
	{
	    	VelMag = VSize(Velocity);

	    	ForceDir = Normal(ForceDir * 0.7 * VelMag + Velocity);
		Velocity =  VelMag * ForceDir;
    		Acceleration = Normal(Velocity) * AccelRate;

		SetRotation(rotator(Velocity));
	}
}

defaultproperties
{
     TrailClass=Class'FireVehiclesV2Omni.FireBallTrail'
     AccelRate=1000.000000
     BurnDamageType=Class'FireVehiclesV2Omni.Burned'
     Speed=15000.000000
     MaxSpeed=15000.000000
     Damage=80.000000
     DamageRadius=250.000000
     NumFireBalls=6
     MomentumTransfer=40000.000000
     MyDamageType=Class'FireVehiclesV2Omni.FlameKillRaptor'
     ExplosionDecal=Class'XEffects.RocketMark'
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'VMWeaponsSM.PlayerWeaponsGroup.bomberBomb'
     AmbientSound=Sound'WeaponSounds.RocketLauncher.RocketLauncherProjectile'
     LifeSpan=5.000000
     AmbientGlow=32
     SoundVolume=255
     SoundRadius=200.000000
     bFixedRotationDir=True
     RotationRate=(Roll=50000)
     DesiredRotation=(Roll=30000)
     ForceType=FT_Constant
     ForceRadius=100.000000
     ForceScale=5.000000
}
