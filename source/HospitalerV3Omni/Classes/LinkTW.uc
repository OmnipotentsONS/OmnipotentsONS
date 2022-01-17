//=============================================================================
//  Link Tank
//=============================================================================
// )o(Nodrak - 13/11/05
//     Custom Tank Pack
//=============================================================================
class LinkTW extends Weapon_LinkTurret;

#exec OBJ LOAD FILE=..\Animations\AS_VehiclesFull_M.ukx

function byte BestMode()
{
	return 0;
}

simulated function UpdateLinkColor( LinkAttachment.ELinkColor Color )
{
	if ( FireMode[1] != None )
		LinkFire(FireMode[1]).UpdateLinkColor( Color );

	switch ( Color )
	{
		case LC_Gold	:	Skins[2] = material'PowerPulseShaderYellow';	break;
		case LC_Green	:	Skins[2] = material'PowerPulseShader';			break;
		case LC_Red		: 	Skins[2] = material'PowerPulseShaderRed';		break;
		case LC_Blue	: 	Skins[2] = material'PowerPulseShaderBlue';		break;
	}
	Skins[0] = Combiner'AS_Weapons_TX.LinkTurret.LinkTurret_Skin1_C';
}

simulated function vector GetEffectStart()
{
    return LinkTWeapon(LinkTankHospV3Omni(Instigator).Weapons[0]).GetFireStart();
    //ONSVehicle(Instigator).Weapons[0].CalcWeaponFire();
	//return ONSVehicle(Instigator).Weapons[0].WeaponFireLocation;
}

simulated function IncrementFlashCount(int mode)
{
    super(Weapon).IncrementFlashCount( mode );

	if ( ThirdPersonActor != None && LinkAttachment(ThirdPersonActor) != None )
        LinkAttachment(ThirdPersonActor).Links = Links;
}

simulated function PawnUnpossessed()
{
	if ( Instigator != None && PlayerController(Instigator.Controller) != None )
		PlayerController(Instigator.Controller).DesiredFOV = PlayerController(Instigator.Controller).DefaultFOV;

	// If was linking to somebody, unlink...
	if ( ThirdPersonActor != None && LinkAttachment(ThirdPersonActor).LinkColor != LC_Gold )
		LinkAttachment(ThirdPersonActor).SetLinkColor( LC_Green );

	super.PawnUnpossessed();
}

//=============================================================================
// defaultproperties
//=============================================================================

defaultproperties
{
     FireModeClass(0)=Class'HospitalerV3Omni.LinkTLinkFire'
     FireModeClass(1)=Class'HospitalerV3Omni.LinkTAltFire'
     OldPickup="none"
     AttachmentClass=Class'HospitalerV3Omni.LinkAttach'
}
