//=============================================================================
// WA_FighterMissileAttachment
//=============================================================================
// Created by Laurent Delayen
// © 2003, Epic Games, Inc.  All Rights Reserved
//=============================================================================

class WA_RoboIonAttachment extends xWeaponAttachment;


simulated event ThirdPersonEffects()
{

    super.ThirdPersonEffects();
}


simulated function MuzzleFlashEffect( int number, float fSide )
{

}



simulated function vector GetFireStart( float fSide )
{

}


//=============================================================================
// defaultproperties
//=============================================================================

defaultproperties
{
     bHidden=True
     Mesh=SkeletalMesh'Weapons.LinkGun_3rd'
}
