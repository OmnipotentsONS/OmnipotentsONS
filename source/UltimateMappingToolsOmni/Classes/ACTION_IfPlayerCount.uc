//-----------------------------------------------------------------------------
// Action_IfPlayerCount
// $ckr1: Copyright 2011  by D. 'Crusha K. Rool' I.$
// $ckr2: <Mapping.Crocodile@googlemail.com>$
// $ckr3: Release date: 14.08.2011 00:13:11 in Package: UltimateMappingTools$
//
// Enters the following section only if at least a specific number of players
// is in the match.
//-----------------------------------------------------------------------------
class ACTION_IfPlayerCount extends ScriptedAction;

var() byte PlayerCount; // Triggers the Event when at least this much players are in the game.
var() bool bCountHumansOnly; // Bots are not considered in the PlayerCount.
var() bool bLessThanPlayerCount; // Only triggers if less than the specified PlayerCount is in the game.


function ProceedToNextAction(ScriptedController C)
{
    C.ActionNum += 1;
    if (bCountHumansOnly)
    {
        if ((bLessThanPlayerCount && C.Level.Game.NumPlayers < PlayerCount) ||
            (!bLessThanPlayerCount && C.Level.Game.NumPlayers >= PlayerCount))
            return;
    }
    else
    {
        if ((bLessThanPlayerCount && (C.Level.Game.NumPlayers + C.Level.Game.NumBots) < PlayerCount) ||
            (!bLessThanPlayerCount && (C.Level.Game.NumPlayers + C.Level.Game.NumBots) >= PlayerCount))
            return;
    }
    ProceedToSectionEnd(C);
}


function bool StartsSection()
{
    return true;
}

function string GetActionString()
{
    if (bLessThanPlayerCount)
    {
        return ActionString@"<"@PlayerCount;
    }
    else
    {
        return ActionString@">="@PlayerCount;
    }
}


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
     ActionString="If PlayerCount"
}
