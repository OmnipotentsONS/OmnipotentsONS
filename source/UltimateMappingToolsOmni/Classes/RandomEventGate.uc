//-----------------------------------------------------------------------------
// RandomEventGate
// $ckr1: Copyright 2011  by D. 'Crusha K. Rool' I.$
// $ckr2: <Mapping.Crocodile@googlemail.com>$
// $ckr3: Release date: 15.08.2011 00:44:23 in Package: UltimateMappingTools$
//
// Triggers the next Event with a probability that can be defined by the mapper.
// You can also set an alternative Event that is used instead, if the other one
// is not chosen.
//-----------------------------------------------------------------------------
class RandomEventGate extends EventGate
    placeable;

var() float TriggerProbability ;
// Enter the probability in percent with that the normal Event shall be triggered.

var() float UnTriggerProbability ;
// Enter the probability in percent with that the normal Event shall be untriggered.

var(Events) name AlternativeEvent ;
// If this is set, then it will be (un)triggered if the normal Event fails.


// ============================================================================
// Initialisation
// ============================================================================
event BeginPlay()
{
  if (Event == '')
      Log(name $ " - No Event specified", 'Warning');

  if ((TriggerProbability >= 100 && UnTriggerProbability >= 100) || (TriggerProbability <= 0 && UnTriggerProbability <= 0))
      Log(name $ " - Probability values makes this actor obsolete, are you sure?", 'Warning');
}


// ============================================================================
event Trigger(Actor Other, Pawn EventInstigator)
{
    if (FRand()*100 <= TriggerProbability)
        TriggerEvent(Event, self, EventInstigator);
    else if (AlternativeEvent != '')
        TriggerEvent(AlternativeEvent, self, EventInstigator);
}

event Untrigger(Actor Other, Pawn EventInstigator)
{
    if (FRand()*100 <= UnTriggerProbability)
        UnTriggerEvent(Event, self, EventInstigator);
    else if (AlternativeEvent != '')
        UnTriggerEvent(AlternativeEvent, self, EventInstigator);
}

// ============================================================================
// Default Values
// ============================================================================

defaultproperties
{
}
