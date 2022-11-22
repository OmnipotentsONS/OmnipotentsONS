//-----------------------------------------------------------------------------
// EnhancedLevelGameRules
// $ckr1: Copyright 2011  by D. 'Crusha K. Rool' I.$
// $ckr2: <Mapping.Crocodile@googlemail.com>$
// $ckr3: Release date: 14.08.2011 00:16:14 in Package: UltimateMappingTools$
// Original code idea by Wormbo
//
// Additionally to the functionality of the normal LevelGameRules, this one can
// also forbid certain Mutators in the map, even if the server has chosen them.
//-----------------------------------------------------------------------------
class EnhancedLevelGameRules extends LevelGameRules
    placeable;

// The Mutators in this array are not allowed in this particular map.
var() array<name> NotAllowedMutator ;



// ============================================================================
function UpdateGame(GameInfo G)
{
    local Mutator M, Next;
    local int i;

    Super.UpdateGame(G);

    // Search for the mutator we want to remove
    for (M = G.BaseMutator; M != None; M = Next)
    {
        Next = M.NextMutator; // Remember M's successor before M gets destroyed
        for (i = 0; i < NotAllowedMutator.length; i++)
        {
            if (!(M.GroupName ~= "Security") && M.IsA(NotAllowedMutator[i]))
            {
                Log("EnhancedLevelGameRules actor disables Mutator"@ M @"for this map");
                M.Destroy(); // There we go!
                if (M != None)
                    Log("Couldn't disable"@ M);
                break;
            }
        }
    }
}

// ============================================================================

defaultproperties
{
}
