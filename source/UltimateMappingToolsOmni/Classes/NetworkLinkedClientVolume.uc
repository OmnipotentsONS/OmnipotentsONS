//-----------------------------------------------------------------------------
// NetworkLinkedClientVolume
// $ckr1: Copyright 2011  by D. 'Crusha K. Rool' I.$
// $ckr2: <Mapping.Crocodile@googlemail.com>$
// $ckr3: Release date: 15.08.2011 00:43:20 in Package: UltimateMappingTools$
//
// Can be associated by a NetworkImportanceVolume to make that Volume only
// active if actual players are inside this Volume.
//
// This should be used in the area from which a player can see an
// OnlineCameraTextureClient.
// Makes only sense if that area is not very frequently visited by human players.
//-----------------------------------------------------------------------------
class NetworkLinkedClientVolume extends Volume;

var() float UpdateTime; // How often this checks for PlayerControllers in it.

var NetworkImportanceVolume ParentNIVolume;
var bool bHasRelevantPlayers, bOldRelevantPlayers; // Remember if we had players at the last check.
var VolumeTimer MyTimer;

event SetInitialState()
{
    local PlayerController PC;

    if ( ParentNIVolume == None )
        return;

    if ( ParentNIVolume.bMakeInitialActorsAlwaysRelevant )
    {
        foreach TouchingActors(class'PlayerController', PC)
        {
            if ( PC != None )
            {
                ParentNIVolume.RelevantLinkedClientVolumes++;
                bHasRelevantPlayers = True;
                bOldRelevantPlayers = True;
                ParentNIVolume.UpdateVolume();
                break;
            }
        }
    }

    if (MyTimer == None)
    {
        MyTimer = Spawn(class'VolumeTimer', self);
        MyTimer.SetTimer(UpdateTime, True);
    }
}


// Call this regularly but not too often to save performance.
function TimerPop(VolumeTimer T)
{
    local PlayerController PC;

    bHasRelevantPlayers = False;
    foreach TouchingActors(class'PlayerController', PC)
    {
        if ( PC != None )
        {
            bHasRelevantPlayers = True;
            break;
        }
    }

    if (bHasRelevantPlayers)
    {
        if (!bOldRelevantPlayers)
        {
            ParentNIVolume.RelevantLinkedClientVolumes++;
            ParentNIVolume.UpdateVolume();
            bOldRelevantPlayers = True;
        }
    }
    else
    {
        if (bOldRelevantPlayers)
        {
            ParentNIVolume.RelevantLinkedClientVolumes--;
            ParentNIVolume.UpdateVolume();
            bOldRelevantPlayers = False;
        }
    }
}

defaultproperties
{
     UpdateTime=5.000000
}
