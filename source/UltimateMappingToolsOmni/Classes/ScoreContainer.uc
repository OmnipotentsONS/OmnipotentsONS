//-----------------------------------------------------------------------------
// ScoreContainer
// $ckr1: Copyright 2011  by D. 'Crusha K. Rool' I.$
// $ckr2: <Mapping.Crocodile@googlemail.com>$
// $ckr3: Release date: 16.08.2011 19:47:54 in Package: UltimateMappingTools$
// Big thanks to INIQUITOUS who helped me to fix this thing.
//
// Stores the information about each team's score. (Max: 2.147.483.647; Min: 0)
// You should place only one of this in a map.
//-----------------------------------------------------------------------------
class ScoreContainer extends EventGate
    placeable;

/* Public */

var()  int   InitialScoreRed ;
var()  int   InitialScoreBlue ;
/* The score that is on the team's account at the beginning of a round.
 * Red and Blue means the sides in the first round. The values are swapped automatically
 * when the server has the setting to switch teams after reset, so that the chances
 * are equal for both teams.
 */

var()  bool  bDisplayScoreInHUD ;
// Display the current score of a team to that team. The enemy's score will not be visible.

var()  int ScoreFontSize ;
// The size of the used font for the score.

var() localized string RedScoreString ;
var() localized string BlueScoreString ;

/* The message to display with the score.
 * Red and Blue are changed on Reset, if necessary.
 * The %s character will be replaced with the actual representation of the score.
 */

var() float RedScorePosX ;
var() float RedScorePosY ;
var() float BlueScorePosX ;
var() float BlueScorePosY ;
var() float SpectatorScorePosX ;
var() float SpectatorScorePosY ;
/* The relative location of the screen coordinates where the message should appear in the HUD.
 * Enter values between 0 and 1;
 * 0 is the top left corner, 1 the bottom right.
 * There is one for each team so that you can adjust the position a bit in case that a message doesn't fit the screen properly.
 * It is possible to enter absolute values, but it's not recommend as those won't
 * consider the player's resolution and will look bad in most cases.
 * Spectators will see both strings below each other, starting at the defined position.
 */



/* Intern */
var   int  RedTeamScore, BlueTeamScore ;

//-----------------------------------------------------------------------------
replication
{
    reliable if (bNetDirty && (Role==ROLE_Authority))
        RedTeamScore, BlueTeamScore;
}


//=============================================================================
// Initialisation
//=============================================================================
event PostBeginPlay()
{
    RedTeamScore = InitialScoreRed;
    BlueTeamScore = InitialScoreBlue;

    if (bDisplayScoreInHUD || Level.NetMode != NM_DedicatedServer) // don't spawn the overlay on dedicated servers
        Enable ('Tick');
    else
        Disable ('Tick');
}

//=============================================================================
simulated event Tick(float DeltaTime)
{
    local PlayerController  PC;
    local ScoreContainerHUDOverlay Overlay;
    PC = Level.GetLocalPlayerController();

    if (PC != None)
    {
        Overlay = Spawn(class'ScoreContainerHUDOverlay');
        if (Overlay != None)
        {
            PC.myHUD.AddHudOverlay(Overlay);
            Overlay.PCOwner = PC;
            Overlay.ScoreFontSize = ScoreFontSize ;
            Overlay.RedPosX = RedScorePosX ;
            Overlay.RedPosY = RedScorePosY ;
            Overlay.BluePosX = BlueScorePosX ;
            Overlay.BluePosY = BlueScorePosY ;
            Overlay.SpectatorPosX = SpectatorScorePosX ;
            Overlay.SpectatorPosY = SpectatorScorePosY ;
            Overlay.ParentScoreContainer = self;
        }
        Disable('Tick');
    }
}

//=============================================================================
// Reset on new round
//=============================================================================
function Reset()
{
    if (ONSOnslaughtGame(Level.Game) != None &&
        ONSOnslaughtGame(Level.Game).bSwapSidesAfterReset &&
        !ONSOnslaughtGame(Level.Game).bSidesAreSwitched) // This value changes AFTER Reset, so think the other direction
    {
        RedTeamScore = InitialScoreBlue;
        BlueTeamScore = InitialScoreRed;
    }
    else
    {
        RedTeamScore = InitialScoreRed;
        BlueTeamScore = InitialScoreBlue;
    }
}

//=============================================================================
// Default Values
//=============================================================================

defaultproperties
{
     bDisplayScoreInHUD=True
     ScoreFontSize=-2
     RedScorePosX=0.100000
     RedScorePosY=0.100000
     BlueScorePosX=0.100000
     BlueScorePosY=0.100000
     SpectatorScorePosX=0.100000
     SpectatorScorePosY=0.100000
     bNoDelete=True
     RemoteRole=ROLE_SimulatedProxy
     NetUpdateFrequency=5.000000
     NetPriority=2.000000
     Texture=Texture'Engine.S_Inventory'
}
