//-----------------------------------------------------------------------------
// DynamicSpawnableKarmaThing
//
// $ckr1: Copyright 2011  by D. 'Crusha K. Rool' I.$
// $ckr2: <Mapping.Crocodile@googlemail.com>$
// $ckr3: Release date: 14.08.2011 00:16:14 in Package: UltimateMappingTools$  (originally in KarmaOnline)
//
// A dynamic (and not so network efficient) version of the KarmaThing that can
// be spawned at runtime. It's used by the UltimateDestroyableEnvironment and
// not supposed to be placed in the map by hand.
//-----------------------------------------------------------------------------
class DynamicSpawnableKarmaThing extends KarmaThing
    notplaceable;

defaultproperties
{
     bNoDelete=False
}
