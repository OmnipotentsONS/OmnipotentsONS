//-----------------------------------------------------------------------------
// LogicGate (and all subclasses)
// $ckr1: Copyright 2011  by D. 'Crusha K. Rool' I.$
// $ckr2: <Mapping.Crocodile@googlemail.com>$
// $ckr3: Release date: 14.08.2011 00:19:06 in Package: UltimateMappingTools$
//
// Abstract class of all logical gates and modifiers for Events.
// The subclasses are able to perform specific logical operations.
// A 'condition', as the term is used in the subclasses, is the specified event.
// It is 'True' when it has been triggered and 'False' when it has been
// UnTriggered and by default.
//
// The outcoming Event is always the one that is specified in the default Event-field.
// The default Tag-field is always used so don't forget about it.
//-----------------------------------------------------------------------------
class LogicGate extends EventGate
    abstract
    notplaceable;

// ============================================================================

defaultproperties
{
}
