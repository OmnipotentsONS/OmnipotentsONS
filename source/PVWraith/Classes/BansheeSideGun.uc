/******************************************************************************
BansheeSideGun

Creation date: 2010-10-05 17:50
Last change: $Id$
Copyright © 2010, Wormbo
Website: http://www.koehler-homepage.de/Wormbo/
Feel free to reuse this code. Send me a note if you found it helpful or want
to report bugs/provide improvements.
Please ask for permission first, if you intend to make money off reused code.
******************************************************************************/

class BansheeSideGun extends ONSDualACSideGun;


var int RemainingShotCount;
var() float FireRecoilAmount;
var() float MissileReloadTime;


/**
Bots don't use zoom.
*/
function byte BestMode()
{
	return 0;
}

function bool CanAttack(Actor Other)
{
	return RemainingShotCount > 0 && Super.CanAttack(Other);
}

event bool AttemptFire(Controller C, bool bAltFire)
{
	if (Role != ROLE_Authority || bForceCenterAim)
		return False;

	if (RemainingShotCount > 0) {
		FireSingle(C, bAltFire);
		--RemainingShotCount;
		SetTimer(MissileReloadTime + FireInterval, true);
		if (RemainingShotCount == 0) {
			// wait longer, no use trying to fire if no ammo
			FireCountdown += MissileReloadTime + 0.01;
		}
	}
	return False;
}

function Projectile SpawnProjectile(class<Projectile> ProjClass, bool bAltFire)
{
	local Projectile Proj;

	Proj = Super(ONSWeapon).SpawnProjectile(ProjClass, bAltFire);
	if (Proj != None)
	{
		Proj.SetOwner(None); // ambient sound fix
		Instigator.KAddImpulse(-Proj.MomentumTransfer * Proj.Velocity, Proj.Location);
	}
	return Proj;
}


simulated event OwnerEffects()
{
	if (Level.NetMode == NM_Client && !bIsAltFire) {
		if (RemainingShotCount > 0)
			RemainingShotCount--;
		SetTimer(MissileReloadTime + FireInterval, true);
	}
	Super(ONSLinkableWeapon).OwnerEffects();
}


simulated function Timer()
{
	if (RemainingShotCount < MaxShotCount)
		RemainingShotCount++;

	if (RemainingShotCount >= MaxShotCount)
		SetTimer(0, false);
	else if (TimerRate > MissileReloadTime)
		SetTimer(MissileReloadTime, true);
}

function WeaponCeaseFire(Controller C, bool bWasAltFire);


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
     RemainingShotCount=20
     MissileReloadTime=0.300000
     MaxShotCount=20
     RotationsPerSecond=0.150000
     bInstantRotation=False
     Spread=0.100000
     FireInterval=0.200000
     FireSoundClass=Sound'PVWraith.Effects.MercIgnite'
     AltFireSoundClass=None
     ProjectileClass=Class'PVWraith.WVMercuryMissile'
     AltFireProjectileClass=None
     AIInfo(0)=(RefireRate=0.900000)
}
