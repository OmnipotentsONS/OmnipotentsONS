//-----------------------------------------------------------------------------
// ScoreCheck
// $ckr1: Copyright 2011  by D. 'Crusha K. Rool' I.$
// $ckr2: <Mapping.Crocodile@googlemail.com>$
// $ckr3: Release date: 15.08.2011 00:44:56 in Package: UltimateMappingTools$
//
// Checks whether the Score of the chosen team is equal or above the specified
// value and will trigger an Event in that case. The Score itself won't be changed.
// It will untrigger it if the Score falls below the specified value again.
// If in bEventGate mode, this will only check the Score when being (un)triggered to
// determine if it should (un)trigger the next event.
//-----------------------------------------------------------------------------
class ScoreCheck extends EventGate
    placeable;

/* Public */
var() edfindable ScoreContainer TargetContainer ; // Check the score in this Container.
var()  byte TeamNum ;    // Check this team's Score in the Container.
var()  int  ScoreLimit ; // Trigger if the Score is above this value.
var()  bool bEventGate ; // Don't check automatically but only when getting (un)triggered
                         // and (un)trigger the next Event if enough credit is available.

var(Events) name BelowScoreLimitEvent ;
// Will be triggered if not enough points are available on the team's account in case that bEventGate = True.


/* Intern */
var  bool bHasTriggeredAlready ;

// ============================================================================
// Initialisation
// ============================================================================
event BeginPlay()
{
    if (TargetContainer == None)
        Log(name $ " - No TargetContainer specified", 'Warning');
    if (ScoreLimit < 0)
        Log(name $ " - ScoreLimit < 0, this case can't happen", 'Warning');
    if (TeamNum > 1)
        Log(name $ " - Invalid TeamNum", 'Warning');
}

event SetInitialState()
{
    if (!bEventGate)
    {
        if (TeamNum == 0)
            GotoState('CheckRedScore');
        else
            GotoState('CheckBlueScore');
    }
    else
        GotoState('EventGate');
}

// ============================================================================

state CheckRedScore
{
    event Tick(float DeltaTime)
    {
        if (TargetContainer != None)
        {
            if (TargetContainer.RedTeamScore >= ScoreLimit)
            {
                if (!bHasTriggeredAlready)
                    TriggerEvent(Event, self, None);
                    bHasTriggeredAlready = True;
            }
            else
            {
                if (bHasTriggeredAlready)
                    UnTriggerEvent(Event, self, None);
                    bHasTriggeredAlready = False;
            }
        }
    }
}


state CheckBlueScore
{
    event Tick(float DeltaTime)
    {
        if (TargetContainer != None)
        {
            if (TargetContainer.BlueTeamScore >= ScoreLimit)
            {
                if (!bHasTriggeredAlready)
                {
                    TriggerEvent(Event, self, None);
                    bHasTriggeredAlready = True;
                }
            }
            else
            {
                if (bHasTriggeredAlready)
                {
                    UnTriggerEvent(Event, self, None);
                    bHasTriggeredAlready = False;
                }
            }
        }
    }
}

state EventGate
{
    event Trigger(Actor Other, Pawn EventInstigator)
    {
        if (TeamNum == 0)
        {
            if (TargetContainer != None)
            {
                if (TargetContainer.RedTeamScore >= ScoreLimit)
                {
                    TriggerEvent(Event, self, None);
                }
                else
                {
                    TriggerEvent(BelowScoreLimitEvent, self, None);
                }
            }

        }
        else
        {
            if (TargetContainer != None)
            {
                if (TargetContainer.BlueTeamScore >= ScoreLimit)
                {
                    TriggerEvent(Event, self, None);
                }
                else
                {
                    TriggerEvent(BelowScoreLimitEvent, self, None);
                }
            }
        }
    }

    event UnTrigger(Actor Other, Pawn EvenInstigator)
    {
        if (TeamNum == 0)
        {
            if (TargetContainer != None)
            {
                if (TargetContainer.RedTeamScore >= ScoreLimit)
                {
                    UnTriggerEvent(Event, self, None);
                }
                else
                {
                    UnTriggerEvent(BelowScoreLimitEvent, self, None);
                }
            }

        }
        else
        {
            if (TargetContainer != None)
            {
                if (TargetContainer.BlueTeamScore >= ScoreLimit)
                {
                    UnTriggerEvent(Event, self, None);
                }
                else
                {
                    UnTriggerEvent(BelowScoreLimitEvent, self, None);
                }
            }
        }
    }
}

// ============================================================================

function Reset()
{
    if (ONSOnslaughtGame(Level.Game) != None && ONSOnslaughtGame(Level.Game).bSwapSidesAfterReset)
    {
        TeamNum = abs(TeamNum-1);
        SetInitialState();
    }
}

defaultproperties
{
     Texture=Texture'UltimateMappingTools_Tex.Icons.ScoreCheck_Icon'
}
