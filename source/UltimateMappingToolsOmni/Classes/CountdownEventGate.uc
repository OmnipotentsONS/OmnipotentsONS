//-----------------------------------------------------------------------------
// CountdownEventGate
// $ckr1: Copyright 2011  by D. 'Crusha K. Rool' I.$
// $ckr2: <Mapping.Crocodile@googlemail.com>$
// $ckr3: Release date: 13.10.2011 16:17:35 in Package: UltimateMappingTools$
//
// Waits a certain time before triggering the next Event.
// The condition mustn't be untriggered in that time, or the countdown stops.
// There is a ToleranceTime in which the event can be triggered again to
// continue the current countdown.
//-----------------------------------------------------------------------------
class CountdownEventGate extends EventGate
    placeable;

//-----------------------------------------------------------------------------
// Countdown variables and Events
//-----------------------------------------------------------------------------
var(Events) name CountdownStoppedEvent ;
/*  This will be triggered when the condition gets untriggered.
 *  You can use it to do something when the ToleranceTime starts.
 */

var(Events) name ToleranceStoppedEvent ;
/*  This will be triggered when the condition gets triggered while
 *  the gate is in ToleranceTime.
 */

var()   float  CountdownTime ;
/*  Wait for the CountdownTime before triggering the Event.
 *  The Event will not get triggered if a part of the condition
 *  becomes False during the countdown. 0 disables this, but makes no sense.
 */

var()   float  ToleranceTime ;
/*  If the whole condition gets False after being true, then you have this much
 *  time to get it True again to keep your CountdownTime progress. Otherwise you
 *  start over again. 0 disables this.
 */
var()   bool   bLoopCountdown ; // Triggers the Event all CountdownTime seconds until this gets untriggered.

var()   bool   bNoUntrigger ; // This will only trigger, but never untrigger.



//-----------------------------------------------------------------------------
// CountdownHUD variables
//-----------------------------------------------------------------------------
var()   bool   bBroadcastCountdown ;
//  Display messages about the remaining second on the countdown in the HUD.

var()   bool   bSubtileCounting ;
// If True, the timer will only appear in certain intervals. Otherwise it's always visible when the countdown is active.


var() float CountdownPosX ; // The relative location of the countdown in the HUD.
var() float CountdownPosY ; // Only the countdown - not the messages.

var() localized string CountdownString ; // Displayed with the countdown. %c will be replaced with a numerical representation of the countdown.

var() int ScoreFontSize;
// This int size controls how big the font is at different resolutions. -2 is normally quite good.


//-----------------------------------------------------------------------------
// Message system variables
//-----------------------------------------------------------------------------
// The following messages are displayed by default. Leave the strings blank to display nothing.

struct   TeamMessage
{
  var() localized String  MsgCountdownStart ;   // Message to display when the Countdown starts.
  var() localized String  MsgCountdownSuccess ; // Message to display when the Countdown runs out.
  var() localized String  MsgCountdownAbort ;   // Message to display when the Countdown is aborted in time.
  var() localized String  MsgToleranceSuccess ; // Message to display when the ToleranceTime runs out.
  var() localized String  MsgToleranceAbort ;   // Message to display when this is retriggered in the ToleranceTime.
};
var() TeamMessage BlueTeamMessages ;
var() TeamMessage RedTeamMessages ;

var()   bool   bSwitchMessageTeamsAfterReset ; // Use all RedTeamMessages on the blue team in swapped rounds and the other way around.
var     byte   RedTeam ;  // For Reset()
var     byte   BlueTeam ; // For Reset()

var()   enum EMT_MessageType    // The place and font for all messages to use.
{
    EMT_Default,
    EMT_CriticalEvent,
    EMT_DeathMessage,
    EMT_Say,
    EMT_TeamSay,
} MessageType;
var     name   MSGType;





//-----------------------------------------------------------------------------
// Intern variables
//-----------------------------------------------------------------------------
var     bool   bWasTolerance ;  // Whether this actor was just in Tolerance, so write the ToleranceAbort-Msg.
var     bool   bMainCountdown ; // Do the main thing, not the tolerance.
var     Pawn   TempInstigator ; // Remember, because of a gap to the next TriggerEvent.
var     float  CountdownProgress ; // Saves the last CountdownTime for later re-use.
var     float  ToleranceProgress ;
var     int    CountdownProgressInt ; // Typecast it once to save performance.


//=============================================================================
// Initialisation
//=============================================================================
event BeginPlay()
{
    // Perform various checks
    if (Tag == '')
        Log(name $ " - No Tag specified", 'Warning');
    if (event == '')
        Log(name $ " - No event specified", 'Warning');
    if (CountdownTime == 0)
        Log(name $ " - CountdownTime is 0. Are you sure this is what you want?", 'Warning');

    super.BeginPlay();
}

event PostBeginPlay()
{
    CountdownProgress = CountdownTime;
    BlueTeam = 1;

    switch (MessageType)
    {
        case EMT_CriticalEvent  : MSGType = 'CriticalEvent';        break;
        case EMT_DeathMessage   : MSGType = 'xDeathMessage';        break;
        case EMT_Say            : MSGType = 'SayMessagePlus';       break;
        case EMT_TeamSay        : MSGType = 'TeamSayMessagePlus';   break;
        default                 : MSGType = 'StringMessagePlus';    break;
    }
}

event SetInitialState()
{
    if (Level.NetMode == NM_DedicatedServer)
        GotoState('ServerTick');
    else if (bBroadcastCountdown)
        GotoState('ClientTick');

}


state ServerTick
{

//=============================================================================
// Timercontrol
//=============================================================================
    event Trigger(Actor Other, Pawn EventInstigator)
    {
        if (!bMainCountdown) // Do not restart the Timer on triggering
        {
            if (bWasTolerance)
            {
                bWasTolerance = false;
                DisplayHUDMessage(RedTeamMessages.MsgToleranceAbort, RedTeam);
                DisplayHUDMessage(BlueTeamMessages.MsgToleranceAbort, BlueTeam);
                TriggerEvent(ToleranceStoppedEvent, self, TempInstigator);
            }
            TempInstigator = EventInstigator;
            bMainCountdown = True;

            DisplayHUDMessage(RedTeamMessages.MsgCountdownStart, RedTeam);
            DisplayHUDMessage(BlueTeamMessages.MsgCountdownStart, BlueTeam);

            Enable('Tick');
        }
    }

    event UnTrigger(Actor Other, Pawn EventInstigator)
    {
        if (bMainCountdown)
        {
            TempInstigator = EventInstigator;
            bMainCountdown = false;
            bWasTolerance = True;

            DisplayHUDMessage(RedTeamMessages.MsgCountdownAbort, RedTeam);
            DisplayHUDMessage(BlueTeamMessages.MsgCountdownAbort, BlueTeam);

            if (CountdownStoppedEvent != '')
                TriggerEvent(CountdownStoppedEvent, self, TempInstigator);
            ToleranceProgress = ToleranceTime;
            Enable('Tick');
        }
    }

    event Tick(float DeltaTime)
    {
        if (bMainCountdown) // CountdownTimer
        {
            CountdownProgress -= DeltaTime;
            if (CountdownProgress <= 0)
            {
                if (!bLoopCountdown)  // Continue the Tick?
                    Disable('Tick');

                DisplayHUDMessage(RedTeamMessages.MsgCountdownSuccess, RedTeam);
                DisplayHUDMessage(BlueTeamMessages.MsgCountdownSuccess, BlueTeam);

                CountdownProgress = CountdownTime;
                TriggerEvent( Event, self, TempInstigator );
            }
            else if (bBroadcastCountdown)
            {

            }
        }
        else // ToleranceTimer
        {
            ToleranceProgress -= DeltaTime;
            if (ToleranceProgress <= 0)
            {
                Disable('Tick');
                bWasTolerance = false;
                CountdownProgress = CountdownTime;

                DisplayHUDMessage(RedTeamMessages.MsgToleranceSuccess, RedTeam);
                DisplayHUDMessage(BlueTeamMessages.MsgToleranceSuccess, BlueTeam);

                if (!bNoUntrigger)
                    UntriggerEvent(event, self, TempInstigator);
            }
        }
    }
}


state ClientTick
{
    simulated event Tick(float DeltaTime)
    {
        local PlayerController  PC;
        local CountdownHUDOverlay Overlay;
        PC = Level.GetLocalPlayerController();

        if (PC != None)
        {
            Overlay = Spawn(class'CountdownHUDOverlay');
            if (Overlay != None)
            {
                PC.myHUD.AddHudOverlay(Overlay);
                Overlay.PCOwner = PC;
            }
            Disable('Tick');
        }
    }
}

function DisplayHUDMessage(String Message, byte TeamNum)
{
    local Controller        C;
    local PlayerController  P;

    for (C=Level.ControllerList; C!=None; C=C.NextController)
    {
        P = PlayerController(C);
        if (P != None)
        {
            switch (P.GetTeamNum())
            {
                 case 0:
                     if ((TeamNum == 0) || (TeamNum == 255))
                         P.TeamMessage(C.PlayerReplicationInfo, Message, MSGType);
                     break;
                 case 1:
                     if ((TeamNum == 1) || (TeamNum == 255))
                         P.TeamMessage(C.PlayerReplicationInfo, Message, MSGType);
                     break;
                 default:
                     P.TeamMessage(C.PlayerReplicationInfo, Message, MSGType);
                     break;
            }
        }
    }
}

//=============================================================================
// Reset on new round
//=============================================================================
function Reset()
{
    super.Reset();

    CountdownProgress = CountdownTime;
    bMainCountdown = false;

    if (bSwitchMessageTeamsAfterReset && ONSOnslaughtGame(Level.Game) != None &&
     ONSOnslaughtGame(Level.Game).bSwapSidesAfterReset)
    {
        RedTeam = abs(RedTeam-1);
        BlueTeam = abs(BlueTeam-1);
    }

}

//=============================================================================
// Default Values
//=============================================================================

defaultproperties
{
     CountdownTime=60.000000
     bBroadcastCountdown=True
     ScoreFontSize=-2
     bSwitchMessageTeamsAfterReset=True
     messagetype=EMT_CriticalEvent
     RemoteRole=ROLE_SimulatedProxy
     NetUpdateFrequency=2.000000
}
