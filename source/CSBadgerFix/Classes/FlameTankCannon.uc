//-----------------------------------------------------------
//
//-----------------------------------------------------------
class FlameTankCannon extends ONSHoverTankCannon;

var float ChargeLevel, ChargeTick, ChargeTime, MaxCHargeLevel, napalmfirecounter, NapalmFuelCost, fireballfuelcost;
var bool  bChargeUp;
var bool Napalming;
var Controller TempController;

replication
{
  reliable if(Role == Role_Authority) 
           bChargeUp, ChargeLevel;
}

//do effects (muzzle flash, force feedback, etc) immediately for the weapon's owner (don't wait for replication)
simulated event OwnerEffects()
{

	if (Role < ROLE_Authority)
	{
		if (bIsAltFire)
			FireCountdown = AltFireInterval;
		else
			FireCountdown = FireInterval;

		AimLockReleaseTime = Level.TimeSeconds + FireCountdown * FireIntervalAimLock;

		if ( (bIsAltfire && ChargeLevel>(FireballFuelCost-0.001)) || (!bIsAltfire && Napalming && NapalmFireCounter<=0.0 && ChargeLevel>(NapalmFuelCost-0.001) && bChargeUp) )
	        	FlashMuzzleFlash();

		if (AmbientEffectEmitter != None)
			AmbientEffectEmitter.SetEmitterStatus(true);

	        // Play firing noise
        	if (!bAmbientFireSound)
        	{
            		if (bIsAltFire && ChargeLevel>(FireballFuelCost-0.001))
                		PlaySound(AltFireSoundClass, SLOT_None, FireSoundVolume/255.0,, AltFireSoundRadius,, false);
            		else if (Napalming && ChargeLevel>(NapalmFuelCost-0.001) && bChargeUp)
                		PlaySound(FireSoundClass, SLOT_None, FireSoundVolume/255.0,, FireSoundRadius,, false);
        	}
	}
}

event bool AttemptFire(Controller C, bool bAltFire)
{
  	if(Role != ROLE_Authority || bForceCenterAim)
		return False;

	if (FireCountdown <= 0)
	{
		CalcWeaponFire();
		if (bCorrectAim)
			WeaponFireRotation = AdjustAim(bAltFire);
		if (Spread > 0)
			WeaponFireRotation = rotator(vector(WeaponFireRotation) + VRand()*FRand()*Spread);

        	DualFireOffset *= -1;

		Instigator.MakeNoise(1.0);
		if (bAltFire)
		{
			FireCountdown = AltFireInterval;
			AltFire(C);
		}
		else
		{
		    	FireCountdown = FireInterval;
		    	Fire(C);
		}
		AimLockReleaseTime = Level.TimeSeconds + FireCountdown * FireIntervalAimLock;


	    return True;
	}

	return False;
}

state ProjectileFireMode
{
     	function Fire(Controller C)
    	{
		if ( ChargeLevel > 0.142857 )
		{
			TempController = C;
			Napalming = True;
		}
		else if ( ChargeLevel < 0.142857 )
		{
			Napalming = False;
		}
        }

	function AltFire(Controller C)
	{
		if (ChargeLevel>FireBallFuelCost)
		{
			ChargeLevel-=FireBallFuelCost;
			SpawnProjectile(AltFireProjectileClass, True);
		}
	}

	function CeaseFire(Controller C)
	{
		Napalming = False;
	}

    	event Tick(float DeltaTime)
    	{
         	if (  FlameTank(Owner).Driver != None  &&   ChargeLevel < MaxCHargeLevel  && !Napalming)
              		ChargeLevel = FClamp(ChargeLevel + ChargeTick * DeltaTime, 0, MaxCHargeLevel);

		if (ChargeLevel>0.143)
		{
			if (Napalming && NapalmFireCounter<=0.0 && ChargeLevel>0.0 && bChargeUp)
			{
				Super.Fire(TempController);
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

simulated function float ChargeBar()
{

    return FMin(0.999999, ChargeLevel);

}

defaultproperties
{
     ChargeTick=0.200000
     MaxCHargeLevel=0.999999
     NapalmFuelCost=0.142857
     fireballfuelcost=0.600000
     bChargeUp=True
     PitchUpLimit=9000
     RotationsPerSecond=0.200000
     bShowChargingBar=True
     RedSkin=Texture'FireTank_Tex.FireTank.FireTankRed'
     BlueSkin=Texture'FireTank_Tex.FireTank.FireTankBlue'
     FireInterval=0.200000
     AltFireInterval=0.200000
     EffectEmitterClass=Class'CSBadgerFix.NapalmTankFireEffect'
     FireSoundClass=Sound'ONSVehicleSounds-S.Explosions.VehicleExplosion02'
     AltFireSoundClass=Sound'WeaponSounds.BaseImpactAndExplosions.BExplosion2'
     RotateSound=Sound'BioAegis_Sound.BioTank.BiotankTurret'
     ProjectileClass=Class'CSBadgerFix.NapalmTankFire'
     AltFireProjectileClass=Class'CSBadgerFix.FireballProjectile'
     bSelected=True
}
