class HospitilarLinkGunBeamEffect extends LinkTBeamEffect;

simulated function SetBeamLocation()
{
	if ( Instigator == None || HospitilarLinkGunPawn(Instigator) == None )
    {
        super.SetBeamLocation();
		return;
    }
    StartEffect = LinkTWeapon(HospitilarLinkGunPawn(Instigator).Gun).GetFireStart(0);

	SetLocation( StartEffect );
}

simulated function vector SetBeamRotation()
{
	local vector	Start, HL, HN;
	local rotator rota;

    if ( Instigator != None )
	{
		Start = LinkTWeapon(HospitilarLinkGunPawn(Instigator).Gun).GetFireStart();
		LinkTWeapon(HospitilarLinkGunPawn(Instigator).Gun).SimulateTraceFire( start, rota, HL, HN );
		SetRotation( LinkTWeapon(HospitilarLinkGunPawn(Instigator).Gun).WeaponFireRotation );
        //SetRotation( Instigator.Rotation );
	}
    else
        SetRotation( Rotator(EndEffect - StartEffect) );

	return Normal( Vector(Rotation) );
}

defaultproperties
{
}
