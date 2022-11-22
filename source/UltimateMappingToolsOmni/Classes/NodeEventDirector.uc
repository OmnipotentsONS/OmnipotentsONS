//-----------------------------------------------------------------------------
// NodeEventDirector
// $ckr1: Copyright 2011  by D. 'Crusha K. Rool' I.$
// $ckr2: <Mapping.Crocodile@googlemail.com>$
// $ckr3: Release date: 14.08.2011 00:19:50 in Package: UltimateMappingTools$
//
// This actor receives the three Events of an ONSPowerNode and
// interprets the current state of the node from these informations.
// The actor can then fire Trigger- or Untrigger-Events when
// the state of the Node changes.
//-----------------------------------------------------------------------------
class NodeEventDirector extends EventGate
    placeable;

/*  IMPORTANT:
 *  The default Tag-field of this actor will be set to the PowerNode's
 *  Destroyed-Event, there is no use in setting something there by yourself.
 *  The default Event-field determines the Event to (un)trigger.
 *
 *  You still have to enter 3 different Event-names in the PowerNode's properties:
 *  The fields to fill in are the RedActivation-, BlueActivation- and Destroyed-field.
 *  A name entered in those fields MUST BE A UNIQUE EVENT-NAME in the map,
 *  or there will be problems with this actor.
 */

var()  edfindable  ONSPowerCore  ObservationTarget ; // Click on the PowerNode you want to observe


// Which team shall build the node so that the condition is true?
// Use two of this Actor on the same node to watch both teams.
var()   byte   ObserveTeamNum ;  // 0 = Red; 1 = Blue; 255 = None

var     bool   bRedHasBuild ;
var     bool   bBlueHasBuild ;



// The following fields are filled in automatically, using the specified Target.
var   name   PowerNodeRedBuildTag ;
var   name   PowerNodeBlueBuildTag ;


// ============================================================================
// Initialisation
// ============================================================================
function PostBeginPlay()
{
  local UltimateProbeEvent ProbeEvent;

  Tag = ObservationTarget.DestroyedEventName;
  PowerNodeRedBuildTag = ObservationTarget.RedActivationEventName;
  PowerNodeBlueBuildTag = ObservationTarget.BlueActivationEventName;

  // Perform various checks
  if (Tag == '')
      Log(name $ " - Target has no Destroyed-Event specified", 'Warning');
  if (PowerNodeRedBuildTag == '')
      Log(name $ " - Target has no RedTeamActivated-Event specified", 'Warning');
  if (PowerNodeBlueBuildTag == '')
      Log(name $ " - Target has no BlueTeamActivated-Event specified", 'Warning');
  else if ((PowerNodeBlueBuildTag == PowerNodeRedBuildTag) || (PowerNodeBlueBuildTag == Tag))
      Log(name $ " - Target has two identical Events set", 'Warning');
  if ((Tag != '') && (Tag == PowerNodeRedBuildTag))
      Log(name $ " - Target has two identical Events set", 'Warning');
  if (Event == '')
      Log(name $ " - No Event specified", 'Warning');

  // Create the ProbeEvents to observe the individual Tags
  if (PowerNodeRedBuildTag != '')
  {
      ProbeEvent = Spawn(class'UltimateProbeEvent', Self, PowerNodeRedBuildTag);
      ProbeEvent.OnTrigger   = NodeRedBuildTrigger;
  }

  if (PowerNodeBlueBuildTag != '')
  {
      ProbeEvent = Spawn(class'UltimateProbeEvent', Self, PowerNodeBlueBuildTag);
      ProbeEvent.OnTrigger   = NodeBlueBuildTrigger;
  }

  Super.PostBeginPlay();
}


// Take the last Initialisation-Function, just to be sure.
function SetInitialState()
{
    UpdateGate(None); // Update to notice False-values too
}

// ============================================================================
// Triggerfunctions
// ============================================================================
function Trigger(Actor Other, Pawn EventInstigator)
{
    bRedHasBuild = false;
    bBlueHasBuild = false;
    UpdateGate(EventInstigator);
}

function NodeRedBuildTrigger(Actor Other, Pawn EventInstigator)
{
    bRedHasBuild = true;
    UpdateGate(EventInstigator);
}

function NodeBlueBuildTrigger(Actor Other, Pawn EventInstigator)
{
    bBlueHasBuild = true;
    UpdateGate(EventInstigator);
}


function UpdateGate(Pawn EventInstigator)
{
    if ((ObserveTeamNum == 0 && bRedHasBuild) || (ObserveTeamNum == 1 && bBlueHasBuild) ||
        (ObserveTeamNum == 255 && (!bBlueHasBuild && !bRedHasBuild)))
        TriggerEvent(event, self, EventInstigator);
    else
        UnTriggerEvent(event, self, EventInstigator);
}


// ============================================================================
// Reset on new round
// ============================================================================
function Reset()
{
    Super.Reset();

    if (ONSOnslaughtGame(Level.Game) != None &&
        ONSOnslaughtGame(Level.Game).bSwapSidesAfterReset && ObserveTeamNum != 255)
        ObserveTeamNum = abs(ObserveTeamNum-1);
}

// ============================================================================
// Default Values
// ============================================================================

defaultproperties
{
}
