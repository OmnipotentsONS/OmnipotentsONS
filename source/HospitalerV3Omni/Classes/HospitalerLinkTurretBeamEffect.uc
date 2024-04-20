// ============================================================================
// Link Tank beam effect.
// ============================================================================

class HospitalerLinkTurretBeamEffect extends LinkBeamEffect
	notplaceable;


simulated function SetBeamLocation()
{
	if ( Instigator == None || HospitalerLinkTurretPawn(Instigator) == None )
    {
        super.SetBeamLocation();
		return;
    }
   StartEffect = HospitalerLinkTurret(HospitalerLinkTurretPawn(Instigator).Gun).WeaponFireLocation;
   //StartEffect = WeaponFireLocation;

	SetLocation( StartEffect );
}

simulated function Vector SetBeamRotation()
{
    if ( (Instigator != None) && PlayerController(Instigator.Controller) != None )
        SetRotation( HospitalerLinkTurret(HospitalerLinkTurretPawn(Instigator).Gun).WeaponFireRotation);
    else
        SetRotation( HospitalerLinkTurret(HospitalerLinkTurretPawn(Instigator).Gun).WeaponFireRotation );
	//LOG("EndEffectBeam:"$EndEffect);
	 mSpawnVecA = EndEffect;
	return Normal(EndEffect - Location);
}

simulated function  SetBeamSize(int NumLinks)
{
	mSizeRange[0] = default.mSizeRange[0] * (NumLinks*0.6 + 1);
	mWaveShift = default.mWaveShift * (NumLinks*0.6 + 1);
}



defaultproperties
{
     mSizeRange(0)=20.000000
     /* Defaults from LinkBeamEffect
     mRegenDist=65.000000
     mSpinRange(0)=45000.000000
     mSizeRange(0)=11.000000
     mColorRange(0)=(B=240,G=240,R=240)
     mColorRange(1)=(B=240,G=240,R=240)
     mAttenuate=False
     mAttenKa=0.000000
     mWaveFrequency=0.060000
     mWaveAmplitude=8.000000
     mWaveShift=100000.000000
     */
     
     bAlwaysRelevant=True
}
