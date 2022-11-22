//-----------------------------------------------------------------------------
// ScoreSubtract
// $ckr1: Copyright 2011  by D. 'Crusha K. Rool' I.$
// $ckr2: <Mapping.Crocodile@googlemail.com>$
// $ckr3: Release date: 15.08.2011 00:45:32 in Package: UltimateMappingTools$
//
// Subtracts a fixed value from a team's score in the Target-ScoreContainer when triggered.
// It will then trigger an event if the had enough "credit" on it's account.
// Negative values in the ScoreContainer are not possible.
//-----------------------------------------------------------------------------
class ScoreSubtract extends EventGate
    placeable;

var()  int  SubtractValue ; // How much to subtract on each triggering.
var()  byte TeamNum ;       // Subtract the score from which team's account?  0= Red; 1= Blue;
                            // The teams are automatically switched if necessary.

var()  byte TeamNumCanTrigger ;
// If set to something else than 255, this will only be activated if the Instigator's TeamNum
// matches the number that is specified here, so that the enemy can't do things with your score.
// The success of this depends on whether the trigger-chain reaction passes the
// information about the Instigator, if an Instigator exists.


var(Events) name NotEnoughPointsEvent ;
// Will be triggered if not enough points are available on the team's account.

var() edfindable ScoreContainer TargetContainer ;
// Subtract the score from the account in this container.


// ============================================================================
// Initialisation
// ============================================================================
event BeginPlay()
{
    if (TargetContainer == None)
        Log(name $ " - No TargetContainer specified", 'Warning');
    if (SubtractValue == 0)
        Log(name $ " - SubtractValue = 0, this actor would be obsolete", 'Warning');
    if (TeamNum > 1)
        Log(name $ " - Invalid TeamNum", 'Warning');
}


// ============================================================================
event Trigger(Actor Other, Pawn EventInstigator)
{
    if (TargetContainer != None)
    {
        if (TeamNumCanTrigger == 255 || (TeamNumCanTrigger != 255 && (EventInstigator == None || EventInstigator.Controller.GetTeamNum() == TeamNumCanTrigger)))
        {
            if (TeamNum == 1)
            {
                if (TargetContainer.BlueTeamScore - SubtractValue >= 0)
                {
                    TargetContainer.BlueTeamScore -= SubtractValue;
                    TriggerEvent(event, self, EventInstigator);
                }
                else
                    TriggerEvent(NotEnoughPointsEvent, self, EventInstigator);
            }
            else if (TargetContainer.RedTeamScore - SubtractValue >= 0)
            {
                TargetContainer.RedTeamScore -= SubtractValue;
                TriggerEvent(event, self, EventInstigator);
            }
            else
                TriggerEvent(NotEnoughPointsEvent, self, EventInstigator);
        }
    }
}


// ============================================================================
// Reset on new round, change teams if necessary
// ============================================================================
function Reset()
{
    if (ONSOnslaughtGame(Level.Game) != None &&
        ONSOnslaughtGame(Level.Game).bSwapSidesAfterReset)
    {
        TeamNum = abs(TeamNum-1);
        if (TeamNumCanTrigger != 255)
            TeamNumCanTrigger = abs(TeamNum-1);
    }

}

// ============================================================================
// Default Values
// ============================================================================

defaultproperties
{
     SubtractValue=50
     TeamNumCanTrigger=255
     Texture=Texture'UltimateMappingTools_Tex.Icons.ScoreSubtract_Icon'
}
