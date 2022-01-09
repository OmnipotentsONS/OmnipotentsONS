class CSLinkMechLinkBeamEffect extends LinkBeamEffect;

simulated function SetBeamLocation()
{
	if ( (Instigator == None) || (ONSVehicle(Instigator) == None) || (ONSVehicle(Instigator).Weapons.Length <= 0) )
    {
        //super.SetBeamLocation();
        //StartEffect = Location;
		return;
    }

    StartEffect = ONSVehicle(Instigator).Weapons[0].WeaponFireLocation;
//    if (Role == ROLE_Authority)
//    	RepStartEffect = StartEffect;

	SetLocation( StartEffect );
}

simulated function vector SetBeamRotation()
{
	SetRotation( Rotator(EndEffect - StartEffect) );

	return Normal( Vector(Rotation) );
}

defaultproperties
{
     //mSizeRange(0)=30.000000
     mSizeRange(0)=120.000000
     bAlwaysRelevant=True
}