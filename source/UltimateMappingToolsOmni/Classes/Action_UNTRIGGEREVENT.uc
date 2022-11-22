//=============================================================================
// Action_UnTriggerEvent
//
// $ckr1: Copyright 2011  by D. 'Crusha K. Rool' I.$
// $ckr2: <Mapping.Crocodile@googlemail.com>$
// $ckr3: Release date: 14.08.2011 00:13:15 in Package: UltimateMappingTools$
//
// Nothing special, it's strange that it wasn't included with the game already.
//=============================================================================
class Action_UNTRIGGEREVENT extends Action_TRIGGEREVENT;


function bool InitActionFor(ScriptedController C)
{
    // untrigger event associated with action
    C.UnTriggerEvent(Event,C.SequenceScript,C.GetInstigator());
    return false;
}

defaultproperties
{
     ActionString="untrigger event"
}
