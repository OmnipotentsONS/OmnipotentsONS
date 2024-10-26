//-----------------------------------------------------------
//
//-----------------------------------------------------------
class MirageRaptorOmniGun extends ONSAttackCraftGun;


 simulated event FlashMuzzleFlash()
{
	Super.FlashMuzzleFlash();

	PlayAnim('Fire', 1, 0);

		}



	function AltFire(Controller C)
	{
		local MirageRaptorOmniMissle M;
		local Vehicle V, Best;
		local float CurAim, BestAim;

		M = MirageRaptorOmniMissle(SpawnProjectile(AltFireProjectileClass, True));
		if (M != None)
		{
			if (AIController(Instigator.Controller) != None)
			{
				V = Vehicle(Instigator.Controller.Enemy);
				if (V != None && (V.bCanFly || V.IsA('ONSHoverCraft')) && Instigator.FastTrace(V.Location, Instigator.Location))
					M.SetHomingTarget(V);
			}
			else
			{
				BestAim = MinAim;
				for (V = Level.Game.VehicleList; V != None; V = V.NextVehicle)
					if ((V.bCanFly || V.IsA('ONSHoverCraft')) && V != Instigator && Instigator.GetTeamNum() != V.GetTeamNum())
					{
						CurAim = Normal(V.Location - WeaponFireLocation) dot vector(WeaponFireRotation);
						if (CurAim > BestAim && Instigator.FastTrace(V.Location, Instigator.Location))
						{
							Best = V;
							BestAim = CurAim;
						}
					}
				if (Best != None)
					M.SetHomingTarget(Best);
			}
		}
	}

defaultproperties
{
     TeamProjectileClasses(0)=Class'MirageRaptorOmni.MirageRaptorOmniProjectileRed'
     TeamProjectileClasses(1)=Class'MirageRaptorOmni.MirageRaptorOmniProjectileBlue'
     YawBone="Firepoint"
     YawStartConstraint=57344.000000
     YawEndConstraint=8192.000000
     PitchBone="MainAttach"
     PitchUpLimit=6000
     PitchDownLimit=53248
     WeaponFireAttachmentBone="Firepoint"
     WeaponFireOffset=-250
     RotationsPerSecond=2.800000
     FireInterval=0.080000
     AltFireInterval=2.000000
     FireSoundClass=Sound'MirageRaptorSounds.MirageRaptorMini2'
     AltFireSoundClass=Sound'MirageRaptorSounds.MirageRaptorAlt'
     //ProjectileClass=Class'MirageRaptorOmni.MirageRaptorOmniProjectileRed'
     AltFireProjectileClass=Class'MirageRaptorOmni.MirageRaptorOmniMissle'
     Mesh=SkeletalMesh'MirageRaptorOmniAnims.Minigun'
}
