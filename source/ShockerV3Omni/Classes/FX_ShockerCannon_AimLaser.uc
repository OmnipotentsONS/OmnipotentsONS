//=============================================================================
// FX_IonPlasmaTank_AimLaser
//=============================================================================
// Created by Laurent Delayen (C) 2003 Epic Games
//=============================================================================

class FX_ShockerCannon_AimLaser extends FX_Turret_IonCannon_LaserBeam;

var ShockerIonCannon WeaponOwner;

replication
{
    unreliable if ( Role == ROLE_Authority && bNetInitial && bNetOwner )
        WeaponOwner;
}

simulated function SetWeaponOwner()
{
	WeaponOwner = ShockerIonCannon(Owner);
}

simulated function UpdateBeamLocation()
{
	if ( WeaponOwner != None )
		WeaponOwner.UpdateLaserBeamLocation(StartLocation, EndLocation);
}

defaultproperties
{
}
