//-----------------------------------------------------------------------------
// ScoreAdd
// $ckr1: Copyright 2011  by D. 'Crusha K. Rool' I.$
// $ckr2: <Mapping.Crocodile@googlemail.com>$
// $ckr3: Release date: 15.08.2011 00:44:40 in Package: UltimateMappingTools$
//
// Adds a fixed value to a team's score in the Target-ScoreContainer when triggered.
// Remember that the maximum value for the ScoreContainer is 2.147.483.647
//
// Don't worry, if you'd increase a ScoreContainer-value of around 0 by 10000 per
// second, then you would still need 2 days 11 hours 39 minutes 8 seconds to exceed
// the maximum. ;)
//-----------------------------------------------------------------------------
class ScoreAdd extends EventGate
    placeable;

var()  int  AddValue ;  // How much to add on each triggering.
var()  byte TeamNum ;   // Add the score to which team's account?  0= Red; 1= Blue
                        // The teams are automatically switched if necessary.

var()  byte TeamNumCanTrigger ;
// If set to something else than 255, this will only be activated if the Instigator's TeamNum
// matches the number that is specified here, so that the enemy can't do things with your score.
// The success of this depends on whether the trigger-chain reaction passes the
// information about the Instigator, if an Instigator exists.


var() edfindable ScoreContainer TargetContainer ;
// Add the score to the account in this container.


var() float  LoopTime ;
// If greater than 0, this will add the AddValue every time when this much time has passed.
// This is enabled on triggering and disabled on untriggering then.
// Take in mind that if TeamNumCanTrigger is set to something different from 255,
// this can also only be untriggered by a member of it's own team.



/* Intern */
var   float  PassedTime ;


// ============================================================================
// Initialisation
// ============================================================================
event BeginPlay()
{
    if (TargetContainer == None)
        Log(name $ " - No TargetContainer specified", 'Warning');
    if (AddValue == 0)
        Log(name $ " - AddValue = 0, this actor would be obsolete", 'Warning');
    if (TeamNum > 1)
        Log(name $ " - Invalid TeamNum", 'Warning');
}

event PostBeginPlay()
{
    if (LoopTime <= 0)
        Disable('Tick');
}


// ============================================================================
event Trigger(Actor Other, Pawn EventInstigator)
{
    if (TargetContainer != None)
    {
        if (TeamNumCanTrigger == 255 || (TeamNumCanTrigger != 255 && (EventInstigator == None || EventInstigator.Controller.GetTeamNum() == TeamNumCanTrigger)))
        {
            if (TeamNum == 1)
                TargetContainer.BlueTeamScore += AddValue;
            else
                TargetContainer.RedTeamScore += AddValue;

            if (LoopTime > 0)
                Enable('Tick');
        }
    }
}

event Untrigger(Actor Other, Pawn EventInstigator)
{
    if (TeamNumCanTrigger == 255 || (TeamNumCanTrigger != 255 && (EventInstigator == None || EventInstigator.Controller.GetTeamNum() == TeamNumCanTrigger)))
        Disable('Tick');
}


event Tick(float DeltaTime)
{
    PassedTime += DeltaTime;

    if (PassedTime >= LoopTime)
    {
        PassedTime -= LoopTime;
        if (TargetContainer != None)
        {
            if (TeamNum == 1)
                TargetContainer.BlueTeamScore += AddValue;
            else
                TargetContainer.RedTeamScore += AddValue;
        }
    }
}


// ============================================================================
// Reset on new round
// ============================================================================
function Reset()
{
    if (ONSOnslaughtGame(Level.Game) != None &&
        ONSOnslaughtGame(Level.Game).bSwapSidesAfterReset)
        TeamNum = abs(TeamNum-1);

}

// ============================================================================
// Default Values
// ============================================================================

defaultproperties
{
     AddValue=50
     TeamNumCanTrigger=255
     Texture=Texture'UltimateMappingTools_Tex.Icons.ScoreAdd_Icon'
}
