//-----------------------------------------------------------------------------
// Logical XOR
// $ckr1: Copyright 2011  by D. 'Crusha K. Rool' I.$
// $ckr2: <Mapping.Crocodile@googlemail.com>$
// $ckr3: Release date: 15.08.2011 00:42:40 in Package: UltimateMappingTools$
//
// Triggers an Event if EXACTLY ONE OF TWO conditions is True.
// Untriggers it, if an Event had been triggered and both
// conditions became False or True.
//-----------------------------------------------------------------------------
class LogicalXOR extends LogicGate
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

  super.BeginPlay();
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
    if ((bFirstIsTrue && !bSecondIsTrue) || (bFirstIsTrue && bSecondIsTrue))
    {
        TriggerEvent(event, self, EventInstigator);
        bWasAllTrue = true;
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
     Texture=Texture'UltimateMappingTools_Tex.Icons.XOR_Icon'
}
