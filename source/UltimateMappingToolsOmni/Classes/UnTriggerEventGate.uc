//-----------------------------------------------------------------------------
// UnTriggerEventGate
// $ckr1: Copyright 2011  by D. 'Crusha K. Rool' I.$
// $ckr2: <Mapping.Crocodile@googlemail.com>$
// $ckr3: Release date: 15.08.2011 00:47:50 in Package: UltimateMappingTools$
//
// This actor turns the incoming UnTriggerEvents into TriggerEvents.
// Do not confuse this with the logical NOT, which will do the work in
// both directions all the time.
// This one is thought for the case that the destionation of the chain of Events
// understands only multiple TriggerEvents, but no UnTriggerEvents.
// You can decide whether the other uncasted Event-type should pass or be stopped.
//-----------------------------------------------------------------------------
class UnTriggerEventGate extends EventGate
    placeable;

/* Public */

var()  bool  bTriggerToUntrigger ;
// This gate works in the other direction.

var()  bool  bStopNonCast ;
// Will not let the (Un)Trigger-event that is not casted pass. It will simply stop here.

var()  bool  bConvertEverySecondEvent ;
/* I.e. if only UnTriggerEvents come in, this will do the following:
 * UnTriggerEvent - TriggerEvent - UnTriggerEvent - TriggerEvent - ...
 *
 * If bTriggerToUntrigger is True and TriggerEvents come in, this will do:
 * TriggerEvent - UnTriggerEvent - TriggerEvent - ...
 */



/* Intern */
var bool bIsSecondTriggerEvent ;
var bool bIsSecondUnTriggerEvent ;

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

  super.BeginPlay();
}

// ============================================================================

    event Trigger(Actor Other, Pawn EventInstigator)
    {
        if (bTriggerToUntrigger)
        {
            if (!bConvertEverySecondEvent || (bConvertEverySecondEvent && bIsSecondTriggerEvent))
            {
                UnTriggerEvent(Event, self, EventInstigator);
                bIsSecondTriggerEvent = False;
            }
            else
            {
                TriggerEvent(Event, self, EventInstigator);
                bIsSecondTriggerEvent = True;
            }
        }
        else
        {
            if (!bStopNonCast)
                TriggerEvent(Event, self, EventInstigator);
        }
    }

    event UnTrigger(Actor Other, Pawn EventInstigator)
    {
        if (bTriggerToUntrigger)
        {
            if (!bStopNonCast)
                UnTriggerEvent(Event, self, EventInstigator);
        }
        else
        {
            if (!bConvertEverySecondEvent || (bConvertEverySecondEvent && bIsSecondUnTriggerEvent))
            {
                TriggerEvent(Event, self, EventInstigator);
                bIsSecondTriggerEvent = False;
            }
            else
            {
                UnTriggerEvent(Event, self, EventInstigator);
                bIsSecondTriggerEvent = True;
            }
        }
    }

/*  Coder note: bTriggerToUntrigger can't be StateCode because the functionality
 *  needs to be given from the very beginning because other EventLogicGates can
 *  start a chain of events before the InitialState is set.
 */

// ============================================================================
// Default Values
// ============================================================================

defaultproperties
{
}
