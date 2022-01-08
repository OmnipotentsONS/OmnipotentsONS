//=============================================================================
// Weapon_FighterGuns
// for Firing Gun Proj and Homming Missiles
//=============================================================================
// Adapted from Laurent Delayen
// � 2003, Epic Games, Inc.  All Rights Reserved
//=============================================================================

class Weapon_PhantomGuns extends Weapon_Missiles;

#exec OBJ LOAD FILE=..\StaticMeshes\AS_Vehicles_SM.usx
#exec OBJ LOAD FILE=..\Sounds\IndoorAmbience.uax



//=============================================================================
// defaultproperties
//=============================================================================

defaultproperties
{
     FireModeClass(0)=Class'CSAPVerIV.WeaponFire_FighterGunFire'
     FireModeClass(1)=Class'CSAPVerIV.WeaponFire_FighterMissileFire'
     AIRating=0.680000
     CurrentRating=0.680000
     Priority=5
     SmallViewOffset=(X=15.000000,Z=-60.000000)
     InventoryGroup=4
     PlayerViewOffset=(X=15.000000,Z=-60.000000)
     AttachmentClass=Class'CSAPVerIV.WA_UTSpaceFighter'
     ItemName="Guns And Missiles"
     StaticMesh=StaticMesh'APVerIV_ST.Phantom_ST.Phant_Cockpit'
     DrawScale3D=(Z=1.000000)
}
