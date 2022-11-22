//-----------------------------------------------------------------------------
// PlayerCountTrigger
// $ckr1: Copyright 2011  by D. 'Crusha K. Rool' I.$
// $ckr2: <Mapping.Crocodile@googlemail.com>$
// $ckr3: Release date: 13.10.2011 16:03:37 in Package: UltimateMappingTools$
//
// Triggers an Event when at least so many players are in the game as specified here.
// Untriggers it when the PlayerCount shrinks below the specified amount.
//
// Hint: Use a LogicalNOT to make this thing work in the other direction,
// so that it triggers if less than x players are in the game.
//-----------------------------------------------------------------------------
class PlayerCountTrigger extends Triggers;

var() byte PlayerCount;      // Triggers the Event when at least this much players are in the game.
var() bool bCountHumansOnly; // Bots are not considered in the PlayerCount.


var bool bHasTriggeredAlready;

function SetInitialState()
{
    if (bCountHumansOnly)
        GotoState('HumansOnly');
    else
        GotoState('HumansAndBots');
}

//=============================================================================
state HumansOnly
{
    event Tick(float DeltaTime)
    {
        if (!bHasTriggeredAlready && Level.Game.NumPlayers >= PlayerCount)
        {
            TriggerEvent(Event, self, None);
            bHasTriggeredAlready = True;
        }
        else if (bHasTriggeredAlready && Level.Game.NumPlayers < PlayerCount)
        {
            UnTriggerEvent(Event, self, None);
            bHasTriggeredAlready = False;
        }
    }
}

state HumansAndBots
{
    event Tick(float DeltaTime)
    {
        if (!bHasTriggeredAlready && (Level.Game.NumPlayers + Level.Game.NumBots) >= PlayerCount)
        {
            TriggerEvent(Event, self, None);
            bHasTriggeredAlready = True;
        }
        else if (bHasTriggeredAlready && (Level.Game.NumPlayers + Level.Game.NumBots) < PlayerCount)
        {
            UnTriggerEvent(Event, self, None);
            bHasTriggeredAlready = False;
        }
    }
}

//=============================================================================
// Reset on new round
//=============================================================================
function Reset()
{
    bHasTriggeredAlready = False;
    UnTriggerEvent(Event, self, None);
}

//=============================================================================
// Default Values
//=============================================================================

defaultproperties
{
     PlayerCount=16
     bCollideActors=False
}
