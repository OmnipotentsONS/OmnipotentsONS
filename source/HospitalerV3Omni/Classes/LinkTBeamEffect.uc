//=============================================================================
//  Link Tank
//=============================================================================
// )o(Nodrak - 13/11/05
//     Custom Tank Pack
//=============================================================================
class LinkTBeamEffect extends LinkBeamEffect
	notplaceable;


simulated function SetBeamLocation()
{
	if ( Instigator == None || LinkTankHospV3Omni(Instigator) == None )
    {
        super.SetBeamLocation();
		return;
    }
    StartEffect = LinkTWeapon(LinkTankHospV3Omni(Instigator).Weapons[0]).GetFireStart(0);

	SetLocation( StartEffect );
}

simulated function vector SetBeamRotation()
{
	local vector	Start, HL, HN;
	local rotator rota;

    if ( Instigator != None )
	{
		Start = LinkTWeapon(LinkTankHospV3Omni(Instigator).Weapons[0]).GetFireStart();
		LinkTWeapon(LinkTankHospV3Omni(Instigator).Weapons[0]).SimulateTraceFire( start, rota, HL, HN );
		SetRotation( LinkTWeapon(LinkTankHospV3Omni(Instigator).Weapons[0]).WeaponFireRotation );
        //SetRotation( Instigator.Rotation );
	}
    else
        SetRotation( Rotator(EndEffect - StartEffect) );

	return Normal( Vector(Rotation) );
}

defaultproperties
{
     mSizeRange(0)=20.000000
}
