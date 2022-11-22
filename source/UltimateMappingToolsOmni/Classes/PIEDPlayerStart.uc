//=============================================================================
// PlayInEditorPlayerStart
//
// $ckr1: Copyright 2011  by D. 'Crusha K. Rool' I.$
// $ckr2: <Mapping.Crocodile@googlemail.com>$
// $ckr3: Release date: 13.10.2011 21:56:30 in Package: UltimateMappingTools$
//
// Placing one of these in the map will force the player to spawn at it,
// disabling all other PlayerStarts in the meanwhile. That way can you quickly
// check a certain position ingame during mapping without needing to walk there
// from the regular startpoints all the time.
// Just make sure to remove this when you are done.
//=============================================================================
class PIEDPlayerStart extends PlayerStart;

event PreBeginPlay()
{
    local PlayerStart P;

    if (!bEnabled)
        return;

    log("PlayInEditorPlayerStart is active!", 'warning');

    foreach AllActors(class'PlayerStart', P)
    {
        if (P != self)
        {
            // Make it as least attractive as possible.
            P.bEnabled = False;
            P.bPrimaryStart = False;
            P.TeamNumber = 255;
        }
    }
}

// For ONS.
event SetInitialState()
{
    local ONSPowerCore OPC;
    local int i;

    if (!bEnabled)
        return;

    if (ONSOnslaughtGame(Level.Game) != None)
    {
        foreach AllActors(class'ONSPowerCore', OPC)
        {
            for (i = 0; i < OPC.CloseActors.Length; i++)
            {
                if (PlayerStart(OPC.CloseActors[i]) != None)
                {
                    OPC.CloseActors.Remove(i, 1);
                }
            }

            OPC.CloseActors[OPC.CloseActors.Length] = self;
        }
    }
}

defaultproperties
{
}
