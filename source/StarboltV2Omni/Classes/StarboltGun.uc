class StarboltGun extends ONSDualACGatlingGun;

state InstantFireMode
{
	simulated function SpawnHitEffects(actor HitActor, vector HitLocation, vector HitNormal)
	{
		local ONSTurretBeamEffect Beam;

		if (Level.NetMode != NM_DedicatedServer)
		{
			if (Role < ROLE_Authority)
			{
				CalcWeaponFire();
				DualFireOffset *= -1;
			}

			Beam = Spawn(BeamEffectClass[Team],,, WeaponFireLocation, rotator(HitLocation - WeaponFireLocation));
			BeamEmitter(Beam.Emitters[0]).BeamDistanceRange.Min = VSize(WeaponFireLocation - HitLocation);
			BeamEmitter(Beam.Emitters[0]).BeamDistanceRange.Max = VSize(WeaponFireLocation - HitLocation);
			BeamEmitter(Beam.Emitters[1]).BeamDistanceRange.Min = VSize(WeaponFireLocation - HitLocation);
			BeamEmitter(Beam.Emitters[1]).BeamDistanceRange.Max = VSize(WeaponFireLocation - HitLocation);
			Beam.SpawnEffects(HitLocation, HitNormal);
		}
	}

//    function AltFire(Controller C)
//    {
//    }
}

defaultproperties
{
     TraceRange=11500 // added by pooty, default is 20000 limits range.
     CullDistance=11500
     PitchUpLimit=18000
     FireInterval=0.100000
     AltFireInterval=3.000000
     AltFireSoundClass=Sound'CicadaSnds.Decoy.DecoyLaunch'
     DamageType=Class'StarboltV2Omni.DamTypeStarboltLaser'
     AltFireProjectileClass=Class'StarboltV2Omni.FlareBomb'
     Mesh=SkeletalMesh'ONSWeapons-A.PlasmaGun'
     bSelected=True
}
