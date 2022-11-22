//-----------------------------------------------------------------------------
// LevelLoadedTrigger
// $ckr1: Copyright 2011  by D. 'Crusha K. Rool' I.$
// $ckr2: <Mapping.Crocodile@googlemail.com>$
// $ckr3: Release date: 15.08.2011 00:41:15 in Package: UltimateMappingTools$
//
// Causes Events at the beginning of the match or on Reset.
//-----------------------------------------------------------------------------
class LevelLoadedTrigger extends Triggers;

var() name ResetEvent;

event SetInitialState()
{
    super.SetInitialState();

    TriggerEvent(Event, self, None);
}

function Reset()
{
    TriggerEvent(ResetEvent, self, None);
}

defaultproperties
{
     bCollideActors=False
}
