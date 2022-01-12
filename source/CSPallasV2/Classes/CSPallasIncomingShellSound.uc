class CSPallasIncomingShellSound extends ONSIncomingShellSound;
#exec AUDIO IMPORT FILE=Sounds\CSPallasShellIncoming.wav

function Timer()
{
    PlaySound(ShellSound, SLOT_None, 4.0, false, 2000.0);
	Destroy();
}

defaultproperties
{
     ShellSound=Sound'CSPallasV2.CSPallasShellIncoming'
}
