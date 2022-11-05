/******************************************************************************
WraithWeaponPawn

Creation date: 2013-02-16 13:02
Last change: $Id$
Copyright © 2013, Wormbo
Website: http://www.koehler-homepage.de/Wormbo/
Feel free to reuse this code. Send me a note if you found it helpful or want
to report bugs/provide improvements.
Please ask for permission first, if you intend to make money off reused code.
******************************************************************************/

class WraithWeaponPawn extends ONSWeaponPawn abstract;


var bool bTurnedOff;


simulated function TurnOff()
{
	//Log("In WraithWeaponPawn-Turnoff");
	bTurnedOff = True;
	if (WraithWeapon(Gun) != None)
		WraithWeapon(Gun).bTurnedOff = True;

	Super.TurnOff();
}

function VehicleCeaseFire(bool bWasAltFire)
{
	Super.VehicleCeaseFire(bWasAltFire);
	if (Gun != None)
	{
		Gun.WeaponCeaseFire(Controller, bWasAltFire); // WTF was this missing in ONSWeaponPawn?
	}
}


function KDriverEnter(Pawn P)
{
	////Log("In WraithWeaponPawn-DriverEnter");
	Super.KDriverEnter(P);

	if (bTurnedOff)
		return;

	if (!VehicleBase.bDriving)
	{
		VehicleBase.bDriving = true;
		VehicleBase.DrivingStatusChanged();
	}
}

event bool KDriverLeave(bool bForceLeave)
{
	local bool result;
  //Log("In WraithWeaponPawn-KDriverLeave");
	result  = Super.KDriverLeave(bForceLeave);

	if (!bTurnedOff && result && VehicleBase.IsVehicleEmpty())
	{
		VehicleBase.bDriving = false;
		VehicleBase.DrivingStatusChanged();
	}

	return result;
}


function AltFire(optional float F)
{
	local PlayerController PC;

	if (bHasAltFire)
	{
		Super.AltFire(F);
	}
	else
	{
		PC = PlayerController(Controller);
		if (PC == None)
			return;

		bWeaponIsAltFiring = true;
		PC.ToggleZoom();
	}
}

function ClientVehicleCeaseFire(bool bWasAltFire)
{
	local PlayerController PC;
//Log("In WraithLinkTurret=ClientVehicleCeaseFire");
	if (bHasAltFire || !bWasAltFire)
	{
		Super.ClientVehicleCeaseFire(bWasAltFire);
		return;
	}

	PC = PlayerController(Controller);
	if (PC == None)
		return;

	bWeaponIsAltFiring = false;
	PC.StopZoom();
}

simulated function ClientKDriverLeave(PlayerController PC)
{
	Super.ClientKDriverLeave(PC);
////Log("In WraithWeaponPawn=ClientKDriverLeave");
	if (!bHasAltFire)
	{
		bWeaponIsAltFiring = false;
		PC.EndZoom();
	}
}

function ShouldTargetMissile(Projectile P)
{
	if (Bot(Controller) != None && Bot(Controller).Skill >= 5.0)
	{
		if (Controller.Enemy != None && Bot(Controller).EnemyVisible() && Bot(Controller).Skill < 5)
			return;
		ShootMissile(P);
	}
}


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
}
