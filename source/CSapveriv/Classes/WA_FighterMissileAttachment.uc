//=============================================================================
// WA_FighterMissileAttachment
//=============================================================================
// Created by Laurent Delayen
// © 2003, Epic Games, Inc.  All Rights Reserved
//=============================================================================

class WA_FighterMissileAttachment extends xWeaponAttachment;

var	bool						bSwitch;
var float	LastFireTime;



simulated event ThirdPersonEffects()
{
	bSwitch = ( (FlashCount % 2) == 1 );
    if ( Level.NetMode != NM_DedicatedServer && Instigator != None && FlashCount > 0 )
	{

        // have pawn play firing anim
		if ( Instigator != None && FiringMode == 0 && FlashCount > 0 )
		{
			if ( bSwitch )
				Instigator.PlayFiring(1.0, '1');
			else
				Instigator.PlayFiring(1.0, '0');
		}
    }
    super.ThirdPersonEffects();
}


simulated function MuzzleFlashEffect( int number, float fSide )
{
	local vector					Start;
	Start = GetFireStart( fSide );
	PlayFireFX( fSide );
}

simulated function PlayFireFX( float fSide )
{
	local vector					Start, HL, HN;
	local Actor						HitActor;
	if ( Instigator != None && AirPower_Vehicle(Instigator) != None )
	{
		Start = GetFireStart( fSide );
		HitActor = AirPower_Fighter(Instigator).CalcWeaponFire( HL, HN );
	}
}

simulated function vector GetFireStart( float fSide )
{
	local vector	X, Y, Z, MuzzleSpawnOffset;
    local bool bleft;
	if ( Instigator != None && AirPower_Fighter(Instigator) != None )
	   {
        if (bLeft)
		  {
		   MuzzleSpawnOffset = AirPower_Fighter(Instigator).VehicleProjSpawnOffsetLeft;
           bleft=false;
          }
        else
          {
           MuzzleSpawnOffset = AirPower_Fighter(Instigator).VehicleProjSpawnOffsetRight;
           bleft=true;
          }
        }
	GetAxes( Instigator.Rotation, X, Y, Z );
    return Instigator.Location + X*MuzzleSpawnOffset.X + fSide*Y*MuzzleSpawnOffset.Y + Z*MuzzleSpawnOffset.Z;
}


//=============================================================================
// defaultproperties
//=============================================================================

defaultproperties
{
     bRapidFire=True
     bAltRapidFire=True
     bHidden=True
     Mesh=SkeletalMesh'Weapons.LinkGun_3rd'
     AmbientGlow=128
}
