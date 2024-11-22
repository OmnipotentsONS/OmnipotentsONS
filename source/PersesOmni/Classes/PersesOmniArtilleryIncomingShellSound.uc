

class PersesOmniArtilleryIncomingShellSound extends ONSIncomingShellSound;


// exec audio import file=UT3SPMA.uax


function StartTimer(float TimeToImpact)
{
	if (TimeToImpact > SoundLength)
		SetTimer(TimeToImpact - SoundLength, false);
	else
		Destroy();
}


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
     SoundLength=3.500000
     ShellSound=Sound'UT3SPMA.SPMAShellIncoming'
}
