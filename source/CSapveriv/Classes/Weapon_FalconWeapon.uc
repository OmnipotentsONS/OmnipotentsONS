//=============================================================================
// Weapon_FalconWeapon
//=============================================================================
// Adapted from Laurent Delayen
// � 2003, Epic Games, Inc.  All Rights Reserved
//=============================================================================

class Weapon_FalconWeapon extends Weapon_Missiles;

//=============================================================================
// defaultproperties
//=============================================================================

defaultproperties
{
     FireModeClass(0)=Class'CSAPVerIV.WeaponFire_FalconFire'
     SmallViewOffset=(Z=-5.000000)
     PlayerViewOffset=(Z=-5.000000)
     AttachmentClass=Class'CSAPVerIV.WA_UTSpaceFighter'
     StaticMesh=StaticMesh'APVerIV_ST.FalconST.FalconCockpit'
}
