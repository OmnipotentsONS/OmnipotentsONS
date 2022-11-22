//-----------------------------------------------------------------------------
// Action_IfInstigatorTeam
// $ckr1: Copyright 2011  by D. 'Crusha K. Rool' I.$
// $ckr2: <Mapping.Crocodile@googlemail.com>$
// $ckr3: Release date: 14.08.2011 00:13:00 in Package: UltimateMappingTools$
//
// Enters the following section only if at least a specific number of players
// is in the match.
//-----------------------------------------------------------------------------
class ACTION_IfInstigatorTeam extends ScriptedAction;

var() byte TeamNum;


function ProceedToNextAction(ScriptedController C)
{
    local Pawn ActionInstigator;

    C.ActionNum += 1;
    ActionInstigator = C.GetInstigator();

    if (ActionInstigator != None && ActionInstigator.PlayerReplicationInfo != None &&
        ActionInstigator.PlayerReplicationInfo.Team != None)
    {
        if (ActionInstigator.PlayerReplicationInfo.Team.TeamIndex != TeamNum)
            ProceedToSectionEnd(C);
    }
}


function bool StartsSection()
{
    return true;
}

function string GetActionString()
{
    return ActionString@TeamNum;
}


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
     ActionString="If Instigator TeamNum"
}
