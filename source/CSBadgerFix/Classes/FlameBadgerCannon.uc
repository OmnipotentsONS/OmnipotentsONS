//=============================================================================
// FlameBadgerCannon.
//=============================================================================
class FlameBadgerCannon extends FlameTankCannon;

state ProjectileFireMode
{
	event Tick(float DeltaTime)
	{
		if (Vehicle(Owner).Driver != None && ChargeLevel < MaxCHargeLevel && !Napalming)
			ChargeLevel = FClamp(ChargeLevel + ChargeTick * DeltaTime, 0, MaxCHargeLevel);

		if (ChargeLevel>0.143)
		{
			if (Napalming && NapalmFireCounter<=0.0 && ChargeLevel>0.0 && bChargeUp)
			{
				Super(ONSHoverTankCannon).Fire(TempController);
				NapalmFireCounter=FireInterval;
				if (ChargeLevel<=NapalmFuelCost)
				{
					ChargeLevel=0.0;
					bChargeup = False;
				}
				else
					ChargeLevel-=NapalmFuelCost;
			}
			else
				NapalmFireCounter-=deltaTime;
		}

		if (ChargeLevel>=MaxCHargeLevel)
			bChargeup = True;    	
	}
}

defaultproperties
{
     YawBone="BadgerTurret"
     PitchBone="TurretBarrel"
     PitchUpLimit=6000
     WeaponFireAttachmentBone="TurretFire"
     RedSkin=Texture'MoreBadgers.FireBadger.FireBadgerRed'
     BlueSkin=Texture'MoreBadgers.FireBadger.FireBadgerBlue'
     ProjectileClass=Class'CSBadgerFix.NapalmBadgerFire'
     AltFireProjectileClass=Class'CSBadgerFix.BadgerFireballProjectile'
     Mesh=SkeletalMesh'CSBadgerFix.BadgerTurret'
}
