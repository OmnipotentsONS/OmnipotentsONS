//=============================================================================
// ACTION_TriggerVolume
//
// $ckr1: Copyright 2011  by D. 'Crusha K. Rool' I.$
// $ckr2: <Mapping.Crocodile@googlemail.com>$
// $ckr3: Release date: 14.08.2011 00:13:20 in Package: UltimateMappingTools$
//
// I just found it much more usable to have this in the ScriptedTrigger..
//=============================================================================
class ACTION_VolumeTrigger extends ScriptedAction;


var(Action) name Event;

function bool InitActionFor(ScriptedController C)
{
    local Volume V;

    // trigger volumes associated with action
    ForEach C.AllActors(class'Volume', V, Event)
    {
        V.Trigger(C.SequenceScript, C.GetInstigator());
    }

    return false;
}

function string GetActionString()
{
    return ActionString@Event;
}

defaultproperties
{
     ActionString="trigger volume"
}
