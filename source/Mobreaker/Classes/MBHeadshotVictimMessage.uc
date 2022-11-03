//=============================================================================
// MBHeadshotVictimMessage
// Copyright 2003-2010 by Wormbo <wormbo@online.de>
//
// Displays a headshot message for headshot victims.
//=============================================================================


class MBHeadshotVictimMessage extends SpecialKillMessage abstract;


//=============================================================================
// Localization
//=============================================================================

var localized string DecapitationByString;


//=============================================================================
// GetString
//
// Returns the string displayed for headshot victims.
//=============================================================================

static function string GetString(optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject)
{
	if (RelatedPRI_1 != None)
		return Repl(default.DecapitationByString, "%k", RelatedPRI_1.PlayerName, true);
	
	return Default.DecapitationString;
}


//=============================================================================
// Default properties
//=============================================================================

defaultproperties
{
     DecapitationByString="Head Shot by %k !!"
}
