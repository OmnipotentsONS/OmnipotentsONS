//-----------------------------------------------------------------------------
// LinksetupEventGate
// $ckr1: Copyright 2011  by D. 'Crusha K. Rool' I.$
// $ckr2: <Mapping.Crocodile@googlemail.com>$
// $ckr3: Release date: 14.08.2011 00:17:35 in Package: UltimateMappingTools$
//
// When being triggered, this will only trigger the next Event, if the current
// Linksetup matches one of the specified ones in the array.
//-----------------------------------------------------------------------------
class LinksetupEventGate extends EventGate;

var() array<String>  AllowedLinksetups ;
// Add names of Linksetups to this list. The next Event will only get (un)triggered
// when the current Linksetup is equal to one in this list.



// ============================================================================
// Initialisation
// ============================================================================
function BeginPlay()
{
    if (AllowedLinksetups.length <= 0)
        Log(name $ " - No entries in AllowedLinksetups, this Actor would be obsolete", 'Warning');

    if (ONSOnslaughtGame(Level.Game) == None)
        Log(name $ " - This Actor works only in Onslaught gametype", 'Warning');
}

// ============================================================================
function Trigger(Actor Other, Pawn EventInstigator)
{
    if (LinksetupCheck())
        TriggerEvent(Event, Other, EventInstigator);
}

function UnTrigger(Actor Other, Pawn EventInstigator)
{
    if (LinksetupCheck());
        UnTriggerEvent(Event, Other, EventInstigator);
}


function bool LinksetupCheck()
{
    local int i;

    for (i = 0; i < AllowedLinksetups.length; i++)
    {
        if (ONSOnslaughtGame(Level.Game) != None && ONSOnslaughtGame(Level.Game).CurrentSetupName ~= AllowedLinksetups[i])
            return True;
    }
    return False;
}

defaultproperties
{
}
