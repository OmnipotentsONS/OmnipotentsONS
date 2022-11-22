//-----------------------------------------------------------------------------
// EventGate (and all subclasses)
// $ckr1: Copyright 2011  by D. 'Crusha K. Rool' I.$
// $ckr2: <Mapping.Crocodile@googlemail.com>$
// $ckr3: Release date: 14.08.2011 00:16:32 in Package: UltimateMappingTools$
//
// Abstract base class of all Actors that modify Events.
//-----------------------------------------------------------------------------
class EventGate extends Triggers
    abstract
    notplaceable;

// ============================================================================

defaultproperties
{
     Texture=Texture'Engine.SubActionTrigger'
     bCollideActors=False
     bBlockZeroExtentTraces=False
     bBlockNonZeroExtentTraces=False
}
