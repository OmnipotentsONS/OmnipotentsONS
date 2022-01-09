//=============================================================================
// HammerMinigunMaster - Makes the HammerMinigun mirror its actions.
//=============================================================================
class HammerMinigunMaster extends HammerMinigun;

var bool bOwnerSound;

//Makes sure the second minigun is active at the same time as this one, and is aiming at the same point.
function Tick(float Delta)
{
	Super.Tick(Delta);

	if(Owner == None)
		return;

	ONSVehicle(Owner).Weapons[2].bActive = bActive;
	ONSVehicle(Owner).Weapons[2].CurrentHitLocation = CurrentHitLocation;
}

//Fire the second minigun at the same time as this one.
function bool AttemptFire(Controller C, bool bAltFire)
{
	ONSVehicle(Owner).Weapons[2].AttemptFire(C, bAltFire);

	return Super.AttemptFire(C, bAltFire);
}

//Makes sure effects are stopped for the second minigun.
function CeaseFire(Controller C)
{
	Super.CeaseFire(C);

	ONSVehicle(Owner).Weapons[2].CeaseFire(C);
}

simulated function ClientStopFire(Controller C, bool bWasAltFire)
{
	Super.ClientStopFire(C, bWasAltFire);

	ONSVehicle(Owner).Weapons[2].ClientStopFire(C, bWasAltFire);
}

//The code down there delays the firing sound for this weapon by half the FireInterval so it plays alternately with the other slave weapon (makes it sound faster and gives a better stereo effect).
state InstantFireMode
{
    function Fire(Controller C)
    {
        FlashMuzzleFlash();

        if (AmbientEffectEmitter != None)
        {
            AmbientEffectEmitter.SetEmitterStatus(true);
        }

        // Play firing noise
        if (bAmbientFireSound)
            AmbientSound = FireSoundClass;
        else
		SetTimer(FireInterval * 0.5, false);

        TraceFire(WeaponFireLocation, WeaponFireRotation);
    }
}

simulated event OwnerEffects()
{
	if (!bIsRepeatingFF)
	{
		if (bIsAltFire)
			ClientPlayForceFeedback( AltFireForce );
		else
			ClientPlayForceFeedback( FireForce );
	}
    ShakeView();

	if (Role < ROLE_Authority)
	{
		if (bIsAltFire)
			FireCountdown = AltFireInterval;
		else
			FireCountdown = FireInterval;

		AimLockReleaseTime = Level.TimeSeconds + FireCountdown * FireIntervalAimLock;

        FlashMuzzleFlash();

		if (AmbientEffectEmitter != None)
			AmbientEffectEmitter.SetEmitterStatus(true);

        // Play firing noise
        if (!bAmbientFireSound)
        {
		bOwnerSound = true;
		SetTimer(FireInterval * 0.5, false);
        }
	}
}

simulated function Timer()
{
	if(bOwnerSound)
	{
		PlaySound(FireSoundClass, SLOT_None, FireSoundVolume/255.0,, FireSoundRadius, FireSoundPitch, False);
		bOwnerSound = false;
	}
	else
		PlayOwnedSound(FireSoundClass, SLOT_None, FireSoundVolume/255.0,, FireSoundRadius, FireSoundPitch, False);
}

defaultproperties
{
     FireSoundPitch=1.500000
}
