//-----------------------------------------------------------------------------
// Logical NOT
// $ckr1: Copyright 2011  by D. 'Crusha K. Rool' I.$
// $ckr2: <Mapping.Crocodile@googlemail.com>$
// $ckr3: Release date: 15.08.2011 00:42:21 in Package: UltimateMappingTools$
//
// Toggles the boolean value of an incoming Event and forwards it.
// If the Event was an Untrigger-Event, then it will become a
// Trigger-Event and the other way around.
//-----------------------------------------------------------------------------
class LogicalNOT extends LogicGate
    placeable;

// ============================================================================
// Initialisation
// ============================================================================
event BeginPlay()
{
  // Perform various checks
  if (Tag == '')
      Log(name $ " - No Tag specified", 'Warning');
  if (event == '')
      Log(name $ " - No Event specified", 'Warning');
}

// ============================================================================

event Trigger(Actor Other, Pawn EventInstigator)
{
    UntriggerEvent(event, self, EventInstigator);
}

event UnTrigger(Actor Other, Pawn EventInstigator)
{
    TriggerEvent(event, self, EventInstigator);
}

// ============================================================================
// Default Values
// ============================================================================

defaultproperties
{
     Texture=Texture'UltimateMappingTools_Tex.Icons.NOT_Icon'
}
