//=============================================================================
//  Link Tank
//=============================================================================
// )o(Nodrak - 13/11/05
//     Custom Tank Pack
//=============================================================================
class LinkTWeapon extends ONSweapon;

var LinkTW linkconfirming1;
var LinkTLinkFire linkconfirming2;
var LinkTBeamEffect linkconfirming3;
var LinkTankPlasma linkconfirming4;
var LinkTankAmmo linkconfirming5;
var LinkTAltFire linkconfirming6;
var LinkAttach linkconfirming7;

function name GetWeaponBoneFor(Inventory I)
{
	return '';
}

function byte BestMode()
{
	return 0;
}

/* return world location of crosshair's == vehicle's focus point */
simulated function vector GetCrosshairWorldLocation()
{
	return GetFireStart( 65536 );	// far focus point to ensure trace hit
}

/* Returns world location of vehicle fire start */
simulated function vector GetFireStart( optional float XOffset )
{
	CalcWeaponFire();
	return WeaponFireLocation;
}

simulated function ClientStopFire(Controller C, bool bWasAltFire)
{
          if (bWasAltFire &&  (LinkTankHospV3Omni(self.Owner).AmbientSound != none ))
          {
          LinkTankHospV3Omni(self.Owner).setsounds();
          }
          super.ClientStopFire( C,  bWasAltFire);

}

function AttachMuzzleFlash ( xEmitter FlashEmitterX )
{
         AttachToBone( FlashEmitterX, WeaponFireAttachmentBone );
         //FlashEmitterX.bHardAttach = true;
         //FlashEmitterX.SetBase( self );
         log("attactching " @ FlashEmitterX @ "to bone " @ WeaponFireAttachmentBone );

}

state InstantFireMode
{

	function Fire(Controller C)
	{

	}

	function AltFire(Controller C)
	{

	}

}

simulated function UpdateLinkColor( LinkAttachment.ELinkColor color )
{
	switch ( Color )
	{
		case LC_Gold	:	Skins[2] = material'PowerPulseShaderYellow';	break;
		case LC_Green	:	Skins[2] = material'PowerPulseShader';			break;
		case LC_Red		: 	Skins[2] = material'PowerPulseShaderRed';		break;
		case LC_Blue	: 	Skins[2] = material'PowerPulseShaderBlue';		break;
	}
	Skins[0] = Combiner'AS_Weapons_TX.LinkTurret.LinkTurret_Skin2_C';
}

defaultproperties
{
     YawBone="Object02"
     PitchBone="Object02"
     PitchUpLimit=8000
     PitchDownLimit=62000
     WeaponFireAttachmentBone="Muzzle"
     WeaponFireOffset=20.000000
     RotationsPerSecond=0.500000
     bInstantFire=True
     bShowChargingBar=True
     bDoOffsetTrace=True
     FireInterval=0.350000
     AltFireInterval=0.120000
     FireForce="PRVRearFire"
     DamageMin=15
     DamageMax=15
     AIInfo(0)=(bLeadTarget=True,RefireRate=0.400000)
     Mesh=SkeletalMesh'ANIM_TTanks1b.LinkBody'
     DrawScale=0.300000
     Skins(0)=Combiner'AS_Weapons_TX.LinkTurret.LinkTurret_Skin2_C'
     Skins(1)=Combiner'AS_Weapons_TX.LinkTurret.LinkTurret_Skin1_C'
}
