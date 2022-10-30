//=============================================================================
// WVDamTypeDirectHit
// Copyright 2003-2010 by Wormbo <wormbo@online.de>
//
// Damage type for mercury missile hitting the head and blowing up.
//=============================================================================


class PVWDamTypeMercuryHeadHit extends PVWDamTypeMercuryDirectHit abstract;


//=============================================================================
// IncrementKills
//
// Play a headshot announcement and count the number of headshots
//=============================================================================

static function IncrementKills(Controller Killer)
{
	class'DamTypeSniperHeadshot'.static.IncrementKills(Killer);
}


//=============================================================================
// Default properties
//=============================================================================

defaultproperties
{
     DeathString="%k drove a Wraith mercury missile into %o's big ol' melon."
     FemaleSuicide="%o somehow managed to take off her head with her own mercury missile."
     MaleSuicide="%o somehow managed to take off his head with his own mercury missile."
     bAlwaysSevers=True
     bSpecial=True
}
