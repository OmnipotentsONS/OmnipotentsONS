//=============================================================================
// Weapon_SpaceFighter
//=============================================================================
// Created by Laurent Delayen
// � 2003, Epic Games, Inc.  All Rights Reserved
//=============================================================================

class Weapon_ExcaliburBotFighter extends Weapon_Missiles
    config(user)
    HideDropDown
	CacheExempt;

#exec OBJ LOAD FILE=..\StaticMeshes\AS_Vehicles_SM.usx

function byte BestMode()
{
	local bot B;

	B = Bot(Instigator.Controller);
	if ( B == None )
		return 0;

	if ( (Vehicle(B.Enemy) != None)
	     && (B.Enemy.bCanFly || B.Enemy.IsA('ONSHoverCraft')) && (FRand() < 0.3 + 0.1 * B.Skill) )
		return 1;
	else
		return 0;


    //if ( Instigator.Controller.Enemy == None )
		return 0;
	//if ( GameObjective(Instigator.Controller.Focus) != None )
	//	return 0;

	//if ( Instigator.Controller.bFire != 0 )
	//	return 0;
	//else if ( Instigator.Controller.bAltFire != 0 )
	//	return 1;
	//if ( FRand() < 0.65 )
	//	return 1;
	//return 0;
}
//=============================================================================
// defaultproperties
//=============================================================================

defaultproperties
{
     FireModeClass(0)=Class'CSAPVerIV.WeaponFire_FighterGunFire'
     FireModeClass(1)=Class'CSAPVerIV.WeaponFire_FighterMissileFire'
     AttachmentClass=Class'CSAPVerIV.WA_TestGun'
     ItemName="Guns"
}
