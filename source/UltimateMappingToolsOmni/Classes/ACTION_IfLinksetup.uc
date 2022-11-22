//-----------------------------------------------------------------------------
// Action_IfLinksetup
// $ckr1: Copyright 2011  by D. 'Crusha K. Rool' I.$
// $ckr2: <Mapping.Crocodile@googlemail.com>$
// $ckr3: Release date: 14.08.2011 00:13:06 in Package: UltimateMappingTools$
//
// Enters the following section only if the linksetup is specified in the array
// and this is an ONS map.
//-----------------------------------------------------------------------------
class ACTION_IfLinksetup extends ScriptedAction;


var() array<String>  AllowedLinksetups ;
// Add names of Linksetups to this list. The next Event will only get (un)triggered
// when the current Linksetup is equal to one in this list.


event PostBeginPlay( ScriptedSequence SS )
{
    if (AllowedLinksetups.length <= 0)
        Log(name $ " - No entries in AllowedLinksetups, this Action would be obsolete", 'Warning');

    if (ONSOnslaughtGame(SS.Level.Game) == None)
        Log(name $ " - This works only in Onslaught gametype", 'Warning');
}


function ProceedToNextAction(ScriptedController C)
{
    C.ActionNum += 1;
    if (LinksetupCheck(C))
        return;
    ProceedToSectionEnd(C);
}


function bool StartsSection()
{
    return true;
}


function bool LinksetupCheck(ScriptedController C)
{
    local int i;

    for (i = 0; i < AllowedLinksetups.length; i++)
    {
        if (ONSOnslaughtGame(C.Level.Game) != None && ONSOnslaughtGame(C.Level.Game).CurrentSetupName ~= AllowedLinksetups[i])
            return True;
    }
    return False;
}


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
     ActionString="If Linksetup Is Active"
}
