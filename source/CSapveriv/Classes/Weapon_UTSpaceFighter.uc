//=============================================================================
// Weapon_SpaceFighter
//=============================================================================
// Created by Laurent Delayen
// � 2003, Epic Games, Inc.  All Rights Reserved
//=============================================================================

class Weapon_UTSpaceFighter extends Weapon_Missiles
    config(user)
    HideDropDown
	CacheExempt;

#exec OBJ LOAD FILE=..\StaticMeshes\AS_Vehicles_SM.usx


//=============================================================================
// defaultproperties
//=============================================================================

defaultproperties
{
     FireModeClass(0)=Class'CSAPVerIV.FM_UTSpaceFighter_InstantHitLaser'
     FireModeClass(1)=Class'CSAPVerIV.WeaponFire_FighterMissileFire'
     AttachmentClass=Class'CSAPVerIV.WA_UTSpaceFighter'
     StaticMesh=StaticMesh'AS_Vehicles_SM.Vehicles.SpaceFighter_Human_FP'
}
