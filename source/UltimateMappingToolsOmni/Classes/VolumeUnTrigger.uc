//=============================================================================
// VolumeUnTrigger
//
// $ckr1: Copyright 2011  by D. 'Crusha K. Rool' I.$
// $ckr2: <Mapping.Crocodile@googlemail.com>$
// $ckr3: Release date: 14.08.2011 00:26:30 in Package: UltimateMappingTools$
//
// Same functionality as VolumeTrigger, but can ADDITIONALLY untrigger
// a Volume when this gets untriggered.
// Only the BlockingVolumeToggleable and the HealVolume supports untriggering for now!
//=============================================================================
class VolumeUnTrigger extends VolumeTrigger;

event UnTrigger( Actor Other, Pawn EventInstigator )
{
    local Volume V;

    if ( Role < Role_Authority )
        return;

    ForEach AllActors(class'Volume', V, Event)
        V.UnTrigger(Other, EventInstigator);
}

defaultproperties
{
}
