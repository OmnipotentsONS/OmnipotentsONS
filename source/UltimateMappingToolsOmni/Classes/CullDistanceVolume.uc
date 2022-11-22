//-----------------------------------------------------------------------------
// CullDistanceVolume
// $ckr1: Copyright 2011  by D. 'Crusha K. Rool' I.$
// $ckr2: <Mapping.Crocodile@googlemail.com>$
// $ckr3: Release date: 15.08.2011 00:38:44 in Package: UltimateMappingTools$
//
// This catches up the idea of the CullDistanceVolume from UT3: At the beginning
// of the match, all StaticMeshes are checked if their BoundingSphere's diameter
// is smaller than the values in this array. Then they automatically get the
// CullDistance set from these properties that match their size, thus allow to
// quickly set up performance enhancements for the whole map.
// If Volumes overlap, the more radical CullDistance will be used on a mesh.
//
// The calculations of this are all executed on the client as soon as he enters
// the match, so the server won't take any performance impact by this but clients
// have a slightly longer loading time (increases linear with the number of
// StaticMeshes in the Volume).
//-----------------------------------------------------------------------------
class CullDistanceVolume extends Volume;

struct _CullSettings
{
    var() float Size; // Meshes with a smaller BoundingSphere diameter than this will get the CullDistance set.
    var() float CullDistance; // The mesh will stop being rendered if it's further away than this.
};

var() array<_CullSettings> CullDistances; // The settings.

var() bool bEnabled; // For testing differences between an enabled and disabled Volume.
var() bool bLogMeshSizes; // Writes the sizes of each StaticMesh in the map to the log. For testing only!
var() bool bAllowExcludeTags; // If True, StaticMeshes whose ExcludeTag matches this Volume's Tag
                              // will not receive new CullDistance settings.
                              // Turn this off if you don't use ExcludeTags to have faster calculations at mapload.


simulated event PostBeginPlay()
{
    local StaticMeshActor SMA;
    local float CurDiameter;
    local int i;
    local bool bExclude;


    if (Level.NetMode != NM_DedicatedServer)
    {
        if (!bEnabled || CullDistances.Length == 0)
        {
            return;
        }

        // Quicksort. We need to have the diameters sorted.
        Quicksort(0, CullDistances.Length -1);


        foreach TouchingActors(class'StaticMeshActor', SMA)
        {
            // Exclusion
            if (bAllowExcludeTags && Tag != '')
            {
                bExclude = False;

                for (i = 0; i < 8; i++)
                {
                    if (SMA.ExcludeTag[i] == Tag)
                    {

                        bExclude = True;
                    }
                }

                if (bExclude)
                {
                    continue;
                }
            }

            CurDiameter = SMA.GetRenderBoundingSphere().W * 2;

            if (bLogMeshSizes)
            {
                log(string(SMA.Name) @ "; Size:" @ CurDiameter);
            }

            for (i = 0; i < CullDistances.Length; i++)
            {
                if (CurDiameter < CullDistances[i].Size)
                {
                    if (SMA.CullDistance == 0 || SMA.CullDistance > CullDistances[i].CullDistance)
                        SMA.CullDistance = CullDistances[i].CullDistance;

                    break;
                }
            }
        }
    }
}


simulated function Quicksort(int low, int high)
{
    local int i, j;
    local float Pivot;

    i = low;
    j = high;

    // Get the pivot element from the middle of the list
    Pivot = CullDistances[low + (high-low)/2].Size;

    // Divide into two lists
    while (i <= j)
    {
        // If the current value from the left list is smaller then the pivot
        // element then get the next element from the left list
        while (CullDistances[i].Size < Pivot)
        {
            i++;
        }

        // If the current value from the right list is larger then the pivot
        // element then get the next element from the right list
        while (CullDistances[j].Size > Pivot)
        {
            j--;
        }

        // If we have found a values in the left list which is larger then
        // the pivot element and if we have found a value in the right list
        // which is smaller then the pivot element then we exchange the
        // values.
        // As we are done we can increase i and j
        if (i <= j)
        {
            Exchange(i, j);
            i++;
            j--;
        }
    }

    // Recursion
    if (low < j)
        Quicksort(low, j);
    if (i < high)
        Quicksort(i, high);
}

simulated function Exchange(int i, int j)
{
    local _CullSettings Temp;

    Temp = CullDistances[i];
    CullDistances[i] = CullDistances[j];
    CullDistances[j] = Temp;
}

defaultproperties
{
     bEnabled=True
}
