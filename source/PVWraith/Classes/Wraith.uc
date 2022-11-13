/******************************************************************************
Orignally Ban shee converted to Wraith

Creation date: 2010-10-05 17:20
Last change: $Id$
Copyright © 2010, Wormbo
Website: http://www.koehler-homepage.de/Wormbo/
Feel free to reuse this code. Send me a note if you found it helpful or want
to report bugs/provide improvements.
Please ask for permission first, if you intend to make money off reused code.
******************************************************************************/

/***
Edited:  Jan 2020
Edited By: pooty for OMNI
Made some changes to beef up this vehicle as the Wraith

Thanks to Wormbo for his original work
***/


class Wraith extends ONSDualAttackCraft;


// obj load WVMercuryMissiles.u package=PVWraith
// embedded MercuryMissles in this vehicle
// allows better config/control and avoid class collisions

#exec audio import File=Sounds\WraithEngine.wav
#exec audio import File=Sounds\WraithStart.wav
#exec audio import File=Sounds\WraithStop.wav


/**
Skip Cicada logic - no lock-on.
*/
simulated function DrawHUD(Canvas C)
{
	local HudCDeathmatch H;
	local float XL, YL, PosY;
	local string CoPilot;

	Super(ONSVehicle).DrawHUD(C);

	H = HudCDeathmatch(C.Viewport.Actor.MyHud);
	if (H == None)
		return;

	HudMissileCount.Tints[0] = H.HudColorRed;
	HudMissileCount.Tints[1] = H.HudColorBlue;

	H.DrawSpriteWidget(C, HudMissileCount);
	H.DrawSpriteWidget(C, HudMissileIcon);
	HudMissileDigits.Value = WraithSideGun(Weapons[0]).RemainingShotCount;
	H.DrawNumericWidget(C, HudMissileDigits, DigitsBig);

	if (WeaponPawns[0] != None && WeaponPawns[0].PlayerReplicationInfo != None) {
		CoPilot = WeaponPawns[0].PlayerReplicationInfo.PlayerName;
		C.Font = H.GetMediumFontFor(C);
		C.Strlen(CoPilot, XL, YL);
		PosY = C.ClipY * 0.7;
		C.SetPos(C.ClipX - XL - 5, PosY);//(Canvas.ClipY/2) - (YL/2));
		C.SetDrawColor(255, 255, 255, 255);
		C.DrawText(CoPilot);

		C.Font = H.GetConsoleFont(C);
		C.StrLen(CoPilotLabel, XL, YL);
		C.SetPos(C.ClipX - XL - 5, PosY - 5 - YL);
		C.SetDrawColor(160, 160, 160, 255);
		C.DrawText(CoPilotLabel);
	}
}

/**
Skip Cicada logic - no decoys available.
*/
event LockOnWarning()
{
	Super(Vehicle).LockOnWarning();
}

/**
Skip Cicada logic - no decoys available.
*/
function IncomingMissile(Projectile P);


/**
Try firing at incoming AVRiLs only if no gunner.
*/
function ShouldTargetMissile(Projectile P)
{
	if (WeaponPawns.Length > 0 && WeaponPawns[0].Controller == None)
		Super(Vehicle).ShouldTargetMissile(P);
}


/**
Can attack immediately.
*/
function float RangedAttackTime()
{
	return 0;
}


/**
Zoom - very useful for Mercury Missiles.
*/
// TODO: implement  Mercury Missile Launcher zoom modes?
function AltFire(optional float F)
{
	local PlayerController PC;

	PC = PlayerController(Controller);
	if (PC == None)
		return;

	bWeaponIsAltFiring = true;
	PC.ToggleZoomWithMax(0.5);
}


function ClientVehicleCeaseFire(bool bWasAltFire)
{
	local PlayerController PC;

	if (!bWasAltFire) {
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

	bWeaponIsAltFiring = false;
	PC.EndZoom();
}

function Vehicle FindEntryVehicle(Pawn P)
{
	local Vehicle EntryVehicle;

	EntryVehicle = Super.FindEntryVehicle(P);
	if (EntryVehicle == None && Driver != None)
	{
		// If a player is trying to drive and we're full of bots, kick out the bot driver so the player can drive
		if (PlayerController(P.Controller) != None && Bot(Controller) != None && Controller.SameTeamAs(P.Controller)) {
			KDriverLeave(true);
			return self;
		}
	}
	else return EntryVehicle;
}

function bool IsChassisTouchingGround()
{
	if (KParams != None && KParams.bContactingLevel)
	{
		KParams.CalcContactRegion();
		return KParams.ContactRegionNormal.Z > 0.7;
	}
	return false;
}


function DriverLeft()
{
	if (IsChassisTouchingGround())
	{
		if (AmbientSound != None)
			AmbientSound = None;

		if (ShutDownSound != None)
			PlaySound(ShutDownSound, SLOT_None, 1.0);

		if (!bNeverReset && ParentFactory != None && (VSize(Location - ParentFactory.Location) > 5000.0 || !FastTrace(ParentFactory.Location, Location)))
		{
			if (bKeyVehicle)
				ResetTime = Level.TimeSeconds + 15;
			else
			ResetTime = Level.TimeSeconds + 30;
		}

		Super(SVehicle).DriverLeft();
	}
	else
	{
		bDriving = True;
		GotoState('AutoLanding');
	}
}


state AutoLanding
{
	function Tick(float DeltaTime)
	{
		local Actor HitActor;
		local vector X, Y, Z, HitNormal, HitLocation;

		Global.Tick(DeltaTime);

		if (!IsVehicleEmpty())
		{
			GotoState('Auto');
		}
		else if (IsChassisTouchingGround())
		{
			GotoState('Auto');
			bDriving = False;
			DriverLeft();
		}
		else
		{
			HitActor = Trace(HitLocation, HitNormal, Location - vect(0,0,2500), Location, false);
			if ( Velocity.Z < -1200 )
				OutputRise = 1.0;
			else if ( HitActor == None )
				OutputRise = -1.0;
			else if ( VSize(HitLocation - Location) < -2*Velocity.Z )
			{
				if ( Velocity.Z > -100 )
					OutputRise = 0;
				else
					OutputRise = 1.0;
			}
			else if ( Velocity.Z > -500 )
				OutputRise = -0.4;
			else
				OutputRise = -0.1;

			GetAxes(Rotation.Yaw * rot(0,1,0), X, Y, Z);
			OutputThrust = Round(FClamp((Velocity dot X) * -0.01, -1, 1));
			OutputStrafe = Round(FClamp((Velocity dot Y) *  0.01, -1, 1));
		}
	}

	function KDriverEnter(Pawn P)
	{
		GotoState('Auto');
		Global.KDriverEnter(P);
	}
}


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
     HudMissileIcon=(WidgetTexture=Texture'PVWraith.MercHUDIcon')
     HudMissileDigits=(MinDigitCount=2)
     MaxThrustForce=120.000000
     MaxStrafeForce=95.000000
     DriverWeapons(0)=(WeaponClass=Class'PVWraith.WraithSideGun')
     DriverWeapons(1)=(WeaponClass=Class'PVWraith.WraithSideGun')
     //PassengerWeapons(0)=(WeaponPawnClass=Class'PVWraith.WraithBellyGunPawn')
     PassengerWeapons(0)=(WeaponPawnClass=Class'PVWraith.WraithLinkTurretPawn')
     bHasAltFire=False
     RedSkin=Texture'PVWraith_Tex.Skins.WraithRed'
     BlueSkin=Texture'PVWraith_Tex.Skins.WraithBlue'
     IdleSound=Sound'PVWraith.WraithEngine'
     StartUpSound=Sound'PVWraith.WraithStart'
     ShutDownSound=Sound'PVWraith.WraithStop'
     VehiclePositionString="in a Wraith"
     VehicleNameString="Wraith 1.5"
     RanOverDamageType=Class'PVWraith.DamTypeWraithRoadkill'
     CrushedDamageType=Class'PVWraith.DamTypeWraithPancake'
}
