/******************************************************************************
Allows the mapper to assign specific sky boxes to this zone. The skyboxes can be
chosen randomly at match begin, so it's possible to have skys in a map that
are completely different in various rounds.

Keep in mind that this is used instead of a ZoneInfo, not instead of a
SkyZoneInfo.

Copyright (c) 2009, Wormbo
Copyright (c) 2010, Crusha K. Rool, changed by permission
******************************************************************************/

class UltimateSkyZoneInfo extends ZoneInfo;




struct _SkyZoneInfos
{
    /*
     * The Tag name of the SkyZoneInfo to use. Every entry can link to multiple
     * SkyZones, but they should have different detail settings.
     */
    var() name SkyZoneTag;


    // You can change the Zone's DistanceFogColor with the chosen skybox.
    var() color DistanceFogColor;

    var() name SkyBoxEvent;
};


/* Each array entry should represent one kind of skybox from which one is chosen at match begin.
 * Don't leave an empty entry in this array, it would cause errors with this actor
 * and I am too lazy to code it in a way so that not even the dumbest boy out there
 * can break it. :) // Crusha
 */
var() array<_SkyZoneInfos> SkyZoneInfos;



/*
 * Each UltimateSkyZoneInfo that has this Tag set in their properties will use the
 * array index that was used in this actor, so it's possible to create a whole set
 * of actors that belong together when the index is chosen randomly.
 */
var() name LinkedUltimateSkyZoneInfoTag;



// Chosen on the server side, can be transferred to other UltimateSky_ZoneInfos.
var   int  ChosenArrayIndex;


// True if another UltimateSkyZoneInfo set the ArrayIndex for us.
var   bool bReceivedArrayIndex;


replication
{
    reliable if(bNetDirty && Role == ROLE_Authority)
        ChosenArrayIndex;
}



//=============================================================================
// Server should choose a random entry from the SkyZoneTags array and tell the
// clients about it. Then it should sync all other actors with the matching Tag.
//=============================================================================
event PreBeginPlay()
{
    local UltimateSkyZoneInfo OtherUSZI;

    if (SkyZoneInfos.length == 0) // Functionality of this actor is not used.
    {
        Super.LinkToSkybox();
        Super(Actor).PreBeginPlay();
        // We don't want this thing to call THIS version of the LinkToSkybox function.

        return;
    }
    else
    {
        if (!bReceivedArrayIndex && Role == ROLE_Authority)
        {
            ChosenArrayIndex = Rand(SkyZoneInfos.Length); // Choose an entry from the array randomly.
            TriggerEvent(SkyZoneInfos[ChosenArrayIndex].SkyBoxEvent, self, None);

            foreach AllActors(class'UltimateSkyZoneInfo', OtherUSZI, LinkedUltimateSkyZoneInfoTag)
            {
                if (!OtherUSZI.bReceivedArrayIndex)
                {
                    OtherUSZI.ChosenArrayIndex = ChosenArrayIndex;
                    OtherUSZI.bReceivedArrayIndex = True;
                }
            }
        }

        Super.PreBeginPlay();
    }
}





//=============================================================================
// Called from PreBeginPlay() to link a SkyZoneInfo actor as this zone's sky box.
// Finds a SkyZoneInfo with a matching Tag and best-fitting detail level.
//=============================================================================
simulated function LinkToSkybox()
{
    local SkyZoneInfo thisSkyZone;

    foreach AllActors(class'SkyZoneInfo', thisSkyZone)
    {
        if (BetterThanCurrentSkyZone(thisSkyZone))
            SkyZone = thisSkyZone;
    }

    // Set a matching fog color for the sky.
    DistanceFogColor = SkyZoneInfos[ChosenArrayIndex].DistanceFogColor;
}


//=============================================================================
// Rates a SkyZoneInfo against the currently linked sky zone.
// Zones are first rated by Tag match, then by their target detail level.
//=============================================================================
function bool BetterThanCurrentSkyZone(SkyZoneInfo OtherSkyZone)
{
    if (SkyZone == None)
        return true; // no current sky zone, everything is better than that

    // check matching Tag first
    if (SkyZone.Tag != SkyZoneInfos[ChosenArrayIndex].SkyZoneTag && OtherSkyZone.Tag == SkyZoneInfos[ChosenArrayIndex].SkyZoneTag)
        return true;
    if (SkyZone.Tag == SkyZoneInfos[ChosenArrayIndex].SkyZoneTag && OtherSkyZone.Tag != SkyZoneInfos[ChosenArrayIndex].SkyZoneTag)
        return false;

    // here either both match or both don't match, now check detail level

    // super high detail?
    if (SkyZone.bSuperHighDetail && !OtherSkyZone.bSuperHighDetail)
        return Level.DetailMode < DM_SuperHigh;
    if (OtherSkyZone.bSuperHighDetail)
        return Level.DetailMode == DM_SuperHigh;

    // high detail?
    if (SkyZone.bHighDetail && !OtherSkyZone.bHighDetail)
        return Level.DetailMode < DM_High;
    if (OtherSkyZone.bHighDetail)
        return Level.DetailMode == DM_High;

    // both have low detail, doesn't matter which one to use
    return true;
}

defaultproperties
{
}
