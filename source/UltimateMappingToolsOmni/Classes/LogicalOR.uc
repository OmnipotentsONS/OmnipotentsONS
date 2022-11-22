//-----------------------------------------------------------------------------
// Logical OR
// $ckr1: Copyright 2011  by D. 'Crusha K. Rool' I.$
// $ckr2: <Mapping.Crocodile@googlemail.com>$
// $ckr3: Release date: 15.08.2011 00:42:31 in Package: UltimateMappingTools$
//
// Triggers an Event if AT LEAST ONE condition is True.
// Untriggers it, if an Event had been triggered and both
// conditions became False again.
//-----------------------------------------------------------------------------
class LogicalOR extends LogicGate
    placeable;

var(Events)   name   SecondTag ;

var           bool   bWasAllTrue ; // Remember that you triggered already,
                                   // so there is no untriggering without having triggered.
var           bool   bFirstIsTrue ;
var           bool   bSecondIsTrue ;

// ============================================================================
// Initialisation
// ============================================================================
event BeginPlay()
{
  local UltimateProbeEvent ProbeEvent;

  // Perform various checks
  if (Tag == '')
      Log(name $ " - No Tag specified", 'Warning');
  if (SecondTag == '')
      Log(name $ " - No SecondTag specified", 'Warning');
  else if (SecondTag == Tag)
      Log(name $ " - Two identical Tags set", 'Warning');
  if (Event == '')
      Log(name $ " - No Event specified", 'Warning');

  // Create the ProbeEvent to observe the SecondTag
  if (SecondTag != '')
  {
      ProbeEvent = Spawn(class'UltimateProbeEvent', Self, SecondTag);
      ProbeEvent.OnTrigger   = SecondaryTrigger;
      ProbeEvent.OnUntrigger = SecondaryUntrigger;
  }
}

// ============================================================================

event Trigger(Actor Other, Pawn EventInstigator)
{
    bFirstIsTrue = true;
    UpdateGate(EventInstigator);
}

event Untrigger(Actor Other, Pawn EventInstigator)
{
    bFirstIsTrue = false;
    UpdateGate(EventInstigator);
}

function SecondaryTrigger(Actor Other, Pawn EventInstigator)
{
    bSecondIsTrue = true;
    UpdateGate(EventInstigator);
}

function SecondaryUntrigger(Actor Other, Pawn EventInstigator)
{
    bSecondIsTrue = false;
    UpdateGate(EventInstigator);
}

function UpdateGate(Pawn EventInstigator)
{
    if ((bFirstIsTrue || bSecondIsTrue) && !bWasAllTrue)
    {
        TriggerEvent(event, self, EventInstigator);
        bWasAllTrue = true; // Trigger only once in a row, not if only the number
                            // of conditions that are true changes
    }
    else if (bWasAllTrue)
    {
        UnTriggerEvent(event, self, EventInstigator);
        bWasAllTrue = false;
    }
}

// ============================================================================
// Reset on new round
// ============================================================================
function Reset()
{
    bFirstIsTrue = default.bFirstIsTrue;
    bSecondIsTrue = default.bSecondIsTrue;
    bWasAllTrue = default.bWasAllTrue;
}

// ============================================================================
// Default Values
// ============================================================================

defaultproperties
{
     Texture=Texture'UltimateMappingTools_Tex.Icons.OR_Icon'
}
