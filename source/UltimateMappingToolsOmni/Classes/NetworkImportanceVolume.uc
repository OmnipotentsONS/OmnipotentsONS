//-----------------------------------------------------------------------------
// NetworkImportanceVolume
// $ckr1: Copyright 2011  by D. 'Crusha K. Rool' I.$
// $ckr2: <Mapping.Crocodile@googlemail.com>$
// $ckr3: Release date: 15.08.2011 00:43:05 in Package: UltimateMappingTools$
//
// Forces all Actors inside to be always relevant to network clients. Keep this
// Volume of a reasonable size.
// This should be used with an OnlineCameraTextureClient because it makes everything
// in it relevant to the player, also if he can actually only see the place
// through the camera.
//-----------------------------------------------------------------------------
class NetworkImportanceVolume extends Volume;


var array<Actor> TemporaryRelevantActors;
// Remember all Actors that are not bAlwaysRelevant by default.

var() bool bMakeInitialActorsAlwaysRelevant;
// If True, everything that is already inside the volume at the beginning of the match is relevant as well.

var() name NetworkLinkedClientVolumeTag;
/* Link NetworkLinkedClientVolumes to this Volume to make it only active if there
 * are human players in those Volumes.
 * This allows to save bandwidth for everyone if there are no viewers in the area
 * from which the actors in this volume should be considered relevant.
 */

var() array< class<Actor> > RelevantClasses;
// Only these classes will be made relevant in order to save performance.
// Pawns are usually sufficient, unless you want to take care of KActors as well.




var  bool  bEnabled;
// True if there are LinkedClientVolumes with players inside or if no such

var int RelevantLinkedClientVolumes;
// Total number of all LinkedVolumes with PlayerControllers inside.
// Store it here for global access.

// ============================================================================
// PostBeginPlay
//
// If wished, this can add all initially touching actors to the array.
// ============================================================================

event PostBeginPlay()
{
    local Actor A;
    local NetworkLinkedClientVolume NLCV;
    local bool bFoundOne;


    if (bMakeInitialActorsAlwaysRelevant)
    {
        foreach TouchingActors(class'Actor', A)
        {
            if (CheckClassRelevance(A) && !A.bAlwaysRelevant && !A.bNoDelete)
            {
                TemporaryRelevantActors[TemporaryRelevantActors.Length] = A;
                A.bAlwaysRelevant = True;
            }
        }
    }

    if (NetworkLinkedClientVolumeTag != '')
    {
        foreach AllActors(class'NetworkLinkedClientVolume', NLCV, NetworkLinkedClientVolumeTag)
        {
            if (NLCV != None)
            {
                NLCV.ParentNIVolume = self;
                bFoundOne = True;
            }
        }
        if (!bFoundOne)
            Log(name $ " - no NetworkLinkedClientVolumes with matching Tag found", 'Warning');

        bEnabled = False;
    }
}


// ============================================================================
// Touch
//
// Whenever a new actor that is not always relevant enters the volume, it will
// become always relevant and be remembered.
// ============================================================================

event Touch(Actor Other)
{
    if (bEnabled && CheckClassRelevance(Other) && !Other.bAlwaysRelevant && !Other.bNoDelete)
    {
        TemporaryRelevantActors[TemporaryRelevantActors.Length] = Other;
        Other.bAlwaysRelevant = True;
    }
}


// ============================================================================
// UnTouch
//
// Whenever an actor that is always relevant leaves this volume, a check will be
// done to find out if the actor is always relevant by default or just inside
// this volume. In the latter, it will remove the actor from the array and set
// bAlwaysRelevant to False for it.
// ============================================================================

event UnTouch(Actor Other)
{
    local int i;

    if (CheckClassRelevance(Other) && Other.bAlwaysRelevant && !Other.bNoDelete)
    {
        for (i =0; i < TemporaryRelevantActors.Length; i++)
        {
            if (TemporaryRelevantActors[i] == Other)
            {
                Other.bAlwaysRelevant = False;
                TemporaryRelevantActors.Remove(i, 1);
            }
        }
    }
}


function bool CheckClassRelevance(Actor A)
{
    local int i;

    for (i = 0; i < RelevantClasses.Length; i++)
    {
        if ( ClassIsChildOf(A.Class, RelevantClasses[i]) )
            return True;
    }

    return False;
}


// ============================================================================
// UpdateVolume
//
// Enable or disable the Volume, depending on NetworkLinkedClientVolumes
// ============================================================================

singular function UpdateVolume()
{
    local Actor A;
    local int i;

    if (!bEnabled && RelevantLinkedClientVolumes > 0) // Enable Volume, make all actors always relevant.
    {
        bEnabled = True;
        foreach TouchingActors(class'Actor', A)
        {
            if (CheckClassRelevance(A) && !A.bAlwaysRelevant && !A.bNoDelete)
            {
                TemporaryRelevantActors[TemporaryRelevantActors.Length] = A;
                A.bAlwaysRelevant = True;
            }
        }
    }
    else if (bEnabled && RelevantLinkedClientVolumes <= 0) // Disable Volume, set all actors back to their original relevance.
    {
        bEnabled = False;
        foreach TouchingActors(class'Actor', A)
        {
            if (CheckClassRelevance(A) && A.bAlwaysRelevant && !A.bNoDelete)
            {
                for (i = 0; i < TemporaryRelevantActors.Length; i++)
                {
                    if (TemporaryRelevantActors[i] == A)
                    {
                        A.bAlwaysRelevant = False;
                        TemporaryRelevantActors.Remove(i, 1);
                        break;
                    }
                }
            }
        }
        TemporaryRelevantActors.Remove(0, TemporaryRelevantActors.Length); // Just to make sure.
    }

}

defaultproperties
{
}
