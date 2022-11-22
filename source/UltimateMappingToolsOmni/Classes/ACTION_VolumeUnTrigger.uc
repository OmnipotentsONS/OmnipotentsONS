//=============================================================================
// ACTION_VolumeUnTrigger
//
// $ckr1: Copyright 2011  by D. 'Crusha K. Rool' I.$
// $ckr2: <Mapping.Crocodile@googlemail.com>$
// $ckr3: Release date: 14.08.2011 00:13:24 in Package: UltimateMappingTools$
//
// Same functionality as VolumeTrigger, but untriggers a Volume.
// Only the BlockingVolumeToggleable supports untriggering for now!
//=============================================================================
class ACTION_VolumeUnTrigger extends ACTION_VolumeTrigger;


function bool InitActionFor(ScriptedController C)
{
    local Volume V;

    // trigger volumes associated with action
    ForEach C.AllActors(class'Volume', V, Event)
    {
        V.UnTrigger(C.SequenceScript, C.GetInstigator());
    }

    return false;
}

defaultproperties
{
     ActionString="untrigger volume"
}
