class StarboltGun extends ONSDualACGatlingGun;

var class<StarBoltTurretBeamEffect> StarBeamEffectClass[2];

state InstantFireMode
{
	simulated function SpawnHitEffects(actor HitActor, vector HitLocation, vector HitNormal)
	{
		local StarboltTurretBeamEffect Beam;

		if (Level.NetMode != NM_DedicatedServer)
		{
			if (Role < ROLE_Authority)
			{
				CalcWeaponFire();
				DualFireOffset *= -1;
			}

			Beam = Spawn(StarBeamEffectClass[Team],,, WeaponFireLocation, rotator(HitLocation - WeaponFireLocation));
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
     TraceRange=20000 // Back to usual 20000 for lasers per community outrage.
     CullDistance=20000
     // set damage same as phoenix
     DamageMin=12
     DamageMax=15
     PitchUpLimit=18000
     FireInterval=0.133333  //slowed just a touch as it lags on the server.
     AltFireInterval=3.000000
     AltFireSoundClass=Sound'CicadaSnds.Decoy.DecoyLaunch'
     DamageType=Class'StarboltV2Omni.DamTypeStarboltLaser'
     AltFireProjectileClass=Class'StarboltV2Omni.FlareBomb'
     Mesh=SkeletalMesh'ONSWeapons-A.PlasmaGun'
     bSelected=True
     StarBeamEffectClass(0)=class'StarboltTurretBeamEffect'
     StarBeamEffectClass(1)=class'StarboltTurretBeamEffectBlue'

}
